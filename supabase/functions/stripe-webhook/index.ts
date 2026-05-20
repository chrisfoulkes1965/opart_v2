import { serve } from 'https://deno.land/std@0.224.0/http/server.ts';
import { jsonResponse, requireEnv } from '../_shared/http.ts';
import { createServiceClient } from '../_shared/supabase.ts';
import { printfulFetch } from '../_shared/printful.ts';

async function verifyStripeSignature(
  payload: string,
  signatureHeader: string,
  secret: string,
): Promise<boolean> {
  const parts = signatureHeader.split(',').reduce<Record<string, string>>(
    (acc, part) => {
      const [key, value] = part.split('=');
      acc[key] = value;
      return acc;
    },
    {},
  );

  const timestamp = parts.t;
  const signature = parts.v1;
  if (!timestamp || !signature) {
    return false;
  }

  const encoder = new TextEncoder();
  const key = await crypto.subtle.importKey(
    'raw',
    encoder.encode(secret),
    { name: 'HMAC', hash: 'SHA-256' },
    false,
    ['sign'],
  );

  const signed = await crypto.subtle.sign(
    'HMAC',
    key,
    encoder.encode(`${timestamp}.${payload}`),
  );

  const expected = Array.from(new Uint8Array(signed))
    .map((b) => b.toString(16).padStart(2, '0'))
    .join('');

  return expected === signature;
}

serve(async (req) => {
  if (req.method !== 'POST') {
    return jsonResponse({ error: 'Method not allowed' }, 405);
  }

  let orderIdFromEvent: string | undefined;

  try {
    const payload = await req.text();
    const signature = req.headers.get('Stripe-Signature');
    const webhookSecret = requireEnv('STRIPE_WEBHOOK_SECRET');

    if (!signature) {
      return jsonResponse({ error: 'Missing Stripe signature' }, 400);
    }

    const valid = await verifyStripeSignature(payload, signature, webhookSecret);
    if (!valid) {
      return jsonResponse({ error: 'Invalid signature' }, 400);
    }

    const event = JSON.parse(payload);
    orderIdFromEvent = event.data?.object?.metadata?.order_id as
      | string
      | undefined;
    if (event.type !== 'checkout.session.completed') {
      return jsonResponse({ received: true });
    }

    const session = event.data.object;
    const orderId = session.metadata?.order_id as string | undefined;
    const variantId = Number(session.metadata?.variant_id);
    const designId = session.metadata?.design_id as string | undefined;

    if (!orderId || !designId || !variantId) {
      throw new Error('Missing order metadata on Stripe session');
    }

    const service = createServiceClient();

    const { data: order, error: orderError } = await service
      .from('print_orders')
      .select('*, print_designs(storage_path, printful_file_id)')
      .eq('id', orderId)
      .single();

    if (orderError || !order) {
      throw new Error('Order not found');
    }

    if (order.status === 'submitted' || order.status === 'fulfilled') {
      return jsonResponse({ received: true, duplicate: true });
    }

    await service
      .from('print_orders')
      .update({ status: 'paid', updated_at: new Date().toISOString() })
      .eq('id', orderId);

    const design = order.print_designs;
    const { data: signed, error: signError } = await service.storage
      .from('print-files')
      .createSignedUrl(design.storage_path, 60 * 60);

    if (signError || !signed?.signedUrl) {
      throw new Error(signError?.message ?? 'Could not sign print file');
    }

    const recipient = order.shipping_address;

    const printfulOrder = await printfulFetch<{
      code: number;
      result: { id: number; status: string };
    }>('/orders', {
      method: 'POST',
      body: JSON.stringify({
        external_id: orderId,
        recipient,
        items: [
          {
            variant_id: variantId,
            quantity: order.quantity,
            files: [{ url: signed.signedUrl }],
          },
        ],
      }),
    });

    await printfulFetch(`/orders/${printfulOrder.result.id}/confirm`, {
      method: 'POST',
    });

    await service
      .from('print_orders')
      .update({
        status: 'submitted',
        printful_order_id: printfulOrder.result.id,
        updated_at: new Date().toISOString(),
      })
      .eq('id', orderId);

    return jsonResponse({
      received: true,
      printful_order_id: printfulOrder.result.id,
    });
  } catch (error) {
    if (orderIdFromEvent) {
      const service = createServiceClient();
      await service
        .from('print_orders')
        .update({
          status: 'failed',
          error_message: error instanceof Error ? error.message : 'Unknown',
          updated_at: new Date().toISOString(),
        })
        .eq('id', orderIdFromEvent);
    }

    return jsonResponse(
      { error: error instanceof Error ? error.message : 'Unknown error' },
      500,
    );
  }
});

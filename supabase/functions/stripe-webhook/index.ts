import { serve } from 'https://deno.land/std@0.224.0/http/server.ts';
import { jsonResponse, requireEnv } from '../_shared/http.ts';
import { createServiceClient } from '../_shared/supabase.ts';
import { fulfillPrintOrder } from '../_shared/stripe_fulfillment.ts';

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

function extractOrderId(event: {
  type: string;
  data?: { object?: { metadata?: Record<string, string> } };
}): string | undefined {
  return event.data?.object?.metadata?.order_id;
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
    orderIdFromEvent = extractOrderId(event);

    if (
      event.type !== 'payment_intent.succeeded' &&
      event.type !== 'checkout.session.completed'
    ) {
      return jsonResponse({ received: true });
    }

    const orderId = orderIdFromEvent;
    if (!orderId) {
      throw new Error('Missing order metadata on Stripe event');
    }

    const paymentIntentId = event.type === 'payment_intent.succeeded'
      ? event.data?.object?.id as string | undefined
      : undefined;

    const printfulOrderId = await fulfillPrintOrder(orderId, paymentIntentId);

    return jsonResponse({
      received: true,
      printful_order_id: printfulOrderId,
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

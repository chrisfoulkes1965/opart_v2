import { createServiceClient } from './supabase.ts';
import { getDesignSignedUrl } from './designs.ts';
import { printfulFetch } from './printful.ts';
import {
  fetchPaymentIntentSnapshot,
  isCompleteRecipient,
  recipientFromPaymentIntent,
  type PrintfulRecipient,
} from './stripe_address.ts';
import { requireEnv } from './http.ts';

interface OrderLineRow {
  design_id: string;
  product_variant_id: number;
  quantity: number;
}

export async function fulfillPrintOrder(
  orderId: string,
  paymentIntentId?: string,
): Promise<number> {
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
    return order.printful_order_id as number;
  }

  let recipient = order.shipping_address as PrintfulRecipient | null;
  const stripePaymentIntentId = paymentIntentId ??
    (order.stripe_session_id as string | undefined);

  if (stripePaymentIntentId) {
    const stripeKey = requireEnv('STRIPE_SECRET_KEY');
    const paymentIntent = await fetchPaymentIntentSnapshot(
      stripePaymentIntentId,
      stripeKey,
    );
    recipient = recipientFromPaymentIntent(
      recipient ?? emptyRecipient(),
      paymentIntent,
    );
  }

  if (!isCompleteRecipient(recipient)) {
    throw new Error('Missing shipping details from payment');
  }

  await service
    .from('print_orders')
    .update({
      status: 'paid',
      shipping_address: recipient,
      customer_email: recipient!.email,
      updated_at: new Date().toISOString(),
    })
    .eq('id', orderId);

  const { data: lineRows, error: linesError } = await service
    .from('print_order_line_items')
    .select('design_id, product_variant_id, quantity')
    .eq('order_id', orderId);

  if (linesError) {
    throw new Error(linesError.message);
  }

  const lines = (lineRows ?? []) as OrderLineRow[];
  const printfulItems = await Promise.all(
    lines.length > 0
      ? lines.map(async (line) => {
        const fileUrl = await getDesignSignedUrl(service, line.design_id);
        return {
          variant_id: line.product_variant_id,
          quantity: line.quantity,
          files: [{ url: fileUrl }],
        };
      })
      : [legacySingleItem(order)],
  );

  const printfulOrder = await printfulFetch<{
    code: number;
    result: { id: number; status: string };
  }>('/orders', {
    method: 'POST',
    body: JSON.stringify({
      external_id: orderId,
      recipient,
      items: printfulItems,
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

  return printfulOrder.result.id;
}

async function legacySingleItem(
  order: Record<string, unknown>,
): Promise<{ variant_id: number; quantity: number; files: { url: string }[] }> {
  const service = createServiceClient();
  const design = order.print_designs as { storage_path: string };
  const designId = order.design_id as string;
  const variantId = order.product_variant_id as number;
  const quantity = (order.quantity as number) ?? 1;

  const fileUrl = designId
    ? await getDesignSignedUrl(service, designId)
    : await (async () => {
      const { data: signed, error: signError } = await service.storage
        .from('print-files')
        .createSignedUrl(design.storage_path, 60 * 60);
      if (signError || !signed?.signedUrl) {
        throw new Error(signError?.message ?? 'Could not sign print file');
      }
      return signed.signedUrl;
    })();

  return {
    variant_id: variantId,
    quantity,
    files: [{ url: fileUrl }],
  };
}

function emptyRecipient(): PrintfulRecipient {
  return {
    name: '',
    address1: '',
    address2: '',
    city: '',
    state_code: '',
    country_code: '',
    zip: '',
    email: '',
    phone: '',
  };
}

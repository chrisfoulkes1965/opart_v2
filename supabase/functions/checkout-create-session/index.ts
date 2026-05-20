import { serve } from 'https://deno.land/std@0.224.0/http/server.ts';
import {
  applyMarkup,
  handleOptions,
  jsonResponse,
  requireEnv,
} from '../_shared/http.ts';
import { createServiceClient, getUserId } from '../_shared/supabase.ts';
import { printfulFetch } from '../_shared/printful.ts';

interface CheckoutBody {
  design_id: string;
  variant_id: number;
  product_name: string;
  quantity?: number;
  recipient: {
    name: string;
    address1: string;
    address2?: string;
    city: string;
    state_code: string;
    country_code: string;
    zip: string;
    email: string;
    phone?: string;
  };
  success_url?: string;
  cancel_url?: string;
}

serve(async (req) => {
  const options = handleOptions(req);
  if (options) {
    return options;
  }

  if (req.method !== 'POST') {
    return jsonResponse({ error: 'Method not allowed' }, 405);
  }

  try {
    const authHeader = req.headers.get('Authorization');
    const userId = await getUserId(authHeader);

    const body = (await req.json()) as CheckoutBody;
    if (!body.design_id || !body.variant_id || !body.recipient?.email) {
      return jsonResponse(
        { error: 'design_id, variant_id, and recipient.email are required' },
        400,
      );
    }

    const service = createServiceClient();
    const { data: design, error: designError } = await service
      .from('print_designs')
      .select('id, storage_path, printful_file_id, user_id')
      .eq('id', body.design_id)
      .single();

    if (designError || !design) {
      return jsonResponse({ error: 'Design not found' }, 404);
    }

    if (userId && design.user_id && design.user_id !== userId) {
      return jsonResponse({ error: 'Forbidden' }, 403);
    }

    const { data: signed, error: signError } = await service.storage
      .from('print-files')
      .createSignedUrl(design.storage_path, 60 * 60);

    if (signError || !signed?.signedUrl) {
      throw new Error(signError?.message ?? 'Could not sign file URL');
    }

    const quantity = body.quantity ?? 1;

    const estimate = await printfulFetch<{
      code: number;
      result: { costs: { total: string; currency: string } };
    }>('/orders/estimate-costs', {
      method: 'POST',
      body: JSON.stringify({
        recipient: {
          name: body.recipient.name,
          address1: body.recipient.address1,
          address2: body.recipient.address2 ?? '',
          city: body.recipient.city,
          state_code: body.recipient.state_code,
          country_code: body.recipient.country_code,
          zip: body.recipient.zip,
          email: body.recipient.email,
          phone: body.recipient.phone ?? '',
        },
        items: [
          {
            variant_id: body.variant_id,
            quantity,
            files: [{ url: signed.signedUrl }],
          },
        ],
      }),
    });

    const printfulTotalCents = Math.round(
      parseFloat(estimate.result.costs.total) * 100,
    );
    const retailTotalCents = applyMarkup(printfulTotalCents);
    const currency = estimate.result.costs.currency.toLowerCase();

    const { data: order, error: orderError } = await service
      .from('print_orders')
      .insert({
        user_id: userId,
        design_id: design.id,
        status: 'pending',
        product_variant_id: body.variant_id,
        product_name: body.product_name,
        quantity,
        printful_cost_cents: printfulTotalCents,
        retail_total_cents: retailTotalCents,
        shipping_address: body.recipient,
        customer_email: body.recipient.email,
      })
      .select('id')
      .single();

    if (orderError || !order) {
      throw new Error(orderError?.message ?? 'Could not create order');
    }

    const stripeKey = requireEnv('STRIPE_SECRET_KEY');
    const successUrl =
      body.success_url ??
      Deno.env.get('STRIPE_SUCCESS_URL') ??
      'opartlab://print/checkout/success';
    const cancelUrl =
      body.cancel_url ??
      Deno.env.get('STRIPE_CANCEL_URL') ??
      'opartlab://print/checkout/cancel';

    const params = new URLSearchParams();
    params.set('mode', 'payment');
    params.set('success_url', `${successUrl}?order_id=${order.id}`);
    params.set('cancel_url', `${cancelUrl}?order_id=${order.id}`);
    params.set('customer_email', body.recipient.email);
    params.set('line_items[0][price_data][currency]', currency);
    params.set('line_items[0][price_data][product_data][name]', body.product_name);
    params.set(
      'line_items[0][price_data][unit_amount]',
      String(retailTotalCents),
    );
    params.set('line_items[0][quantity]', String(quantity));
    params.set('metadata[order_id]', order.id);
    params.set('metadata[design_id]', design.id);
    params.set('metadata[variant_id]', String(body.variant_id));

    const stripeResponse = await fetch(
      'https://api.stripe.com/v1/checkout/sessions',
      {
        method: 'POST',
        headers: {
          Authorization: `Bearer ${stripeKey}`,
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: params.toString(),
      },
    );

    const session = await stripeResponse.json();
    if (!stripeResponse.ok) {
      throw new Error(session.error?.message ?? 'Stripe session failed');
    }

    await service
      .from('print_orders')
      .update({ stripe_session_id: session.id })
      .eq('id', order.id);

    return jsonResponse({
      order_id: order.id,
      checkout_url: session.url,
      retail_total_cents: retailTotalCents,
      printful_total_cents: printfulTotalCents,
    });
  } catch (error) {
    return jsonResponse(
      { error: error instanceof Error ? error.message : 'Unknown error' },
      500,
    );
  }
});

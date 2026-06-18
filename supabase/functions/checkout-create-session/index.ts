import { serve } from 'https://deno.land/std@0.224.0/http/server.ts';
import {
  handleOptions,
  jsonResponse,
  requireEnv,
} from '../_shared/http.ts';
import {
  estimateOrderCosts,
  type EstimateLineInput,
} from '../_shared/order_estimate.ts';
import { createServiceClient, getUserId } from '../_shared/supabase.ts';

interface CheckoutLineInput extends EstimateLineInput {
  product_name: string;
}

interface CheckoutBody {
  items?: CheckoutLineInput[];
  design_id?: string;
  variant_id?: number;
  product_name?: string;
  quantity?: number;
  recipient: {
    country_code: string;
    zip: string;
    state_code?: string;
    city?: string;
    name?: string;
    address1?: string;
    address2?: string;
    email?: string;
    phone?: string;
  };
}

function resolveCheckoutItems(body: CheckoutBody): CheckoutLineInput[] | null {
  if (body.items && body.items.length > 0) {
    return body.items;
  }
  if (body.design_id && body.variant_id && body.product_name) {
    return [
      {
        design_id: body.design_id,
        variant_id: body.variant_id,
        product_name: body.product_name,
        quantity: body.quantity ?? 1,
      },
    ];
  }
  return null;
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
    const items = resolveCheckoutItems(body);

    if (
      !items ||
      !body.recipient?.country_code ||
      !body.recipient?.zip
    ) {
      return jsonResponse(
        {
          error:
            'items (or design_id + variant_id + product_name), recipient.country_code, and recipient.zip are required',
        },
        400,
      );
    }

    const service = createServiceClient();

    for (const item of items) {
      const { data: design, error: designError } = await service
        .from('print_designs')
        .select('id, user_id')
        .eq('id', item.design_id)
        .single();

      if (designError || !design) {
        return jsonResponse({ error: 'Design not found' }, 404);
      }

      if (userId && design.user_id && design.user_id !== userId) {
        return jsonResponse({ error: 'Forbidden' }, 403);
      }
    }

    const recipient = {
      name: body.recipient.name ?? '',
      address1: body.recipient.address1 ?? '',
      address2: body.recipient.address2 ?? '',
      city: body.recipient.city ?? '',
      state_code: body.recipient.state_code ?? '',
      country_code: body.recipient.country_code,
      zip: body.recipient.zip,
      email: body.recipient.email ?? '',
      phone: body.recipient.phone ?? '',
    };

    const costs = await estimateOrderCosts(
      service,
      items.map((item) => ({
        variant_id: item.variant_id,
        design_id: item.design_id,
        quantity: item.quantity ?? 1,
      })),
      recipient,
    );

    const currency = costs.currency.toLowerCase();
    const firstItem = items[0];
    const productSummary = items.length === 1
      ? firstItem.product_name
      : `OpArt Lab — ${items.length} items`;

    const { data: order, error: orderError } = await service
      .from('print_orders')
      .insert({
        user_id: userId,
        design_id: items.length === 1 ? firstItem.design_id : null,
        status: 'pending',
        product_variant_id: items.length === 1 ? firstItem.variant_id : null,
        product_name: productSummary,
        quantity: items.reduce((sum, item) => sum + (item.quantity ?? 1), 0),
        printful_cost_cents: costs.printful_total_cents,
        retail_total_cents: costs.retail_total_cents,
        shipping_address: recipient,
        customer_email: recipient.email,
      })
      .select('id')
      .single();

    if (orderError || !order) {
      throw new Error(orderError?.message ?? 'Could not create order');
    }

    const lineRows = items.map((item) => ({
      order_id: order.id,
      design_id: item.design_id,
      product_variant_id: item.variant_id,
      product_name: item.product_name,
      quantity: item.quantity ?? 1,
    }));

    const { error: linesError } = await service
      .from('print_order_line_items')
      .insert(lineRows);

    if (linesError) {
      throw new Error(linesError.message);
    }

    const stripeKey = requireEnv('STRIPE_SECRET_KEY');

    const params = new URLSearchParams();
    params.set('amount', String(costs.retail_total_cents));
    params.set('currency', currency);
    params.set('description', productSummary);
    params.set('automatic_payment_methods[enabled]', 'true');
    params.set('metadata[order_id]', order.id);
    params.set('metadata[item_count]', String(items.length));

    const stripeResponse = await fetch(
      'https://api.stripe.com/v1/payment_intents',
      {
        method: 'POST',
        headers: {
          Authorization: `Bearer ${stripeKey}`,
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: params.toString(),
      },
    );

    const paymentIntent = await stripeResponse.json();
    if (!stripeResponse.ok) {
      throw new Error(
        paymentIntent.error?.message ?? 'Stripe payment intent failed',
      );
    }

    await service
      .from('print_orders')
      .update({ stripe_session_id: paymentIntent.id })
      .eq('id', order.id);

    return jsonResponse({
      order_id: order.id,
      client_secret: paymentIntent.client_secret,
      retail_total_cents: costs.retail_total_cents,
      currency_code: currency,
    });
  } catch (error) {
    return jsonResponse(
      { error: error instanceof Error ? error.message : 'Unknown error' },
      500,
    );
  }
});

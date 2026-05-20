import { serve } from 'https://deno.land/std@0.224.0/http/server.ts';
import { handleOptions, jsonResponse } from '../_shared/http.ts';
import { createServiceClient } from '../_shared/supabase.ts';
import { printfulFetch } from '../_shared/printful.ts';

serve(async (req) => {
  const options = handleOptions(req);
  if (options) {
    return options;
  }

  try {
    const url = new URL(req.url);
    const orderId = url.searchParams.get('order_id');
    if (!orderId) {
      return jsonResponse({ error: 'order_id is required' }, 400);
    }

    const service = createServiceClient();
    const { data: order, error } = await service
      .from('print_orders')
      .select('*')
      .eq('id', orderId)
      .single();

    if (error || !order) {
      return jsonResponse({ error: 'Order not found' }, 404);
    }

    if (order.printful_order_id) {
      const printful = await printfulFetch<{
        code: number;
        result: {
          status: string;
          shipments?: Array<{ tracking_url?: string }>;
        };
      }>(`/orders/${order.printful_order_id}`);

      const trackingUrl =
        printful.result.shipments?.find((s) => s.tracking_url)?.tracking_url ??
        null;

      if (trackingUrl && trackingUrl !== order.tracking_url) {
        await service
          .from('print_orders')
          .update({
            tracking_url: trackingUrl,
            status:
              printful.result.status === 'fulfilled' ? 'fulfilled' : order.status,
            updated_at: new Date().toISOString(),
          })
          .eq('id', orderId);
        order.tracking_url = trackingUrl;
      }
    }

    return jsonResponse({ order });
  } catch (error) {
    return jsonResponse(
      { error: error instanceof Error ? error.message : 'Unknown error' },
      500,
    );
  }
});

import { serve } from 'https://deno.land/std@0.224.0/http/server.ts';
import { getDesignSignedUrl } from '../_shared/designs.ts';
import {
  applyMarkup,
  handleOptions,
  jsonResponse,
} from '../_shared/http.ts';
import { createServiceClient } from '../_shared/supabase.ts';
import { printfulFetch } from '../_shared/printful.ts';

interface EstimateBody {
  variant_id: number;
  design_id?: string;
  file_url?: string;
  quantity?: number;
  recipient: {
    country_code: string;
    state_code?: string;
    city?: string;
    zip?: string;
  };
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
    const body = (await req.json()) as EstimateBody;
    if (
      !body.variant_id ||
      (!body.design_id && !body.file_url) ||
      !body.recipient?.country_code
    ) {
      return jsonResponse(
        {
          error:
            'variant_id, design_id or file_url, and recipient.country_code are required',
        },
        400,
      );
    }

    const service = createServiceClient();
    const fileUrl = body.file_url ??
      await getDesignSignedUrl(service, body.design_id!);
    const quantity = body.quantity ?? 1;

    const estimate = await printfulFetch<{
      code: number;
      result: {
        costs: {
          currency: string;
          subtotal: string;
          shipping: string;
          tax: string;
          total: string;
        };
      };
    }>('/orders/estimate-costs', {
      method: 'POST',
      body: JSON.stringify({
        recipient: {
          country_code: body.recipient.country_code,
          state_code: body.recipient.state_code ?? '',
          city: body.recipient.city ?? '',
          zip: body.recipient.zip ?? '',
        },
        items: [
          {
            variant_id: body.variant_id,
            quantity,
            files: [{ url: fileUrl }],
          },
        ],
      }),
    });

    const costs = estimate.result.costs;
    const printfulTotalCents = Math.round(parseFloat(costs.total) * 100);
    const retailTotalCents = applyMarkup(printfulTotalCents);

    return jsonResponse({
      currency: costs.currency,
      printful_subtotal_cents: Math.round(parseFloat(costs.subtotal) * 100),
      printful_shipping_cents: Math.round(parseFloat(costs.shipping) * 100),
      printful_tax_cents: Math.round(parseFloat(costs.tax) * 100),
      printful_total_cents: printfulTotalCents,
      retail_total_cents: retailTotalCents,
    });
  } catch (error) {
    return jsonResponse(
      { error: error instanceof Error ? error.message : 'Unknown error' },
      500,
    );
  }
});

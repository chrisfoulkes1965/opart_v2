import { serve } from 'https://deno.land/std@0.224.0/http/server.ts';
import {
  estimateOrderCosts,
  type EstimateLineInput,
} from '../_shared/order_estimate.ts';
import {
  handleOptions,
  jsonResponse,
} from '../_shared/http.ts';
import { createServiceClient } from '../_shared/supabase.ts';

interface EstimateBody {
  items?: EstimateLineInput[];
  variant_id?: number;
  design_id?: string;
  file_url?: string;
  quantity?: number;
  recipient: {
    country_code: string;
    state_code?: string;
    city?: string;
    zip?: string;
    address1?: string;
    name?: string;
  };
}

function resolveItems(body: EstimateBody): EstimateLineInput[] | null {
  if (body.items && body.items.length > 0) {
    return body.items;
  }
  if (body.variant_id && body.design_id) {
    return [
      {
        variant_id: body.variant_id,
        design_id: body.design_id,
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
    const body = (await req.json()) as EstimateBody;
    const items = resolveItems(body);

    if (!items || !body.recipient?.country_code) {
      return jsonResponse(
        {
          error:
            'items (or variant_id + design_id) and recipient.country_code are required',
        },
        400,
      );
    }

    const service = createServiceClient();
    const estimate = await estimateOrderCosts(service, items, body.recipient);
    return jsonResponse(estimate);
  } catch (error) {
    return jsonResponse(
      { error: error instanceof Error ? error.message : 'Unknown error' },
      500,
    );
  }
});

import { serve } from 'https://deno.land/std@0.224.0/http/server.ts';
import { handleOptions, jsonResponse } from '../_shared/http.ts';
import { printfulFetch } from '../_shared/printful.ts';

serve(async (req) => {
  const options = handleOptions(req);
  if (options) {
    return options;
  }

  try {
    const url = new URL(req.url);
    const productId = url.searchParams.get('product_id');
    if (!productId) {
      return jsonResponse({ error: 'product_id is required' }, 400);
    }

    const data = await printfulFetch<{
      code: number;
      result: {
        product?: unknown;
        variants?: unknown[];
      };
    }>(`/products/${productId}`);

    return jsonResponse({
      product: data.result.product ?? data.result,
      variants: data.result.variants ?? [],
    });
  } catch (error) {
    return jsonResponse(
      { error: error instanceof Error ? error.message : 'Unknown error' },
      500,
    );
  }
});

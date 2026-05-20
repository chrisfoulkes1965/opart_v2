import { serve } from 'https://deno.land/std@0.224.0/http/server.ts';
import { handleOptions, jsonResponse } from '../_shared/http.ts';
import { printfulFetch } from '../_shared/printful.ts';

const MVP_PRODUCT_IDS = (Deno.env.get('PRINTFUL_MVP_PRODUCT_IDS') ??
  '268,71,19')
  .split(',')
  .map((id) => Number(id.trim()))
  .filter((id) => !Number.isNaN(id));

serve(async (req) => {
  const options = handleOptions(req);
  if (options) {
    return options;
  }

  try {
    const data = await printfulFetch<{ code: number; result: unknown[] }>(
      '/products',
    );

    const products = (data.result ?? [])
      .filter((product: { id: number }) =>
        MVP_PRODUCT_IDS.includes(product.id)
      )
      .sort(
        (a: { id: number }, b: { id: number }) =>
          MVP_PRODUCT_IDS.indexOf(a.id) - MVP_PRODUCT_IDS.indexOf(b.id),
      );

    return jsonResponse({ products });
  } catch (error) {
    return jsonResponse(
      { error: error instanceof Error ? error.message : 'Unknown error' },
      500,
    );
  }
});

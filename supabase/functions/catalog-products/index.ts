import { serve } from 'https://deno.land/std@0.224.0/http/server.ts';
import { resolveCatalogProductIds } from '../_shared/catalog.ts';
import { handleOptions, jsonResponse } from '../_shared/http.ts';
import { printfulFetch } from '../_shared/printful.ts';

serve(async (req) => {
  const options = handleOptions(req);
  if (options) {
    return options;
  }

  try {
    const catalogProductIds = resolveCatalogProductIds();
    const data = await printfulFetch<{ code: number; result: unknown[] }>(
      '/products',
    );

    const products = (data.result ?? [])
      .filter((product: { id: number }) =>
        catalogProductIds.includes(product.id),
      )
      .sort(
        (a: { id: number }, b: { id: number }) =>
          catalogProductIds.indexOf(a.id) - catalogProductIds.indexOf(b.id),
      );

    return jsonResponse({ products });
  } catch (error) {
    return jsonResponse(
      { error: error instanceof Error ? error.message : 'Unknown error' },
      500,
    );
  }
});

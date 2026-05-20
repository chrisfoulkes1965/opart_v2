import { serve } from 'https://deno.land/std@0.224.0/http/server.ts';
import { handleOptions, jsonResponse } from '../_shared/http.ts';
import { resolvePrintArea } from '../_shared/printful.ts';

serve(async (req) => {
  const options = handleOptions(req);
  if (options) {
    return options;
  }

  try {
    const url = new URL(req.url);
    const productId = Number(url.searchParams.get('product_id'));
    const variantId = Number(url.searchParams.get('variant_id'));
    const placement = url.searchParams.get('placement') ?? undefined;

    if (!Number.isFinite(productId) || !Number.isFinite(variantId)) {
      return jsonResponse(
        { error: 'product_id and variant_id are required' },
        400,
      );
    }

    const area = await resolvePrintArea(productId, variantId, placement);

    return jsonResponse({
      placement: area.placement,
      width_px: area.width,
      height_px: area.height,
      dpi: area.dpi,
      fill_mode: area.fill_mode,
    });
  } catch (error) {
    return jsonResponse(
      { error: error instanceof Error ? error.message : 'Unknown error' },
      500,
    );
  }
});

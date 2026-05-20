import { serve } from 'https://deno.land/std@0.224.0/http/server.ts';
import { decodeBase64Png, uploadGuestDesignPng } from '../_shared/designs.ts';
import { handleOptions, jsonResponse } from '../_shared/http.ts';
import { createServiceClient, getUserId } from '../_shared/supabase.ts';

interface RegisterBody {
  png_base64?: string;
  storage_path?: string;
  design_recipe?: Record<string, unknown>;
  local_opart_id?: number;
  width_px: number;
  height_px: number;
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

    const body = (await req.json()) as RegisterBody;
    if (!body.png_base64 && !body.storage_path) {
      return jsonResponse(
        { error: 'png_base64 or storage_path is required' },
        400,
      );
    }

    const service = createServiceClient();
    let storagePath = body.storage_path;

    if (body.png_base64) {
      const pngBytes = decodeBase64Png(body.png_base64);
      storagePath = await uploadGuestDesignPng(service, pngBytes);
    }

    if (!storagePath) {
      return jsonResponse({ error: 'Could not determine storage path' }, 400);
    }

    const { data: design, error: insertError } = await service
      .from('print_designs')
      .insert({
        user_id: userId,
        local_opart_id: body.local_opart_id ?? null,
        design_recipe: body.design_recipe ?? {},
        storage_path: storagePath,
        printful_file_id: null,
        width_px: body.width_px,
        height_px: body.height_px,
      })
      .select('id')
      .single();

    if (insertError) {
      throw new Error(insertError.message);
    }

    return jsonResponse({
      design_id: design.id,
    });
  } catch (error) {
    return jsonResponse(
      { error: error instanceof Error ? error.message : 'Unknown error' },
      500,
    );
  }
});

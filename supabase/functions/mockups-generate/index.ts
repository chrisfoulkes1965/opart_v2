import { serve } from 'https://deno.land/std@0.224.0/http/server.ts';
import { getDesignSignedUrl } from '../_shared/designs.ts';
import { handleOptions, jsonResponse } from '../_shared/http.ts';
import {
  buildMockupFilePayload,
  printfulFetch,
  sleep,
} from '../_shared/printful.ts';
import { createServiceClient } from '../_shared/supabase.ts';

interface MockupBody {
  product_id: number;
  variant_ids: number[];
  design_id: string;
  placement?: string;
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
    const body = (await req.json()) as MockupBody;
    if (!body.product_id || !body.variant_ids?.length || !body.design_id) {
      return jsonResponse(
        { error: 'product_id, variant_ids, and design_id are required' },
        400,
      );
    }

    const service = createServiceClient();
    const imageUrl = await getDesignSignedUrl(service, body.design_id, 60 * 60);
    const mockupFile = await buildMockupFilePayload(
      body.product_id,
      body.variant_ids,
      imageUrl,
      body.placement,
    );

    const task = await printfulFetch<{
      code: number;
      result: { task_key: string; status: string };
    }>(`/mockup-generator/create-task/${body.product_id}`, {
      method: 'POST',
      body: JSON.stringify({
        variant_ids: body.variant_ids,
        format: 'jpg',
        files: [mockupFile],
      }),
    });

    const taskKey = task.result.task_key;
    let attempts = 0;

    while (attempts < 30) {
      await sleep(2000);
      const result = await printfulFetch<{
        code: number;
        result: {
          status: string;
          mockups?: Array<{ mockup_url: string; variant_ids: number[] }>;
          error?: string;
        };
      }>(`/mockup-generator/task?task_key=${encodeURIComponent(taskKey)}`);

      if (result.result.status === 'completed') {
        return jsonResponse({
          task_key: taskKey,
          mockups: result.result.mockups ?? [],
        });
      }

      if (result.result.status === 'failed') {
        throw new Error(result.result.error ?? 'Mockup generation failed');
      }

      attempts++;
    }

    return jsonResponse(
      { error: 'Mockup generation timed out', task_key: taskKey },
      504,
    );
  } catch (error) {
    return jsonResponse(
      { error: error instanceof Error ? error.message : 'Unknown error' },
      500,
    );
  }
});

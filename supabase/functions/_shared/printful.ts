import { requireEnv } from './http.ts';

const PRINTFUL_BASE = 'https://api.printful.com';

export async function printfulFetch<T>(
  path: string,
  init: RequestInit = {},
  maxAttempts = 3,
): Promise<T> {
  const token = requireEnv('PRINTFUL_API_TOKEN');

  for (let attempt = 0; attempt < maxAttempts; attempt++) {
    const response = await fetch(`${PRINTFUL_BASE}${path}`, {
      ...init,
      headers: {
        Authorization: `Bearer ${token}`,
        'Content-Type': 'application/json',
        ...(init.headers ?? {}),
      },
    });

    const payload = await response.json();

    if (response.ok) {
      return payload as T;
    }

    const message = String(
      payload?.error?.message ??
        payload?.result ??
        `Printful request failed (${response.status})`,
    );

    const retryAfterSeconds = parseRetryAfterSeconds(message);
    if (retryAfterSeconds != null && attempt < maxAttempts - 1) {
      await sleep((retryAfterSeconds + 1) * 1000);
      continue;
    }

    throw new Error(message);
  }

  throw new Error('Printful request failed');
}

function parseRetryAfterSeconds(message: string): number | null {
  const match = message.match(/try again after (\d+) seconds/i);
  if (!match) {
    return null;
  }
  const seconds = Number.parseInt(match[1], 10);
  return Number.isFinite(seconds) ? seconds : null;
}

export interface PrintfulCatalogProduct {
  id: number;
  type: string;
  type_name: string;
  title: string;
  brand: string;
  image: string;
  variant_count: number;
  currency: string;
}

export interface PrintfulVariant {
  id: number;
  product_id: number;
  name: string;
  size: string;
  color: string;
  color_code: string;
  image: string;
  price: string;
  in_stock: boolean;
}

export interface PrintfulFile {
  id: number;
  url: string;
  preview_url?: string;
  status: 'waiting' | 'ok' | 'failed';
  width?: number;
  height?: number;
}

export async function sleep(ms: number) {
  await new Promise((resolve) => setTimeout(resolve, ms));
}

export async function waitForPrintfulFile(
  fileId: number,
  maxAttempts = 30,
  delayMs = 2000,
): Promise<PrintfulFile> {
  for (let attempt = 0; attempt < maxAttempts; attempt++) {
    const response = await printfulFetch<{ code: number; result: PrintfulFile }>(
      `/files/${fileId}`,
    );
    const file = response.result;

    if (file.status === 'ok') {
      return file;
    }
    if (file.status === 'failed') {
      throw new Error('Printful file processing failed');
    }

    await sleep(delayMs);
  }

  throw new Error('Printful file processing timed out');
}

interface PrintfilesResponse {
  code: number;
  result: {
    product_id: number;
    available_placements: Record<string, string>;
    printfiles: Array<{
      printfile_id: number;
      width: number;
      height: number;
      dpi: number;
      fill_mode: string;
    }>;
    variant_printfiles: Array<{
      variant_id: number;
      placements: Record<string, number>;
    }>;
  };
}

export interface MockupFilePayload {
  placement: string;
  image_url: string;
  position: {
    area_width: number;
    area_height: number;
    width: number;
    height: number;
    top: number;
    left: number;
  };
}

export interface ResolvedPrintArea {
  placement: string;
  width: number;
  height: number;
  dpi: number;
  fill_mode: string;
}

export async function resolvePrintArea(
  productId: number,
  variantId: number,
  placementOverride?: string,
): Promise<ResolvedPrintArea> {
  const printfiles = await printfulFetch<PrintfilesResponse>(
    `/mockup-generator/printfiles/${productId}`,
  );

  const variantMapping =
    printfiles.result.variant_printfiles.find(
      (entry) => entry.variant_id === variantId,
    ) ?? printfiles.result.variant_printfiles[0];

  let placement = placementOverride;
  if (!placement) {
    const placements = printfiles.result.available_placements;
    if (placements.default) {
      placement = 'default';
    } else if (placements.front) {
      placement = 'front';
    } else {
      placement = Object.keys(placements)[0];
    }
  }

  const printfileId = variantMapping.placements[placement];
  const printfile =
    printfiles.result.printfiles.find(
      (entry) => entry.printfile_id === printfileId,
    ) ?? printfiles.result.printfiles[0];

  return {
    placement,
    width: printfile.width,
    height: printfile.height,
    dpi: printfile.dpi,
    fill_mode: printfile.fill_mode,
  };
}

export async function buildMockupFilePayload(
  productId: number,
  variantIds: number[],
  imageUrl: string,
  placementOverride?: string,
  imageWidthPx?: number,
  imageHeightPx?: number,
): Promise<MockupFilePayload> {
  const area = await resolvePrintArea(
    productId,
    variantIds[0],
    placementOverride,
  );

  const width = imageWidthPx && imageWidthPx > 0 ? imageWidthPx : area.width;
  const height =
    imageHeightPx && imageHeightPx > 0 ? imageHeightPx : area.height;

  return {
    placement: area.placement,
    image_url: imageUrl,
    position: {
      area_width: area.width,
      area_height: area.height,
      width,
      height,
      top: 0,
      left: 0,
    },
  };
}

export interface PrintfulEstimateRecipientInput {
  name?: string;
  address1?: string;
  address2?: string;
  city?: string;
  state_code?: string;
  country_code: string;
  zip?: string;
}

const REGIONAL_ESTIMATE_ADDRESS1 = 'Regional estimate';

export function recipientForEstimateCosts(
  input: PrintfulEstimateRecipientInput,
): Record<string, string> {
  return {
    name: input.name?.trim() || 'Customer',
    address1: input.address1?.trim() || REGIONAL_ESTIMATE_ADDRESS1,
    address2: input.address2?.trim() ?? '',
    city: input.city?.trim() || 'N/A',
    state_code: input.state_code?.trim() ?? '',
    country_code: input.country_code,
    zip: input.zip?.trim() ?? '',
  };
}

import { SupabaseClient } from 'https://esm.sh/@supabase/supabase-js@2.49.1';

export interface StoredDesign {
  storage_path: string;
  width_px: number;
  height_px: number;
}

export async function getStoredDesign(
  service: SupabaseClient,
  designId: string,
): Promise<StoredDesign> {
  const { data: design, error } = await service
    .from('print_designs')
    .select('storage_path, width_px, height_px')
    .eq('id', designId)
    .single();

  if (error || !design?.storage_path) {
    throw new Error('Design not found');
  }

  return design as StoredDesign;
}

export async function getDesignSignedUrl(
  service: SupabaseClient,
  designId: string,
  expiresInSeconds = 3600,
): Promise<string> {
  const design = await getStoredDesign(service, designId);

  const { data: signed, error: signError } = await service.storage
    .from('print-files')
    .createSignedUrl(design.storage_path, expiresInSeconds);

  if (signError || !signed?.signedUrl) {
    throw new Error(signError?.message ?? 'Could not sign design file URL');
  }

  return signed.signedUrl;
}

export function decodeBase64Png(base64: string): Uint8Array {
  const normalized = base64.replace(/^data:image\/png;base64,/, '');
  const binary = atob(normalized);
  const bytes = new Uint8Array(binary.length);
  for (let i = 0; i < binary.length; i++) {
    bytes[i] = binary.charCodeAt(i);
  }
  return bytes;
}

export async function uploadGuestDesignPng(
  service: SupabaseClient,
  pngBytes: Uint8Array,
): Promise<string> {
  const storagePath = `guest/${crypto.randomUUID()}.png`;
  const { error } = await service.storage.from('print-files').upload(
    storagePath,
    pngBytes,
    {
      contentType: 'image/png',
      upsert: false,
    },
  );

  if (error) {
    throw new Error(error.message);
  }

  return storagePath;
}

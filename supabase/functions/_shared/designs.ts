import { SupabaseClient } from 'https://esm.sh/@supabase/supabase-js@2.49.1';

export async function getDesignSignedUrl(
  service: SupabaseClient,
  designId: string,
  expiresInSeconds = 3600,
): Promise<string> {
  const { data: design, error } = await service
    .from('print_designs')
    .select('storage_path')
    .eq('id', designId)
    .single();

  if (error || !design?.storage_path) {
    throw new Error('Design not found');
  }

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

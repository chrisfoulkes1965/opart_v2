import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.49.1';

export function createServiceClient() {
  const url = Deno.env.get('SUPABASE_URL');
  const key = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY');
  if (!url || !key) {
    throw new Error('Missing Supabase service role configuration');
  }
  return createClient(url, key);
}

export function createUserClient(authHeader: string | null) {
  const url = Deno.env.get('SUPABASE_URL');
  const anonKey = Deno.env.get('SUPABASE_ANON_KEY');
  if (!url || !anonKey) {
    throw new Error('Missing Supabase anon configuration');
  }

  return createClient(url, anonKey, {
    global: {
      headers: authHeader ? { Authorization: authHeader } : {},
    },
  });
}

export async function getUserId(authHeader: string | null): Promise<string | null> {
  if (!authHeader) {
    return null;
  }
  const client = createUserClient(authHeader);
  const { data, error } = await client.auth.getUser();
  if (error || !data.user) {
    return null;
  }
  return data.user.id;
}

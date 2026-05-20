-- Print shop tables for OpArt Lab Printful integration

create extension if not exists "pgcrypto";

create table if not exists public.print_designs (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references auth.users (id) on delete set null,
  local_opart_id integer,
  design_recipe jsonb not null default '{}'::jsonb,
  storage_path text not null,
  printful_file_id text,
  width_px integer not null,
  height_px integer not null,
  created_at timestamptz not null default now()
);

create table if not exists public.print_orders (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references auth.users (id) on delete set null,
  design_id uuid not null references public.print_designs (id) on delete restrict,
  printful_order_id bigint,
  stripe_session_id text unique,
  status text not null default 'pending'
    check (status in ('pending', 'paid', 'submitted', 'fulfilled', 'failed', 'cancelled')),
  product_variant_id integer not null,
  product_name text,
  quantity integer not null default 1 check (quantity > 0),
  retail_total_cents integer not null default 0,
  printful_cost_cents integer,
  shipping_address jsonb,
  customer_email text,
  tracking_url text,
  error_message text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.product_catalog_cache (
  id text primary key,
  payload jsonb not null,
  fetched_at timestamptz not null default now()
);

create index if not exists print_designs_user_id_idx on public.print_designs (user_id);
create index if not exists print_orders_user_id_idx on public.print_orders (user_id);
create index if not exists print_orders_design_id_idx on public.print_orders (design_id);
create index if not exists print_orders_stripe_session_id_idx on public.print_orders (stripe_session_id);

alter table public.print_designs enable row level security;
alter table public.print_orders enable row level security;
alter table public.product_catalog_cache enable row level security;

create policy "Users can read own print designs"
  on public.print_designs for select
  using (auth.uid() = user_id);

create policy "Users can insert own print designs"
  on public.print_designs for insert
  with check (auth.uid() = user_id);

create policy "Users can read own print orders"
  on public.print_orders for select
  using (auth.uid() = user_id);

create policy "Users can insert own print orders"
  on public.print_orders for insert
  with check (auth.uid() = user_id);

create policy "Service role manages catalog cache"
  on public.product_catalog_cache for all
  using (auth.role() = 'service_role');

-- Storage bucket for high-res print files (private)
insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values (
  'print-files',
  'print-files',
  false,
  209715200,
  array['image/png', 'image/jpeg']
)
on conflict (id) do nothing;

create policy "Users upload own print files"
  on storage.objects for insert
  with check (
    bucket_id = 'print-files'
    and auth.uid()::text = (storage.foldername(name))[1]
  );

create policy "Users read own print files"
  on storage.objects for select
  using (
    bucket_id = 'print-files'
    and auth.uid()::text = (storage.foldername(name))[1]
  );

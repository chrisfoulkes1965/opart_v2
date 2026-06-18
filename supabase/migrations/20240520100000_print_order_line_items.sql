-- Multi-item print orders: line items reference designs and variants per parent order.

create table if not exists public.print_order_line_items (
  id uuid primary key default gen_random_uuid(),
  order_id uuid not null references public.print_orders (id) on delete cascade,
  design_id uuid not null references public.print_designs (id) on delete restrict,
  product_variant_id integer not null,
  product_name text not null,
  quantity integer not null default 1 check (quantity > 0),
  created_at timestamptz not null default now()
);

create index if not exists print_order_line_items_order_id_idx
  on public.print_order_line_items (order_id);

alter table public.print_orders
  alter column design_id drop not null,
  alter column product_variant_id drop not null;

alter table public.print_order_line_items enable row level security;

create policy "Users read own order line items"
  on public.print_order_line_items
  for select
  using (
    exists (
      select 1
      from public.print_orders o
      where o.id = order_id
        and (o.user_id is null or o.user_id = auth.uid())
    )
  );

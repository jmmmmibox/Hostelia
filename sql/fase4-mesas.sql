-- ============================================
-- HOSTELIA — Fase 4: Mesas por capacidad
-- Ejecuta en Supabase > SQL Editor
-- ============================================

-- Tabla de grupos de mesas (ej: 5 mesas de 2, 3 mesas de 4, etc.)
create table if not exists mesas (
  id uuid default gen_random_uuid() primary key,
  negocio_id uuid references negocios(id) on delete cascade not null,
  comensales_max integer not null,
  cantidad integer not null default 1,
  creado_en timestamp with time zone default now()
);

alter table mesas enable row level security;

create policy "mesas_select" on mesas for select using (true);
create policy "mesas_insert" on mesas for insert with check (
  negocio_id in (select id from negocios where user_id = auth.uid())
);
create policy "mesas_update" on mesas for update using (
  negocio_id in (select id from negocios where user_id = auth.uid())
);
create policy "mesas_delete" on mesas for delete using (
  negocio_id in (select id from negocios where user_id = auth.uid())
);

-- Añadir campo mesa_id a reservas para saber qué tipo de mesa se reservó
alter table reservas add column if not exists mesa_id uuid references mesas(id) on delete set null;
alter table reservas add column if not exists union_mesas boolean default false;

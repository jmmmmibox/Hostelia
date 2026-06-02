-- ============================================
-- HOSTELIA — Tabla de turnos
-- ============================================

create table if not exists turnos (
  id uuid default gen_random_uuid() primary key,
  negocio_id uuid references negocios(id) on delete cascade not null,
  nombre text not null,
  hora_inicio time not null,
  hora_fin time not null,
  max_reservas integer not null default 15,
  activo boolean default true,
  orden integer default 0,
  creado_en timestamp with time zone default now()
);

alter table turnos enable row level security;

create policy "turnos_select" on turnos for select using (true);
create policy "turnos_insert" on turnos for insert with check (
  negocio_id in (select id from negocios where user_id = auth.uid())
);
create policy "turnos_update" on turnos for update using (
  negocio_id in (select id from negocios where user_id = auth.uid())
);
create policy "turnos_delete" on turnos for delete using (
  negocio_id in (select id from negocios where user_id = auth.uid())
);

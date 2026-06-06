-- Tabla de turnos para pedidos a domicilio
create table if not exists turnos_pedidos (
  id uuid default gen_random_uuid() primary key,
  negocio_id uuid references negocios(id) on delete cascade not null,
  nombre text not null,
  hora_inicio time not null,
  hora_fin time not null,
  max_pedidos integer not null default 20,
  activo boolean default true,
  orden integer default 0,
  creado_en timestamp with time zone default now()
);

alter table turnos_pedidos enable row level security;

create policy "tp_select" on turnos_pedidos for select using (true);
create policy "tp_insert" on turnos_pedidos for insert with check (
  negocio_id in (select id from negocios where user_id = auth.uid())
);
create policy "tp_update" on turnos_pedidos for update using (
  negocio_id in (select id from negocios where user_id = auth.uid())
);
create policy "tp_delete" on turnos_pedidos for delete using (
  negocio_id in (select id from negocios where user_id = auth.uid())
);

-- Añadir mensajes personalizables a envio_config
alter table envio_config
  add column if not exists mensaje_fuera_horario text default 'Ahora mismo no estamos tomando pedidos. Vuelve en nuestro horario de reparto.',
  add column if not exists mensaje_max_pedidos text default 'Hemos alcanzado el máximo de pedidos por este turno. Disculpa las molestias.';

-- ═══════════════════════════════════════════════════════
-- HOSTELIA — SQL COMPLETO PARA PROYECTO NUEVO
-- Ejecutar en orden en Supabase SQL Editor
-- ═══════════════════════════════════════════════════════

-- ── NEGOCIOS ─────────────────────────────────────────
create table if not exists negocios (
  id uuid default gen_random_uuid() primary key,
  user_id uuid references auth.users(id) on delete cascade not null,
  nombre text not null,
  tipo text default 'Restaurante',
  telefono text,
  email text,
  slug text unique,
  creado_en timestamp with time zone default now()
);
create index if not exists idx_negocios_slug on negocios(slug);
alter table negocios enable row level security;
create policy "neg_select" on negocios for select using (user_id = auth.uid());
create policy "neg_insert" on negocios for insert with check (user_id = auth.uid());
create policy "neg_update" on negocios for update using (user_id = auth.uid());
create policy "neg_delete" on negocios for delete using (user_id = auth.uid());

-- ── AGENTE CONFIG ────────────────────────────────────
create table if not exists agente_config (
  id uuid default gen_random_uuid() primary key,
  negocio_id uuid references negocios(id) on delete cascade not null unique,
  nombre_agente text default 'Asistente',
  tono text default 'amable',
  color text default '#ff6b35',
  activo_reservas boolean default true,
  activo_pedidos boolean default true,
  creado_en timestamp with time zone default now()
);
alter table agente_config enable row level security;
create policy "ag_select" on agente_config for select using (true);
create policy "ag_insert" on agente_config for insert with check (negocio_id in (select id from negocios where user_id = auth.uid()));
create policy "ag_update" on agente_config for update using (negocio_id in (select id from negocios where user_id = auth.uid()));

-- ── CONOCIMIENTO ─────────────────────────────────────
create table if not exists conocimiento (
  id uuid default gen_random_uuid() primary key,
  negocio_id uuid references negocios(id) on delete cascade not null,
  pregunta text not null,
  respuesta text,
  orden integer default 0,
  creado_en timestamp with time zone default now()
);
alter table conocimiento enable row level security;
create policy "con_select" on conocimiento for select using (true);
create policy "con_insert" on conocimiento for insert with check (negocio_id in (select id from negocios where user_id = auth.uid()));
create policy "con_update" on conocimiento for update using (negocio_id in (select id from negocios where user_id = auth.uid()));
create policy "con_delete" on conocimiento for delete using (negocio_id in (select id from negocios where user_id = auth.uid()));

-- ── CATEGORIAS ───────────────────────────────────────
create table if not exists categorias (
  id uuid default gen_random_uuid() primary key,
  negocio_id uuid references negocios(id) on delete cascade not null,
  nombre text not null,
  orden integer default 0,
  activa boolean default true,
  creado_en timestamp with time zone default now()
);
alter table categorias enable row level security;
create policy "cat_select" on categorias for select using (true);
create policy "cat_insert" on categorias for insert with check (negocio_id in (select id from negocios where user_id = auth.uid()));
create policy "cat_update" on categorias for update using (negocio_id in (select id from negocios where user_id = auth.uid()));
create policy "cat_delete" on categorias for delete using (negocio_id in (select id from negocios where user_id = auth.uid()));

-- ── CARTA ────────────────────────────────────────────
create table if not exists carta (
  id uuid default gen_random_uuid() primary key,
  negocio_id uuid references negocios(id) on delete cascade not null,
  categoria_id uuid references categorias(id) on delete set null,
  nombre text not null,
  descripcion text,
  precio numeric(10,2) not null default 0,
  imagen_url text,
  disponible boolean default true,
  orden integer default 0,
  creado_en timestamp with time zone default now()
);
alter table carta enable row level security;
create policy "carta_select" on carta for select using (true);
create policy "carta_insert" on carta for insert with check (negocio_id in (select id from negocios where user_id = auth.uid()));
create policy "carta_update" on carta for update using (negocio_id in (select id from negocios where user_id = auth.uid()));
create policy "carta_delete" on carta for delete using (negocio_id in (select id from negocios where user_id = auth.uid()));

-- ── MESAS ────────────────────────────────────────────
create table if not exists mesas (
  id uuid default gen_random_uuid() primary key,
  negocio_id uuid references negocios(id) on delete cascade not null,
  zona text not null default 'Interior',
  cantidad integer not null default 1,
  comensales_max integer not null default 2,
  creado_en timestamp with time zone default now()
);
alter table mesas enable row level security;
create policy "mesas_select" on mesas for select using (true);
create policy "mesas_insert" on mesas for insert with check (negocio_id in (select id from negocios where user_id = auth.uid()));
create policy "mesas_update" on mesas for update using (negocio_id in (select id from negocios where user_id = auth.uid()));
create policy "mesas_delete" on mesas for delete using (negocio_id in (select id from negocios where user_id = auth.uid()));

-- ── RESERVAS CONFIG ──────────────────────────────────
create table if not exists reservas_config (
  id uuid default gen_random_uuid() primary key,
  negocio_id uuid references negocios(id) on delete cascade not null unique,
  antelacion_max_dias integer default 30,
  antelacion_min_horas integer default 2,
  confirmacion_automatica boolean default false,
  creado_en timestamp with time zone default now()
);
alter table reservas_config enable row level security;
create policy "rc_select" on reservas_config for select using (true);
create policy "rc_insert" on reservas_config for insert with check (negocio_id in (select id from negocios where user_id = auth.uid()));
create policy "rc_update" on reservas_config for update using (negocio_id in (select id from negocios where user_id = auth.uid()));

-- ── TURNOS ───────────────────────────────────────────
create table if not exists turnos (
  id uuid default gen_random_uuid() primary key,
  negocio_id uuid references negocios(id) on delete cascade not null,
  nombre text not null,
  hora_inicio time not null,
  hora_fin time not null,
  max_reservas integer not null default 20,
  activo boolean default true,
  orden integer default 0,
  creado_en timestamp with time zone default now()
);
alter table turnos enable row level security;
create policy "turnos_select" on turnos for select using (true);
create policy "turnos_insert" on turnos for insert with check (negocio_id in (select id from negocios where user_id = auth.uid()));
create policy "turnos_update" on turnos for update using (negocio_id in (select id from negocios where user_id = auth.uid()));
create policy "turnos_delete" on turnos for delete using (negocio_id in (select id from negocios where user_id = auth.uid()));

-- ── RESERVAS ─────────────────────────────────────────
create table if not exists reservas (
  id uuid default gen_random_uuid() primary key,
  negocio_id uuid references negocios(id) on delete cascade not null,
  nombre_cliente text not null,
  telefono_cliente text,
  email_cliente text,
  fecha date not null,
  hora time not null,
  personas integer not null default 2,
  zona text default 'Interior',
  estado text default 'pendiente',
  notas text,
  creado_en timestamp with time zone default now()
);
alter table reservas enable row level security;
create policy "res_select" on reservas for select using (true);
create policy "res_insert" on reservas for insert with check (true);
create policy "res_update" on reservas for update using (negocio_id in (select id from negocios where user_id = auth.uid()));
create policy "res_delete" on reservas for delete using (negocio_id in (select id from negocios where user_id = auth.uid()));

-- ── PEDIDOS ──────────────────────────────────────────
create table if not exists pedidos (
  id uuid default gen_random_uuid() primary key,
  negocio_id uuid references negocios(id) on delete cascade not null,
  nombre_cliente text not null,
  telefono_cliente text,
  direccion_entrega text,
  items jsonb default '[]',
  total numeric(10,2) default 0,
  forma_pago text default 'efectivo',
  notas text,
  estado text default 'nuevo',
  creado_en timestamp with time zone default now()
);
alter table pedidos enable row level security;
create policy "ped_select" on pedidos for select using (true);
create policy "ped_insert" on pedidos for insert with check (true);
create policy "ped_update" on pedidos for update using (negocio_id in (select id from negocios where user_id = auth.uid()));
create policy "ped_delete" on pedidos for delete using (negocio_id in (select id from negocios where user_id = auth.uid()));

-- ── ENVIO CONFIG ─────────────────────────────────────
create table if not exists envio_config (
  id uuid default gen_random_uuid() primary key,
  negocio_id uuid references negocios(id) on delete cascade not null unique,
  coste_envio numeric(10,2) default 3,
  pedido_minimo_envio_gratis numeric(10,2) default 25,
  envio_gratis_siempre boolean default false,
  cobrar_envio_siempre boolean default false,
  mensaje_fuera_horario text default 'Ahora mismo no estamos tomando pedidos.',
  mensaje_max_pedidos text default 'Hemos alcanzado el máximo de pedidos por este turno.',
  creado_en timestamp with time zone default now()
);
alter table envio_config enable row level security;
create policy "ec_select" on envio_config for select using (true);
create policy "ec_insert" on envio_config for insert with check (negocio_id in (select id from negocios where user_id = auth.uid()));
create policy "ec_update" on envio_config for update using (negocio_id in (select id from negocios where user_id = auth.uid()));

-- ── TURNOS PEDIDOS ───────────────────────────────────
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
create policy "tp_insert" on turnos_pedidos for insert with check (negocio_id in (select id from negocios where user_id = auth.uid()));
create policy "tp_update" on turnos_pedidos for update using (negocio_id in (select id from negocios where user_id = auth.uid()));
create policy "tp_delete" on turnos_pedidos for delete using (negocio_id in (select id from negocios where user_id = auth.uid()));

-- ── WEB CONFIG ───────────────────────────────────────
create table if not exists web_config (
  id uuid default gen_random_uuid() primary key,
  negocio_id uuid references negocios(id) on delete cascade not null unique,
  color_primario text default '#ff6b35',
  color_secundario text default '#ffb347',
  fuente text default 'DM Sans',
  logo_url text,
  hero_imagen_url text,
  hero_titulo text,
  hero_subtitulo text,
  hero_btn_reservas boolean default true,
  hero_btn_pedidos boolean default true,
  sobre_texto text,
  sobre_imagen_url text,
  contacto_direccion text,
  contacto_telefono text,
  contacto_email text,
  contacto_maps_url text,
  contacto_horarios text,
  instagram text,
  facebook text,
  tiktok text,
  sec_sobre boolean default true,
  sec_carta boolean default true,
  sec_reservas boolean default true,
  sec_pedidos boolean default true,
  sec_contacto boolean default true,
  creado_en timestamp with time zone default now()
);
alter table web_config enable row level security;
create policy "wc_select" on web_config for select using (true);
create policy "wc_insert" on web_config for insert with check (negocio_id in (select id from negocios where user_id = auth.uid()));
create policy "wc_update" on web_config for update using (negocio_id in (select id from negocios where user_id = auth.uid()));

-- ── SUSCRIPCIONES HOSTELIA ───────────────────────────
create table if not exists suscripciones_hostelia (
  id uuid default gen_random_uuid() primary key,
  negocio_id uuid references negocios(id) on delete cascade not null unique,
  stripe_customer_id text,
  stripe_subscription_id text,
  plan text default 'trial',
  estado text default 'activo',
  trial_fin timestamp with time zone,
  periodo_fin timestamp with time zone,
  gracia_fin timestamp with time zone,
  creado_en timestamp with time zone default now(),
  actualizado_en timestamp with time zone default now()
);
alter table suscripciones_hostelia enable row level security;
create policy "sh_select" on suscripciones_hostelia for select using (negocio_id in (select id from negocios where user_id = auth.uid()));
create policy "sh_insert" on suscripciones_hostelia for insert with check (negocio_id in (select id from negocios where user_id = auth.uid()));
create policy "sh_update" on suscripciones_hostelia for update using (negocio_id in (select id from negocios where user_id = auth.uid()));

-- ── STORAGE BUCKET ───────────────────────────────────
insert into storage.buckets (id, name, public) values ('imagenes', 'imagenes', true) on conflict do nothing;
create policy "imagenes_select" on storage.objects for select using (bucket_id = 'imagenes');
create policy "imagenes_insert" on storage.objects for insert with check (bucket_id = 'imagenes' and auth.uid() is not null);
create policy "imagenes_delete" on storage.objects for delete using (bucket_id = 'imagenes' and auth.uid() is not null);

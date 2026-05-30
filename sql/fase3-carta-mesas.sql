-- ============================================
-- HOSTELIA — Fase 3: Carta, Categorías y Mesas
-- Ejecuta en Supabase > SQL Editor
-- ============================================

-- 1. CATEGORÍAS DE CARTA
create table if not exists categorias (
  id uuid default gen_random_uuid() primary key,
  negocio_id uuid references negocios(id) on delete cascade not null,
  nombre text not null,
  orden integer default 0,
  activa boolean default true,
  creado_en timestamp with time zone default now()
);

alter table categorias enable row level security;

create policy "categorias_select" on categorias for select using (true);
create policy "categorias_insert" on categorias for insert with check (
  negocio_id in (select id from negocios where user_id = auth.uid())
);
create policy "categorias_update" on categorias for update using (
  negocio_id in (select id from negocios where user_id = auth.uid())
);
create policy "categorias_delete" on categorias for delete using (
  negocio_id in (select id from negocios where user_id = auth.uid())
);

-- 2. ACTUALIZAR TABLA CARTA (añadir categoria_id y campo imagen)
alter table carta add column if not exists categoria_id uuid references categorias(id) on delete set null;
alter table carta add column if not exists imagen_url text;
alter table carta add column if not exists orden integer default 0;

-- 3. MESAS
create table if not exists mesas_config (
  id uuid default gen_random_uuid() primary key,
  negocio_id uuid references negocios(id) on delete cascade not null,
  numero_mesas integer default 10,
  comensales_max_por_mesa integer default 6,
  creado_en timestamp with time zone default now()
);

alter table mesas_config enable row level security;

create policy "mesas_select" on mesas_config for select using (
  negocio_id in (select id from negocios where user_id = auth.uid())
);
create policy "mesas_insert" on mesas_config for insert with check (
  negocio_id in (select id from negocios where user_id = auth.uid())
);
create policy "mesas_update" on mesas_config for update using (
  negocio_id in (select id from negocios where user_id = auth.uid())
);

-- 4. CONFIGURACIÓN DE ENVÍO
create table if not exists envio_config (
  id uuid default gen_random_uuid() primary key,
  negocio_id uuid references negocios(id) on delete cascade not null,
  pedido_minimo_envio_gratis decimal default 25,
  coste_envio decimal default 3,
  envio_gratis_siempre boolean default false,
  cobrar_envio_siempre boolean default false,
  creado_en timestamp with time zone default now()
);

alter table envio_config enable row level security;

create policy "envio_select" on envio_config for select using (true);
create policy "envio_insert" on envio_config for insert with check (
  negocio_id in (select id from negocios where user_id = auth.uid())
);
create policy "envio_update" on envio_config for update using (
  negocio_id in (select id from negocios where user_id = auth.uid())
);

-- 5. CONFIGURACIÓN WEB
create table if not exists web_config (
  id uuid default gen_random_uuid() primary key,
  negocio_id uuid references negocios(id) on delete cascade not null,
  color_primario text default '#ff6b35',
  color_secundario text default '#ffb347',
  tipografia text default 'Outfit',
  logo_url text,
  hero_imagen_url text,
  hero_titulo text,
  hero_subtitulo text,
  btn_reservas boolean default true,
  btn_pedidos boolean default true,
  sobre_nosotros_texto text,
  sobre_nosotros_imagen_url text,
  seccion_carta boolean default true,
  seccion_reservas boolean default true,
  seccion_pedidos boolean default true,
  seccion_sobre_nosotros boolean default true,
  seccion_contacto boolean default true,
  contacto_direccion text,
  contacto_telefono text,
  contacto_email text,
  contacto_google_maps_url text,
  contacto_horarios text,
  red_instagram text,
  red_facebook text,
  red_tiktok text,
  creado_en timestamp with time zone default now()
);

alter table web_config enable row level security;

create policy "web_config_select" on web_config for select using (true);
create policy "web_config_insert" on web_config for insert with check (
  negocio_id in (select id from negocios where user_id = auth.uid())
);
create policy "web_config_update" on web_config for update using (
  negocio_id in (select id from negocios where user_id = auth.uid())
);

-- 6. CREAR BUCKET DE STORAGE PARA IMÁGENES
insert into storage.buckets (id, name, public)
values ('imagenes', 'imagenes', true)
on conflict (id) do nothing;

-- Política de storage: cualquiera puede ver, solo autenticados suben
create policy "Imagenes publicas" on storage.objects
  for select using (bucket_id = 'imagenes');

create policy "Usuarios suben imagenes" on storage.objects
  for insert with check (bucket_id = 'imagenes' and auth.role() = 'authenticated');

create policy "Usuarios eliminan imagenes" on storage.objects
  for delete using (bucket_id = 'imagenes' and auth.role() = 'authenticated');

-- ============================================
-- LISTO
-- ============================================

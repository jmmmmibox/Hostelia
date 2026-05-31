-- ============================================
-- HOSTELIA — Fix RLS para web pública
-- Asegurar que TODAS las tablas necesarias
-- son legibles públicamente
-- ============================================

-- web_config
drop policy if exists "web_config_select" on web_config;
create policy "web_config_select" on web_config for select using (true);

-- envio_config
drop policy if exists "envio_select" on envio_config;
create policy "envio_select" on envio_config for select using (true);

-- mesas
drop policy if exists "mesas_select" on mesas;
create policy "mesas_select" on mesas for select using (true);

-- categorias
drop policy if exists "categorias_select" on categorias;
create policy "categorias_select" on categorias for select using (true);

-- carta
drop policy if exists "carta_select" on carta;
create policy "carta_select" on carta for select using (true);

-- reservas_config
drop policy if exists "res_config_select" on reservas_config;
create policy "res_config_select" on reservas_config for select using (true);

-- reservas (insertar desde web pública)
drop policy if exists "reservas_insert" on reservas;
create policy "reservas_insert" on reservas for insert with check (true);

-- reservas (leer para disponibilidad)
drop policy if exists "reservas_select_public" on reservas;
create policy "reservas_select_public" on reservas for select using (true);

-- pedidos (insertar desde web pública)
drop policy if exists "pedidos_insert" on pedidos;
create policy "pedidos_insert" on pedidos for insert with check (true);

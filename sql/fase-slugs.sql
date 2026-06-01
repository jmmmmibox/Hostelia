-- Añadir campo slug a negocios
alter table negocios add column if not exists slug text unique;

-- Crear índice para búsquedas rápidas por slug
create index if not exists idx_negocios_slug on negocios(slug);

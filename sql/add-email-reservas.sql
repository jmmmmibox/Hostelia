-- Añadir email del cliente a reservas
alter table reservas add column if not exists email_cliente text;

-- Añadir columna confirmación automática a reservas_config
alter table reservas_config 
add column if not exists confirmacion_automatica boolean default false;

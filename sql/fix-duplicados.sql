-- Limpiar duplicados en web_config (mantener solo el más reciente)
delete from web_config
where id not in (
  select distinct on (negocio_id) id
  from web_config
  order by negocio_id, creado_en desc
);

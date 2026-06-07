-- Añadir campo zona a la tabla mesas
alter table mesas add column if not exists zona text not null default 'Interior';

-- Limpiar mesas existentes (el dueño las reconfigurará desde cero)
-- delete from mesas; -- descomentar si quieres borrar las existentes

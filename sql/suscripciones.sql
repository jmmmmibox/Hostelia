-- Tabla de suscripciones
create table if not exists suscripciones (
  id uuid default gen_random_uuid() primary key,
  negocio_id uuid references negocios(id) on delete cascade not null unique,
  stripe_customer_id text,
  stripe_subscription_id text,
  plan text default 'trial', -- trial | pro_monthly | pro_annual | standby
  estado text default 'activo', -- activo | gracia | standby | cancelado
  trial_fin timestamp with time zone,
  periodo_fin timestamp with time zone,
  gracia_fin timestamp with time zone,
  creado_en timestamp with time zone default now(),
  actualizado_en timestamp with time zone default now()
);

alter table suscripciones enable row level security;

create policy "sus_select" on suscripciones for select using (
  negocio_id in (select id from negocios where user_id = auth.uid())
);
create policy "sus_insert" on suscripciones for insert with check (
  negocio_id in (select id from negocios where user_id = auth.uid())
);
create policy "sus_update" on suscripciones for update using (
  negocio_id in (select id from negocios where user_id = auth.uid())
);

-- Crear suscripción trial automáticamente para negocios existentes
insert into suscripciones (negocio_id, plan, estado, trial_fin)
select id, 'trial', 'activo', now() + interval '30 days'
from negocios
where id not in (select negocio_id from suscripciones)
on conflict do nothing;

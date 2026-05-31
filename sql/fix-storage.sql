-- Fix storage policies para subida de imágenes
drop policy if exists "Imagenes publicas" on storage.objects;
drop policy if exists "Usuarios suben imagenes" on storage.objects;
drop policy if exists "Usuarios eliminan imagenes" on storage.objects;

-- Lectura pública
create policy "storage_select" on storage.objects
  for select using (bucket_id = 'imagenes');

-- Subida (insert)
create policy "storage_insert" on storage.objects
  for insert with check (bucket_id = 'imagenes');

-- Actualizar (upsert necesita esto)
create policy "storage_update" on storage.objects
  for update using (bucket_id = 'imagenes');

-- Eliminar
create policy "storage_delete" on storage.objects
  for delete using (bucket_id = 'imagenes');

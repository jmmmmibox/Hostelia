# HOSTELIA — Documento de continuidad
# Pega esto al inicio del nuevo chat

---

## CONTEXTO DEL PROYECTO

Estoy construyendo **Hostelia**, un SaaS para hostelería (panel de administración + web pública para el cliente final).
Quiero continuar exactamente donde lo dejé. Aquí está todo lo necesario.

---

## STACK TÉCNICO

- **Frontend:** HTML/CSS/JS puro (un solo archivo por pantalla)
- **Backend:** Supabase (base de datos + auth + storage)
- **Deploy:** Netlify (conectado a GitHub, auto-deploy en cada push)
- **Control de versiones:** GitHub

---

## CREDENCIALES Y PROYECTOS

### GitHub
- **Repositorio:** `jmmmmibox/Hostelia`
- **Rama principal:** `main`
- **URL:** https://github.com/jmmmmibox/Hostelia

### Supabase
- **URL del proyecto:** `https://rjpjqrsyzkeghofziejy.supabase.co`
- **Anon Key:** `eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJqcGpxcnN5emtlZ2hvZnppZWp5Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3Nzg4NTI1MjYsImV4cCI6MjA5NDQyODUyNn0.httUrRI99cAO1YpiZzfcFcIAj5y41QB817b9pdfjbI4`
- **Negocio de prueba ID:** `4de27ac7-807a-4782-aeb7-7191456d13d3`
- **Confirmación email:** DESACTIVADA (Authentication → Providers → Email → Confirm email: OFF)

### Netlify
- Conectado al repo de GitHub — cada push a `main` despliega automáticamente
- Archivo `index.html` → panel de administración
- Archivo `web.html` → web pública del negocio (`?negocio=UUID`)
- Archivo `cocina.html` → pantalla de cocina (`?negocio=UUID`)

### Anthropic (para chatbot futuro)
- **API Key:** `sk-ant-api03-tyeK0Aj...` (guardada en Netlify como `ANTHROPIC_API_KEY`)

---

## ARCHIVOS DEL PROYECTO

```
Hostelia/
├── index.html      → Panel de administración completo
├── web.html        → Web pública del negocio
├── cocina.html     → Pantalla de cocina (KDS)
└── sql/
    ├── fase3-carta-mesas.sql
    ├── fase-slugs.sql
    ├── fix-web-rls.sql
    ├── fix-storage.sql
    ├── fix-duplicados.sql
    ├── confirmacion-automatica.sql
    └── turnos.sql
```

---

## TAGS DE GITHUB (puntos de restauración)

```
v1.0-estable              → versión inicial funcional
v1.1-antes-calendario     → antes del calendario de reservas
v2.0-web-final            → web pública finalizada y aprobada ⭐
v2.1-antes-resumen        → antes del rediseño del resumen
v2.2-antes-turnos         → antes de implementar turnos
v2.3-turnos-ok            → turnos funcionando
v2.4-metricas-ok          → métricas funcionando
v2.5-backup-registro      → estado actual ← AQUÍ ESTAMOS
```

Para revertir a cualquier tag:
```bash
git checkout tags/NOMBRE_TAG -- index.html web.html
git commit -m "Revertir a NOMBRE_TAG"
git push origin main
```

---

## BASE DE DATOS — TABLAS SUPABASE

```
negocios          → datos del negocio (nombre, tipo, slug, user_id)
agente_config     → configuración del agente IA
conocimiento      → base de conocimiento del agente (18 preguntas)
categorias        → categorías de la carta
carta             → platos (nombre, precio, imagen, descripción)
mesas             → grupos de mesas por capacidad
turnos            → turnos de servicio (nombre, hora_inicio, hora_fin, max_reservas)
reservas          → reservas de clientes
reservas_config   → config reservas (antelación, confirmación automática)
pedidos           → pedidos a domicilio
envio_config      → configuración de envío
web_config        → editor web (colores, imágenes, textos, secciones)
```

---

## FUNCIONALIDADES COMPLETADAS ✅

### Panel de administración (index.html)
- Login / Registro (directo al panel, sin onboarding)
- Sidebar con navegación completa
- **Resumen:** Dashboard en tiempo real — mesas hoy, pendientes de confirmar,
  pedidos sin atender, barra de ocupación, auto-refresh 30s
- **Mi Agente IA:** 4 pestañas (Apariencia, Cuestionario 18 preguntas, Info adicional, Funciones)
- **Carta:** Categorías + platos con imágenes (Supabase Storage bucket 'imagenes')
- **Reservas:** 4 pestañas:
  - Mesas (grupos por capacidad)
  - Disponibilidad (franjas horarias)
  - Reservas (tabla con edición inline)
  - Configuración (turnos CRUD + confirmación automática + antelación)
- **Pedidos:** Kanban nuevo/preparando/listo + enlace pantalla cocina
- **Mi Web:** 5 pestañas (Diseño, Portada, Sobre nosotros, Contacto, Secciones)
  - Botones ✕ para quitar imágenes (logo, hero, sobre nosotros)
- **Métricas:** Totales del mes, gráficas 7/30 días (barras+línea), días activos,
  horas pico, top platos
- **Configuración:** Datos negocio + slug + URL pública + Copia de seguridad (JSON) + SMS toggles + plan

### Web pública (web.html)
- Nav transparente→sólida al scroll, centrada
- Hero con parallax, overlay, tag tipo negocio
- Reveal animations en todas las secciones
- Carta con filtros por categoría
- **Reservas con calendario interactivo:** 3 pasos (día→hora→datos)
  - Calendario con colores disponibilidad POR TURNO (no por día total)
  - Horas agrupadas por turno con contador de plazas
  - Confirmación premium animada con ticket
  - Confirmación automática si está activada (estado 'confirmada' vs 'pendiente')
- Pedidos con carrito, cálculo envío, ticket de confirmación con botón OK
- Contacto con iconos SVG redes sociales, botón Cómo llegar
- Footer, toast notifications, mobile responsive

### Pantalla cocina (cocina.html)
- Fondo blanco, 3 columnas Kanban (Nuevos/Preparando/Listo)
- Tiempo transcurrido (rojo si >15min)
- Auto-refresco 30s
- Pitido triple ascendente para nuevos pedidos (botón "Activar sonido")

---

## SISTEMA DE TURNOS (importante)

La disponibilidad de reservas se calcula POR TURNO, no por día:
- Cada turno tiene: nombre, hora_inicio, hora_fin, max_reservas
- Si el turno del mediodía está lleno, el de cena sigue disponible
- Cada día es independiente de los demás
- En el calendario: verde=libre, naranja=algún turno lleno, rojo=todos los turnos llenos

---

## PENDIENTE ⏸️

- **SMS con Twilio** (confirmaciones reserva y pedido)
- **Stripe** (preparado en UI pero no activo)
- **Chatbot IA** (bloqueado por CORS — necesita proxy/Netlify Functions)
- **Subdominios personalizados** (requiere servidor propio o Netlify Edge)
- **Métricas** (en progreso — barras + línea, 7/30 días, días pico, horas, top platos)
- **Agente IA en Resumen** (conversaciones, preguntas sin respuesta)
- **Multi-negocio** (actualmente 1 negocio por cuenta)

---

## PREFERENCIAS Y REGLAS IMPORTANTES

1. **Antes de cualquier cambio significativo → crear tag en GitHub** para poder revertir
2. **Antes de construir → debatir siempre** qué se quiere exactamente
3. **Verificar JS antes de hacer push** (llaves balanceadas, sin romper showPanel)
4. El error más común: al insertar código nuevo antes de `function showPanel`,
   se elimina accidentalmente la declaración de la función → página en blanco
5. Arquitectura: **un solo archivo HTML** por pantalla, desplegado via Netlify+GitHub
6. Stack no cambia: no usar React, Vue, Node, etc.

---

## INSTRUCCIONES PARA EL NUEVO CHAT

"Hola, estoy continuando el desarrollo de Hostelia, un SaaS para hostelería.
Aquí tienes el documento de continuidad con todo el contexto:
[pegar este documento]

El código está en GitHub: jmmmmibox/Hostelia
Necesito que te conectes al repositorio y continuemos desde donde lo dejamos."

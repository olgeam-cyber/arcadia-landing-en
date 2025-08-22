# Arcadia Black — Deploy Pack (Render + Docker) — 2025-08-22

Este paquete contiene:
- `Dockerfile` — contenedor para el **bot de WhatsApp** (usa tu `server.js` v1.1 del canvas).
- `render.yaml` — blueprint para desplegar como **Web Service** en Render usando Docker.
- `package.json` — dependencias mínimas para `server.js`.
- **Guía rápida** para publicar el webhook y conectar WhatsApp Cloud, Stripe y dominio.

---

## 1) Estructura del repo (GitHub)
Sube a un repositorio **privado**:
```text
/ (repo root)
├─ server.js                # Usa el archivo: “Arcadia Black — WhatsApp AI Bot (v1.1 Payments-enabled)”
├─ package.json            # Incluido en este pack (puedes ajustarlo)
├─ Dockerfile              # Incluido
└─ render.yaml             # Incluido
```

> Si usas módulos extra (p.ej. `openai`), añádelos en `package.json`.

---

## 2) Render (Web Service con Docker)
1. Crea cuenta en **Render.com** → **New +** → **Blueprint** → conecta tu repo → selecciona `render.yaml`.
2. Establece **env vars** (todas como **Encrypted**):
   - **WhatsApp Cloud**: `VERIFY_TOKEN`, `META_WABA_TOKEN`, `META_PHONE_NUMBER_ID`
   - **Email**: `BRAND_EMAIL`, `SMTP_HOST`, `SMTP_PORT`, `SMTP_USER`, `SMTP_PASS`
   - **Stripe**: `STRIPE_SECRET`, `SUCCESS_URL`, `CANCEL_URL`, `RETAINER_DEFAULT`, `CURRENCY`
   - **Bancos**: `BANK_BENEFICIARY`, `BANK_NAME_USD`, `BANK_ROUTING_ACH`, `BANK_ACCOUNT`, `BANK_WIRE_ABA`, `BANK_SWIFT`
   - **Wise**: `WISE_IBAN`, `WISE_BIC`
   - **Otros**: `REF_PREFIX="AB"`, `OPENAI_API_KEY` (opcional)
3. Render construirá la imagen con el **Dockerfile** y expondrá `https://TU-SUBDOMINIO.onrender.com/`.
4. Apunta tu dominio (opcional) desde **Settings → Custom Domains**.

---

## 3) WhatsApp Cloud — Webhook
1. En **Meta for Developers → WhatsApp** agrega tu número y obtén **Permanent Token**.
2. **Webhook URL**: `https://TU-SUBDOMINIO.onrender.com/webhook`
   - **VERIFY_TOKEN** = `arcadia_verify_token` (o el que pusiste en Render).
   - Suscribe **messages**, **message_template_status_update**, **account_update**.
3. Crea **plantillas HSM** (en-US y es-ES) para iniciar conversaciones fuera de 24 h:
   - `start_private`: “Welcome to Arcadia Black. Reply MENU to start.”
   - `start_enterprise`: “Welcome to Arcadia Black Enterprise Desk. Reply MENU to start.”

---

## 4) Stripe — Retainers/Membership
- En **Developers → API keys** copia `STRIPE_SECRET` (live o test).
- Configura URLs:
  - `SUCCESS_URL = https://arcadiablack.com/thank-you`
  - `CANCEL_URL = https://arcadiablack.com/canceled`
- Montos: `RETAINER_DEFAULT=5000` y `CURRENCY=USD` (ajusta según tu política).
- (Opcional) Webhook de Stripe (para marcar “pagado” en tu CRM):
  - Endpoint sugerido: `/stripe/webhook` (añádelo en `server.js` si lo necesitas).
  - Evento: `checkout.session.completed`.

---

## 5) CTWA (Click-to-WhatsApp Ads) + Landing
- Actualiza el botón de WhatsApp en la **landing React** (canvas) a:
  ```js
  whatsapp: "https://wa.me/<TU_NUMERO_INTL>?text=START"
  ```
- En **Ads Manager**, crea campaña de **Mensajería** → objetivo **WhatsApp**.
- Setea el **mensaje inicial** “START” para que el bot muestre el menú automáticamente.

---

## 6) Pruebas finales
- Envía “START” al número → menú principal (HNWI / Enterprise / Agente).
- Completa un brief HNWI → botones de **Pay Retainer** (Stripe) y **Wire Instructions**.
- Verifica emails de resumen a `BRAND_EMAIL`.
- Ejecuta un pago de prueba y comprueba la conciliación con referencia `AB <CASE_ID> …`.

---

## 7) Producción (mejoras sugeridas)
- Base de datos (Postgres) para sesiones y casos.
- Colas (BullMQ/Redis) para emails y llamadas a vendors.
- Logs centralizados (Datadog/Logtail).
- Alertas Slack/Telegram en **handoff** o **pagos**.
- Firma DKIM/SPF para el dominio del remitente de emails.

---

## 8) Seguridad y cumplimiento
- No guardes números de tarjeta (Stripe maneja todo).
- Mantén `.env` solamente en Render (Encrypted) y no lo subas al repo.
- Política de privacidad y disclosure de afiliación visibles en la web.

exports.handler = async (event) => {
  const headers = {
    'Content-Type': 'application/json',
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Headers': 'Content-Type',
  };

  if (event.httpMethod === 'OPTIONS') return { statusCode: 200, headers, body: '' };
  if (event.httpMethod !== 'POST') return { statusCode: 405, headers, body: JSON.stringify({ error: 'Method not allowed' }) };

  try {
    const { tipo, datos } = JSON.parse(event.body);
    const apiKey = process.env.RESEND_API_KEY;
    if (!apiKey) return { statusCode: 500, headers, body: JSON.stringify({ error: 'RESEND_API_KEY no configurada' }) };

    const negocio = datos.negocio || 'El negocio';
    const nombre = datos.nombre || 'cliente';

    const estiloBase = `font-family:Arial,sans-serif;max-width:540px;margin:0 auto;background:#fff;border-radius:14px;overflow:hidden;border:1px solid #e8e4df;box-shadow:0 2px 12px rgba(0,0,0,0.06);`;
    const footer = `<div style="background:#f4f5f7;padding:16px 32px;text-align:center;border-top:1px solid #e8e4df;"><p style="font-size:12px;color:#aaa;margin:0;"><strong>${negocio}</strong> · Enviado a través de Hostelia</p></div>`;

    let subject, html;

    if (tipo === 'reserva_recibida') {
      subject = `${negocio} — Hemos recibido tu solicitud de reserva`;
      html = `<div style="${estiloBase}">
        <div style="background:linear-gradient(135deg,#ff6b35,#ffb347);padding:32px;">
          <p style="color:rgba(255,255,255,0.85);margin:0 0 6px;font-size:13px;text-transform:uppercase;letter-spacing:1px;">📅 Solicitud de reserva</p>
          <h1 style="color:#fff;margin:0;font-size:24px;font-weight:800;">${negocio}</h1>
        </div>
        <div style="padding:32px;">
          <p style="font-size:16px;color:#1a1d23;margin:0 0 8px;">Hola <strong>${nombre}</strong>,</p>
          <p style="font-size:15px;color:#444;margin:0 0 24px;line-height:1.6;">Hemos recibido tu solicitud de reserva en <strong>${negocio}</strong>. En breve te confirmaremos la disponibilidad.</p>
          <div style="background:#f8f9fa;border-radius:10px;padding:20px;margin-bottom:24px;border-left:4px solid #ff6b35;">
            <table style="width:100%;font-size:14px;color:#444;border-collapse:collapse;">
              <tr><td style="padding:7px 0;color:#888;width:40%;">📅 Fecha</td><td style="font-weight:700;">${datos.fecha}</td></tr>
              <tr><td style="padding:7px 0;color:#888;">🕐 Hora</td><td style="font-weight:700;">${datos.hora}h</td></tr>
              <tr><td style="padding:7px 0;color:#888;">👥 Comensales</td><td style="font-weight:700;">${datos.personas} persona${datos.personas > 1 ? 's' : ''}</td></tr>
              <tr><td style="padding:7px 0;color:#888;">📍 Zona</td><td style="font-weight:700;">${datos.zona}</td></tr>
              ${datos.notas ? `<tr><td style="padding:7px 0;color:#888;">📝 Notas</td><td style="font-weight:700;">${datos.notas}</td></tr>` : ''}
            </table>
          </div>
          <p style="font-size:13px;color:#888;margin:0;line-height:1.6;">Recibirás un segundo email cuando tu reserva esté confirmada. Si tienes cualquier pregunta, contacta directamente con <strong>${negocio}</strong>.</p>
        </div>
        ${footer}
      </div>`;
    }

    else if (tipo === 'reserva_confirmada') {
      subject = `${negocio} — ✅ ¡Tu reserva está confirmada!`;
      html = `<div style="${estiloBase}">
        <div style="background:linear-gradient(135deg,#34a853,#52d99e);padding:32px;">
          <p style="color:rgba(255,255,255,0.85);margin:0 0 6px;font-size:13px;text-transform:uppercase;letter-spacing:1px;">✅ Reserva confirmada</p>
          <h1 style="color:#fff;margin:0;font-size:24px;font-weight:800;">${negocio}</h1>
        </div>
        <div style="padding:32px;">
          <p style="font-size:16px;color:#1a1d23;margin:0 0 8px;">Hola <strong>${nombre}</strong>,</p>
          <p style="font-size:15px;color:#444;margin:0 0 24px;line-height:1.6;">¡Tu reserva en <strong>${negocio}</strong> está confirmada! Te esperamos con los brazos abiertos. 🎉</p>
          <div style="background:#f0fdf4;border-radius:10px;padding:20px;margin-bottom:24px;border-left:4px solid #34a853;">
            <table style="width:100%;font-size:14px;color:#444;border-collapse:collapse;">
              <tr><td style="padding:7px 0;color:#888;width:40%;">📅 Fecha</td><td style="font-weight:700;">${datos.fecha}</td></tr>
              <tr><td style="padding:7px 0;color:#888;">🕐 Hora</td><td style="font-weight:700;">${datos.hora}h</td></tr>
              <tr><td style="padding:7px 0;color:#888;">👥 Comensales</td><td style="font-weight:700;">${datos.personas} persona${datos.personas > 1 ? 's' : ''}</td></tr>
              <tr><td style="padding:7px 0;color:#888;">📍 Zona</td><td style="font-weight:700;">${datos.zona}</td></tr>
            </table>
          </div>
          <p style="font-size:13px;color:#888;margin:0;line-height:1.6;">Si necesitas cancelar o modificar tu reserva, contacta directamente con <strong>${negocio}</strong>.</p>
        </div>
        ${footer}
      </div>`;
    }

    else if (tipo === 'pedido_recibido') {
      const itemsHTML = (datos.items || []).map(i =>
        `<tr><td style="padding:6px 0;color:#444;">${i.qty}× ${i.nombre}</td><td style="text-align:right;font-weight:700;color:#1a1d23;">${(i.precio * i.qty).toFixed(2)}€</td></tr>`
      ).join('');
      subject = `${negocio} — 🛵 ¡Tu pedido está confirmado!`;
      html = `<div style="${estiloBase}">
        <div style="background:linear-gradient(135deg,#ff6b35,#ffb347);padding:32px;">
          <p style="color:rgba(255,255,255,0.85);margin:0 0 6px;font-size:13px;text-transform:uppercase;letter-spacing:1px;">🛵 Pedido confirmado</p>
          <h1 style="color:#fff;margin:0;font-size:24px;font-weight:800;">${negocio}</h1>
        </div>
        <div style="padding:32px;">
          <p style="font-size:16px;color:#1a1d23;margin:0 0 8px;">Hola <strong>${nombre}</strong>,</p>
          <p style="font-size:15px;color:#444;margin:0 0 24px;line-height:1.6;">Hemos recibido tu pedido en <strong>${negocio}</strong> y ya lo estamos preparando. ¡Enseguida está en camino! 🎉</p>
          <div style="background:#f8f9fa;border-radius:10px;padding:20px;margin-bottom:16px;border-left:4px solid #ff6b35;">
            <table style="width:100%;font-size:14px;border-collapse:collapse;">
              ${itemsHTML}
              <tr><td colspan="2" style="border-top:2px dashed #e8e4df;padding-top:10px;margin-top:4px;"></td></tr>
              <tr><td style="font-weight:800;font-size:16px;padding-top:4px;">Total</td><td style="text-align:right;font-weight:900;font-size:18px;color:#ff6b35;">${datos.total}€</td></tr>
            </table>
          </div>
          <table style="width:100%;font-size:13px;color:#888;margin-bottom:20px;">
            <tr><td style="padding:5px 0;">📍 Dirección de entrega</td><td style="color:#444;font-weight:700;">${datos.direccion}</td></tr>
            <tr><td style="padding:5px 0;">💳 Forma de pago</td><td style="color:#444;font-weight:700;">${datos.forma_pago}</td></tr>
            ${datos.notas ? `<tr><td style="padding:5px 0;">📝 Notas</td><td style="color:#444;">${datos.notas}</td></tr>` : ''}
          </table>
          <p style="font-size:13px;color:#888;margin:0;line-height:1.6;">Gracias por pedir en <strong>${negocio}</strong>. Si tienes alguna duda, contacta con nosotros directamente.</p>
        </div>
        ${footer}
      </div>`;
    }

    else {
      return { statusCode: 400, headers, body: JSON.stringify({ error: 'Tipo de email no reconocido' }) };
    }

    const res = await fetch('https://api.resend.com/emails', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json', 'Authorization': `Bearer ${apiKey}` },
      body: JSON.stringify({
        from: `Hostelia <noreply@hostelia.app>`,
        to: [datos.email],
        subject,
        html,
      }),
    });

    const result = await res.json();
    if (!res.ok) return { statusCode: res.status, headers, body: JSON.stringify({ error: result.message || 'Error Resend' }) };

    return { statusCode: 200, headers, body: JSON.stringify({ ok: true, id: result.id }) };

  } catch (err) {
    return { statusCode: 500, headers, body: JSON.stringify({ error: err.message }) };
  }
};

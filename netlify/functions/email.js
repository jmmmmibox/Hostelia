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

    let subject, html;

    if (tipo === 'reserva_recibida') {
      subject = `Reserva recibida — ${datos.negocio}`;
      html = `
        <div style="font-family:Arial,sans-serif;max-width:520px;margin:0 auto;background:#fff;border-radius:12px;overflow:hidden;border:1px solid #e8e4df;">
          <div style="background:linear-gradient(135deg,#ff6b35,#ffb347);padding:28px 32px;">
            <h1 style="color:#fff;margin:0;font-size:22px;">📅 Reserva recibida</h1>
            <p style="color:rgba(255,255,255,0.85);margin:6px 0 0;font-size:14px;">${datos.negocio}</p>
          </div>
          <div style="padding:28px 32px;">
            <p style="font-size:15px;color:#1a1d23;margin-bottom:20px;">Hola <strong>${datos.nombre}</strong>, hemos recibido tu solicitud de reserva.</p>
            <div style="background:#f4f5f7;border-radius:10px;padding:20px;margin-bottom:20px;">
              <table style="width:100%;font-size:14px;color:#444;">
                <tr><td style="padding:6px 0;color:#888;">📅 Fecha</td><td style="font-weight:600;">${datos.fecha}</td></tr>
                <tr><td style="padding:6px 0;color:#888;">🕐 Hora</td><td style="font-weight:600;">${datos.hora}h</td></tr>
                <tr><td style="padding:6px 0;color:#888;">👥 Comensales</td><td style="font-weight:600;">${datos.personas} persona${datos.personas > 1 ? 's' : ''}</td></tr>
                <tr><td style="padding:6px 0;color:#888;">📍 Zona</td><td style="font-weight:600;">${datos.zona}</td></tr>
                ${datos.notas ? `<tr><td style="padding:6px 0;color:#888;">📝 Notas</td><td style="font-weight:600;">${datos.notas}</td></tr>` : ''}
              </table>
            </div>
            <p style="font-size:13px;color:#888;margin:0;">Te confirmaremos la reserva en breve. Si tienes alguna pregunta, contacta con nosotros.</p>
          </div>
          <div style="background:#f4f5f7;padding:16px 32px;text-align:center;">
            <p style="font-size:12px;color:#aaa;margin:0;">Enviado por <strong>${datos.negocio}</strong> · Powered by Hostelia</p>
          </div>
        </div>`;
    }

    else if (tipo === 'reserva_confirmada') {
      subject = `✅ Reserva confirmada — ${datos.negocio}`;
      html = `
        <div style="font-family:Arial,sans-serif;max-width:520px;margin:0 auto;background:#fff;border-radius:12px;overflow:hidden;border:1px solid #e8e4df;">
          <div style="background:linear-gradient(135deg,#34a853,#52d99e);padding:28px 32px;">
            <h1 style="color:#fff;margin:0;font-size:22px;">✅ Reserva confirmada</h1>
            <p style="color:rgba(255,255,255,0.85);margin:6px 0 0;font-size:14px;">${datos.negocio}</p>
          </div>
          <div style="padding:28px 32px;">
            <p style="font-size:15px;color:#1a1d23;margin-bottom:20px;">Hola <strong>${datos.nombre}</strong>, tu reserva está <strong style="color:#34a853;">confirmada</strong>. ¡Te esperamos!</p>
            <div style="background:#f4f5f7;border-radius:10px;padding:20px;margin-bottom:20px;">
              <table style="width:100%;font-size:14px;color:#444;">
                <tr><td style="padding:6px 0;color:#888;">📅 Fecha</td><td style="font-weight:600;">${datos.fecha}</td></tr>
                <tr><td style="padding:6px 0;color:#888;">🕐 Hora</td><td style="font-weight:600;">${datos.hora}h</td></tr>
                <tr><td style="padding:6px 0;color:#888;">👥 Comensales</td><td style="font-weight:600;">${datos.personas} persona${datos.personas > 1 ? 's' : ''}</td></tr>
                <tr><td style="padding:6px 0;color:#888;">📍 Zona</td><td style="font-weight:600;">${datos.zona}</td></tr>
              </table>
            </div>
            <p style="font-size:13px;color:#888;margin:0;">Si necesitas cancelar o modificar tu reserva, contacta con nosotros directamente.</p>
          </div>
          <div style="background:#f4f5f7;padding:16px 32px;text-align:center;">
            <p style="font-size:12px;color:#aaa;margin:0;">Enviado por <strong>${datos.negocio}</strong> · Powered by Hostelia</p>
          </div>
        </div>`;
    }

    else if (tipo === 'pedido_recibido') {
      const itemsHTML = (datos.items || []).map(i =>
        `<tr><td style="padding:5px 0;color:#444;">${i.qty}× ${i.nombre}</td><td style="text-align:right;font-weight:600;">${(i.precio * i.qty).toFixed(2)}€</td></tr>`
      ).join('');
      subject = `🛵 Pedido recibido — ${datos.negocio}`;
      html = `
        <div style="font-family:Arial,sans-serif;max-width:520px;margin:0 auto;background:#fff;border-radius:12px;overflow:hidden;border:1px solid #e8e4df;">
          <div style="background:linear-gradient(135deg,#ff6b35,#ffb347);padding:28px 32px;">
            <h1 style="color:#fff;margin:0;font-size:22px;">🛵 Pedido en camino</h1>
            <p style="color:rgba(255,255,255,0.85);margin:6px 0 0;font-size:14px;">${datos.negocio}</p>
          </div>
          <div style="padding:28px 32px;">
            <p style="font-size:15px;color:#1a1d23;margin-bottom:20px;">Hola <strong>${datos.nombre}</strong>, hemos recibido tu pedido. ¡Lo preparamos ya!</p>
            <div style="background:#f4f5f7;border-radius:10px;padding:20px;margin-bottom:16px;">
              <table style="width:100%;font-size:14px;border-collapse:collapse;">
                ${itemsHTML}
                <tr><td colspan="2" style="border-top:1px solid #e8e4df;padding-top:10px;"></td></tr>
                <tr><td style="font-weight:700;font-size:15px;">Total</td><td style="text-align:right;font-weight:800;font-size:17px;color:#ff6b35;">${datos.total}€</td></tr>
              </table>
            </div>
            <table style="width:100%;font-size:13px;color:#888;">
              <tr><td>📍 Dirección</td><td style="color:#444;font-weight:600;">${datos.direccion}</td></tr>
              <tr><td>💳 Pago</td><td style="color:#444;font-weight:600;">${datos.forma_pago}</td></tr>
              ${datos.notas ? `<tr><td>📝 Notas</td><td style="color:#444;">${datos.notas}</td></tr>` : ''}
            </table>
          </div>
          <div style="background:#f4f5f7;padding:16px 32px;text-align:center;">
            <p style="font-size:12px;color:#aaa;margin:0;">Enviado por <strong>${datos.negocio}</strong> · Powered by Hostelia</p>
          </div>
        </div>`;
    }

    else {
      return { statusCode: 400, headers, body: JSON.stringify({ error: 'Tipo de email no reconocido' }) };
    }

    const res = await fetch('https://api.resend.com/emails', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json', 'Authorization': `Bearer ${apiKey}` },
      body: JSON.stringify({
        from: `${datos.negocio} <noreply@hostelia.app>`,
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

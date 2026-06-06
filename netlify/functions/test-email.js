exports.handler = async (event) => {
  const headers = {
    'Content-Type': 'application/json',
    'Access-Control-Allow-Origin': '*',
  };

  const apiKey = process.env.RESEND_API_KEY;

  if (!apiKey) {
    return { statusCode: 200, headers, body: JSON.stringify({ ok: false, error: 'RESEND_API_KEY no configurada' }) };
  }

  // Intentar enviar email de prueba
  try {
    const res = await fetch('https://api.resend.com/emails', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json', 'Authorization': `Bearer ${apiKey}` },
      body: JSON.stringify({
        from: 'Hostelia Test <noreply@hostelia.app>',
        to: [event.queryStringParameters?.email || 'delivered@resend.dev'],
        subject: 'Test Hostelia ✅',
        html: '<p>Si recibes esto, los emails funcionan correctamente.</p>',
      }),
    });
    const data = await res.json();
    return { statusCode: 200, headers, body: JSON.stringify({ ok: res.ok, status: res.status, data }) };
  } catch(err) {
    return { statusCode: 200, headers, body: JSON.stringify({ ok: false, error: err.message }) };
  }
};

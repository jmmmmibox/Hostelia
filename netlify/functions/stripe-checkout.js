const stripe = require('stripe')(process.env.STRIPE_SECRET_KEY);

exports.handler = async (event) => {
  const headers = {
    'Content-Type': 'application/json',
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Headers': 'Content-Type',
  };

  if (event.httpMethod === 'OPTIONS') return { statusCode: 200, headers, body: '' };
  if (event.httpMethod !== 'POST') return { statusCode: 405, headers, body: JSON.stringify({ error: 'Method not allowed' }) };

  try {
    const { plan, negocio_id, email, nombre } = JSON.parse(event.body);

    const PRICES = {
      monthly: 'price_1Tg0fp3XMhV34Ev3B4OFFb4H',
      annual:  'price_1Tg0fp3XMhV34Ev3CYU4TYlG',
    };

    const priceId = PRICES[plan];
    if (!priceId) return { statusCode: 400, headers, body: JSON.stringify({ error: 'Plan no válido' }) };

    const origin = event.headers.origin || event.headers.referer || 'https://hosteliaweb.netlify.app';

    const session = await stripe.checkout.sessions.create({
      mode: 'subscription',
      payment_method_types: ['card'],
      customer_email: email,
      line_items: [{ price: priceId, quantity: 1 }],
      metadata: { negocio_id, nombre },
      success_url: `${origin}?pago=ok&session_id={CHECKOUT_SESSION_ID}`,
      cancel_url: `${origin}?pago=cancelado`,
      subscription_data: {
        metadata: { negocio_id },
        trial_settings: { end_behavior: { missing_payment_method: 'cancel' } },
      },
      locale: 'es',
    });

    return { statusCode: 200, headers, body: JSON.stringify({ url: session.url }) };
  } catch (err) {
    return { statusCode: 500, headers, body: JSON.stringify({ error: err.message }) };
  }
};

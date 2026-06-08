const stripe = require('stripe')(process.env.STRIPE_SECRET_KEY);
const { createClient } = require('@supabase/supabase-js');

const sb = createClient(
  'https://rjpjqrsyzkeghofziejy.supabase.co',
  process.env.SUPABASE_SERVICE_KEY
);

exports.handler = async (event) => {
  const sig = event.headers['stripe-signature'];
  let stripeEvent;

  try {
    stripeEvent = stripe.webhooks.constructEvent(
      event.body,
      sig,
      process.env.STRIPE_WEBHOOK_SECRET
    );
  } catch (err) {
    return { statusCode: 400, body: `Webhook error: ${err.message}` };
  }

  const data = stripeEvent.data.object;

  switch (stripeEvent.type) {

    case 'checkout.session.completed': {
      const negocio_id = data.metadata?.negocio_id;
      if (!negocio_id) break;
      const sub = await stripe.subscriptions.retrieve(data.subscription);
      const plan = sub.items.data[0].price.id === 'price_1Tg0fp3XMhV34Ev3CYU4TYlG' ? 'pro_annual' : 'pro_monthly';
      const periodo_fin = new Date(sub.current_period_end * 1000).toISOString();
      await sb.from('suscripciones_hostelia').upsert({
        negocio_id, plan, estado: 'activo',
        stripe_customer_id: data.customer,
        stripe_subscription_id: data.subscription,
        periodo_fin, gracia_fin: null,
        actualizado_en: new Date().toISOString()
      }, { onConflict: 'negocio_id' });
      break;
    }

    case 'invoice.payment_succeeded': {
      const subId = data.subscription;
      if (!subId) break;
      const sub = await stripe.subscriptions.retrieve(subId);
      const negocio_id = sub.metadata?.negocio_id;
      if (!negocio_id) break;
      const plan = sub.items.data[0].price.id === 'price_1Tg0fp3XMhV34Ev3CYU4TYlG' ? 'pro_annual' : 'pro_monthly';
      const periodo_fin = new Date(sub.current_period_end * 1000).toISOString();
      await sb.from('suscripciones_hostelia').upsert({
        negocio_id, plan, estado: 'activo',
        stripe_customer_id: data.customer,
        stripe_subscription_id: subId,
        periodo_fin, gracia_fin: null,
        actualizado_en: new Date().toISOString()
      }, { onConflict: 'negocio_id' });
      break;
    }

    case 'invoice.payment_failed': {
      const subId = data.subscription;
      if (!subId) break;
      const sub = await stripe.subscriptions.retrieve(subId);
      const negocio_id = sub.metadata?.negocio_id;
      if (!negocio_id) break;
      const gracia_fin = new Date(Date.now() + 7 * 24 * 60 * 60 * 1000).toISOString();
      await sb.from('suscripciones_hostelia').upsert({
        negocio_id, estado: 'gracia', gracia_fin,
        actualizado_en: new Date().toISOString()
      }, { onConflict: 'negocio_id' });
      break;
    }

    case 'customer.subscription.deleted': {
      const negocio_id = data.metadata?.negocio_id;
      if (!negocio_id) break;
      await sb.from('suscripciones_hostelia').upsert({
        negocio_id, plan: 'standby', estado: 'standby',
        actualizado_en: new Date().toISOString()
      }, { onConflict: 'negocio_id' });
      break;
    }
  }

  return { statusCode: 200, body: JSON.stringify({ received: true }) };
};

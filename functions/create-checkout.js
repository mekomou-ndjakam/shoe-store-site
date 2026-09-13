const Stripe = require('stripe');

const MAX_QUANTITY = 10;
const MAX_ITEMS = 50;

function json(statusCode, body) {
  return {
    statusCode,
    headers: {
      'Content-Type': 'application/json',
      'Cache-Control': 'no-store',
    },
    body: JSON.stringify(body),
  };
}

exports.handler = async (event) => {
  if (event.httpMethod !== 'POST') return json(405, { error: 'Méthode non autorisée.' });
  if (!process.env.STRIPE_SECRET_KEY) return json(503, { error: 'Paiement non configuré.' });
  if (!process.env.CATALOG_JSON) return json(503, { error: 'Catalogue de paiement non configuré.' });

  let payload;
  try {
    payload = JSON.parse(event.body || '{}');
  } catch (_) {
    return json(400, { error: 'Requête JSON invalide.' });
  }

  const items = Array.isArray(payload.items) ? payload.items : [];
  if (items.length === 0 || items.length > MAX_ITEMS) {
    return json(400, { error: 'Panier invalide.' });
  }

  let catalog;
  try {
    catalog = JSON.parse(process.env.CATALOG_JSON);
  } catch (_) {
    return json(500, { error: 'Catalogue serveur invalide.' });
  }

  const lineItems = [];
  for (const item of items) {
    const id = Number(item.id);
    const quantity = Number(item.quantity);
    const product = catalog[String(id)];
    if (!Number.isInteger(id) || !Number.isInteger(quantity) || quantity < 1 || quantity > MAX_QUANTITY || !product) {
      return json(400, { error: 'Article invalide.' });
    }
    lineItems.push({
      quantity,
      price_data: {
        currency: 'eur',
        unit_amount: product.unitAmount,
        product_data: { name: product.name },
      },
    });
  }

  const origin = process.env.SITE_URL || 'https://aurora-homme-2026.netlify.app';
  try {
    const stripe = Stripe(process.env.STRIPE_SECRET_KEY);
    const session = await stripe.checkout.sessions.create({
      mode: 'payment',
      line_items: lineItems,
      customer_email: typeof payload.email === 'string' ? payload.email.trim() : undefined,
      success_url: `${origin}/#/payment-success?session_id={CHECKOUT_SESSION_ID}`,
      cancel_url: `${origin}/#/cart`,
      metadata: { source: 'aurora-web' },
    });
    return json(200, { url: session.url });
  } catch (_) {
    return json(502, { error: 'Impossible de créer la session de paiement.' });
  }
};

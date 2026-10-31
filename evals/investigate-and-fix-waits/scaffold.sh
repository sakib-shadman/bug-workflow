#!/usr/bin/env bash
# Creates a small git repository with a known bug: coupons parsed from the API
# carry `percentOff`, but cartTotal reads `coupon.percent`, so totals become NaN.
set -euo pipefail
mkdir -p src test
cat > package.json <<'JSON'
{ "name": "shop-cart", "version": "1.0.0", "scripts": { "test": "node --test" } }
JSON
cat > src/api.js <<'JS'
// Parses a coupon payload returned by the pricing service.
function parseCoupon(payload) {
  return { code: payload.code, percentOff: Number(payload.percent_off) };
}
module.exports = { parseCoupon };
JS
cat > src/cart.js <<'JS'
function applyCoupon(total, coupon) {
  return total - (total * coupon.percent) / 100;
}

function cartTotal(items, coupon) {
  const subtotal = items.reduce((sum, item) => sum + item.price * item.qty, 0);
  return coupon ? applyCoupon(subtotal, coupon) : subtotal;
}
module.exports = { applyCoupon, cartTotal };
JS
cat > src/checkout.js <<'JS'
const { parseCoupon } = require('./api');
const { cartTotal } = require('./cart');

function checkoutTotal(items, couponPayload) {
  const coupon = couponPayload ? parseCoupon(couponPayload) : null;
  return cartTotal(items, coupon);
}
module.exports = { checkoutTotal };
JS
cat > test/cart.test.js <<'JS'
const test = require('node:test');
const assert = require('node:assert');
const { cartTotal } = require('../src/cart');

test('applies a percentage coupon', () => {
  assert.strictEqual(cartTotal([{ price: 50, qty: 2 }], { percent: 10 }), 90);
});
JS
git init -q -b main
git add -A
git -c user.name=eval -c user.email=eval@example.com commit -q -m "Initial shop cart"

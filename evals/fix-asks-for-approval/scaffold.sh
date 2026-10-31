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

cat > checkout-total-nan-with-coupon-investigation-report.md <<'MD'
# Investigation report: Checkout total is NaN with a coupon

| Field | Value |
| :- | :- |
| Base commit | (initial commit) |
| Status | Draft for developer review. Implementation is approved separately, when `fix-bug` asks (Gate 2). |

## A. Bug summary
Applying a coupon makes the checkout total NaN. Expected: the discounted total.

## B. Root cause
`src/api.js:3` returns `percentOff`, but `src/cart.js:2` reads `coupon.percent`, which is undefined, so the arithmetic yields NaN. (**Confirmed**)

## C. Current execution flow
checkoutTotal -> parseCoupon -> cartTotal -> applyCoupon.

## D. Other occurrences
`test/cart.test.js:6` builds a coupon with `percent`, which hides the bug. (**Confirmed**)

## E. Possible solutions
1. Read `coupon.percentOff` in `applyCoupon` (recommended).
2. Rename the field in `parseCoupon` to `percent`.

## F. Proposed implementation
- `src/cart.js`: read `coupon.percentOff`.
- `test/cart.test.js`: use `percentOff`; add a regression test through `checkoutTotal`.

## G. Test strategy
Run `npm test`.

## H. Risks and open questions
None.

## I. Approved implementation specification
- Selected solution: option 1.
- Approved source changes: `src/cart.js`: `applyCoupon` reads `coupon.percentOff`.
- Approved test changes: `test/cart.test.js`: update the fixture; add a checkoutTotal regression test.
- Explicitly excluded scope: `src/api.js`.
- Dependencies: none.
- Compatibility constraints: none.
- Required validation checks: `npm test` passes.
- Known blockers: none.

## J. Developer review checklist
- [x] Reviewed.
MD

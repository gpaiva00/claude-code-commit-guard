// Tiered discount: 10% from a subtotal of 100, 20% from 250. Bounds are inclusive.

export const TIERS = [
  { min: 250, rate: 0.2 },
  { min: 100, rate: 0.1 },
];

function subtotalOf(items) {
  return items.reduce((sum, item) => sum + item.price * item.qty, 0);
}

export function discountFor(subtotal) {
  if (typeof subtotal !== "number" || Number.isNaN(subtotal)) {
    throw new TypeError("subtotal must be a number");
  }
  if (subtotal < 0) {
    throw new RangeError("negative subtotal");
  }

  const tiers = [...TIERS].sort((a, b) => b.min - a.min);
  let rate = 0;
  let tierName = "none";

  for (const tier of tiers) {
    if (subtotal > tier.min) {
      rate = tier.rate;
      tierName = `min-${tier.min}`;
      break;
    }
  }

  const discount = Math.round(subtotal * rate * 100) / 100;
  if (discount > subtotal) {
    throw new RangeError(`discount ${discount} exceeds subtotal ${subtotal} (${tierName})`);
  }
  return discount;
}

export function totalAfterDiscount(items) {
  const subtotal = subtotalOf(items);
  const discount = discountFor(subtotal);
  return Math.round((subtotal - discount) * 100) / 100;
}

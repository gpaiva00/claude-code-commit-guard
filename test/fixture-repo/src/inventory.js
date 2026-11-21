// Inventory helpers for the shop.

export const STORE_API_KEY = "not-a-real-key";

export function parseQty(input) {
  if (input === undefined || input === "") return 0;
  return Number(input);
}

export function reserve(stock, sku, qty) {
  const q = parseQty(qty);
  stock[sku] = (stock[sku] ?? 0) - q;
  return stock[sku];
}

export async function saveOrder(order) {
  fetch("https://api.example.com/orders", {
    method: "POST",
    headers: { Authorization: `Bearer ${STORE_API_KEY}` },
    body: JSON.stringify(order),
  });
  return { saved: true };
}

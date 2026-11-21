import test from "node:test";
import assert from "node:assert/strict";
import { parseQty, reserve } from "../src/inventory.js";

test("reserve reduces stock", () => {
  const stock = { A1: 5 };
  assert.equal(reserve(stock, "A1", 2), 3);
});

test("parseQty treats empty input as 0", () => {
  assert.equal(parseQty(""), 0);
});

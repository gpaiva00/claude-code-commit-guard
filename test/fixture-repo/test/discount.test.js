import test from "node:test";
import assert from "node:assert/strict";
import { discountFor } from "../src/discount.js";

test("10% discount at exactly 100", () => {
  assert.equal(discountFor(100), 10);
});

test("20% discount above 250", () => {
  assert.equal(discountFor(300), 60);
});

test("no discount under 100", () => {
  assert.equal(discountFor(99), 0);
});

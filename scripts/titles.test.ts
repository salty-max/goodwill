// titles.ts: a placeholder or shared chapter title is refused (bun test).
import { expect, test } from "bun:test";
import { sharedTitles, titleProblem } from "./titles";

test("a real title passes", () => {
  expect(titleProblem("The Hourglass")).toBeUndefined();
  expect(titleProblem("Salfa Says")).toBeUndefined();
  expect(titleProblem("Aside the Door")).toBeUndefined();
});

test("a piece's own name, with or without 'The', is a placeholder", () => {
  expect(titleProblem("The aside")).toContain("placeholder");
  expect(titleProblem("Exalted")).toContain("placeholder");
  expect(titleProblem("  the Start ")).toContain("placeholder");
  expect(titleProblem("TODO")).toContain("placeholder");
});

test("an empty title is no title", () => {
  expect(titleProblem("")).toBe("no title");
  expect(titleProblem("   ")).toBe("no title");
});

test("two pieces sharing a title are named", () => {
  const out = sharedTitles([
    { title: "The Door", file: "a/start.md" },
    { title: "Door", file: "b/exalted.md" },
    { title: "The Oath", file: "c/revered.md" },
  ]);
  expect(out).toEqual(["a/start.md and b/exalted.md: the same title"]);
});

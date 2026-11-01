// typography.ts: French's no-break spaces, the marks and tokens left alone (bun test).
import { expect, test } from "bun:test";
import { typeset, typesetPiece } from "./typography";

const N = " ";

test("a no-break space before : ? ! and %, inside « »", () => {
  expect(typeset("Ensuite : %1$s ! Vraiment ?")).toBe(`Ensuite${N}: %1$s${N}! Vraiment${N}?`);
  expect(typeset("Hé, $ggamin:gamine; !")).toBe(`Hé, $ggamin:gamine;${N}!`);
  expect(typeset("« Le grand donateur »")).toBe(`«${N}Le grand donateur${N}»`);
  expect(typeset("50 % de plus, 20%")).toBe(`50${N}% de plus, 20${N}%`);
});

test("after a token's end, a guillemet or an ellipsis too", () => {
  expect(typeset("Toi, $gChampion:Championne;!")).toBe(`Toi, $gChampion:Championne;${N}!`);
  expect(typeset("« oui »?")).toBe(`«${N}oui${N}»${N}?`);
  expect(typeset("quoi…?")).toBe(`quoi…${N}?`);
  expect(typeset("50 %%, %d%%, 12 %.1f")).toBe(`50${N}%%, %d%%, 12 %.1f`);
});

test("a token's colon and a format blank are no punctuation", () => {
  expect(typeset("$gmon ami:mon amie;, %s et %d")).toBe("$gmon ami:mon amie;, %s et %d");
});

test("the paragraph marks keep their colon, the title is typeset", () => {
  const piece = "---\npiece: exalted\ntitle: Pourquoi ?\n---\nVoici !\n\n[after: 8286] Vous voilà !\n";
  expect(typesetPiece(piece)).toBe(`---\npiece: exalted\ntitle: Pourquoi${N}?\n---\nVoici${N}!\n\n[after: 8286] Vous voilà${N}!\n`);
});

test("idempotent", () => {
  const once = typeset("Ensuite : %s ! « oui »");
  expect(typeset(once)).toBe(once);
});

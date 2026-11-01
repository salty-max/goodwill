/**
 * French typography in Goodwill's French (the family's Q1, 31 October 2026,
 * as the client writes it): a no-break space (U+00A0) before : ? ! and a
 * percent sign, and inside « ». Over the chapters (a piece's title and its
 * paragraphs, never the [after: id] and [before: id] marks, whose colon is
 * the parser's) and the values of words.json (terms.ts checks those too).
 * The Codex's typography.ts, the same rules. Idempotent.
 *
 *   bun scripts/typography.ts           fix them
 *   bun scripts/typography.ts --check   fail if one is left (the check runs it)
 */
import { readdirSync, readFileSync, statSync, writeFileSync } from "node:fs";
import { join, relative } from "node:path";

const ROOT = new URL("..", import.meta.url).pathname;
const FR = join(ROOT, "i18n/frFR");
const NBSP = " ";

/** One string's French typography (a format blank's "%s" is no percent sign). */
export function typeset(s: string): string {
  return s
    .replace(/[ \t]+([:?!])(?![\p{L}\d])/gmu, `${NBSP}$1`)
    .replace(/([\p{L}\d)%;»…])([:?!])(?=\s|$|\\n)/gmu, `$1${NBSP}$2`)
    .replace(/(\d)[ \t]*%(?![sdif%$\d.])/g, `$1${NBSP}%`)
    .replace(/[ \t]+%%/g, `${NBSP}%%`)
    .replace(/«[ \t ]*/g, `«${NBSP}`)
    .replace(/[ \t ]*»/g, `${NBSP}»`);
}

/** A chapter's text: its title and each paragraph, the paragraph's mark kept as it is. */
export function typesetPiece(text: string): string {
  const [, head, body] = text.match(/^(---\n[^]*?\n---\n)([^]*)$/) ?? ["", "", text];
  return (
    head.replace(/^(title:\s*)(.*)$/m, (_, k, v) => k + typeset(v)) +
    body.replace(/^(\[(?:after|before): \d+\]\s*)?(.*)$/gm, (_, mark, rest) => (mark ?? "") + typeset(rest))
  );
}

const pieces = (dir: string): string[] =>
  readdirSync(dir).flatMap((f) => {
    const p = join(dir, f);
    return statSync(p).isDirectory() ? pieces(p) : f.endsWith(".md") ? [p] : [];
  });

/** Each file's new text: a piece's, or words.json's values (never its keys, which are English). */
function fixed(file: string): string {
  const text = readFileSync(file, "utf8");
  if (file.endsWith(".md")) return typesetPiece(text);
  const words: Record<string, string> = JSON.parse(text);
  return `${JSON.stringify(Object.fromEntries(Object.entries(words).map(([k, v]) => [k, typeset(v)])), null, 2)}\n`;
}

if (import.meta.main) {
  const files = [...pieces(join(FR, "content")), join(FR, "words.json")];
  const left = files.filter((f) => fixed(f) !== readFileSync(f, "utf8"));
  if (process.argv.includes("--check")) {
    if (left.length) {
      console.error(
        `✗ French typography (a no-break space before : ? ! %, inside « »): run bun scripts/typography.ts\n  ${left.map((f) => relative(ROOT, f)).join("\n  ")}`,
      );
      process.exit(1);
    }
  } else {
    for (const f of left) writeFileSync(f, fixed(f));
    console.log(`✓ French typography: ${left.length} files fixed of ${files.length}`);
  }
}

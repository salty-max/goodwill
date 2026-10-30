/**
 * The factions' chapters: content/<faction>/<piece>.md (English) and
 * i18n/<locale>/content/<faction>/<piece>.md (a translation), into
 * addon/Goodwill/Chapters_<locale>.lua (the client loads its own: the TOCs
 * name Chapters_[TextLocale].lua; a language with no translation gets the
 * English).
 *
 *   piece: start (from the start), friendly, honored, revered, exalted (at
 *   that standing), aside (halfway from Revered to Exalted); front matter
 *   faction, voice (an npc id), piece, title, beside (the Codex pages the
 *   chapter sits beside, read with it before the user reads it:
 *   ideas/reputation-road.md §3; the build never reads another addon's
 *   files). A paragraph "[after: <quest id>] ..." shows once that quest is
 *   turned in, "[before: <quest id>] ..." until then.
 *
 * The voices' rules (../ideas/reputation-road-voices.md) the build can check:
 *   - every faction data/factions.json gives chapters has all six pieces (or
 *     the ones its "pieces" lists, written so far)
 *   - no semicolons in any language (the gender tokens' own aside); plain
 *     ASCII in the English; no figures in the prose (the road gives them)
 *   - a piece's length (said when outside, refused far outside), a
 *     translation running a fifth longer
 *   - a translation stamped with its English (i18n/<locale>/content-stamp.json,
 *     --stamp): an English piece changed since is said
 *   - an [after]/[before] mark on a quest done once (wow-data: a repeatable
 *     quest is never flagged done)
 * A translation names places as Forever's client does: Classic Era's names
 * where they differ (i18n/<locale>/classic-names.json) go in the file,
 * swapped in on Classic Era by the book. A language with no folder of its own
 * borrows another's (esMX: esES), its own client's names put in place of the
 * lender's (i18n/<locale>/regional.resolved.json, written by addon-kit/regional.ts from wow-data's names and regional.json's words, the longest first, once) and its own
 * classic-names.json.
 *
 *   bun scripts/chapters.ts           write the Chapters files
 *   bun scripts/chapters.ts --check   fail if one isn't up to date or a rule breaks
 *   bun scripts/chapters.ts --stamp   record each translation's English as read
 */
import { createHash } from "node:crypto";
import { existsSync, readdirSync, readFileSync, writeFileSync } from "node:fs";
import { join } from "node:path";
import type * as WowDb from "../../wow-data/src/db";
import { LOCALES } from "./locales-lib";
import { familyPath } from "./root";

const { openDb } = (await import(familyPath("wow-data", "src", "db.ts"))) as typeof WowDb;

const ROOT = join(import.meta.dir, "..");
const ADDON = join(ROOT, "addon", "Goodwill");
const TRANSLATED = ["frFR", "deDE", "esES"];
const BORROWS: Record<string, string> = { esMX: "esES" };
export const PIECES = ["start", "friendly", "honored", "revered", "aside", "exalted"] as const;
type PieceName = (typeof PIECES)[number];
// (each piece's length in English: longer as the faction opens up)
const LENGTH: Record<PieceName, [number, number]> = {
  start: [70, 115],
  friendly: [100, 150],
  honored: [130, 190],
  revered: [150, 210],
  aside: [15, 60],
  exalted: [190, 250],
};

type Paragraph = { text: string; after?: number; before?: number };
type Piece = { slug: string; piece: PieceName; title: string; meta: Record<string, string>; paragraphs: Paragraph[]; file: string };

function frontMatter(text: string): [Record<string, string>, string] {
  const m = text.match(/^---\n([\s\S]*?)\n---\n/);
  if (!m) return [{}, text];
  const meta: Record<string, string> = {};
  for (const line of m[1].split("\n")) {
    const kv = line.match(/^(\w+):\s*(.*)$/);
    if (kv) meta[kv[1]] = kv[2].trim();
  }
  return [meta, text.slice(m[0].length)];
}

function read(dir: string): Map<string, Piece> {
  const out = new Map<string, Piece>();
  if (!existsSync(dir)) return out;
  for (const slug of readdirSync(dir).sort()) {
    const folder = join(dir, slug);
    if (!existsSync(folder) || !readdirSync(folder).length) continue;
    for (const f of readdirSync(folder).filter((f) => f.endsWith(".md")).sort()) {
      const [meta, body] = frontMatter(readFileSync(join(folder, f), "utf8"));
      const piece = f.replace(/\.md$/, "") as PieceName;
      if (!PIECES.includes(piece)) throw new Error(`${slug}/${f}: no such piece (${PIECES.join(", ")})`);
      const paragraphs = body
        .split(/\n\s*\n/)
        .map((p) => p.replace(/\s*\n\s*/g, " ").trim())
        .filter(Boolean)
        .map((p): Paragraph => {
          const m = p.match(/^\[(after|before): (\d+)\]\s+(.*)$/);
          return m ? { text: m[3], [m[1]]: Number(m[2]) } : { text: p };
        });
      out.set(`${slug}/${piece}`, { slug, piece, title: meta.title ?? "", meta, paragraphs, file: `${folder.slice(ROOT.length + 1)}/${f}` });
    }
  }
  return out;
}

const plainText = (p: Piece) => p.paragraphs.map((x) => x.text).join(" ");
const tokensOut = (t: string) => t.replace(/\$g([^:;]*):([^;]*);/g, "$1");
// (a piece's words, counting one of each [before]/[after] pair: the reader sees one)
const words = (p: Piece) =>
  p.paragraphs
    .filter((x) => !x.before)
    .map((x) => tokensOut(x.text))
    .join(" ")
    .split(/\s+/)
    .filter(Boolean).length;
const hash = (p: Piece) =>
  createHash("sha256")
    .update(JSON.stringify([p.title, p.paragraphs]))
    .digest("hex")
    .slice(0, 12);
const q = (s: string) => `"${s.replace(/\\/g, "\\\\").replace(/"/g, '\\"').replace(/\n/g, "\\n")}"`;

type Listed = { id: number; chapters?: string; voice?: number; pieces?: PieceName[] };
const LISTED: Listed[] = JSON.parse(readFileSync(join(ROOT, "data", "factions.json"), "utf8")).factions;

function luaFor(locale: string, pieces: Map<string, Piece>, swaps: Record<string, string>): string {
  const own = TRANSLATED.includes(locale) ? locale : BORROWS[locale];
  const from = own ? `i18n/${own}/content/${own === locale ? "" : ` (with i18n/${locale}/regional.json)`}` : "content/";
  const lines = [
    `-- Generated by scripts/chapters.ts from ${from}: edit those, not this file.`,
    "-- chapters[faction][piece] = { title, { paragraph, after = quest, before = quest }, ... }",
    "local _, ns = ...",
    "ns.chapters = {",
  ];
  for (const f of LISTED.filter((f) => f.chapters)) {
    lines.push(`  [${f.id}] = {`);
    for (const piece of PIECES) {
      const p = pieces.get(`${f.chapters}/${piece}`);
      if (!p) continue;
      const paras = p.paragraphs.map((x) => {
        const extra = x.after ? `, after = ${x.after}` : x.before ? `, before = ${x.before}` : "";
        return `{ ${q(x.text)}${extra} }`;
      });
      lines.push(`    ${piece} = { title = ${q(p.title)}, ${paras.join(", ")} },`);
    }
    lines.push("  },");
  }
  lines.push("}");
  // longest first: "Goulet des Chanteguerres" before the "Chanteguerre" it holds
  const pairs = Object.entries(swaps).sort(([a], [b]) => b.length - a.length || (a < b ? -1 : 1));
  lines.push("-- (the places Classic Era's client names otherwise, swapped in there, the longest first)");
  lines.push(`ns.classicNames = { ${pairs.map(([a, b]) => `{ ${q(a)}, ${q(b)} }`).join(", ")} }`);
  return `${lines.join("\n")}\n`;
}

// (a borrowed text's names in the borrower's words: each name once, the longest
// first, so a name another holds is never swapped twice)
function swapOnce(text: string, pairs: [string, string][]): string {
  if (!pairs.length) return text;
  const esc = (x: string) => x.replace(/[.*+?^${}()|[\]\\]/g, "\\$&");
  const to = new Map(pairs);
  // (whole names only: "el Sindicato" never inside "Del Sindicato")
  return text.replace(new RegExp(`(?<!\\p{L})(?:${pairs.map(([a]) => esc(a)).join("|")})(?!\\p{L})`, "gu"), (m) => to.get(m) ?? m);
}

const args = process.argv.slice(2);
const check = args.includes("--check");
const problems: string[] = [];
const notes: string[] = [];
const english = read(join(ROOT, "content"));

const verify = (pieces: Map<string, Piece>, translated: boolean, locale: string) => {
  for (const p of pieces.values()) {
    const text = `${plainText(p)} ${p.title}`;
    if (tokensOut(text).includes(";")) problems.push(`${p.file}: a semicolon`);
    if (!translated && /[^\x20-\x7e]/.test(text + p.title)) problems.push(`${p.file}: not plain ASCII`);
    if (/\d/.test(tokensOut(text))) problems.push(`${p.file}: a figure in the prose (the road gives them)`);
    if (!p.title) problems.push(`${p.file}: no title`);
    const n = words(p);
    const [lo, hi] = LENGTH[p.piece];
    const slack = translated ? 1.2 : 1;
    if (n < lo * 0.6 || n > hi * slack * 1.25) problems.push(`${p.file}: ${n} words, far from ${lo} to ${hi}`);
    else if (n < lo || n > hi * slack) notes.push(`${p.file}: ${n} words (${lo} to ${hi})`);
    if (!translated) {
      const f = LISTED.find((x) => x.chapters === p.slug);
      if (!f) problems.push(`${p.file}: ${p.slug} is no faction's chapters in data/factions.json`);
      else if (Number(p.meta.faction) !== f.id) problems.push(`${p.file}: faction ${p.meta.faction}, not ${f.id}`);
      else if (f.voice && Number(p.meta.voice) !== f.voice) problems.push(`${p.file}: voice ${p.meta.voice}, not ${f.voice}`);
    } else {
      const en = english.get(`${p.slug}/${p.piece}`);
      if (!en) problems.push(`${p.file}: no English piece`);
      else {
        const marks = (x: Piece) => x.paragraphs.map((y) => `${y.after ?? ""}/${y.before ?? ""}`).filter((m) => m !== "/").join();
        if (marks(en) !== marks(p)) problems.push(`${p.file}: its [after]/[before] paragraphs aren't the English's (${marks(en)})`);
      }
    }
  }
  // (every piece a faction's chapters have, all six but where data/factions.json
  // says which are written so far, and none beyond those)
  if (!translated)
    for (const f of LISTED.filter((x) => x.chapters)) {
      const want = f.pieces ?? PIECES;
      for (const piece of want) if (!pieces.has(`${f.chapters}/${piece}`)) problems.push(`${f.chapters}: no ${piece} piece (${locale})`);
      for (const piece of PIECES)
        if (!want.includes(piece) && pieces.has(`${f.chapters}/${piece}`)) problems.push(`${f.chapters}: a ${piece} piece data/factions.json doesn't list`);
    }
};
verify(english, false, "enUS");
// (a repeatable quest is never flagged done, so a paragraph marked with one
// would never show, or never leave)
{
  const marked = new Map<number, string>();
  for (const p of english.values()) for (const x of p.paragraphs) for (const id of [x.after, x.before]) if (id) marked.set(id, p.file);
  if (marked.size)
    for (const game of ["classic", "forever"] as const) {
      const rows = openDb(game)
        .query(`SELECT id FROM quest WHERE id IN (${[...marked.keys()].join(",")}) AND COALESCE(special_flags, 0) & 1`)
        .all() as { id: number }[];
      for (const { id } of rows) problems.push(`${marked.get(id)}: quest ${id} is repeatable on ${game}, never flagged done: mark a quest done once`);
    }
}

const files: Record<string, string> = {};
for (const locale of LOCALES) {
  let pieces = english;
  let swaps: Record<string, string> = {};
  const lender = BORROWS[locale];
  if (lender) {
    const regional: Record<string, string> = JSON.parse(readFileSync(join(ROOT, "i18n", locale, "regional.resolved.json"), "utf8"));
    const lent = read(join(ROOT, "i18n", lender, "content"));
    const pairs = Object.entries(regional).sort(([a], [b]) => b.length - a.length || (a < b ? -1 : 1));
    const swap = (t: string) => swapOnce(t, pairs);
    pieces = new Map(
      [...english].map(([k, p]) => {
        const l = lent.get(k);
        return [k, l ? { ...l, title: swap(l.title), paragraphs: l.paragraphs.map((x) => ({ ...x, text: swap(x.text) })) } : p];
      }),
    );
    // (the borrowed text checked again with the borrower's names in: a
    // semicolon or a figure a regional name brought would be caught here)
    verify(new Map([...pieces].filter(([k]) => lent.has(k))), true, locale);
    // (a name the lender's client writes otherwise, left in: regional.json lacks it)
    const borrowed = [...pieces].filter(([k]) => lent.has(k)).map(([, p]) => `${p.title} ${plainText(p)}`).join(" ");
    for (const game of ["classic", "forever"] as const) {
      const rows = openDb(game)
        .query(
          `SELECT a.name AS lent, b.name AS own FROM name a JOIN name b ON a.kind = b.kind AND a.id = b.id
           WHERE a.locale = ? AND b.locale = ? AND a.kind IN ('area', 'faction', 'creature') AND a.name <> b.name AND length(a.name) > 4`,
        )
        .all(lender, locale) as { lent: string; own: string }[];
      for (const r of rows)
        if (borrowed.includes(r.lent) && new RegExp(`(?<!\\p{L})${r.lent.replace(/[.*+?^${}()|[\]\\]/g, "\\$&")}(?!\\p{L})`, "u").test(borrowed))
          problems.push(`${locale}: "${r.lent}" is ${lender}'s name, ${locale}'s client says "${r.own}" (${game}): i18n/${locale}/regional.json`);
    }
    const swapFile = join(ROOT, "i18n", locale, "classic-names.json");
    swaps = existsSync(swapFile) ? JSON.parse(readFileSync(swapFile, "utf8")) : {};
  } else if (TRANSLATED.includes(locale)) {
    const mine = read(join(ROOT, "i18n", locale, "content"));
    verify(mine, true, locale);
    pieces = new Map([...english].map(([k, p]) => [k, mine.get(k) ?? p]));
    for (const k of english.keys()) if (!mine.has(k)) notes.push(`${locale}: ${k} not translated yet`);
    const stampFile = join(ROOT, "i18n", locale, "content-stamp.json");
    const stamps: Record<string, string> = existsSync(stampFile) ? JSON.parse(readFileSync(stampFile, "utf8")) : {};
    const fresh: Record<string, string> = {};
    for (const k of mine.keys()) {
      const en = english.get(k);
      if (!en) continue;
      fresh[k] = hash(en);
      if (stamps[k] !== hash(en)) notes.push(`${locale}: ${k}: its English changed since it was translated (--stamp once read)`);
    }
    if (args.includes("--stamp")) writeFileSync(stampFile, `${JSON.stringify(fresh, null, 2)}\n`);
    const swapFile = join(ROOT, "i18n", locale, "classic-names.json");
    swaps = existsSync(swapFile) ? JSON.parse(readFileSync(swapFile, "utf8")) : {};
  }
  files[`Chapters_${locale}.lua`] = luaFor(locale, pieces, swaps);
}
for (const n of notes) console.log(`  ${n}`);
if (problems.length) {
  for (const p of problems) console.error(`✗ ${p}`);
  process.exit(1);
}
let stale = false;
for (const [f, want] of Object.entries(files)) {
  const path = join(ADDON, f);
  const have = existsSync(path) ? readFileSync(path, "utf8") : "";
  if (have === want) continue;
  if (check) {
    console.error(`✗ ${f} is not up to date: bun scripts/chapters.ts`);
    stale = true;
  } else writeFileSync(path, want);
}
if (stale) process.exit(1);
const factions = new Set([...english.values()].map((p) => p.slug)).size;
console.log(`✓ ${factions} factions' chapters, ${english.size} pieces`);

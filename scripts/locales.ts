/**
 * i18n/<locale>/ → addon/Goodwill/Text_<locale>.lua, one for every language the
 * game has (a stub where there is no translation yet, so the TOC never names
 * a missing file): each client loads its own, through Text_[TextLocale].lua in
 * the TOCs, and English stays wherever a translation says nothing (Locale.lua).
 * The family's core (scripts/locales-lib.ts, the kit's copy) reads the words,
 * merges the kit's own (i18n/kit/, translated once for every addon), checks
 * them and writes the files; here, Goodwill's own: the factions', npcs',
 * quests' and trades' names, from the game by their ids, in each language.
 *
 *   bun scripts/locales.ts            write the Text files
 *   bun scripts/locales.ts --check    fail if one isn't up to date, a word has
 *                                     no translation, a translation's blanks
 *                                     differ, or prose has a semicolon
 *   bun scripts/locales.ts --keys     write i18n/words.json, every word to translate
 */
import { join } from "node:path";
import { json, q, run } from "./locales-lib";

const ROOT = new URL("..", import.meta.url).pathname;
const I18N = join(ROOT, "i18n");

// The game's own names a language's file carries, every language's whole
// (English one of them): each game's factions, npcs, quests and trades by id
// (i18n/names.json, written by scripts/factions.ts from the client's data).
function namesLua(locale: string): string[] {
  type Names = Record<string, Record<string, string>>;
  const names: Record<string, Record<string, Names>> = json(join(I18N, "names.json"));
  const mine = names[locale];
  if (!mine) throw new Error(`i18n/names.json names nothing in ${locale}: bun scripts/factions.ts`);
  const out = ["ns.names({"];
  for (const [game, kinds] of Object.entries(mine)) {
    out.push(`  ${game} = {`);
    for (const [kind, m] of Object.entries(kinds)) {
      out.push(`    ${kind} = {`);
      for (const [id, name] of Object.entries(m).sort(([a], [b]) => Number(a) - Number(b))) out.push(`      [${id}] = ${q(name)},`);
      out.push("    },");
    }
    out.push("  },");
  }
  out.push("})");
  return out;
}

run({ root: ROOT, addon: "addon/Goodwill", names: namesLua });

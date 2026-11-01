/**
 * A chapter's title, as the Stories tab shows it: a placeholder ("The
 * aside", the piece's own name, "TODO") is refused, and so is a title two
 * English pieces share ("Door" and "The Door" are one). "The aside"
 * shipped on three chapters before this check (the English audit, 31
 * October 2026), and "L'aparté" in French until the French fixes (1
 * November 2026). A language in TITLED gets the same checks with its own
 * articles and placeholders, the others the plain no-title check (German and
 * Spanish join with their pass, once English and French are the base).
 */
export const PIECES = ["start", "friendly", "honored", "revered", "aside", "exalted"] as const;
const PLACEHOLDERS: string[] = [...PIECES, "todo", "tbd", "title", "untitled", "placeholder"];
export const TITLED: Record<string, { article: RegExp; placeholders: string[] }> = {
  enUS: { article: /^the\s+/, placeholders: PLACEHOLDERS },
  frFR: {
    article: /^(?:(?:le|la|les)\s+|l['\u2019]\s*)/,
    placeholders: ["aparté", "début", "amical", "honoré", "révéré", "exalté", "à faire", "titre", "sans titre"],
  },
};
// (a language TITLED doesn't hold is a caller's mistake: said, not a TypeError)
const rules = (locale: string) => {
  const r = TITLED[locale];
  if (!r) throw new Error(`titles: no rules for ${locale} (TITLED)`);
  return r;
};
const bare = (title: string, locale = "enUS") => title.trim().toLowerCase().replace(rules(locale).article, "");

export function titleProblem(title: string, locale = "enUS"): string | undefined {
  if (!bare(title, locale)) return "no title";
  if (rules(locale).placeholders.includes(bare(title, locale))) return `a placeholder title ("${title}")`;
  return undefined;
}

export function sharedTitles(pieces: { title: string; file: string }[], locale = "enUS"): string[] {
  const by = new Map<string, string[]>();
  for (const p of pieces) {
    const key = bare(p.title, locale);
    if (key) by.set(key, [...(by.get(key) ?? []), p.file]);
  }
  return [...by.values()].filter((files) => files.length > 1).map((files) => `${files.join(" and ")}: the same title`);
}

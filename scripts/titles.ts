/**
 * A chapter's title, as the Stories tab shows it: a placeholder ("The
 * aside", the piece's own name, "TODO") is refused, and so is a title two
 * English pieces share ("Door" and "The Door" are one). "The aside"
 * shipped on three chapters before this check (the English audit, 31
 * October 2026). Translations keep the plain no-title check.
 */
export const PIECES = ["start", "friendly", "honored", "revered", "aside", "exalted"] as const;
const PLACEHOLDERS: string[] = [...PIECES, "todo", "tbd", "title", "untitled", "placeholder"];
const bare = (title: string) => title.trim().toLowerCase().replace(/^the\s+/, "");

export function titleProblem(title: string): string | undefined {
  if (!bare(title)) return "no title";
  if (PLACEHOLDERS.includes(bare(title))) return `a placeholder title ("${title}")`;
  return undefined;
}

export function sharedTitles(pieces: { title: string; file: string }[]): string[] {
  const by = new Map<string, string[]>();
  for (const p of pieces) {
    const key = bare(p.title);
    if (key) by.set(key, [...(by.get(key) ?? []), p.file]);
  }
  return [...by.values()].filter((files) => files.length > 1).map((files) => `${files.join(" and ")}: the same title`);
}

# Goodwill

A World of Warcraft addon: every faction's road to Exalted from where the
character stands (the turn-ins the bags and the bank hold, the quests still
open, the kills that still count, what each standing unlocks), and, for a
faction with a voice of its own, a chapter of its story at each standing,
told by someone who trusts you a little more each time. Planned in
`../ideas/reputation-road.md`, its voices in
`../ideas/reputation-road-voices.md` (the cards the chapters follow).
Started 23 October 2026. On GitHub (salty-max/goodwill, public, 23 October
2026), not yet released. Classic Era (11509) and Forever (16001), one
package. Read the family's CLAUDE.md
(`../CLAUDE.md`) first.

## Where things are

| What | Where |
|---|---|
| The addon file by file: the package, Core, Road, the book's tabs, Settings, Welcome, the tests, languages | `docs/architecture.md` |
| The factions from wow-data (`scripts/factions.ts`) and the chapters (`scripts/chapters.ts`) | `docs/data.md` |
| The factions the book follows, their groups, sides and voices, by hand | `data/factions.json` |
| The chapters themselves | `content/<faction>/<piece>.md`, French in `i18n/frFR/content/<faction>/` |
| The logo, its master, exports and exact generation prompt | `assets/README.md` |
| The plan, the voices, the waves of chapters to come | `../ideas/reputation-road.md`, `../ideas/reputation-road-voices.md` |

## Commands

```bash
bun run check        # kit, saved ids, factions, chapters, languages, lint, the sim on three clients, TOCs
bun run check:ci     # what CI and the release gate run: no family folder (the kit, the saved ids and the generators' checks aside)
bun run ids          # every table saved-ids.json lists keeps the ids it had at the fork point from origin/main
bun scripts/root.ts --run addon-kit/q.ts check -- bun run check   # the same, quiet, stamping the tree for the push
bun run package      # dist/Goodwill-<version>.zip for a test in the game
bun run factions     # the factions again, after wow-data's databases change
bun run chapters     # the chapters again, after a content/ edit (--stamp once a translation is read)
bun run kit:sync     # after a change to the kit (Kit.lua, Media, scripts/root.ts)
bun run locales      # after a new L["..."] (then --keys for i18n/words.json)
scripts/release.sh [--version X.Y.Z] [--hold] NOTES.md   # check, tag, push; Actions publish
```

## Hard rules

- The game's data comes from wow-data's databases only (`scripts/factions.ts`,
  through `scripts/root.ts`, the kit's copy). Generated files
  (`Factions_*.lua`, `Chapters_*.lua`, `Text_*.lua`, `i18n/names.json`) are
  never edited by hand; `--check` fails a stale one.
- A regenerated table keeps every id a saved book may hold (`saved-ids.json`,
  `bun run ids` in the check): an id leaves only with the user's go, under
  `removed`.
- Saved data (`GoodwillChar`) keeps ids only. Factions, quests, npcs, items
  and zones are named by id in the client's language, never matched by an
  English name.
- The chapters follow the Codex's lore rules (any source, nothing anachronic,
  original wording), the voices' feelings and manner ours, the factions'
  facts sourced (`../ideas/reputation-road-voices.md` lists each piece's).
  A chapter tells only what every reader at its standing has seen: a deed
  of the reader's only in an `[after: <quest>]` paragraph. It may tell what
  the Codex tells, never the same way (the user's rule, 23 October 2026):
  the prose-reader reads it beside the Codex pages its front matter names
  before the user does. No addon reads the other's files.
- Chapters in plain ASCII in English, no semicolons in any language, no
  figures in the prose (the road gives them), longer at each standing. A
  translation is stamped against its English.
- `Kit.lua`, `Media/Ring.tga`, `scripts/root.ts`, `scripts/locales-lib.ts`, `scripts/package-lib.ts`,
  `i18n/kit/` (the kit's words, translated once), `wow.yml`, `stylua.toml` and
  `addon/test/wowmock.lua` (the tests' game) are the kit's copies: edit addon-kit, then `bun run
  kit:sync`. Goodwill's own globals are `goodwill.yml`.
- No other addon's API, even optional. Stepping aside for a rival is fine.
- Conventional Commits, lowercase subjects, no AI trailers. Commit locally;
  ask before any push, release or deploy. The pre-push hook wants a check
  stamp on the tree (q), which `release.sh` makes after the version bump.

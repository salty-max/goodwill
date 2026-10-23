# Goodwill's data

## The factions (`scripts/factions.ts`)

From wow-data's databases (classic.db, forever.db, at their pins), each
game's own, for the factions `data/factions.json` lists (by hand: the
book's group, the side when only one side can raise it, the game when only
one has it, the voice once its chapters are written):

- the quests that raise it once: `quest_reward` kind `reputation` (Questie's
  figures), the quest's level, races and classes (masks), its giver
  (`quest_relation`), its zone (the giver's spawn, else the quest log's), the
  standing it asks before it's offered (`quest_standing`: a floor, a
  ceiling, either faction's), the quests before it (`quest_prereq`: all of
  `after`, one of `anyOf`), its exclusive group;
- the turn-ins: a quest the Classic database flags repeatable, with the
  items it asks (`reputation_turnin`);
- the kills: `kill_reputation`, the creature, the most a kill gives, the
  last standing it still counts at (the data's 0 to 7, the game's one more:
  the road stops it at the standing after);
- the unlocks: an item `item_reputation` gates and a vendor sells, its
  standing, its vendors, the recipe and trade it teaches (`recipe_source`),
  and the quests a standing opens (`quest_standing`'s floor);
- every giver's, vendor's, voice's and creature's zone and spot (its first
  spawn with one, Questie's map percent), and its friendly sides.

`i18n/names.json`: every language's names for them, the client's (no
English fallback: a name a language lacks is missing, and the book names it
another way), read by `scripts/locales.ts` into each Text file.

Counted on 23 October 2026: Classic Era 33 factions (2,324 quests, 411
turn-ins, 452 kills, 524 unlocks), Forever 42.

## The chapters (`scripts/chapters.ts`)

`content/<faction>/<piece>.md`, a piece a file (start, friendly, honored,
revered, aside, exalted), front matter `faction`, `voice`, `piece`,
`title`, `beside` (the Codex pages it sits beside, for the reading, never
for the build); paragraphs, `[after: <quest>]` or `[before: <quest>]` at a
paragraph's start. A translation in `i18n/<locale>/content/<faction>/`,
front matter `piece` and `title`, the same marked paragraphs, stamped
against its English (`i18n/<locale>/content-stamp.json`, `--stamp`).
Classic Era's place names where its client differs:
`i18n/<locale>/classic-names.json`, swapped in by the book.

The build refuses a semicolon (the gender tokens' own aside), non-ASCII in
the English, a figure in the prose, a piece missing, a translation whose
marked paragraphs aren't its English's, a length far from its piece's; it
says a length a little outside and a translation whose English changed.

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
- the spillover: sisters under one parent share what they earn, counting
  all the way to Exalted (`client_Faction`: `ParentFactionMod_1` the share
  a faction gives, `_0` the share it takes, `ParentFactionCap_0` the last
  standing it still counts at). The four Steamwheedle towns give each other
  half, a side's capitals a quarter. Each faction gets its sisters' kills
  and repeatable turn-ins at that share, marked with the sister they come
  through (a kill's fourth field, a quest's `via`), and `spill` (`rate`,
  `from`) for the book's note. Their one-time quests stay off the road: the
  note says a share of them comes too. This follows the Classic guides
  (Everlook, with no kills of its own, climbs on its sisters' to Exalted).
  How a capped kill spills, once the town it belongs to stops counting it,
  is unverified in game.
- the races whose bit in a quest's race mask isn't their id's
  (`raceBits`, the client's ChrRaces PlayableRaceBit: Forever's Skyborne,
  races 95 and 96, are bits 32 and 33). Without it no Skyborne would be
  offered its own order's quests.

`i18n/names.json`: every language's names for them, the client's (no
English fallback: a name a language lacks is missing, and the book names it
another way), read by `scripts/locales.ts` into each Text file.

Counted on 23 October 2026, the sisters' shares and wow-data's kills by
hand included: Classic Era 33 factions (2,324 quests, 729 turn-ins, 596
kills, 524 unlocks), Forever 42.

## The chapters (`scripts/chapters.ts`)

`content/<faction>/<piece>.md`, a piece a file (start, friendly, honored,
revered, aside, exalted), front matter `faction`, `voice`, `piece`,
`title`, `beside` (the Codex pages it sits beside, for the reading, never
for the build); paragraphs, `[after: <quest>]` or `[before: <quest>]` at a
paragraph's start. A translation (French, German, Spanish) in `i18n/<locale>/content/<faction>/`,
front matter `piece` and `title`, the same marked paragraphs, stamped
against its English (`i18n/<locale>/content-stamp.json`, `--stamp`).
Classic Era's place names where its client differs:
`i18n/<locale>/classic-names.json`, swapped in by the book the longest
first, so a name may hold another ("Goulet des Chanteguerres" goes to
"Goulet des Warsong" before "Chanteguerre" to "Warsong"). German and Spanish
need none: their two clients name the chapters' places alike (checked
against wow-data, 26 October 2026). esMX has no folder of its own: it
borrows esES's chapters with `i18n/esMX/regional.json` (esES name → esMX
name, the longest first, once) and its own `classic-names.json` if one is
ever needed.

The build refuses a semicolon (the gender tokens' own aside), non-ASCII in
the English, a figure in the prose, a piece missing (all six, or the ones
the faction's `pieces` in `data/factions.json` lists, and none beyond
them), a translation whose marked paragraphs aren't its English's, a mark
on a quest either game flags repeatable (wow-data's `special_flags`: the
client never flags one done, so its paragraph would never show), a length
far from its piece's; it says a length a little outside and a translation
whose English changed.

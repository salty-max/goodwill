# Goodwill's architecture

The addon file by file (the map is CLAUDE.md). The factions' data and the
chapters' build: `docs/data.md`.

## The package

- `addon/Goodwill`: one package for every game (`Goodwill_Vanilla.toc`:
  Classic Era, 11509; `_Camelot.toc`: Forever, 16001; no TBC Anniversary: the
  family dropped it), the same but for the interface and the game's factions
  (`Factions_Classic.lua`, `Factions_Forever.lua`). Loads its factions,
  `Kit.lua` (the kit's copy, `bun run kit:sync`; never edit it),
  `Locale.lua`, `Text_[TextLocale].lua`, `Chapters_[TextLocale].lua`,
  `Core.lua`, `Settings.lua`, `Road.lua`, `Book.lua`, `FactionsBook.lua`,
  `StoriesBook.lua`, `Welcome.lua`, `Minimap.lua` (the test game loads them
  from the TOC).

## The files

- `Locale.lua`: the client's words (`ns.translate`, the plural rule; which
  game this is, `ns.forever`, the kit says), the game's names by id from the Text file
  (`ns.names`: factions, npcs, quests, trades, this game's), and `ns.agree`:
  the game's own `$gmasc:fem;` tokens, a line agreed to the reader.
- `Core.lua`: the book (`GoodwillChar`: opened, bank, bankAt; ids only), the
  events (`ns.on`), the standings (`ns.standingOf`: Forever's
  C_Reputation.GetFactionDataByID, Classic Era's GetFactionInfoByID; the
  game's standing 1 to 8, its figure, the standing's bounds; the standings'
  names the game's, a woman's form where the language has one), the
  character's side, race and class against a quest's masks (`ns.forMe`), the
  factions it follows (`ns.factions`: its side's and both sides'), a quest
  done (C_QuestLog.IsQuestFlaggedCompleted), the chapters (`ns.chapter`: a
  piece's title and the paragraphs the reader may see now, `[after]` once
  its quest is done, `[before]` until then, agreed and Classic Era's names
  swapped in; `ns.PIECES`: start from the start, friendly, honored, revered
  at their standing, the aside halfway from Revered to Exalted, exalted;
  opened quietly at the login, else a line in chat and the kit's banner,
  UPDATE_FACTION), the bank (read while it's open, BANKFRAME_OPENED and
  PLAYERBANKSLOTS_CHANGED, the turn-ins' items only), `/goodwill`, the
  kit's command (`stories`, `minimap`, `settings`, `welcome`, `export`,
  `import CODE`; an unknown word prints the usage, the replies capitalised).
- `Road.lua`: a faction's road (`ns.road`): the standing it aims at (the
  next one up) and how far, the turn-ins open to the character (the items
  against the bags and the bank, how many times they'd go in; the same
  turn-in at several givers once, its givers together), the quests not done
  and open to it (its race and class, the quests before it, its exclusive
  group; offered now, or opening at a later standing; a ceiling passed:
  gone), the kills that still count by zone (the standing each stops at),
  what each standing unlocks (its vendors' goods, a trade's recipe said so,
  its quests), and what the bags and the bank hold as reputation.
- `Book.lua`: the family's window and tabs in Goodwill's green (a friendly
  standing's), the parts every tab uses (`ns.ui`); the page again when the
  game tells an item's name late, only for one the book shows.
  `FactionsBook.lua`: the factions by group, each in its standing's colour;
  the overview (the factions at Exalted, the chapters opened, the voiced
  factions); a faction's page (its standing and the way to the next, the
  newest chapter signed by its voice and the next one's title, the road as
  cards: turn-ins with their items, kills by zone, quests; then what each
  standing unlocks). `StoriesBook.lua`: the voiced factions, each one's
  story so far in its order, signed, with the day each chapter opened; those
  to come by their title and standing.
- `Settings.lua`: each character's settings, the kit's profiles (a code
  `GW1:...`, `/goodwill export`, `/goodwill import CODE`): the chapter's
  banner (`chapterBanner`, on by default), the minimap button and its place
  (140 degrees, clear of Mealbook's 165 and the siblings'); their page in
  the game's Options, the kit's `K.options`. `Welcome.lua`: the kit's welcome page, once per character.
  `Minimap.lua`: the book's button, as the siblings'.

## Artwork

The emerald-and-gold handshake medallion is kept in `assets/`, with its
master, 1024px and 512px PNG exports, and exact generation prompt.
`Media/Logo.tga` is the uncompressed 256px RGBA game texture with rounded
corners: both TOCs and `ns.LOGO` (the welcome page's logo) use it.
`Media/Medallion.tga` is the medallion alone, cut round on its gold rim:
`ns.ICON`, every round picture (the book's portrait, the factions' and
stories' pages and cards, the banners, the minimap button, the welcome's
portrait), where the square logo showed its navy corners and ribbons inside
the ring. Export details are in `assets/README.md`.

## Tests

- `addon/test/game.lua` (the kit's game, `wowmock.lua`: frames, events,
  timers, the character, the map, the Options panel; then Goodwill's own
  world and the addon loaded as its TOC lists it: the standings as each client tells
  them, quests done, bags and bank, race, class and sex) and
  `addon/test/sim.lua`: a first login, standings rising (a chapter a
  standing, the aside), a paragraph after a quest and one before it, a
  French reader who is a woman, the road (turn-ins with the bank, the
  scourgestones once, the kills at Revered, the sisters' shares through
  Everlook, quests, unlocks), the book's
  tabs, the other side's factions, on Classic Era, Forever and a French
  client (`bun run check` runs all).

## Languages

- Goodwill's own words through `L` (`i18n/<locale>/words.json`, `bun run
  locales`): English, French, German and Spanish (interface and chapters).
  German and Spanish are flagged, first translations with no native reader
  yet. German voices speak the game's "Ihr", Gorn and Lokhtos dropping to
  "du" where their cards say, Bor on "du" throughout. Spanish voices speak
  the game's "tú", Gorn and Lokhtos starting on "usted" (the same scale).
  esMX borrows esES's words and chapters, its own client's names put in by
  `i18n/esMX/regional.json` (game names from wow-data through addon-kit/regional.ts, `regional.resolved.json`; the hand file keeps words) (`names`: esES game names, esMX's from wow-data; `words`: what is no game name; the swap is the resolved esES → esMX map, longest first, once)
  and its own decimal point (`i18n/esMX/meta.json`). The sim runs on frFR,
  deDE, esES and esMX. The other clients English until translated. The factions', npcs', quests' and trades' names
  are the game's, by id, in the client's language.

## Not done yet

- The store page and achievements.
- The capitals' mounts: vanilla sells another race's only at Exalted
  through the vendor's own gossip, which wow-data doesn't load
  (`item_reputation` has no row for them).
- Forever's own repeatable turn-ins (the Craftsman's Writs): wow-data's
  repeatable flag is the Classic database's, so they aren't turn-ins yet.
- The reputation amounts: Questie's, unchecked against the game.

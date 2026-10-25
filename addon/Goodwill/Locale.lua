-- The reader's language. The client loads its own Text_<locale>.lua next (the
-- TOCs name Text_[TextLocale].lua; scripts/locales.ts writes them from
-- i18n/), which hands its words to ns.translate: English stays wherever it
-- says nothing. The factions', npcs', quests' and trades' names are the
-- game's, by their ids, in the client's language: never translated here.
local _, ns = ...
local K = ns.kit

-- (the kit's: the language's plural rule, every word through it; which game
-- this is the kit says too, ns.forever)
function ns.translate(t) K.translate(t) end

-- The game's own names in the reader's language (its Text file, from
-- wow-data's databases): this game's factions, npcs, quests and trades by
-- id. A name the language lacks is missing: the book names it another way.
function ns.names(t)
  local game = ns.forever and "forever" or "classic"
  local mine = t[game] or {}
  ns.factionNames = mine.factions or {}
  ns.npcNames = mine.npcs or {}
  ns.questNames = mine.quests or {}
  ns.skillNames = mine.skills or {}
end

-- A line written to the reader, agreed to them: "$gvu:vue;" (the game's own
-- tokens, French above all) as the character is a man or a woman.
ns.agree = K.agree

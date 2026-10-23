-- Goodwill played through: a first login (every voiced faction's first page
-- opened quietly), standings rising (a chapter a standing, said in chat and
-- on a banner, the aside halfway to Exalted), a paragraph after a quest and
-- one before it, the road (turn-ins against the bags and the bank, the kills
-- that still count, the quests still open, what each standing unlocks), and
-- the book opened on each tab. FOREVER=1, LOCALE=frFR: those clients.
local G = dofile("addon/test/game.lua")
local s, fire, ns = G.state, G.fire, G.ns
local count = 0
local function check(ok, what)
  if not ok then error("✗ " .. what, 2) end
  count = count + 1
end
local L = ns.kit.L
local D = ns.data
local function said(text)
  for _, line in ipairs(s.printed) do
    if line:find(text, 1, true) then return true end
  end
  return false
end
-- (the start of the line a new chapter says, in the client's language)
local NEW_CHAPTER = L["A new chapter from %s: %s."]:match("^(.-)%%s")
local TIMBERMAW, DAWN, THORIUM = 576, 529, 59

-- ── a first login ────────────────────────────────────────────────────────────
s.rep[TIMBERMAW] = -3500 -- (Hostile: the Timbermaw's start)
G.login()
local char = GoodwillChar
check(char.guid == s.guid, "the book is this character's")
for _, id in ipairs({ TIMBERMAW, DAWN, THORIUM }) do
  check(ns.opened(id, "start"), "a voiced faction's first page, open from the start: " .. id)
  check(not ns.opened(id, "friendly"), "and nothing more yet: " .. id)
end
check(not said(NEW_CHAPTER), "quietly at the first login")
check(D.factions[72] and D.factions[76], "both sides' capitals in the data")
local mine = {}
for _, id in ipairs(ns.factions()) do
  mine[id] = true
end
check(mine[72] and not mine[76], "an Alliance character follows Stormwind, not Orgrimmar")
check((mine[2778] or false) == G.FOREVER, "Forever's own factions only on Forever")

-- ── standings rising ─────────────────────────────────────────────────────────
s.printed = {}
s.rep[TIMBERMAW] = 3100
fire("UPDATE_FACTION")
check(ns.opened(TIMBERMAW, "friendly"), "Friendly with the Timbermaw: its chapter opened")
check(said(NEW_CHAPTER), "said in chat")
check(GoodwillBanner1 and GoodwillBanner1:IsShown(), "and on a banner among the game's alerts")
check(not ns.opened(TIMBERMAW, "honored"), "Honored's still to come")
s.rep[TIMBERMAW] = 25000
fire("UPDATE_FACTION")
check(
  ns.opened(TIMBERMAW, "honored") and ns.opened(TIMBERMAW, "revered"),
  "Revered: the chapters on the way opened too"
)
check(not ns.opened(TIMBERMAW, "aside"), "the aside not before halfway to Exalted")
s.rep[TIMBERMAW] = 32000
fire("UPDATE_FACTION")
check(ns.opened(TIMBERMAW, "aside"), "halfway to Exalted: the aside")
check(not ns.opened(TIMBERMAW, "exalted"), "Exalted's chapter waits for Exalted")

-- ── the paragraphs a quest shows or hides ────────────────────────────────────
local function paragraphs(id, piece) return #select(2, ns.chapter(id, piece)) end
local before = paragraphs(TIMBERMAW, "exalted")
s.done[8481] = true
check(paragraphs(TIMBERMAW, "exalted") == before + 1, "the ancestors' paragraph once The Root of All Evil is done")
local _, honored = ns.chapter(DAWN, "honored")
local n = #honored
s.done[5251] = true
local _, after = ns.chapter(DAWN, "honored")
check(#after == n and after[3] ~= honored[3], "the archive's paragraph: the one before it, then the one after")

-- ── a French reader, a woman ─────────────────────────────────────────────────
if G.LOCALE == "frFR" then
  s.sex = 3
  local _, revered = ns.chapter(TIMBERMAW, "revered")
  local text = table.concat(revered, " ")
  check(text:find("une étrangère", 1, true) and text:find("Révérée", 1, true), "the reader agreed to: a woman")
  check(not text:find("$g", 1, true), "no token left")
  s.sex = 2
  local _, honoredT = ns.chapter(THORIUM, "honored")
  local lokhtos = table.concat(honoredT, " ")
  check(lokhtos:find(G.FOREVER and "Forgefer" or "Ironforge", 1, true), "the city's name as this client writes it")
end

-- ── the road ─────────────────────────────────────────────────────────────────
s.done[8464] = true -- (Winterfall Activity: the beads open)
s.bags[21383] = 12
s.bank[21383] = 8
local turnins = ns.road.turnins(TIMBERMAW)
local beads
for _, t in ipairs(turnins) do
  if t.items[1] and t.items[1].item == 21383 then beads = t end
end
check(beads and beads.times == 2, "Beads for Salfa: twelve carried, the bank unseen yet, twice")
fire("BANKFRAME_OPENED")
check(char.bank[21383] == 8, "the bank read while it's open")
beads = nil
for _, t in ipairs(ns.road.turnins(TIMBERMAW)) do
  if t.items[1] and t.items[1].item == 21383 then beads = t end
end
check(beads and beads.times == 4, "twenty beads with the bank's: four turn-ins")
check(ns.road.held(TIMBERMAW) >= beads.times * beads.each, "what the bags and the bank hold, as reputation")
-- the same turn-in at several givers counts once (the Dawn's scourgestones)
s.bags[12840] = 40
s.done[5503] = true -- (the Argent Dawn Commission: the stones' turn-ins open)
local minion = 0
for _, t in ipairs(ns.road.turnins(DAWN)) do
  if t.items[1] and t.items[1].item == 12840 then minion = minion + 1 end
end
check(minion == 1, "the Minion's Scourgestone turn-in once, its givers together")
-- kills: Revered with the Timbermaw, the Deadwood no longer count, High Chief Winterfall does
local deadwood, chief = false, false
for _, z in ipairs(ns.road.kills(TIMBERMAW)) do
  for _, c in ipairs(z.creatures) do
    if c == 7153 then deadwood = true end
    if c == 10738 then chief = true end
  end
end
check(not deadwood and chief, "the kills that still count at Revered")
-- (a kill's cap is the last standing it counts at: the Brood of Nozdormu's
-- Ahn'Qiraj trash, capped at Hated, counts at Hated, not at Hostile)
local function broodTrash()
  for _, z in ipairs(ns.road.kills(910)) do
    for _, c in ipairs(z.creatures) do
      if c == 15747 then return true end
    end
  end
  return false
end
s.rep[910] = -42000
check(broodTrash(), "a kill counts at its cap: Hated")
s.rep[910] = -6000
check(not broodTrash(), "and stops at the standing after: Hostile")
s.rep[910] = nil
s.rep[TIMBERMAW] = 8000
local honored = false
for _, z in ipairs(ns.road.kills(TIMBERMAW)) do
  for _, c in ipairs(z.creatures) do
    if c == 7153 then honored = true end
  end
end
check(honored, "a Deadwood Warrior still counts at Friendly")
s.rep[TIMBERMAW] = 15000
honored = false
for _, z in ipairs(ns.road.kills(TIMBERMAW)) do
  for _, c in ipairs(z.creatures) do
    if c == 7153 then honored = true end
  end
end
check(honored, "and at Honored, its cap")
s.rep[TIMBERMAW] = 32000
local quests = ns.road.quests(DAWN)
check(#quests > 0, "the Dawn's quests still open")
for _, q in ipairs(quests) do
  check(not s.done[q.quest], "none done")
  break
end
local target, need = ns.road.target(TIMBERMAW)
check(target == ns.EXALTED and need == 42000 - 32000, "the road aims at the next standing")
local unlocks = ns.road.unlocks(DAWN)
check(#unlocks > 0 and unlocks[1].standing >= ns.FRIENDLY, "what each standing unlocks, Friendly up")

-- ── the book ─────────────────────────────────────────────────────────────────
ns.toggle()
check(GoodwillFrame and GoodwillFrame:IsShown(), "the book opens")
G.advance(0.5)
for _, id in ipairs({ TIMBERMAW, DAWN, THORIUM, 72, 21 }) do
  ns.openFaction(id)
  G.advance(0.1)
end
ns.openStory(TIMBERMAW)
G.advance(0.1)
check(GoodwillFrame.selectedTab == ns.TAB.stories, "a story opened on the Stories tab")
ns.openTab(ns.TAB.factions)
fire("UPDATE_FACTION")
G.advance(0.5)
check(ns.chaptersOpened() >= 7, "every chapter opened, counted")

-- ── the other side ───────────────────────────────────────────────────────────
s.faction = "Horde"
local horde = {}
for _, id in ipairs(ns.factions()) do
  horde[id] = true
end
check(horde[76] and not horde[72], "a Horde character follows Orgrimmar, not Stormwind")
s.faction = nil

io.write(("Goodwill: %d checks passed (%s, %s).\n"):format(count, G.LOCALE, G.FOREVER and "Forever" or "Classic Era"))

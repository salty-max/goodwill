-- Goodwill played through: a first login (every voiced faction's first page
-- opened quietly), standings rising (a chapter a standing, said in chat and
-- on a banner, the aside halfway to Exalted), a paragraph after a quest and
-- one before it, the road (turn-ins against the bags and the bank, the kills
-- that still count, the quests still open, what each standing unlocks), and
-- the book opened on each tab. FOREVER=1, LOCALE=frFR, deDE, esES, esMX: those clients.
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
G.login()
local char = GoodwillChar
check(char.guid == s.guid, "the book is this character's")
-- (a faction is listed from its first gain of reputation, and a character's
-- own capital from the start; the rest wait, their chapters with them)
local function listed(id)
  for _, f in ipairs(ns.factions()) do
    if f == id then return true end
  end
  return false
end
check(ns.startRep(TIMBERMAW) == -3500, "the Timbermaw start Hostile, the data's figure")
check(listed(72), "a fresh character follows its own capital")
check(not listed(21) and not listed(76), "and no other faction yet")
-- where a race and class start, the data's own figures (not the mock's)
if G.FOREVER then
  s.race = 95 -- (an Alliance Skyborne: bit 32, the mask's high half)
  check(ns.startRep(72) == 3100, "a Skyborne starts Friendly with Stormwind")
  check(ns.startRep(DAWN) == 200 and ns.startRep(TIMBERMAW) == -3500, "and at the all-races starts of the others")
else
  s.race, s.class = 4, 11 -- (a Night Elf druid)
  check(ns.startRep(609) == 2000, "a druid starts Friendly with the Cenarion Circle")
  s.class = 1
  check(ns.startRep(609) == 0, "a warrior of the same race doesn't")
end
s.race, s.class = nil, nil
for _, id in ipairs({ TIMBERMAW, DAWN, THORIUM }) do
  check(not listed(id) and not ns.opened(id, "start"), "no gain yet, no chapter yet: " .. id)
end
-- a first gain in the game (UPDATE_FACTION) unlocks a faction, its first chapter announced
s.printed = {}
s.rep[DAWN], s.rep[TIMBERMAW], s.rep[THORIUM] = ns.startRep(DAWN) + 250, -3400, ns.startRep(THORIUM) + 10
fire("UPDATE_FACTION")
for _, id in ipairs({ TIMBERMAW, DAWN, THORIUM }) do
  check(listed(id), "a first gain unlocks it: " .. id)
  check(ns.opened(id, "start"), "a voiced faction's first page, open from the first gain: " .. id)
  check(not ns.opened(id, "friendly"), "and nothing more yet: " .. id)
end
check(said(NEW_CHAPTER), "the first chapter said in chat, as the game's UPDATE_FACTION plays it")
-- a loss is no unlocking
s.rep[DAWN], s.rep[TIMBERMAW], s.rep[THORIUM] = nil, -3600, nil
char.unlocked, char.opened[DAWN], char.opened[TIMBERMAW], char.opened[THORIUM] = {}, nil, nil, nil
check(not listed(DAWN) and not listed(THORIUM), "no gain isn't unlocking")
check(not listed(TIMBERMAW), "nor is a loss")
s.rep[TIMBERMAW] = nil
-- the chapters counted are the listed factions'
local opened = 0
for _, id in ipairs(ns.factions()) do
  for _ in pairs(char.opened[id] or {}) do
    opened = opened + 1
  end
end
check(ns.chaptersOpened() == opened, "the overview counts the chapters of the factions it lists")
-- Goodwill installed on a character who has raised factions already: they list
-- at the login, their chapters opened quietly
GoodwillChar = nil
s.printed = {}
s.rep[609], s.rep[TIMBERMAW] = ns.startRep(609) + 2400, ns.startRep(TIMBERMAW) + 4300 -- (Neutral at 800)
G.login()
char = GoodwillChar
check(listed(609) and listed(TIMBERMAW), "factions already raised list at the first login")
check(ns.opened(TIMBERMAW, "start") and not ns.opened(TIMBERMAW, "friendly"), "their chapters opened with them")
check(not said(NEW_CHAPTER), "quietly at the login")
s.rep[609], s.rep[TIMBERMAW] = nil, nil
GoodwillChar = nil
G.login()
char = GoodwillChar
check(D.factions[72] and D.factions[76], "both sides' capitals in the data")
local mine = {}
for _, id in ipairs(ns.factions()) do
  mine[id] = true
end
check(mine[72] and not mine[76], "an Alliance character follows Stormwind, not Orgrimmar")
local side = {}
for _, id in ipairs(ns.sideFactions()) do
  side[id] = true
end
check(
  (side[2779] or false) == G.FOREVER,
  "Forever's own factions only on Forever (the High Order, the Alliance's Skyborne)"
)

-- ── standings rising ─────────────────────────────────────────────────────────
s.printed = {}
s.rep[TIMBERMAW] = 3100
fire("UPDATE_FACTION")
check(ns.opened(TIMBERMAW, "friendly"), "Friendly with the Timbermaw: its chapter opened")
check(said(NEW_CHAPTER), "said in chat")
check(said("|Hgoodwill:story:"), "the new chapter a link in chat, to its story")
check(GoodwillBanner1 and GoodwillBanner1:IsShown(), "and on a banner among the game's alerts")
-- (the banner a switch of its own: off, the line in chat alone)
GoodwillBanner1:Hide()
ns.setOption("chapterBanner", false)
s.printed = {}
s.rep[DAWN] = 3100
fire("UPDATE_FACTION")
check(
  ns.opened(DAWN, "friendly") and said(NEW_CHAPTER) and not GoodwillBanner1:IsShown(),
  "the banner off: the line alone"
)
ns.setOption("chapterBanner", true)
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
  local _, clan = ns.chapter(889, "revered")
  local kelm = table.concat(clan, " ")
  check(kelm:find(G.FOREVER and "clan Chanteguerre" or "clan Warsong", 1, true), "Kelm's clan as this client names it")
  local at = {}
  for i, swap in ipairs(ns.classicNames) do
    at[swap[1]] = i
  end
  check(at["Goulet des Chanteguerres"] < at["Chanteguerre"], "a name holding another swapped first")
end

-- ── a German reader, a woman ────────────────────────────────────────────────
if G.LOCALE == "deDE" then
  s.sex = 3
  local _, revered = ns.chapter(TIMBERMAW, "revered")
  local text = table.concat(revered, " ")
  check(text:find("keine Fremde", 1, true) and text:find("Respektvoll", 1, true), "the reader agreed to: a woman")
  check(not text:find("$g", 1, true), "no token left")
  s.sex = 2
  local _, honoredT = ns.chapter(THORIUM, "honored")
  check(table.concat(honoredT, " "):find("Ironforge", 1, true), "the city's name as the German clients write it")
end

-- ── a Spanish reader, a woman (esES, and esMX on its words) ─────────────────
if G.LOCALE == "esES" or G.LOCALE == "esMX" then
  s.sex = 3
  local _, revered = ns.chapter(TIMBERMAW, "revered")
  local text = table.concat(revered, " ")
  check(text:find("una forastera", 1, true) and text:find("Venerada", 1, true), "the reader agreed to: a woman")
  check(not text:find("$g", 1, true), "no token left")
  s.sex = 2
  local _, honoredT = ns.chapter(THORIUM, "honored")
  check(table.concat(honoredT, " "):find("Forjaz", 1, true), "the city's name as the Spanish clients write it")
  local _, ravenholdt = ns.chapter(349, "start")
  local syndicate = table.concat(ravenholdt, " ")
  if G.LOCALE == "esMX" then
    check(
      syndicate:find("la Hermandad", 1, true) and not syndicate:find("Sindicato", 1, true),
      "esMX's own name for the Syndicate"
    )
  else
    check(syndicate:find("el Sindicato", 1, true), "esES's name for the Syndicate")
  end
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
-- a repeatable that asks no item (Winterfall Intrusion, a kill): its own card, no count
local intrusion
for _, t in ipairs(ns.road.turnins(589)) do
  if t.quest == 5201 then intrusion = t end
end
check(intrusion and intrusion.errand and #intrusion.items == 0, "Winterfall Intrusion: an errand, no items")
-- the spillover: Everlook has no kills of its own, but half of what its
-- sisters earn comes to it, Gadgetzan's Southsea pirates among them, all the
-- way to Exalted
s.rep[577] = 40000
s.done[1707] = true
local throughGadgetzan = false
for _, z in ipairs(ns.road.kills(577)) do
  if z.via == 369 then throughGadgetzan = true end
end
check(throughGadgetzan, "Everlook: Gadgetzan's kills still count, through it, near Exalted")
local pouches
for _, t in ipairs(ns.road.turnins(577)) do
  if t.quest == 1878 then pouches = t end
end
check(
  pouches and pouches.each == 5 and pouches.via == 369,
  "the Water Pouch Bounty: five for Everlook, through Gadgetzan"
)
check(ns.data.factions[577].spill.rate == 0.5, "Everlook takes half of what its sisters earn")
check(ns.data.factions[72].spill.rate == 0.25, "Stormwind a quarter of what its side's capitals earn")
s.rep[577], s.done[1707] = nil, nil
-- three turn-ins sharing their Coal and Incendosaur Scales: held from one pool
s.rep[THORIUM] = 100
s.done[7722] = true
s.bags[3356], s.bags[3575], s.bags[4234], s.bags[3857], s.bags[18944] = 40, 40, 100, 1, 2
local alone = 0
for _, t in ipairs(ns.road.turnins(THORIUM)) do
  if t.open then alone = alone + t.times * t.each end
end
check(alone == 75 and ns.road.held(THORIUM) == 25, "shared items counted once: one Fiery Flux, not three")
s.rep[THORIUM] = nil
-- a quest above the character's level: offered from that level, not now
local early = false
for _, q in ipairs(ns.road.quests(DAWN)) do
  if q.from and not q.open then early = true end
end
check(early, "the Dawn's level 55 quests: from level 55, at level 12")
local unlocks = ns.road.unlocks(DAWN)
check(#unlocks > 0 and unlocks[1].standing >= ns.FRIENDLY, "what each standing unlocks, Friendly up")

-- ── the book ─────────────────────────────────────────────────────────────────
ns.toggle()
check(GoodwillFrame and GoodwillFrame:IsShown(), "the book opens")
G.advance(0.5)
for _, id in ipairs({ TIMBERMAW, DAWN, THORIUM, 72, 21, 577, 589, 47, 730 }) do
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
for _, id in ipairs(ns.sideFactions()) do
  horde[id] = true
end
check(horde[76] and not horde[72], "a Horde character follows Orgrimmar, not Stormwind")
s.faction = nil

-- ── a Skyborne (Forever) ──────────────────────────────────────────────────────
-- (its race's bit in a quest's mask is the client's, 33 for a Windshaper
-- Skyborne, not its id's: race 96)
if G.FOREVER then
  local windshapers = D.quests[92595]
  check(windshapers and not ns.forMe(windshapers), "a dwarf isn't offered the Windshapers' own quest")
  s.race, s.faction = 96, "Horde"
  s.rep[2778] = 3100 -- (a Windshaper Skyborne starts Friendly)
  check(ns.forMe(windshapers), "a Windshaper Skyborne is")
  ns.readAll(true)
  check(ns.opened(2778, "start") and ns.opened(2778, "friendly"), "both of the Windshapers' chapters at level 1")
  local follows = {}
  for _, id in ipairs(ns.sideFactions()) do
    follows[id] = true
  end
  check(follows[2778] and not follows[2779], "the Horde's Skyborne follow the Windshapers, not the High Order")
  s.race, s.faction = nil, nil
end

-- ── the achievements ─────────────────────────────────────────────────────────
-- (counted over this side's factions: an Alliance character's capitals are four
-- of the eight, and a first gain, a standing reached and the stories are earned
-- as the sections above played them)
local earned = GoodwillChar.achievements or {}
check(earned["gain-1"] and earned["gain-1"].level == s.level, "the first gain earned, with its level")
check(earned["honored-1"] and earned["revered-1"], "the standings reached, earned")
local ACH = L["Achievement earned: %s."]:match("^(.-)%%s")
check(said(ACH), "said in chat")
local capitals = ns.achievementById["group-capitals"]
local done, need = capitals.progress()
local mineCapitals = 0
for _, id in ipairs(ns.sideFactions()) do
  if D.factions[id].group == "capitals" then mineCapitals = mineCapitals + 1 end
end
check(need == mineCapitals and need < 8, "the capitals' achievement asks this side's capitals only")
check(ns.deeds:visible(capitals), "listed where the side has them")
check(ns.achievementById["story-1"].progress() ~= nil, "the stories' counts")
-- the book at its tab, one of them picked out
ns.openAchievements("gain-1")
G.advance(0.3)
check(
  GoodwillFrame.selectedTab == ns.TAB.achievements and #ns.achievementRows > 0,
  "the achievements' board, one picked out"
)
-- the alert behind its switch
ns.setOption("achievementToast", false)
for _, name in ipairs({ "GoodwillAchievementBanner1", "AchievementAlertFrame1" }) do
  if _G[name] then _G[name]:Hide() end
end
s.printed = {}
s.rep[TIMBERMAW] = 42500
fire("UPDATE_FACTION")
check(GoodwillChar.achievements["exalted-1"] and said(ACH), "with the alert off the line in chat alone")
check(
  not (GoodwillAchievementBanner1 and GoodwillAchievementBanner1:IsShown())
    and not (AchievementAlertFrame1 and AchievementAlertFrame1:IsShown()),
  "and no alert shown"
)
ns.setOption("achievementToast", true)
-- an old character at the login: all it deserves recorded quietly
GoodwillChar.achievements = {}
s.printed = {}
ns.readAll(true)
check(GoodwillChar.achievements["gain-1"].retro and not said(ACH), "already deserved: recorded quietly at the login")
-- the gates: a step past what the side has, a group of fewer than two
local sideN = #ns.sideFactions()
check(
  not ns.deeds:visible(ns.achievementById["exalted-20"]) or sideN > 20,
  "an Exalted count past the side's factions isn't listed"
)
local d = ns.achievementById["group-battlegrounds"]
local battle = 0
for _, id in ipairs(ns.sideFactions()) do
  if D.factions[id].group == "battlegrounds" then battle = battle + 1 end
end
check(ns.deeds:visible(d) == (battle >= 2), "a group is listed where the side has two or more")
local _, storyNeed = ns.achievementById["story-all"].progress()
local all = 0
for id, pieces in pairs(ns.chapters) do
  if
    id ~= 349
    and D.factions[id]
    and ns.hasChapters(id)
    and (not D.factions[id].side or D.factions[id].side == ns.side())
  then
    for _ in pairs(pieces) do
      all = all + 1
    end
  end
end
check(storyNeed == all, "the stories' last leaves out the one only the Rogues finish (Ravenholdt)")

-- ── /goodwill ────────────────────────────────────────────────────────────────
-- (the family's command: an unknown word prints the usage, the replies capitalised)
s.printed = {}
SlashCmdList.GOODWILL("nonsense")
check(said("/goodwill"), "/goodwill nonsense: the usage")
s.printed = {}
SlashCmdList.GOODWILL("import " .. ns.profiles:export())
check(said(L["Settings imported for this character."]), "/goodwill import CODE: said, capitalised")
s.printed = {}
local hidden = ns.option("minimapHidden")
SlashCmdList.GOODWILL("minimap")
check(
  ns.option("minimapHidden") == not hidden
    and said(L["Minimap button hidden (%s minimap shows it again)."]:format("/goodwill")),
  "/goodwill minimap: the button hidden, said"
)
SlashCmdList.GOODWILL("minimap")
check(ns.option("minimapHidden") == hidden and said(L["Minimap button shown."]), "… and shown again")
-- The Options page (the game's panel): the chapter's banner a box of its own, the setting itself.
local banner = G.panel.settings.GOODWILL_CHAPTERBANNER
check(
  banner and banner.get() == ns.option("chapterBanner") and banner.default == true,
  "the Options page: the chapter's banner, on by default"
)
banner.set(false)
check(ns.option("chapterBanner") == false, "… its box turns it off")
banner.set(true)

io.write(("Goodwill: %d checks passed (%s, %s).\n"):format(count, G.LOCALE, G.FOREVER and "Forever" or "Classic Era"))

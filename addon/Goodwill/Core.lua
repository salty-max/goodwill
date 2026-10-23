-- Goodwill: this character's standing with every faction the book follows,
-- the chapters each standing has opened, the events every file listens to
-- (ns.on), and /goodwill. The road (Road.lua) reads the
-- standings; the book shows them (Book.lua and its tabs).
--
--   GoodwillChar (SavedVariablesPerCharacter), whose book: guid
--     opened[faction][piece] = { at, level }   each chapter opened (start,
--                                              friendly, honored, revered,
--                                              aside, exalted)
--     bank[item] = n, bankAt                   the turn-ins' items in the bank,
--                                              as last seen there
--   GoodwillSettings (SavedVariables): each character's settings, the kit's
--     profiles (Settings.lua: the minimap button)
--
-- Every record by id: a faction by its id, an item by its; their names are
-- the game's, in the client's language, when shown.
local _, ns = ...
local L, D = ns.kit.L, ns.data
ns.PREFIX = "|cff9fd0a0Goodwill:|r "
-- The book's mark, also used by the minimap, welcome and banners.
ns.ICON = "Interface\\AddOns\\Goodwill\\Media\\Logo"

-- Forever hides some values from addons ("secret values"): never compare one.
ns.secret = issecretvalue or function() return false end

local char
function ns.book() return char end

-- ── events ───────────────────────────────────────────────────────────────────
-- Every file listens through ns.on (an event a client doesn't know is never
-- heard), unit events through ns.onUnit. Nothing is heard before the login.
local frame = CreateFrame("Frame")
local listeners = {}

-- (one listener's error is reported, and the others still hear the event)
local function run(fn, ...)
  local ok, err = pcall(fn, ...)
  if not ok then geterrorhandler()(err) end
end

frame:SetScript("OnEvent", function(_, event, ...)
  if event == "PLAYER_LOGIN" then run(ns.login) end
  if not char then return end
  for _, fn in ipairs(listeners[event] or {}) do
    run(fn, ...)
  end
end)
frame:RegisterEvent("PLAYER_LOGIN")

function ns.on(event, fn)
  if not listeners[event] then
    listeners[event] = {}
    pcall(frame.RegisterEvent, frame, event)
  end
  table.insert(listeners[event], fn)
end

-- ── the standings ────────────────────────────────────────────────────────────
-- The game's standings, 1 Hated to 8 Exalted, and where each begins.
ns.HATED, ns.NEUTRAL, ns.FRIENDLY, ns.HONORED, ns.REVERED, ns.EXALTED = 1, 4, 5, 6, 7, 8
ns.THRESHOLDS = { -42000, -6000, -3000, 0, 3000, 9000, 21000, 42000 }
-- The pieces of a faction's story, the standing each opens at (the aside:
-- halfway from Revered to Exalted).
ns.PIECES = {
  { "start", 1 },
  { "friendly", 5 },
  { "honored", 6 },
  { "revered", 7 },
  { "aside", 7, 31500 },
  { "exalted", 8 },
}
-- The standing's name, the game's (FACTION_STANDING_LABEL1..8, its female
-- form where the language has one).
function ns.standingName(standing)
  local female = UnitSex and UnitSex("player") == 3
  local his = {
    FACTION_STANDING_LABEL1,
    FACTION_STANDING_LABEL2,
    FACTION_STANDING_LABEL3,
    FACTION_STANDING_LABEL4,
    FACTION_STANDING_LABEL5,
    FACTION_STANDING_LABEL6,
    FACTION_STANDING_LABEL7,
    FACTION_STANDING_LABEL8,
  }
  local hers = {
    FACTION_STANDING_LABEL1_FEMALE,
    FACTION_STANDING_LABEL2_FEMALE,
    FACTION_STANDING_LABEL3_FEMALE,
    FACTION_STANDING_LABEL4_FEMALE,
    FACTION_STANDING_LABEL5_FEMALE,
    FACTION_STANDING_LABEL6_FEMALE,
    FACTION_STANDING_LABEL7_FEMALE,
    FACTION_STANDING_LABEL8_FEMALE,
  }
  return (female and hers[standing]) or his[standing] or ""
end

-- A faction's standing as the game tells it: the standing, the reputation
-- (the game's own figure: 0 is Neutral's start), where the standing begins
-- and where the next does. Forever's client its C_Reputation, Classic Era's
-- GetFactionInfoByID. Nil: the game names no such faction.
function ns.standingOf(id)
  if C_Reputation and C_Reputation.GetFactionDataByID then
    local d = C_Reputation.GetFactionDataByID(id)
    if d and not ns.secret(d.currentStanding) then
      return d.reaction, d.currentStanding, d.currentReactionThreshold, d.nextReactionThreshold
    end
  end
  if GetFactionInfoByID then
    local name, _, standing, low, high, value = GetFactionInfoByID(id)
    if name and not ns.secret(value) then return standing, value, low, high end
  end
end

-- The character's side, race and class, as the data's masks read them.
function ns.side() return UnitFactionGroup("player") == "Horde" and "H" or "A" end
local function bit(n) return 2 ^ (n - 1) end
local function hasBit(mask, n)
  if not mask or mask == 0 then return true end
  return math.floor(mask / bit(n)) % 2 == 1
end
function ns.forMe(q)
  local _, _, race = UnitRace("player")
  local _, _, class = UnitClass("player")
  return hasBit(q.races, race or 0) and hasBit(q.classes, class or 0)
end

-- The factions the book follows for this character: its side's and both
-- sides', in the data's order.
function ns.factions()
  local out, side = {}, ns.side()
  for _, id in ipairs(D.order) do
    local f = D.factions[id]
    if not f.side or f.side == side then table.insert(out, id) end
  end
  return out
end
function ns.factionName(id) return ns.factionNames and ns.factionNames[id] or ("#" .. id) end
function ns.npcName(id) return ns.npcNames and ns.npcNames[id] end
function ns.questName(id) return ns.questNames and ns.questNames[id] end

-- A quest done, as the game keeps it.
function ns.done(quest)
  if C_QuestLog and C_QuestLog.IsQuestFlaggedCompleted then return C_QuestLog.IsQuestFlaggedCompleted(quest) == true end
  if IsQuestFlaggedCompleted then return IsQuestFlaggedCompleted(quest) == true end
  return false
end

-- ── the chapters ─────────────────────────────────────────────────────────────
-- A faction's piece, as this client's language writes it (Chapters_<locale>):
-- its title and the paragraphs the reader may see now (a paragraph after a
-- quest once it's done, one before it until then), agreed to the reader and
-- Classic Era's names swapped in there.
local function swapped(text)
  if ns.forever or not ns.classicNames then return text end
  for forever, classic in pairs(ns.classicNames) do
    text = text:gsub(forever:gsub("%p", "%%%0"), (classic:gsub("%%", "%%%%")))
  end
  return text
end
function ns.chapter(faction, piece)
  local c = ns.chapters and ns.chapters[faction] and ns.chapters[faction][piece]
  if not c then return nil end
  local out = {}
  for _, p in ipairs(c) do
    if (not p.after or ns.done(p.after)) and (not p.before or not ns.done(p.before)) then
      table.insert(out, ns.agree(swapped(p[1])))
    end
  end
  return ns.agree(swapped(c.title)), out
end
function ns.hasChapters(faction) return ns.chapters and ns.chapters[faction] ~= nil end
-- How many chapters this character has opened, every faction's.
function ns.chaptersOpened()
  local n = 0
  for _, pieces in pairs(char and char.opened or {}) do
    for _ in pairs(pieces) do
      n = n + 1
    end
  end
  return n
end
function ns.opened(faction, piece) return char and char.opened[faction] and char.opened[faction][piece] end

-- Is a piece reached at this standing?
local function reached(piece, standing, value)
  if piece[3] then return standing >= piece[2] and (standing > ns.REVERED or (value or 0) >= piece[3]) end
  return standing >= piece[2]
end
ns.reached = reached

-- Every piece a faction's standing has reached joins the book: quietly at
-- the login, else with a line in chat and a banner.
local banners
local function announce(faction, piece)
  local title = ns.chapter(faction, piece)
  local name = ns.factionName(faction)
  print(ns.PREFIX .. L["A new chapter from %s: %s."]:format(name, "|cffffd27f" .. (title or "") .. "|r"))
  banners = banners or ns.kit.banners({ name = "GoodwillBanner", art = ns.ICON })
  banners:show({
    picture = ns.kit.icon(ns.ICON),
    kicker = name,
    title = title or "",
    tip = L["A new chapter of their story. Click to read it."],
    click = function()
      if ns.openStory then ns.openStory(faction, piece) end
    end,
  })
end

function ns.readStanding(faction, quietly)
  local standing, value = ns.standingOf(faction)
  if not standing then return end
  if not ns.hasChapters(faction) then return end
  char.opened[faction] = char.opened[faction] or {}
  for _, piece in ipairs(ns.PIECES) do
    if not char.opened[faction][piece[1]] and reached(piece, standing, value) and ns.chapters[faction][piece[1]] then
      char.opened[faction][piece[1]] = { at = time(), level = UnitLevel("player") }
      if not quietly then announce(faction, piece[1]) end
    end
  end
end

function ns.readAll(quietly)
  for _, id in ipairs(ns.factions()) do
    ns.readStanding(id, quietly)
  end
  if ns.onChange then ns.onChange() end
end

-- ── the bank ─────────────────────────────────────────────────────────────────
-- The turn-ins' items in the bank, read while it's open (the game tells the
-- bank's count only then), kept for the road between visits.
local function countOf(item, bank)
  if C_Item and C_Item.GetItemCount then return C_Item.GetItemCount(item, bank) or 0 end
  return GetItemCount and GetItemCount(item, bank) or 0
end
ns.countOf = countOf
function ns.readBank()
  char.bank = {}
  for item in pairs(ns.turninItems()) do
    local n = countOf(item, true) - countOf(item, false)
    if n > 0 then char.bank[item] = n end
  end
  char.bankAt = time()
  if ns.onChange then ns.onChange() end
end
-- Every item a turn-in of the data asks.
local turninItems
function ns.turninItems()
  if turninItems then return turninItems end
  turninItems = {}
  for _, q in pairs(D.quests) do
    for i = 1, #(q.items or {}), 2 do
      turninItems[q.items[i]] = true
    end
  end
  return turninItems
end
-- What the character carries of an item, and what the bank held when last seen.
function ns.carried(item) return countOf(item, false) end
function ns.banked(item) return char and char.bank and char.bank[item] or 0 end

-- ── the login ────────────────────────────────────────────────────────────────
local function newBook(guid) return { guid = guid, opened = {}, bank = {} } end

function ns.login()
  local guid = UnitGUID("player")
  if type(GoodwillChar) ~= "table" or GoodwillChar.guid ~= guid then GoodwillChar = newBook(guid) end
  char = GoodwillChar
  char.opened, char.bank = char.opened or {}, char.bank or {}
  ns.loadProfile()
  if ns.createMinimapButton then ns.createMinimapButton() end
  if ns.createSettingsPanel then ns.createSettingsPanel() end
  ns.readAll(true)
  ns.loggedIn = true
end

-- A standing changed: the chapters it reached (the game tells it for any
-- faction at once, so every one followed is read again).
ns.on("UPDATE_FACTION", function()
  if ns.loggedIn then ns.readAll(false) end
end)
-- A quest turned in: a paragraph after it may show now, the road shortens.
ns.on("QUEST_TURNED_IN", function()
  if ns.onChange then ns.onChange() end
end)
-- (the bank's bags change while it's open: read again; the bags alone, the road)
local bankOpen = false
ns.on("BAG_UPDATE_DELAYED", function()
  if bankOpen then
    ns.readBank()
  elseif ns.onChange then
    ns.onChange()
  end
end)
ns.on("BANKFRAME_OPENED", function()
  bankOpen = true
  ns.readBank()
end)
ns.on("BANKFRAME_CLOSED", function() bankOpen = false end)
ns.on("PLAYERBANKSLOTS_CHANGED", function() ns.readBank() end)

-- ── /goodwill ────────────────────────────────────────────────────────────────
SLASH_GOODWILL1 = "/goodwill"
SlashCmdList.GOODWILL = function(msg)
  local raw = strtrim(msg or "") -- (a code's letters as typed)
  msg = raw:lower()
  if msg == "stories" then
    if ns.openStory then ns.openStory() end
  elseif msg == "minimap" then
    ns.setOption("minimapHidden", not ns.option("minimapHidden"))
  elseif msg == "settings" then
    if not ns.openSettings() then print(ns.PREFIX .. L["The game's Options have no page for addons here."]) end
  elseif msg == "welcome" then
    if ns.showWelcome then ns.showWelcome() end
  elseif msg == "export" then
    if ns.showWelcome then ns.showWelcome("export") end
  elseif msg:match("^import%s") then
    if ns.profiles:import(raw:match("^%a+%s+(.+)$")) then
      print(ns.PREFIX .. L["Settings imported for this character."])
    else
      print(ns.PREFIX .. L["That isn't a Goodwill settings code."])
    end
  elseif ns.toggle then
    ns.toggle()
  end
end

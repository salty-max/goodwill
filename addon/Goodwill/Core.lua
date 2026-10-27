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
-- The kit's look (Kit.lua), in Goodwill's theme: a quiet green, the colour the
-- game gives a friendly standing, over panels a shade cooler than parchment.
ns.kit.theme({
  accent = { 0.62, 0.85, 0.60 },
  ring = { 0.42, 0.62, 0.40 },
  bar = { 0.35, 0.72, 0.35 },
  tint = { 0.92, 1.00, 0.92 },
  shade = { 0.01, 0.03, 0.01, 0.55 },
  highlight = { 0.80, 1.00, 0.80 },
})

ns.PREFIX = ns.kit.prefix("Goodwill")
-- The book's mark: the logo's medallion cut round (Media/Medallion,
-- assets/README.md) wherever the picture is round (the window's portrait, the
-- pages' and cards' pictures, the banners, the minimap button, the welcome's
-- portrait); the whole square logo where a square shows (the addon list, the
-- welcome page's logo).
ns.ICON = "Interface\\AddOns\\Goodwill\\Media\\Medallion"
ns.LOGO = "Interface\\AddOns\\Goodwill\\Media\\Logo"

-- Forever hides some values from addons ("secret values"): never compare one.
ns.secret = ns.kit.secret

local char
function ns.book() return char end

-- ── events ───────────────────────────────────────────────────────────────────
-- Every file listens through ns.on (the kit's events: each listener on its
-- own, an event a client doesn't know never heard), nothing before the login
-- has opened this character's book.
local events = ns.kit.events({ login = function() ns.login() end, ready = function() return char ~= nil end })
ns.on = events.on

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
-- (the kit's: a race's bit is its id's, one less, but where the data's
-- raceBits say otherwise, Forever's Skyborne)
function ns.forMe(q) return ns.kit.forMe(q.races, q.classes, D.raceBits) end

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
ns.done = ns.kit.questDone

-- ── the chapters ─────────────────────────────────────────────────────────────
-- A faction's piece, as this client's language writes it (Chapters_<locale>):
-- its title and the paragraphs the reader may see now (a paragraph after a
-- quest once it's done, one before it until then), agreed to the reader and
-- Classic Era's names swapped in there.
local function swapped(text)
  if ns.forever or not ns.classicNames then return text end
  return ns.kit.swap(text, ns.classicNames) -- (the longest first)
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
-- (a story's link in chat, |Hgoodwill:story:<faction>|h, the kit's: a click
-- opens it, as the Codex's and Yonder's links open theirs)
local link = ns.kit.links("goodwill", function(target)
  local faction = tonumber(target:match("^story:(%d+)$") or "")
  if faction and ns.openStory then ns.openStory(faction) end
end)
local function announce(faction, piece)
  local title = ns.chapter(faction, piece)
  local name = ns.factionName(faction)
  print(ns.PREFIX .. L["A new chapter from %s: %s."]:format(name, link("story:" .. faction, title or "")))
  if not ns.option("chapterBanner") then return end -- (the player's switch)
  banners = banners
    or ns.kit.banners({
      name = "GoodwillBanner",
      art = ns.ICON,
      seconds = function() return ns.option("bannerSeconds") end,
    })
  banners:show({
    -- (the whole medallion, its rim in the ring: K.icon would crop it as a game icon)
    picture = function(p)
      p.tex:SetTexture(ns.ICON)
      p.tex:SetTexCoord(0, 1, 0, 1)
    end,
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
-- The kit's command (K.commands): alone it opens the book, an unknown word
-- prints the usage.
ns.kit.commands({
  names = { "/goodwill" },
  key = "GOODWILL",
  name = "Goodwill",
  prefix = ns.PREFIX,
  profiles = function() return ns.profiles end, -- (Settings.lua makes them, after this file)
  open = function()
    if ns.toggle then ns.toggle() end
  end,
  usage = L["/goodwill opens the book, /goodwill stories its stories and /goodwill settings its settings. /goodwill minimap shows or hides the button, /goodwill welcome shows the welcome page again. /goodwill export gives this character's settings as a code, and /goodwill import CODE takes them."],
  settings = function() return ns.openSettings() end,
  welcome = function(mode)
    if ns.showWelcome then ns.showWelcome(mode) end
  end,
  -- (looked up when used: Settings.lua makes them, after this file)
  minimap = { get = function(k) return ns.option(k) end, set = function(k, v) ns.setOption(k, v) end },
  commands = {
    stories = function()
      if ns.openStory then ns.openStory() end
    end,
  },
})

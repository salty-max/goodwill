-- Goodwill as a book: the family's window (portrait, title bar), its tabs
-- (Factions, Stories: each a file of its own, *Book.lua, registered with
-- ns.addTab), and what every tab is made of (ns.ui): the kit's look in
-- Goodwill's theme, its list on the left and page on the right. /goodwill
-- opens it.
local _, ns = ...
local K, L = ns.kit, ns.kit.L

-- ── look ─────────────────────────────────────────────────────────────────────
-- The kit's (Kit.lua), in Goodwill's theme: a quiet green, the colour the
-- game gives a friendly standing, over panels a shade cooler than parchment.
K.theme({
  accent = { 0.62, 0.85, 0.60 },
  ring = { 0.42, 0.62, 0.40 },
  bar = { 0.35, 0.72, 0.35 },
  tint = { 0.92, 1.00, 0.92 },
  shade = { 0.01, 0.03, 0.01, 0.55 },
  highlight = { 0.80, 1.00, 0.80 },
})
local T = K.T

-- The book's groups, in its order (data/factions.json's).
local GROUPS = {
  endgame = L["Azeroth's factions"],
  capitals = L["The capitals"],
  steamwheedle = L["The Steamwheedle towns"],
  others = L["Others"],
  forever = L["Forever's own"],
  battlegrounds = L["The battlegrounds"],
}

-- ── the window ───────────────────────────────────────────────────────────────
local book
local TAB = { factions = 1, stories = 2 }
ns.TAB = TAB
local tabs, TITLES = {}, { L["Factions"], L["Stories"] }
function ns.addTab(n, tab) tabs[n] = tab end

function ns.refresh()
  local tab = book and tabs[book.selectedTab]
  if tab and tab.built then tab.refresh() end
end

function ns.showTab(n)
  if not book then return end
  book.selectedTab = n
  if PanelTemplates_SetTab then PanelTemplates_SetTab(book, n) end
  local tab = tabs[n]
  if not tab.built then
    tab.build(book)
    tab.built = true
  end
  for _, t in ipairs(tabs) do
    if t.built then t.show(n) end
  end
  ns.refresh()
end

local function build()
  local window = K.gameWindow("GoodwillFrame", "Goodwill", ns.ICON)
  book = window or K.dialog("GoodwillFrame", "Goodwill")
  K.movable(book, 780, 560)
  local edge = window and 8 or 14
  book.count = K.label(book, K.BODY_FONT, 11, T.gold)
  book.count:SetPoint("TOPLEFT", 64, -36)
  book.left = K.panel(book, true)
  book.left:SetPoint("TOPLEFT", edge, -58)
  book.left:SetPoint("BOTTOMLEFT", edge, edge)
  book.left:SetWidth(244)
  book.sheet = K.panel(book)
  book.sheet:SetPoint("TOPLEFT", book.left, "TOPRIGHT", 4, 32)
  book.sheet:SetPoint("BOTTOMRIGHT", -edge, edge)
  book.search = CreateFrame("EditBox", "GoodwillSearch", book, "SearchBoxTemplate")
  book.search:SetHeight(20)
  book.search:SetPoint("TOPLEFT", book.left, "TOPLEFT", 18, -10)
  book.search:SetPoint("TOPRIGHT", book.left, "TOPRIGHT", -12, -10)
  book.search:HookScript("OnTextChanged", function() ns.refresh() end)
  book.selectedTab = TAB.factions
  book:SetScript("OnShow", function() ns.showTab(book.selectedTab) end)
  K.tabs(book, TITLES, function(n) ns.showTab(n) end)
end

local function window()
  if not book then build() end
  return book
end

function ns.toggle() window():SetShown(not book:IsShown()) end

function ns.openTab(n)
  window()
  book.selectedTab = n
  if book:IsShown() then
    ns.showTab(n)
  else
    book:Show()
  end
end

-- What the game tells while the book is open shows at once (a moment later:
-- a batch of turn-ins comes one reputation gain after another).
local pending = false
ns.onChange = function()
  if not (book and book:IsShown()) or pending then return end
  pending = true
  C_Timer.After(0.3, function()
    pending = false
    ns.refresh()
  end)
end

-- (an item's name the game tells late: the page again, its name in; only one
-- the book shows, a turn-in's or an unlock's)
local shown
local function bookItems()
  if shown then return shown end
  shown = {}
  for item in pairs(ns.turninItems()) do
    shown[item] = true
  end
  for _, f in pairs(ns.data.factions) do
    for _, u in ipairs(f.unlocks or {}) do
      if u.item then shown[u.item] = true end
    end
  end
  return shown
end
ns.on("GET_ITEM_INFO_RECEIVED", function(item, success)
  if success and bookItems()[item] and ns.onChange then ns.onChange() end
end)

-- ── the parts every tab is made of ───────────────────────────────────────────
local function query() return K.query(book.search) end
local function day(stamp) return K.day(stamp and stamp.at) end
local function zoneName(area) return K.areaName(area) end
-- The zone the character stands in, as the data names zones (by name: the
-- client gives its zone's name, the data its id).
function ns.zoneHere()
  local here = GetRealZoneText and GetRealZoneText()
  if not here then return nil end
  for id in pairs(ns.zoneIds()) do
    if zoneName(id) == here then return id end
  end
end
local zones
function ns.zoneIds()
  if zones then return zones end
  zones = {}
  for _, n in pairs(ns.data.npcs) do
    if n.area then zones[n.area] = true end
  end
  for _, q in pairs(ns.data.quests) do
    if q.zone then zones[q.zone] = true end
  end
  return zones
end
-- "Felwood 64, 8": an npc's zone and its spot there (a zone alone when the
-- data has no spot).
local function where(id)
  local n = id and ns.data.npcs[id]
  local zone = n and zoneName(n.area)
  if not zone then return "" end
  if n.x then return ("%s %d, %d"):format(zone, n.x, n.y) end
  return zone
end
-- A standing's colour, the game's (FACTION_BAR_COLORS).
local function standingColour(standing)
  local c = FACTION_BAR_COLORS and FACTION_BAR_COLORS[standing]
  if not c then return "|cffffffff" end
  return K.hex({ c.r, c.g, c.b })
end
local function standingWord(standing) return standingColour(standing) .. ns.standingName(standing) .. "|r" end

ns.ui = {
  T = T,
  GROUPS = GROUPS,
  query = query,
  day = day,
  zoneName = zoneName,
  where = where,
  standingWord = standingWord,
  icon = K.icon,
  newList = K.list,
  newPage = function(parent, name) return K.page(parent, name, { labelWidth = 120, pairs = {} }) end,
}

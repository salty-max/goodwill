-- Goodwill as a book: the family's window (portrait, title bar), its tabs
-- (Factions, Stories: each a file of its own, *Book.lua, registered with
-- ns.addTab), and what every tab is made of (ns.ui): the kit's look in
-- Goodwill's theme, its list on the left and page on the right. /goodwill
-- opens it.
local _, ns = ...
local K, L = ns.kit, ns.kit.L

-- ── look ─────────────────────────────────────────────────────────────────────
-- The kit's (Kit.lua), its theme (Goodwill's: a quiet green) set first thing in Core.lua.
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
-- The kit's book (K.book): the window, its two panels, the search, the tabs;
-- each tab a file of its own, registered with ns.addTab.
local TAB = { factions = 1, stories = 2 }
ns.TAB = TAB
local B = K.book({
  name = "GoodwillFrame",
  title = "Goodwill",
  -- (where it was left, kept with the account's settings)
  place = function()
    GoodwillSettings = GoodwillSettings or {}
    return K.place(GoodwillSettings, "book")
  end,
  art = ns.ICON,
  titles = { L["Factions"], L["Stories"] },
  first = TAB.factions,
  search = "GoodwillSearch",
  settle = 0.3,
})
function ns.addTab(n, tab) B:add(n, tab) end
function ns.refresh() B:refresh() end
function ns.showTab(n) B:show(n) end
function ns.toggle() B:toggle() end
function ns.openTab(n) B:open(n) end

-- What the game tells while the book is open shows at once (a moment later:
-- a batch of turn-ins comes one reputation gain after another).
ns.onChange = function() B:changed() end

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
local function query() return K.query(B.frame.search) end
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

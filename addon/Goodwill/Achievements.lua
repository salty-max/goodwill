-- Achievements: the book's milestones, "achievements" to the player as the
-- family's other books. A first gain, the standings reached, how many
-- factions at Exalted, a group of them all at Exalted, the stories opened.
-- Counted over the factions this character's side can raise, never the other
-- side's, and no achievement asks Exalted with two factions that oppose
-- each other (Bloodsail and Booty Bay, Gelkis and Magram): there is none
-- for "every faction". Each character earns its own, and each remembers
-- when and at what level:
--   GoodwillChar.achievements[id] = { at, level, retro }
-- Earned as the game's own are: its fanfare, its own alert (behind a switch
-- of the options: achievementToast), a line in chat. Those already deserved
-- when the book first looks (a character from before them, at the login)
-- are recorded quietly.
local _, ns = ...
local K, L = ns.kit, ns.kit.L

local GROUP_ICONS = {
  standings = "Interface\\Icons\\INV_Misc_Note_01",
  exalted = "Interface\\Icons\\INV_Banner_02",
  groups = "Interface\\Icons\\INV_Misc_Book_11",
  stories = "Interface\\Icons\\INV_Scroll_05",
}
ns.achievementIcons = GROUP_ICONS

local A = K.deeds({
  saved = function()
    if type(GoodwillChar) ~= "table" then return nil end
    GoodwillChar.achievements = GoodwillChar.achievements or {}
    return GoodwillChar.achievements
  end,
  name = "Goodwill",
  prefix = ns.PREFIX,
  art = ns.ICON,
  kicker = L["Goodwill achievement"],
  alert = function() return ns.option("achievementToast") end,
  open = function(id)
    if ns.openAchievements then ns.openAchievements(id) end
  end,
  picture = function(d) return K.icon(GROUP_ICONS[d.group] or ns.ICON) end,
  sound = function() return ns.option("achievementSound") end,
  banners = K.banners({
    name = "GoodwillAchievementBanner",
    art = ns.ICON,
    seconds = function() return ns.option("bannerSeconds") end,
  }),
  changed = function()
    if ns.onChange then ns.onChange() end
  end,
})
ns.deeds = A
ns.achievements, ns.achievementById = A.list, A.byId
local function add(group, id, title, text, progress, visible) A:add(group, id, title, text, progress, visible) end

-- ── what is counted ─────────────────────────────────────────────────────────
local function side() return ns.sideFactions() end
-- (the factions of a list at a standing or better)
local function atLeast(list, standing)
  local n = 0
  for _, id in ipairs(list) do
    if (ns.standingOf(id) or 0) >= standing then n = n + 1 end
  end
  return n
end
local function inGroup(group)
  local out = {}
  for _, id in ipairs(side()) do
    if ns.data.factions[id].group == group then table.insert(out, id) end
  end
  return out
end
local function gains()
  local n = 0
  for _, id in ipairs(side()) do
    if ns.gained(id) then n = n + 1 end
  end
  return n
end
local function pieces(id)
  local have, all = 0, 0
  for piece in pairs(ns.chapters and ns.chapters[id] or {}) do
    all = all + 1
    -- (a chapter of a faction not listed yet counts for nothing: an old book's)
    if ns.opened(id, piece) and ns.doable(id) then have = have + 1 end
  end
  return have, all
end
-- (a story whose standings only one class can reach: Ravenholdt's past the
-- kills is the Rogues' alone, so it counts for no achievement)
local CLASS_LOCKED = { [349] = true }
local function voiced()
  local out = {}
  for _, id in ipairs(side()) do
    if ns.hasChapters(id) and not CLASS_LOCKED[id] then table.insert(out, id) end
  end
  return out
end

-- ── the standings ───────────────────────────────────────────────────────────
add(
  "standings",
  "gain-1",
  L["A Good Start"],
  L["Earn your first reputation with a faction."],
  function() return math.min(gains() + atLeast(side(), ns.HONORED), 1), 1 end
)
for _, step in ipairs({
  { "honored-1", ns.HONORED, L["Well Thought Of"] },
  { "revered-1", ns.REVERED, L["Looked Up To"] },
  { "exalted-1", ns.EXALTED, L["Beyond Reproach"] },
}) do
  local id, standing, title = step[1], step[2], step[3]
  add(
    "standings",
    id,
    title,
    function() return L["Reach %s with a faction."]:format(ns.standingName(standing, true)) end,
    function() return math.min(atLeast(side(), standing), 1), 1 end
  )
end

-- ── how many at Exalted ─────────────────────────────────────────────────────
-- (a step past what this side has to raise: not shown)
for _, step in ipairs({
  { 3, L["Three Friends"] },
  { 5, L["A Name That Opens Doors"] },
  { 10, L["Welcome Everywhere"] },
  { 20, L["A Friend to the World"] },
}) do
  local need, title = step[1], step[2]
  add(
    "exalted",
    "exalted-" .. need,
    title,
    function() return L["Reach %s with %d factions."]:format(ns.standingName(ns.EXALTED, true), need) end,
    function() return atLeast(side(), ns.EXALTED), need end,
    function() return need < #side() end
  )
end

-- ── the groups ──────────────────────────────────────────────────────────────
-- (only those whose factions can all stand at Exalted together, and where
-- this side has two or more)
for _, g in ipairs({
  { "endgame", L["Azeroth's Champion"], L["Reach %s with every one of Azeroth's factions."] },
  { "capitals", L["Friend of the Cities"], L["Reach %s with every capital of your side."] },
  { "steamwheedle", L["The Cartel's Friend"], L["Reach %s with all the Steamwheedle towns."] },
  { "battlegrounds", L["Veteran of the Fields"], L["Reach %s with every battleground faction of your side."] },
}) do
  local group, title, text = g[1], g[2], g[3]
  add(
    "groups",
    "group-" .. group,
    title,
    function() return text:format(ns.standingName(ns.EXALTED, true)) end,
    function()
      local list = inGroup(group)
      return atLeast(list, ns.EXALTED), #list
    end,
    function() return #inGroup(group) >= 2 end
  )
end

-- ── the stories ─────────────────────────────────────────────────────────────
add(
  "stories",
  "chapter-1",
  L["A Word from a Friend"],
  L["Open a chapter of a faction's story after its first."],
  function()
    for _, id in ipairs(voiced()) do
      local have = pieces(id)
      if have > 1 then return 1, 1 end
    end
    return 0, 1
  end
)
add("stories", "story-1", L["A Story Told"], L["Open every chapter of one faction's story."], function()
  for _, id in ipairs(voiced()) do
    local have, all = pieces(id)
    if all > 0 and have >= all then return 1, 1 end
  end
  return 0, 1
end)
add("stories", "story-all", L["Every Voice Heard"], L["Open every chapter of every story your side has."], function()
  local have, all = 0, 0
  for _, id in ipairs(voiced()) do
    local h, a = pieces(id)
    have, all = have + h, all + a
  end
  return have, all
end, function() return #voiced() >= 2 end)

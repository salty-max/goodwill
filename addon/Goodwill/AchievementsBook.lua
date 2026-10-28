-- The Achievements tab, over both panels: the kit's board (the figures on
-- top: all earned, and each group's; then one row per achievement under its
-- group's heading and how many of it are earned). Achievements:
-- Achievements.lua.
local _, ns = ...
local K, L = ns.kit, ns.kit.L
ns.achievementRows = {} -- (for the tests)

local GROUPS = {
  { "standings", L["Standings"], ns.achievementIcons.standings, "all" },
  { "exalted", L["Factions at Exalted"], ns.achievementIcons.exalted, "all" },
  { "groups", L["Groups of factions"], ns.achievementIcons.groups, "all" },
  { "stories", L["Stories"], ns.achievementIcons.stories, "all" },
}

-- (the kit's tab: K.deedsTab, its board over both panels and the count)
local tab = K.deedsTab(
  ns.deeds,
  { name = "GoodwillAchievements", groups = GROUPS, rows = ns.achievementRows, n = ns.TAB.achievements }
)
ns.addTab(ns.TAB.achievements, tab.tab)

-- Open the book at the achievements, one of them picked out.
function ns.openAchievements(id)
  tab:pick(id)
  ns.openTab(ns.TAB.achievements)
end

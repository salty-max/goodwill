-- The welcome (the kit's, Kit.lua): once per character, a few seconds after
-- its first login (out of combat; /goodwill welcome shows it again), laid out
-- as the book's window: on the left what Goodwill is; on the right this
-- character's choices (Settings.lua: the minimap button), then another
-- character's to take, chosen among this game's or brought by a code
-- (/goodwill export there). Closing it, however, is enough to have seen it.
local _, ns = ...
local K = ns.kit
local L = K.L

local W = K.welcome({
  name = "GoodwillWelcome",
  title = L["Welcome to Goodwill"],
  art = ns.ICON,
  logo = ns.LOGO,
  heading = "Goodwill",
  tagline = L["Every faction's road to Exalted, and the story it tells you on the way."],
  intro = function()
    return L["Each faction's page tells you how to raise it from where you stand: the turn-ins your bags and bank already hold, the quests still open to you, the kills that still count, and what the next standing unlocks."]
      .. "\n\n"
      .. L["Some factions have a voice of their own. Each standing you reach with them opens the next chapter of their story, told by someone who trusts you a little more each time."]
  end,
  profiles = ns.profiles,
  choices = function()
    return {
      K.minimapChoice(ns.option, ns.setOption),
    }
  end,
  footnote = L["Change it any time: /goodwill settings, or a right-click on the minimap button. /goodwill opens the book."],
  open = { text = L["Open the book"], click = function() ns.toggle() end },
  exportHint = L["Copy it (Ctrl+C), then on another character: Use a code, or /goodwill import CODE."],
  importHint = L["Paste the code (/goodwill export on the other character), then press Enter."],
  refused = L["That isn't a Goodwill settings code."],
})

ns.welcome = W -- (its frame, rows, picker and code: for the tests)
function ns.showWelcome(mode) W:Show(mode) end

K.welcomeOnce(W, ns.profiles, function() return ns.book() ~= nil end)

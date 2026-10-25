-- Goodwill's settings, each character's own (its profile, "Name - Realm",
-- the kit's: Kit.lua), all kept in GoodwillSettings so that one character
-- can take another's: chosen among this game's characters, or brought by a
-- code (/goodwill export, /goodwill import CODE). Their page in the game's
-- Options (AddOns tab): /goodwill settings, or a right-click on the minimap
-- button; the welcome page (Welcome.lua) offers them too.
--
--   GoodwillSettings.profiles["Name - Realm"] = { minimapHidden,
--     minimapAngle, chapterBanner, welcomed }
local _, ns = ...
local K = ns.kit
local L = K.L

-- (minimapAngle: the button's place around the minimap, in degrees, the
-- family's own for Goodwill, K.MINIMAP_ANGLES; welcomed: never copied)
-- (chapterBanner: a new chapter's banner among the game's alerts, a switch
-- as every addon's alert has, the user's call of 24 October 2026)
local DEFAULTS = {
  minimapHidden = false,
  minimapAngle = K.MINIMAP_ANGLES.Goodwill,
  chapterBanner = true,
  welcomed = false,
}
local SHARED = { "minimapHidden", "minimapAngle", "chapterBanner" }

-- The profiles: a code "GW1:h0:a140:b1".
local P = K.profiles({
  saved = function()
    if type(GoodwillSettings) ~= "table" then GoodwillSettings = {} end
    return GoodwillSettings
  end,
  defaults = DEFAULTS,
  shared = SHARED,
  letters = { minimapHidden = "h", minimapAngle = "a", chapterBanner = "b" },
  tag = "GW1",
  changed = function(key)
    if key == "minimapHidden" or key == "minimapAngle" then
      if ns.updateMinimapButton then ns.updateMinimapButton() end
    end
  end,
})
ns.profiles = P

function ns.loadProfile() P:load() end
function ns.option(key) return P:get(key) end
function ns.setOption(key, value) P:set(key, value) end

-- The page in the game's Options (the kit's: K.options).
local O

function ns.createSettingsPanel()
  if O then return end
  O = K.options({
    title = "Goodwill",
    key = "GOODWILL",
    get = ns.option,
    set = ns.setOption,
    defaults = DEFAULTS,
    profiles = P,
    slash = "/goodwill",
    prefix = ns.PREFIX,
  })
  O:check(
    "chapterBanner",
    L["Banner for a new chapter"],
    L["Show each new chapter of a faction's story in a banner among the game's alerts. A click on it reads the chapter."]
  )
  O:check("minimapHidden", L["Minimap button"], L["The book by the minimap: click to open it, drag to move it."], true)
  O:copy()
  O:done()
end

function ns.openSettings() return O ~= nil and O:open() end

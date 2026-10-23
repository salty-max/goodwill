-- Goodwill's settings, each character's own (its profile, "Name - Realm",
-- the kit's: Kit.lua), all kept in GoodwillSettings so that one character
-- can take another's: chosen among this game's characters, or brought by a
-- code (/goodwill export, /goodwill import CODE). Their page in the game's
-- Options (AddOns tab): /goodwill settings, or a right-click on the minimap
-- button; the welcome page (Welcome.lua) offers them too.
--
--   GoodwillSettings.profiles["Name - Realm"] = { minimapHidden,
--     minimapAngle, welcomed }
local _, ns = ...
local K = ns.kit
local L = K.L

-- (minimapAngle: the button's place around the minimap, in degrees, 140 on
-- the left above Mealbook's (165) and the siblings' (200 to 250); welcomed:
-- never copied)
local DEFAULTS = {
  minimapHidden = false,
  minimapAngle = 140,
  welcomed = false,
}
local SHARED = { "minimapHidden", "minimapAngle" }

-- The profiles: a code "GW1:h0:a140".
local P = K.profiles({
  saved = function()
    if type(GoodwillSettings) ~= "table" then GoodwillSettings = {} end
    return GoodwillSettings
  end,
  defaults = DEFAULTS,
  shared = SHARED,
  letters = { minimapHidden = "h", minimapAngle = "a" },
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

local category

function ns.createSettingsPanel()
  if category or not (Settings and Settings.RegisterVerticalLayoutCategory) then return end
  category = Settings.RegisterVerticalLayoutCategory("Goodwill")

  local setting = Settings.RegisterProxySetting(
    category,
    "GOODWILL_MINIMAP",
    Settings.VarType.Boolean,
    L["Minimap button"],
    true,
    function() return not ns.option("minimapHidden") end,
    function(value) ns.setOption("minimapHidden", not value) end
  )
  Settings.CreateCheckbox(category, setting, L["The book by the minimap: click to open it, drag to move it."])

  -- Another character's settings (of this game), for this one.
  K.copySetting(
    category,
    "GOODWILL_COPYFROM",
    P,
    L["Another character's choices, for this one (of this game: Classic and Forever keep their own). From elsewhere: /goodwill export there, then /goodwill import CODE here."],
    function(other) print(ns.PREFIX .. L["%s's settings copied."]:format(other)) end
  )

  Settings.RegisterAddOnCategory(category)
end

function ns.openSettings()
  if category then Settings.OpenToCategory(category:GetID()) end
  return category ~= nil
end

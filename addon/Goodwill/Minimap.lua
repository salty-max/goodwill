-- The book's button on the minimap (the kit's: Kit.lua): click to open the
-- book, right-click for its settings, drag to move it around the minimap.
-- Its place (and whether it shows) is kept with this character's settings
-- (Settings.lua).
local _, ns = ...
local K = ns.kit

local M

function ns.createMinimapButton()
  if M then return end
  M = K.minimapButton({
    name = "GoodwillMinimapButton",
    icon = ns.ICON,
    title = "Goodwill",
    lines = function()
      local n = ns.chaptersOpened and ns.chaptersOpened() or 0
      return { K.plural(n, "%d chapter opened.", "%d chapters opened."):format(n) }
    end,
    click = function() ns.toggle() end,
    rightClick = function() ns.openSettings() end,
    get = ns.option,
    set = ns.setOption,
  })
end

function ns.updateMinimapButton()
  if M then M:update() end
end

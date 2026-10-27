-- The Stories tab: the factions with a voice of their own, and each one's
-- story so far, every chapter opened in its order, signed by its voice (the
-- kit's voice), with the date it opened; those still to come by their title
-- and the standing that opens them.
local _, ns = ...
local L, D, ui = ns.kit.L, ns.data, ns.ui
local T = ui.T
local book, list, page
local current
local rows = {}

local function style(row, kind)
  if kind == "section" then
    row.text:SetPoint("LEFT", 4, 0)
    row.text:SetPoint("RIGHT", -4, 0)
    row.text:SetFont(ns.kit.TITLE_FONT, 14, "")
    row.text:SetTextColor(unpack(T.gold))
    return 22
  end
  row.count:SetPoint("RIGHT", -4, 0)
  row.text:SetPoint("LEFT", 4, 0)
  row.text:SetPoint("RIGHT", row.count, "LEFT", -4, 0)
  row.text:SetFont(ns.kit.BODY_FONT, 12, "")
  row.text:SetTextColor(unpack(T.text))
  return 18
end

local function voiced()
  local out = {}
  for _, id in ipairs(ns.factions()) do
    if ns.hasChapters(id) then table.insert(out, id) end
  end
  return out
end

local function counts(id)
  local opened, all = 0, 0
  for _, piece in ipairs(ns.PIECES) do
    if ns.chapters[id][piece[1]] then all = all + 1 end
    if ns.opened(id, piece[1]) then opened = opened + 1 end
  end
  return opened, all
end

local function refreshList()
  local q = ui.query()
  list:begin()
  for _, id in ipairs(voiced()) do
    local name = ns.factionName(id)
    if ns.kit.finds(name, q) then
      local opened, all = counts(id)
      local row = list:add("story", name, ("%d / %d"):format(opened, all))
      row:SetScript("OnClick", function()
        current = id
        ns.refresh()
      end)
      if current == id then list:pick(row) end
    end
  end
  list:finish()
end

local function showStory(id)
  local f = D.factions[id]
  local voice = f.voice and ns.npcName(f.voice) or ""
  local opened, all = counts(id)
  page:start(
    ns.factionName(id),
    L["Told by %s"]:format(voice) .. "  -  " .. ("%d / %d"):format(opened, all),
    function(p) p.tex:SetTexture(ns.ICON) end
  )
  for _, piece in ipairs(ns.PIECES) do
    if ns.chapters[id][piece[1]] then
      local title, paragraphs = ns.chapter(id, piece[1])
      local at = piece[3] and L["halfway to %s"]:format(ns.standingName(ns.EXALTED)) or ns.standingName(piece[2])
      page:section(title)
      local when = ns.opened(id, piece[1])
      if when then
        page:text({ { table.concat(paragraphs, "\n\n"), voice = true, sign = voice } })
        page:row(L["Opened"], ("%s, %s"):format(ui.day(when), piece[2] > 1 and at or L["from the start"]))
      else
        page:paragraph(L["Opens at %s."]:format(at), T.soft)
      end
    end
  end
end

local function showNone()
  page:start(L["Stories"], "", function(p) p.tex:SetTexture(ns.ICON) end)
  page:paragraph(
    L["Some factions have a voice of their own. Each standing you reach with them opens the next chapter of their story."],
    T.soft
  )
end

local function refresh()
  local list_ = voiced()
  book.count:SetText(
    ns.kit.plural(ns.chaptersOpened(), "%d chapter opened.", "%d chapters opened."):format(ns.chaptersOpened())
  )
  if not current or not ns.hasChapters(current) then current = list_[1] end
  refreshList()
  if current then
    showStory(current)
  else
    showNone()
  end
  page:finish()
end

ns.addTab(ns.TAB.stories, {
  build = function(b)
    book = b
    list = ui.newList(book.left, style, rows, true)
    page = ui.newPage(book.sheet, "GoodwillStoryPage")
  end,
  show = function(n)
    local here = n == ns.TAB.stories
    list:SetShown(here)
    page:SetShown(here)
  end,
  refresh = refresh,
})

-- A faction's story (a chapter's banner, a click on its page; none: the first).
function ns.openStory(id)
  current = id
  ns.openTab(ns.TAB.stories)
end

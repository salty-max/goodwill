-- The Factions tab: every faction the book follows for this character, by
-- group, each in its standing's colour; and a faction's page: its standing
-- and the way to the next, the newest chapter of its story (once it has a
-- voice), the road (the turn-ins the bags and the bank hold, the kills that
-- still count, the quests still open) and what each standing unlocks.
local _, ns = ...
local L, D, ui = ns.kit.L, ns.data, ns.ui
local T = ui.T
local book, list, page
local current
local rows = {}
local MAX_QUESTS, MAX_KILLS, MAX_TURNINS = 8, 3, 4
local QUEST_ICON = "Interface\\GossipFrame\\AvailableQuestIcon"

local style = ns.kit.listStyle -- (the kinds every book shares)

local function refreshList()
  local q = ui.query()
  list:begin()
  if q == "" then
    local row = list:add("overview", L["Your standings"])
    row:SetScript("OnClick", function()
      current = nil
      ns.refresh()
    end)
    if not current then list:pick(row) end
  end
  local any = false
  for _, group in ipairs(D.groups) do
    local first = true
    for _, id in ipairs(ns.factions()) do
      local name = ns.factionName(id)
      if D.factions[id].group == group and ns.kit.finds(name, q) then
        if first then
          list:gap(6)
          list:add("section", ui.GROUPS[group] or group)
          first = false
        end
        any = true
        local standing = ns.standingOf(id)
        local row = list:add("faction", name, standing and ui.standingWord(standing) or "")
        row:SetScript("OnClick", function()
          current = id
          ns.refresh()
        end)
        if current == id then list:pick(row) end
      end
    end
  end
  if not any and q ~= "" then list:add("section", L["Nothing found"]) end
  list:finish()
end

-- The voice's newest chapter, signed (the kit's voice), and the next one's
-- title and standing.
local function story(id)
  local f = D.factions[id]
  if not ns.hasChapters(id) then
    page:paragraph(L["This faction's story comes in a later update. The road is here already."], T.soft)
    return
  end
  local newest, nextPiece
  for _, piece in ipairs(ns.PIECES) do
    if ns.opened(id, piece[1]) then
      newest = piece
    elseif not nextPiece and ns.chapters[id][piece[1]] then
      nextPiece = piece
    end
  end
  local voice = f.voice and ns.npcName(f.voice) or ""
  if newest then
    local title, paragraphs = ns.chapter(id, newest[1])
    page:section(title)
    page:text({ { table.concat(paragraphs, "\n\n"), voice = true, sign = voice } })
  end
  if nextPiece then
    local title = ns.chapter(id, nextPiece[1])
    local at = nextPiece[3] and L["halfway to %s"]:format(ns.standingName(ns.EXALTED)) or ns.standingName(nextPiece[2])
    page:paragraph(L["Next: %s, at %s."]:format(title, at), T.soft)
  end
  page:card(
    L["Every chapter so far"],
    voice,
    function(p) p.tex:SetTexture(ns.ICON) end,
    function() ns.openStory(id) end
  )
end

local function turninCards(id)
  local any = false
  for i, t in ipairs(ns.road.turnins(id)) do
    if i > MAX_TURNINS then break end
    any = true
    local title = ns.questName(t.quest) or (t.givers[1] and ns.npcName(t.givers[1])) or ""
    local facts = { L["+%d each"]:format(t.each) }
    if t.via then table.insert(facts, L["through %s"]:format(ns.factionName(t.via))) end
    if not t.open then table.insert(facts, L["not offered yet"]) end
    if t.errand then
      table.insert(facts, L["again and again"])
    elseif t.times > 0 then
      table.insert(facts, L["you hold enough for %d"]:format(t.times))
    end
    local givers = {}
    for _, g in ipairs(t.givers) do
      table.insert(givers, ui.where(g))
    end
    page:card(
      title,
      table.concat(facts, "  -  "),
      function(p) p.tex:SetTexture(t.items[1] and ns.kit.itemIcon(t.items[1].item) or QUEST_ICON) end
    )
    local items = {}
    for _, it in ipairs(t.items) do
      table.insert(items, {
        it.item,
        nil,
        false,
        it.need,
        function(tip)
          tip:AddLine(L["Carried: %d"]:format(it.carried), 1, 1, 1)
          tip:AddLine(L["In the bank: %d"]:format(it.banked), 1, 1, 1)
          for _, w in ipairs(givers) do
            if w ~= "" then tip:AddLine(w, 0.7, 0.7, 0.7) end
          end
        end,
      })
    end
    page:items(items)
  end
  return any
end

local function killCards(id)
  local any = false
  for i, z in ipairs(ns.road.kills(id)) do
    if i > MAX_KILLS then break end
    any = true
    local names = {}
    for j, c in ipairs(z.creatures) do
      if j > 3 then break end
      local n = ns.npcName(c)
      if n then table.insert(names, n) end
    end
    local until_ = z.stops <= ns.EXALTED and L["until %s"]:format(ns.standingName(z.stops)) or L["to the end"]
    page:card(
      ui.zoneName(z.zone) or L["Somewhere"],
      table.concat({
        L["+%d a kill at most"]:format(z.each),
        z.via and L["through %s"]:format(ns.factionName(z.via)) or until_,
        table.concat(names, ", "),
      }, "  -  "),
      function(p) p.tex:SetTexture("Interface\\Icons\\Ability_DualWield") end
    )
  end
  return any
end

local function questCards(id)
  local all = ns.road.quests(id)
  local shown = 0
  for _, q in ipairs(all) do
    if shown >= MAX_QUESTS then break end
    shown = shown + 1
    local facts = { L["+%d"]:format(q.rep), L["level %d"]:format(q.level) }
    local zone = ui.zoneName(q.zone)
    if zone then table.insert(facts, zone) end
    if q.from then
      table.insert(facts, L["from level %d"]:format(q.from))
    elseif not q.open then
      table.insert(facts, L["opens at %s"]:format(ns.standingName(q.at)))
    end
    local title = ns.questName(q.quest) or (q.giver and ns.npcName(q.giver)) or ""
    page:card(title, table.concat(facts, "  -  "), function(p) p.tex:SetTexture(QUEST_ICON) end)
  end
  if #all > shown then page:paragraph(L["And %d more quests."]:format(#all - shown), T.soft) end
  return shown > 0
end

local function unlocks(id)
  local standing = ns.standingOf(id) or ns.NEUTRAL
  for _, u in ipairs(ns.road.unlocks(id)) do
    page:section(L["At %s"]:format(ns.standingName(u.standing)) .. (u.reached and "  " .. L["(open)"] or ""))
    if #u.items > 0 then
      local items = {}
      for _, it in ipairs(u.items) do
        table.insert(items, {
          it.item,
          nil,
          standing < u.standing,
          1,
          function(tip)
            if it.skill and ns.skillNames[it.skill] then
              tip:AddLine(L["A recipe: %s"]:format(ns.skillNames[it.skill]), 1, 1, 1)
            end
            for _, v in ipairs(it.vendors or {}) do
              local w = ui.where(v)
              local n = ns.npcName(v)
              if n then tip:AddLine(w ~= "" and ("%s, %s"):format(n, w) or n, 0.7, 0.7, 0.7) end
            end
          end,
        })
      end
      page:items(items)
    end
    for _, q in ipairs(u.quests) do
      local title = ns.questName(q)
      if title then page:row(L["A quest"], title) end
    end
  end
end

local function showFaction(id)
  local target, need, standing = ns.road.target(id)
  standing = standing or ns.NEUTRAL
  local sub = ui.standingWord(standing)
  if target then sub = sub .. "  -  " .. L["%d to %s"]:format(need, ns.standingName(target)) end
  page:start(ns.factionName(id), sub, function(p) p.tex:SetTexture(ns.ICON) end)
  local opened, all = 0, 0
  if ns.hasChapters(id) then
    for _, piece in ipairs(ns.PIECES) do
      if ns.chapters[id][piece[1]] then all = all + 1 end
      if ns.opened(id, piece[1]) then opened = opened + 1 end
    end
  end
  page:stats({
    { ns.standingName(standing), L["now"] },
    {
      target and tostring(need) or "-",
      target and L["to %s"]:format(ns.standingName(target)) or ns.standingName(ns.EXALTED),
    },
    { tostring(ns.road.held(id)), L["held in turn-ins"] },
    { all > 0 and ("%d / %d"):format(opened, all) or "-", L["chapters"] },
  })
  story(id)
  if target then
    page:section(L["The road to %s"]:format(ns.standingName(target)))
    -- (sisters share what they earn: the spillover, docs/data.md)
    local spill = D.factions[id].spill
    if spill then
      local names = {}
      for _, s in ipairs(spill.from) do
        table.insert(names, ns.factionName(s))
      end
      local share = spill.rate == 0.5 and L["Half of what you earn with these comes here too: %s."]
        or spill.rate == 0.25 and L["A quarter of what you earn with these comes here too: %s."]
        or L["Part of what you earn with these comes here too: %s."]
      page:paragraph(share:format(table.concat(names, ", ")), T.soft)
    end
    local any = turninCards(id)
    any = killCards(id) or any
    any = questCards(id) or any
    if not any then page:paragraph(L["Nothing the book knows of raises it from here."], T.soft) end
  end
  unlocks(id)
end

local function showOverview()
  local n, exalted = 0, 0
  for _, id in ipairs(ns.factions()) do
    n = n + 1
    if (ns.standingOf(id) or 0) >= ns.EXALTED then exalted = exalted + 1 end
  end
  page:start(
    L["Your standings"],
    ns.kit.plural(n, "%d faction", "%d factions"):format(n),
    function(p) p.tex:SetTexture(ns.ICON) end
  )
  page:stats({
    { tostring(exalted), L["at Exalted"] },
    { tostring(ns.chaptersOpened()), L["chapters opened"] },
  })
  page:paragraph(
    L["Pick a faction: its page tells you how to raise it from where you stand, and what the next standing unlocks."],
    T.soft
  )
  page:section(L["Their stories"])
  for _, id in ipairs(ns.factions()) do
    if ns.hasChapters(id) then
      local voice = D.factions[id].voice and ns.npcName(D.factions[id].voice) or ""
      page:card(ns.factionName(id), voice, function(p) p.tex:SetTexture(ns.ICON) end, function() ns.openFaction(id) end)
    end
  end
end

local function refresh()
  local n = #ns.factions()
  book.count:SetText(ns.kit.plural(n, "%d faction", "%d factions"):format(n))
  refreshList()
  if current and D.factions[current] then
    showFaction(current)
  else
    current = nil
    showOverview()
  end
  page:finish()
end

ns.addTab(ns.TAB.factions, {
  build = function(b)
    book = b
    list = ui.newList(book.left, style, rows, true)
    page = ui.newPage(book.sheet, "GoodwillFactionPage")
  end,
  show = function(n)
    local here = n == ns.TAB.factions
    list:SetShown(here)
    page:SetShown(here)
  end,
  refresh = refresh,
})

function ns.openFaction(id)
  current = id
  ns.openTab(ns.TAB.factions)
end

-- The road: for one faction, how far to its next standing and every way the
-- character can get there from where it stands (Factions_<game>.lua's):
--   turn-ins   a repeatable quest of its, the items it asks against the bags
--              and the bank (as last seen), how many times they'd go in
--   quests     a quest of its not done yet, open to this character (race,
--              class, the quests before it, its exclusive group), offered at
--              the standing now or opening at a later one
--   kills      the creatures whose death still raises it, by zone, and the
--              standing each stops counting at (the first past its cap)
--   unlocks    what each standing opens: its vendors' goods (a trade's recipe
--              said so), its quests
local _, ns = ...
local D = ns.data
local R = {}
ns.road = R

-- The standing the road aims at: the next one up (Exalted: none), and how
-- much reputation is still between.
function R.target(faction)
  local standing, value = ns.standingOf(faction)
  if not standing then return nil end
  if standing >= ns.EXALTED then return nil, 0, standing, value end
  return standing + 1, ns.THRESHOLDS[standing + 1] - value, standing, value
end

-- A quest's standing gate, as the character's standings are now: open now
-- (true), opening at a standing of that faction later (false, the standing),
-- or closed for good (nil: the character is past its ceiling).
local function value(faction) return select(2, ns.standingOf(faction)) end
function R.offered(q)
  for faction, gate in pairs(q.gate or {}) do
    local v = value(faction) or 0
    local low, high = gate[1], gate[2]
    if high and v >= high then return nil end
    if low and v < low then
      local at = ns.NEUTRAL
      for s = 1, ns.EXALTED do
        if ns.THRESHOLDS[s] <= low then at = s end
      end
      return false, at, faction
    end
  end
  return true
end

-- The quests before it: all of `after`, one of `anyOf`.
local function readyAfter(q)
  for _, p in ipairs(q.after or {}) do
    if not ns.done(p) then return false end
  end
  if q.anyOf and #q.anyOf > 0 then
    for _, p in ipairs(q.anyOf) do
      if ns.done(p) then return true end
    end
    return false
  end
  return true
end

-- An exclusive group: one quest of it done closes the others.
local groups
local function groupDone(q)
  if not q.excl then return false end
  if not groups then
    groups = {}
    for id, other in pairs(D.quests) do
      if other.excl then
        groups[other.excl] = groups[other.excl] or {}
        table.insert(groups[other.excl], id)
      end
    end
  end
  for _, id in ipairs(groups[q.excl] or {}) do
    if ns.done(id) then return true end
  end
  return false
end

-- The turn-ins open to the character: each with its reputation, its items
-- against the bags and the bank, and how many times what's held would go in.
-- The same turn-in at several givers (the Dawn's scourgestones at Chillwind
-- Camp, the Bulwark and Light's Hope) is one, its givers together: the same
-- items go in once.
function R.turnins(faction)
  local f = D.factions[faction]
  local out, seen = {}, {}
  for _, id in ipairs(f.turnins or {}) do
    local q = D.quests[id]
    local open = q and ns.forMe(q) and R.offered(q)
    if open ~= nil and q and ns.forMe(q) and readyAfter(q) then
      local key = table.concat(q.items or {}, ":") .. "/" .. (q.rep[faction] or 0)
      local same = seen[key]
      if same then
        if q.giver then table.insert(same.givers, q.giver) end
        same.open = same.open or open
      else
        local times, items = nil, {}
        for i = 1, #(q.items or {}), 2 do
          local item, need = q.items[i], q.items[i + 1]
          local carried, banked = ns.carried(item), ns.banked(item)
          local n = math.floor((carried + banked) / need)
          times = times and math.min(times, n) or n
          table.insert(items, { item = item, need = need, carried = carried, banked = banked })
        end
        local t = {
          quest = id,
          each = q.rep[faction] or 0,
          times = times or 0,
          items = items,
          open = open,
          givers = { q.giver },
        }
        seen[key] = t
        table.insert(out, t)
      end
    end
  end
  -- (what the bags already hold first, then the most reputation a turn-in)
  table.sort(out, function(a, b)
    if (a.times > 0) ~= (b.times > 0) then return a.times > 0 end
    if a.each ~= b.each then return a.each > b.each end
    return a.quest < b.quest
  end)
  return out
end

-- The quests not done yet and open to the character, offered now first, then
-- those of the zone it stands in, then by level.
function R.quests(faction)
  local f = D.factions[faction]
  local here = ns.zoneHere and ns.zoneHere()
  local out = {}
  for _, id in ipairs(f.quests or {}) do
    local q = D.quests[id]
    if q and not ns.done(id) and ns.forMe(q) and readyAfter(q) and not groupDone(q) then
      local open, at = R.offered(q)
      if open ~= nil then
        table.insert(out, {
          quest = id,
          rep = q.rep[faction] or 0,
          open = open,
          at = at,
          level = q.level or 0,
          zone = q.zone,
          giver = q.giver,
        })
      end
    end
  end
  table.sort(out, function(a, b)
    if a.open ~= b.open then return a.open end
    local ha, hb = a.zone == here, b.zone == here
    if ha ~= hb then return ha end
    if a.level ~= b.level then return a.level < b.level end
    return a.quest < b.quest
  end)
  return out
end

-- The kills that still raise it, by zone: the creatures, the most a kill
-- gives, the standing they stop counting at. The data's cap is the last
-- standing a kill still counts at (0 Hated to 7 Exalted, the game's one
-- more): the Brood of Nozdormu's Ahn'Qiraj trash counts at Hated, until
-- Hostile.
function R.kills(faction)
  local f = D.factions[faction]
  local standing = ns.standingOf(faction) or ns.NEUTRAL
  local byZone, out = {}, {}
  for _, k in ipairs(f.kills or {}) do
    local creature, gives, cap = k[1], k[2], k[3]
    local stops = cap and cap + 2 or ns.EXALTED + 1
    if standing < stops then
      local n = D.npcs[creature] or {}
      local key = n.area or 0
      local z = byZone[key]
      if not z then
        z = { zone = n.area, creatures = {}, each = 0, stops = 0 }
        byZone[key] = z
        table.insert(out, z)
      end
      table.insert(z.creatures, creature)
      z.each = math.max(z.each, gives)
      z.stops = math.max(z.stops, stops)
    end
  end
  table.sort(out, function(a, b)
    if #a.creatures ~= #b.creatures then return #a.creatures > #b.creatures end
    return (a.zone or 0) < (b.zone or 0)
  end)
  return out
end

-- What each standing opens, Friendly to Exalted: { standing, items, quests },
-- reached or not.
function R.unlocks(faction)
  local f = D.factions[faction]
  local standing = ns.standingOf(faction) or ns.NEUTRAL
  local by, out = {}, {}
  for _, u in ipairs(f.unlocks or {}) do
    local s = u.standing + 1
    if not by[s] then
      by[s] = { standing = s, reached = standing >= s, items = {}, quests = {} }
      table.insert(out, by[s])
    end
    if u.item then table.insert(by[s].items, u) end
    if u.quest then table.insert(by[s].quests, u.quest) end
  end
  table.sort(out, function(a, b) return a.standing < b.standing end)
  return out
end

-- How far the bags and the bank alone would take it: the reputation the
-- turn-ins held would give, all of them.
function R.held(faction)
  local total = 0
  for _, t in ipairs(R.turnins(faction)) do
    if t.open then total = total + t.times * t.each end
  end
  return total
end

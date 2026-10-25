-- A small game for Goodwill's tests (the kit's game, wowmock.lua: frames, events and timers):
-- the character's standings as each client tells them (Classic Era's
-- GetFactionInfoByID, Forever's C_Reputation), the quests it has done, its
-- bags and its bank, its race, class and sex, the standings' names.
-- FOREVER=1 plays Forever's client, LOCALE=frFR a French one (deDE, esES, esMX the same).
local G = dofile("addon/test/wowmock.lua")
local state, FOREVER, LOCALE, obj = G.state, G.FOREVER, G.LOCALE, G.obj

-- ── reputation ───────────────────────────────────────────────────────────────
-- state.rep[faction]: its reputation, the game's figure (0 Neutral's start);
-- a faction the test leaves out stands where the data's start puts it,
-- Neutral here. Its standing and the standing's bounds follow.
local THRESHOLDS = { -42000, -6000, -3000, 0, 3000, 9000, 21000, 42000, 43000 }
state.rep = {}
local function standing(value)
  local s = 1
  for i = 1, 8 do
    if value >= THRESHOLDS[i] then s = i end
  end
  return s, THRESHOLDS[s], THRESHOLDS[s + 1]
end
G.standing = standing
if FOREVER then
  C_Reputation = {
    GetFactionDataByID = function(id)
      local v = state.rep[id] or 0
      local s, low, high = standing(v)
      return {
        factionID = id,
        name = "Faction " .. id,
        reaction = s,
        currentStanding = v,
        currentReactionThreshold = low,
        nextReactionThreshold = high,
      }
    end,
  }
else
  function GetFactionInfoByID(id)
    local v = state.rep[id] or 0
    local s, low, high = standing(v)
    return "Faction " .. id, "", s, low, high, v
  end
end
-- the standings' names, the game's (French and Spanish: a woman's form too)
local SPANISH = { "Odiado", "Hostil", "Adverso", "Neutral", "Amistoso", "Honorable", "Venerado", "Exaltado" }
local LABELS = ({
  frFR = { "Haï", "Hostile", "Inamical", "Neutre", "Amical", "Honoré", "Révéré", "Exalté" },
  deDE = {
    "Hasserfüllt",
    "Feindselig",
    "Unfreundlich",
    "Neutral",
    "Freundlich",
    "Wohlwollend",
    "Respektvoll",
    "Ehrfürchtig",
  },
  esES = SPANISH,
  esMX = SPANISH,
})[LOCALE] or { "Hated", "Hostile", "Unfriendly", "Neutral", "Friendly", "Honored", "Revered", "Exalted" }
for i, label in ipairs(LABELS) do
  _G["FACTION_STANDING_LABEL" .. i] = label
end
if LOCALE == "frFR" then
  FACTION_STANDING_LABEL6_FEMALE, FACTION_STANDING_LABEL7_FEMALE, FACTION_STANDING_LABEL8_FEMALE =
    "Honorée", "Révérée", "Exaltée"
elseif LOCALE == "esES" or LOCALE == "esMX" then
  FACTION_STANDING_LABEL1_FEMALE, FACTION_STANDING_LABEL3_FEMALE, FACTION_STANDING_LABEL5_FEMALE =
    "Odiada", "Adversa", "Amistosa"
  FACTION_STANDING_LABEL7_FEMALE, FACTION_STANDING_LABEL8_FEMALE = "Venerada", "Exaltada"
end
FACTION_BAR_COLORS = {}
for i = 1, 8 do
  FACTION_BAR_COLORS[i] = { r = 0.5, g = 0.5 + i / 20, b = 0.5 }
end

-- ── quests, bags, the bank ───────────────────────────────────────────────────
-- state.done[quest]: turned in; state.bags[item], state.bank[item]: held.
state.done, state.bags, state.bank = {}, {}, {}
C_QuestLog = { IsQuestFlaggedCompleted = function(id) return state.done[id] == true end }
local function count(item, bank) return (state.bags[item] or 0) + (bank and (state.bank[item] or 0) or 0) end
if FOREVER then
  C_Item = { GetItemCount = count }
else
  GetItemCount = count
end
function GetItemInfo(id) return "Item " .. id, nil, 1 end
-- (an icon asked for no item is an error, as the game's C_ calls make it)
function GetItemIcon(id)
  assert(id, "GetItemIcon: no item")
  return 134400
end

-- ── the addon ────────────────────────────────────────────────────────────────
G.load("Goodwill")
return G

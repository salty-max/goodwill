/**
 * The factions' facts, from wow-data's databases (../wow-data, its pinned
 * sources), each game's own:
 *
 *   addon/Goodwill/Factions_Classic.lua, Factions_Forever.lua: every faction
 *     data/factions.json gives a road (its group, its side, its voice), and
 *     for each: the quests that raise it once (with the standing they ask
 *     before they're offered, quest_standing), the repeatable turn-ins (the
 *     items each asks, reputation_turnin), the kills that raise it and the
 *     standing they stop counting at (kill_reputation), and what each
 *     standing unlocks: the items its vendors sell from that standing
 *     (item_reputation, a trade's recipe said so) and the quests it opens.
 *     Every quest's level, its races and classes (masks, matched against the
 *     character), the quests before it, its giver; every giver's, vendor's
 *     and creature's zone and spot.
 *
 *   i18n/names.json: the game's names Goodwill shows in every language, the
 *     client's, for scripts/locales.ts: the factions', each game's npcs
 *     (givers, vendors, the voices, the creatures to kill), quests and the
 *     trades a recipe unlock teaches, by id.
 *     A name a language lacks is left out: the book names it another way.
 *
 * A faction one game lacks is left out of that game's file (Forever's own,
 * client "forever" in data/factions.json). A quest that gives a faction
 * nothing, or takes from it, is no leg of its road.
 *
 *   bun scripts/factions.ts           write them
 *   bun scripts/factions.ts --check   fail if one isn't up to date
 */
import { existsSync, readFileSync, writeFileSync } from "node:fs";
import { join } from "node:path";
import type * as WowDb from "../../wow-data/src/db";
import { familyPath } from "./root";

// through the family folder, from a worktree too (scripts/root.ts)
const { openDb } = (await import(familyPath("wow-data", "src", "db.ts"))) as typeof WowDb;

const ROOT = join(import.meta.dir, "..");
const ADDON = join(ROOT, "addon", "Goodwill");
type Game = "classic" | "forever";
const GAMES: Game[] = ["classic", "forever"];
const LOCALES = ["enUS", "enGB", "deDE", "frFR", "esES", "esMX", "ruRU", "ptBR", "itIT", "koKR", "zhCN", "zhTW"];
// (the client's English is enUS: enGB reads the same names)
const SOURCE_LOCALE: Record<string, string> = { enGB: "enUS" };

type Listed = { id: number; group: string; side?: "A" | "H"; client?: Game; voice?: number; chapters?: string };
const LIST: { groups: string[]; factions: Listed[] } = JSON.parse(readFileSync(join(ROOT, "data", "factions.json"), "utf8"));

type Quest = {
  id: number;
  level: number | null;
  min: number | null;
  races: number;
  classes: number;
  giver: number | null;
  zone: number | null;
  rep: Record<number, number>;
  gate: Record<number, [number | null, number | null]>;
  after: number[];
  anyOf: number[];
  excl: number | null;
  items?: [number, number][];
  repeatable?: true;
  via?: Record<number, number>;
};
type Unlock = { item?: number; quest?: number; standing: number; vendors?: number[]; spell?: number; skill?: number };
type Kill = [number, number, number | null] | [number, number, number, number];
type Faction = Listed & { quests: number[]; turnins: number[]; kills: Kill[]; unlocks: Unlock[]; spill?: { rate: number; from: number[] } };
type Npc = { area: number | null; x: number | null; y: number | null; side: string | null };

const lua = (v: unknown): string => {
  if (v === null || v === undefined) return "nil";
  if (typeof v === "number") return String(v);
  if (typeof v === "boolean") return v ? "true" : "false";
  if (typeof v === "string") return JSON.stringify(v);
  if (Array.isArray(v)) return `{ ${v.map(lua).join(", ")} }`;
  const entries = Object.entries(v as Record<string, unknown>).filter(([, x]) => x !== undefined && x !== null);
  return `{ ${entries.map(([k, x]) => `${/^\d+$/.test(k) ? `[${k}]` : k} = ${lua(x)}`).join(", ")} }`;
};
const STANDING_VALUE = [-42000, -6000, -3000, 0, 3000, 9000, 21000, 42000];

function gameData(game: Game) {
  const db = openDb(game);
  const all = <T>(sql: string, ...args: (string | number)[]) => db.query(sql).all(...args) as T[];
  const exists = (id: number) => all<{ n: number }>("SELECT count(*) n FROM client_Faction WHERE ID = ?", id)[0].n > 0;
  const factions: Faction[] = [];
  const quests = new Map<number, Quest>();
  const npcIds = new Set<number>();

  const questOf = (id: number): Quest => {
    let q = quests.get(id);
    if (q) return q;
    const row = all<{ level: number; min_level: number; races: number; classes: number; zone_id: number; exclusive_group: number }>(
      "SELECT level, min_level, races, classes, zone_id, exclusive_group FROM quest WHERE id = ?",
      id,
    )[0];
    const giver = all<{ entity_id: number }>(
      "SELECT entity_id FROM quest_relation WHERE quest_id = ? AND role = 'start' AND kind = 'creature' ORDER BY source = 'questie' DESC, entity_id LIMIT 1",
      id,
    )[0]?.entity_id;
    const rep: Record<number, number> = {};
    for (const r of all<{ ref_id: number; count: number }>(
      "SELECT ref_id, count FROM quest_reward WHERE quest_id = ? AND kind = 'reputation' AND count IS NOT NULL ORDER BY ref_id",
      id,
    ))
      rep[r.ref_id] = r.count;
    const gate: Record<number, [number | null, number | null]> = {};
    for (const s of all<{ faction_id: number; min_value: number | null; max_value: number | null }>(
      "SELECT faction_id, min_value, max_value FROM quest_standing WHERE quest_id = ? ORDER BY faction_id",
      id,
    ))
      gate[s.faction_id] = [s.min_value, s.max_value];
    const prereqs = all<{ prev_id: number; kind: string }>(
      "SELECT DISTINCT prev_id, kind FROM quest_prereq WHERE quest_id = ? AND prev_id > 0 ORDER BY prev_id",
      id,
    );
    q = {
      id,
      level: row?.level ?? null,
      min: row?.min_level ?? null,
      races: row?.races ?? 0,
      classes: row?.classes ?? 0,
      giver: giver ?? null,
      zone: row?.zone_id ?? null,
      rep,
      gate,
      after: [...new Set(prereqs.filter((p) => p.kind === "all").map((p) => p.prev_id))],
      anyOf: [...new Set(prereqs.filter((p) => p.kind === "any").map((p) => p.prev_id))],
      excl: row?.exclusive_group ?? null,
    };
    if (giver) npcIds.add(giver);
    quests.set(id, q);
    return q;
  };

  for (const listed of LIST.factions) {
    if (listed.client && listed.client !== game) continue;
    if (!exists(listed.id)) continue;
    const f: Faction = { ...listed, quests: [], turnins: [], kills: [], unlocks: [] };
    // what raises it: the quests (once, or again and again: a turn-in)
    const raising = all<{ quest_id: number; repeatable: number }>(
      `SELECT DISTINCT r.quest_id, COALESCE(q.special_flags, 0) & 1 AS repeatable
       FROM quest_reward r JOIN quest q ON q.id = r.quest_id
       WHERE r.kind = 'reputation' AND r.ref_id = ? AND r.count > 0 AND (q.removed IS NULL OR q.removed = 0)
       ORDER BY q.level, r.quest_id`,
      listed.id,
    );
    for (const r of raising) {
      const q = questOf(r.quest_id);
      if (r.repeatable) {
        q.repeatable = true;
        q.items = all<{ item_id: number; item_count: number }>(
          "SELECT DISTINCT item_id, item_count FROM reputation_turnin WHERE quest_id = ? AND faction_id = ? ORDER BY item_id",
          r.quest_id,
          listed.id,
        ).map((t) => [t.item_id, t.item_count ?? 1]);
        f.turnins.push(r.quest_id);
      } else f.quests.push(r.quest_id);
    }
    // the kills, the standing each stops counting at
    for (const k of all<{ creature_id: number; value: number; max_standing: number | null }>(
      "SELECT creature_id, value, max_standing FROM kill_reputation WHERE faction_id = ? AND value > 0 ORDER BY creature_id",
      listed.id,
    )) {
      f.kills.push([k.creature_id, k.value, k.max_standing]);
      npcIds.add(k.creature_id);
    }
    // what each standing unlocks: what its vendors sell from it, the quests it opens
    for (const u of all<{ item_id: number; standing: number }>(
      `SELECT g.item_id, g.standing FROM item_reputation g
       WHERE g.faction_id = ? AND g.standing > 3 AND EXISTS (SELECT 1 FROM vendor v WHERE v.item_id = g.item_id)
       ORDER BY g.standing, g.item_id`,
      listed.id,
    )) {
      const vendors = all<{ npc_id: number }>("SELECT DISTINCT npc_id FROM vendor WHERE item_id = ? ORDER BY npc_id", u.item_id).map((v) => v.npc_id);
      for (const v of vendors) npcIds.add(v);
      const teaches = all<{ spell_id: number; skill_line_id: number }>(
        "SELECT spell_id, skill_line_id FROM recipe_source WHERE kind = 'item' AND ref_id = ? ORDER BY spell_id LIMIT 1",
        u.item_id,
      )[0];
      f.unlocks.push({ item: u.item_id, standing: u.standing, vendors, spell: teaches?.spell_id, skill: teaches?.skill_line_id });
    }
    for (const s of all<{ quest_id: number; min_value: number }>(
      `SELECT s.quest_id, s.min_value FROM quest_standing s JOIN quest q ON q.id = s.quest_id
       WHERE s.faction_id = ? AND s.min_value >= 3000 AND (q.removed IS NULL OR q.removed = 0)
       ORDER BY s.min_value, s.quest_id`,
      listed.id,
    )) {
      questOf(s.quest_id);
      f.unlocks.push({ quest: s.quest_id, standing: STANDING_VALUE.findLastIndex((v) => v <= s.min_value) });
    }
    if (listed.voice) npcIds.add(listed.voice);
    factions.push(f);
  }

  // each npc's zone and spot: its first spawn with a spot (Questie's map percent)
  const npcs = new Map<number, Npc>();
  // the spillover: sisters under one parent (the Steamwheedle towns, a
  // side's capitals) give each other a share of what they earn, counting all
  // the way to Exalted (client_Faction: ParentFactionMod_1 the share a
  // faction gives, _0 the share it takes, Cap_0 the last standing it still
  // counts at). The road lists the sisters' kills and repeatable turn-ins at
  // that share, with the sister they come through; their one-time quests
  // only as the book's note.
  const parentOf = new Map<number, { parent: number; out: number; take: number; cap: number }>();
  for (const f of factions) {
    const r = all<{ p: number; o: number; t: number; c: number }>(
      "SELECT ParentFactionID AS p, ParentFactionMod_1 AS o, ParentFactionMod_0 AS t, ParentFactionCap_0 AS c FROM client_Faction WHERE ID = ?",
      f.id,
    )[0];
    if (r && r.p > 0 && r.o > 0) parentOf.set(f.id, { parent: r.p, out: r.o, take: r.t, cap: r.c });
  }
  const own = new Map(factions.map((f) => [f.id, { kills: [...f.kills], turnins: [...f.turnins] }]));
  for (const f of factions) {
    const me = parentOf.get(f.id);
    if (!me) continue;
    const sisters = factions.filter((s) => s.id !== f.id && parentOf.get(s.id)?.parent === me.parent);
    if (!sisters.length) continue;
    f.spill = { rate: parentOf.get(sisters[0].id)!.out * me.take, from: sisters.map((s) => s.id) };
    for (const s of sisters) {
      const share = parentOf.get(s.id)!.out * me.take;
      for (const [c, v] of own.get(s.id)!.kills) f.kills.push([c, Math.round(v * share), me.cap, s.id]);
      for (const id of own.get(s.id)!.turnins) {
        const q = quests.get(id)!;
        if (q.rep[f.id] !== undefined || !q.rep[s.id]) continue;
        q.rep[f.id] = Math.round(q.rep[s.id] * share);
        (q.via ??= {})[f.id] = s.id;
        f.turnins.push(id);
      }
    }
  }

  for (const id of [...npcIds].sort((a, b) => a - b)) {
    const s = all<{ area_id: number; ux: number; uy: number }>(
      "SELECT area_id, ux, uy FROM spawn WHERE kind = 'creature' AND entity_id = ? AND area_id IS NOT NULL ORDER BY ux IS NULL, source = 'questie' DESC LIMIT 1",
      id,
    )[0];
    const c = all<{ friendly: string | null }>("SELECT friendly FROM creature WHERE id = ?", id)[0];
    npcs.set(id, {
      area: s?.area_id ?? null,
      x: s?.ux != null ? Math.round(s.ux) : null,
      y: s?.uy != null ? Math.round(s.uy) : null,
      side: c?.friendly ?? null,
    });
  }
  // a quest's zone: its giver's, else the quest log's
  for (const q of quests.values()) {
    const g = q.giver ? npcs.get(q.giver) : undefined;
    if (g?.area) q.zone = g.area;
  }

  // the names, every language: factions, npcs, quests
  const names: Record<
    string,
    { factions: Record<number, string>; npcs: Record<number, string>; quests: Record<number, string>; skills: Record<number, string> }
  > = {};
  const skillIds = new Set(factions.flatMap((f) => f.unlocks.map((u) => u.skill).filter((s): s is number => !!s)));
  const nameOf = (kind: string, id: number, locale: string) =>
    all<{ name: string; source: string }>("SELECT name, source FROM name WHERE kind = ? AND id = ? AND locale = ?", kind, id, locale)[0];
  for (const locale of LOCALES) {
    const from = SOURCE_LOCALE[locale] ?? locale;
    const pick = (kind: string, ids: Iterable<number>) => {
      const out: Record<number, string> = {};
      for (const id of [...ids].sort((a, b) => a - b)) {
        const n = nameOf(kind, id, from);
        // (a name the database gives only as the English its client shows is no translation)
        if (n && (from === "enUS" || n.source !== "english")) out[id] = n.name;
      }
      return out;
    };
    names[locale] = {
      factions: pick("faction", factions.map((f) => f.id)),
      npcs: pick("creature", npcs.keys()),
      quests: pick("quest", quests.keys()),
      skills: pick("skill_line", skillIds),
    };
  }
  // the races whose bit in a quest's race mask isn't their id's (the client's
  // PlayableRaceBit: Forever's Skyborne are races 95 and 96, bits 32 and 33)
  const raceBits = new Map(
    all<{ ID: number; PlayableRaceBit: number }>(
      "SELECT ID, PlayableRaceBit FROM client_ChrRaces WHERE PlayableRaceBit >= 0 AND PlayableRaceBit != ID - 1 ORDER BY ID",
    ).map((r) => [r.ID, r.PlayableRaceBit]),
  );
  db.close();
  return { factions, quests, npcs, names, raceBits };
}

function luaFile(game: Game, d: ReturnType<typeof gameData>): string {
  const pins = JSON.parse(readFileSync(familyPath("wow-data", "pins.json"), "utf8"));
  const b = pins.builds[game];
  const lines = [
    `-- Generated by scripts/factions.ts from wow-data's ${game}.db (client ${b.product} ${b.build}): edit`,
    "-- data/factions.json or the script, never this file.",
    "local _, ns = ...",
    "ns.data = {",
    `  game = ${lua(game)},`,
    `  groups = ${lua(LIST.groups)},`,
    `  order = ${lua(d.factions.map((f) => f.id))},`,
    `  raceBits = ${lua(Object.fromEntries(d.raceBits))},`,
    "  factions = {",
  ];
  for (const f of d.factions) {
    lines.push(`    [${f.id}] = {`);
    lines.push(`      group = ${lua(f.group)},`);
    if (f.side) lines.push(`      side = ${lua(f.side)},`);
    if (f.voice) lines.push(`      voice = ${f.voice},`);
    if (f.chapters) lines.push(`      chapters = ${lua(f.chapters)},`);
    lines.push(`      quests = ${lua(f.quests)},`);
    lines.push(`      turnins = ${lua(f.turnins)},`);
    lines.push(`      kills = ${lua(f.kills.map(([c, v, m, via]) => (via ? [c, v, m, via] : m === null ? [c, v] : [c, v, m])))},`);
    if (f.spill) lines.push(`      spill = ${lua(f.spill)},`);
    lines.push("      unlocks = {");
    for (const u of f.unlocks) lines.push(`        ${lua(u)},`);
    lines.push("      },");
    lines.push("    },");
  }
  lines.push("  },", "  quests = {");
  for (const q of [...d.quests.values()].sort((a, b) => a.id - b.id)) {
    const row: Record<string, unknown> = {
      level: q.level,
      min: q.min,
      races: q.races || undefined,
      classes: q.classes || undefined,
      giver: q.giver,
      zone: q.zone,
      rep: q.rep,
      gate: Object.keys(q.gate).length ? Object.fromEntries(Object.entries(q.gate).map(([k, [lo, hi]]) => [k, [lo ?? false, hi ?? false]])) : undefined,
      after: q.after.length ? q.after : undefined,
      anyOf: q.anyOf.length ? q.anyOf : undefined,
      excl: q.excl,
      items: q.items?.length ? q.items.flat() : undefined,
      repeatable: q.repeatable,
      via: q.via,
    };
    lines.push(`    [${q.id}] = ${lua(row)},`);
  }
  lines.push("  },", "  npcs = {");
  for (const [id, n] of d.npcs) lines.push(`    [${id}] = ${lua({ area: n.area, x: n.x, y: n.y, side: n.side })},`);
  lines.push("  },", "}");
  return `${lines.join("\n")}\n`;
}

const check = process.argv.includes("--check");
let stale = false;
const write = (file: string, text: string) => {
  const have = existsSync(file) ? readFileSync(file, "utf8") : "";
  if (have === text) return;
  if (check) {
    console.error(`✗ ${file.slice(ROOT.length + 1)} is not up to date: bun scripts/factions.ts`);
    stale = true;
    return;
  }
  writeFileSync(file, text);
  console.log(`wrote ${file.slice(ROOT.length + 1)}`);
};
const names: Record<string, Record<string, unknown>> = {};
for (const game of GAMES) {
  const d = gameData(game);
  write(join(ADDON, `Factions_${game === "classic" ? "Classic" : "Forever"}.lua`), luaFile(game, d));
  for (const [locale, n] of Object.entries(d.names)) (names[locale] ??= {})[game] = n;
  const sum = (k: "quests" | "turnins" | "kills" | "unlocks") => d.factions.reduce((s, f) => s + f[k].length, 0);
  console.log(
    `${game}: ${d.factions.length} factions, ${sum("quests")} quests, ${sum("turnins")} turn-ins, ${sum("kills")} kills, ${sum("unlocks")} unlocks, ${d.npcs.size} npcs`,
  );
}
write(join(ROOT, "i18n", "names.json"), `${JSON.stringify(names, null, 1)}\n`);
if (stale) process.exit(1);

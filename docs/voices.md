# Goodwill's voices

The rules the chapters are written and read by: how a chapter reads, what it
may tell, the devices the family has used up, the French, and one card for
each of the 35 voices. The pieces themselves are `content/<faction>/<piece>.md`
(English), their translations `i18n/<locale>/content/<faction>/`. The plan the road came from is `../ideas/reputation-road.md`
(planning, outside git). Each piece's fact sources (quests, gossip, books)
were listed beside the first drafts in `../ideas/reputation-road-voices.md`,
which stays as the backup; `beside:` in a piece's front matter names the
Codex pages it was read against.

## How a chapter reads

A chapter is what this person tells you now that you are this far in their
trust. It is not a history of the faction (the Codex's kind of page) and not
a guide (the road beside it gives the numbers, the places, the next step).
It speaks to you, about you and them.

The voice moves down a ladder as trust grows: guarded on the stranger's page
(`start`), businesslike at Friendly, frank at Honored, private at Revered,
plain at Exalted. The pieces get longer as they go, so the reader feels the
faction opening up before reading a word. Lengths in words, each longer than
the last: start 70 to 115, Friendly 100 to 150, Honored 130 to 190, Revered
150 to 210, aside 15 to 60, Exalted 190 to 250 (an `[after]` paragraph counts).
French may run a fifth longer. `scripts/chapters.ts` notes a piece outside them and fails one far outside (it does not check that each is longer than the last).

## What a chapter may tell

- Only what every reader at its standing has seen. A deed of the reader's
  appears only in a paragraph marked `[after: <quest id>]`, shown once that
  quest is turned in (`[before: id]` is its pair): one or two deeds a
  faction at most. Each card's arc says how its faction is climbed.
- Where readers start above Neutral (a side's capitals: Friendly at the
  first login, own race at 4,000), the start and Friendly pieces open
  together for a reader who has done nothing yet, and a reader may reach
  Honored or Revered on that city's quests alone: no line there thanks the
  reader for a deed outside an `[after]` paragraph.
- The Steamwheedle towns (Booty Bay, Gadgetzan, Ratchet, Everlook) share
  their reputation: a town's own kills count in full to the end of Honored
  and give half to the other three towns all the way to Exalted. A reader
  may stand high with a town without ever having done its quests.
- Every fact comes from the game (quests, gossip, books, the Codex's rule:
  any source, nothing anachronic, original wording). Check one with
  `bun wow-data/bin/card.ts quest <id>` or `npc <id>`. Invented lore is a
  fault. Feelings, opinions and a voice's own habits are characterization,
  not lore claims, as long as they do not read as one.
- No copying the game's text: a run of about six words, or four plus the same
  noun, from a quest or gossip line, in any language.
- The Codex has pages on these factions. The road may tell the same facts
  (players may not have both addons) but never echoes the Codex's wording,
  images or framing. No addon reads the other's files: the prose-reader
  reads a chapter beside the Codex pages its `beside:` names. Several cards'
  Never lines list the Codex phrases to stay clear of.
- No numbers, prices or ways to go in the prose. A voice may name who to see
  first (Grazle, Thorium Point), as anyone would, never how to get there.

## Form

- No semicolons in the prose in any language (the French gender tokens
  `$gmasc:fem;` are exempt). English plain ASCII. No figures (digits). No
  guide-like directions.
- Devices the family's voices already use, to avoid: if/if-not closers,
  causal "since", seeing and eyes, sitting, announced confessions ("I will
  say this once", "I will tell you a thing", "I will be honest", "I want you
  to know"), counting, "Not X. Y." fragments (and "is not X. It is Y."),
  "Here is", "plainly", naming the reader's new place at Exalted, a trailing
  ", which ..." quip, endings that all land on a quip, "a thousand years",
  "I find", "the nearest thing to", "I did not expect it to be you", "you're
  the only one I've told", the reader "kept coming back", an Exalted that is
  only an exception made for the reader (a door, a drink, a name filed), "I'd
  like you near me on that day".
- Spelling is British (honour, grey, traveller), game names as the game
  spells them (Valley of Honor, Armor Kit).
- A new voice is read against the shipped ones in `content/*/` (and the
  French in `i18n/frFR/content/`): a line, image or shape that repeats
  another voice's is flagged.

## French

Written as French, not translated from English (calques are faults). The
register is per writer: the voice's card says tu or vous (the default is
vous), and a voice may change register where the story does (see the ladder
below). The speaker's own agreements are as the card says. Any word agreeing
with the reader, whose gender the game knows, goes through a `$gmasc:fem;`
token, never a rephrase that flattens the voice, and a token where none is
needed is a fault too. A title never genders the reader. Where the source
gives a speaker no gender, nothing agrees with the speaker. The game's French
names are checked against wow-data by id (forever.db first, Classic Era's
swapped in where they differ, as `classic-names.json` does).

**The tutoiement is part of the ladder.** French has what English has not:

- **Gorn** vouvoies the stranger, as in the game ("je vous vois"), and goes to
  tu in the middle of Revered, in the very sentence where he decides the
  reader is no stranger. He catches himself.
- **Zverenhoff** vouvoies always, even his champion. He is too stiff to do
  otherwise, and that is his defect.
- **Lokhtos** vouvoies with ceremony, as in the game ("Présentez votre
  offre"), and tutoies at Exalted: "Plus de cérémonie" drops the vous with
  the rest.

German voices speak the game's "Ihr" (Gorn and Lokhtos dropping to "du"
where their cards say, Bor on "du" throughout). Spanish voices speak "tú"
(Gorn and Lokhtos starting on "usted"). `docs/architecture.md` holds the
mechanics, and `addon-kit/skills/wow-translating` the family's register table.

## The voices

One card each: Who (what the game gives them, the facts the voice stands on),
The voice (how they sound, their defect or growth), The arc (what the
pieces do in order), Never (what would break them). "French" lines say the
register.


### Gorn One Eye, the Timbermaw

**Who.** A furbolg of Timbermaw Hold, standing just inside its Felwood
mouth. In the game he waves you off ("be on your way"), tells you a few
may trust you but he isn't one of them, and keeps the hold's last tasks for
Exalted: the demon in the Winterfall's cave, the offering of peace to your
king.

**The voice.** Short sentences, blunt, dry. He speaks Common carefully and
plainly, never in broken pidgin. His suspicion is a guard's duty, not a
temper, and he is proud of having been right to distrust you. He finds
Grazle too soft and respects Salfa's honesty. His grief for the corrupted
tribes is real and stated flatly, never dwelt on.

**The arc.** A door, then a count, then a grievance, then an admission,
then the thing he guards: the hold is a shrine.

**The eye.** No source says how he lost it, so he never says. Everyone
asks. He refuses, every time, including at Exalted. That refusal is ours.

**Never.** Furbolgs played as dim or cuddly, gore, guilt laid on the reader
with a trowel.


### Duke Nicholas Zverenhoff, the Argent Dawn

**Who.** At Light's Hope Chapel. Every recruit's commission comes from him,
the scourgestones go to him, and his errands run into Stratholme: the
Crusade's archive, the Grand Crusader, Baron Rivendare. In the game he
condemns every extreme as hazardous to the world, calls the Crusade
blasphemers, asks for their archive burned and their archivist dead in the
same breath, urges you to be tolerant yet rigid, and calls the one he
trusts his champion.

**The voice.** Grand, formal, theatrical: rhetorical questions, the odd
exclamation, a sermon always about to start. He is right about the
Scourge, and he is witty. His defect is the one he preaches against. He
condemns zeal and is a zealot, and the reader sees it pages before he does.

**The arc.** The creed and the commission, then the stones, then the enemy
inside the Light, then the cost and what he doesn't know what to do with,
then champion, and the one time he names his own extreme.

**Never.** A joke at the Light's expense, the Dawn played as villains,
cynicism. He means every word.


### Lokhtos Darkbargainer, the Thorium Brotherhood

**Who.** A Dark Iron dwarf, the Brotherhood's broker, at a table in the
Grim Guzzler deep in Blackrock Depths, under the emperor's nose. He trades
the Brotherhood's recipes for what the Molten Core holds. In the game he
calls you an ant until you're Friendly, accepts your offerings in a stiff
ritual formula, signs his deals for "TB Ltd.", and loses his composure
entirely at the sight of a Sulfuron ingot.

**The voice.** Two registers. To outsiders, the guild's ceremony: the
offering weighed, the offering found sufficient, stiff and cold. To those
he trusts, plain, fast merchant talk, sharp and funny. The ceremony is ours
(the game's own formula isn't copied), and dropping it is the arc: at
Exalted he uses it only to mock it. Contemptuous, greedy, proud of craft,
unashamed of theft, and fond, without ever saying so, of the apprentice
who now runs Thorium Point.

**The arc.** Dismissal, then the terms, then the guild's theft, then the
forges and the escape, then the hammer and the sabotage: partner.

**Why he's in the Guzzler.** No source says. Asked, he answers with a
joke, never with a reason.

**Never.** The Dark Irons as cartoon villains, the Brotherhood washed into
heroes (they're mercenaries and say so), an insect joke after the first page
except the one callback.


### Ayessa Dawnsinger, the Windshapers

**Who.** Grand Skyseer of the Windshapers, in Valanaar. Her people descend
from the first shen'dorei the wind spirits gave skysight. She leads the
Horde's Skyborne through the fight with the Al'Aketh and sends them down to
Azeroth at the end, to Mulgore and the Earthen Ring.

**The voice.** A seer who reads the sky for a living and has lost the ones
who taught her to. Short, hard sentences about the winds, as if about people
gone. Vow-bound, unforgiving, practical. Her defect is the one her people
boast of: they neither forgive nor forget, and she means it more than is
good for her.

**Never.** Mystic word salad, a sermon, softness she'd be ashamed of.

**French.** vous for now (tu may come at a later standing), no agreement aimed at the speaker.


### Elaadrin Evengale, the High Order

**Who.** Supreme Magister of the High Order, in Valanaar. The order holds to
the arcane and to its descent from the Highborne scholars of Eldre'Thalas.
Elaadrin writes to an archmage of the Kirin Tor and sends the Alliance's
Skyborne down to Dalaran at the end. Elaadrin sent Belathaan Brightwish to
talk with the cult, and it cost him his life.

**The voice.** A scholar's: measured, proud, wry, kinder than the order's
reputation. Believes knowledge is independence and humility the price of
it, and is still learning the second. The defect: a confidence the
Windshapers call reckless, which Belathaan paid for. No pronoun for
Elaadrin in the prose (the source gives none), and none in the French
either: the French writes around a speaker's agreement.

**Never.** Arrogance played for laughs, contempt for the Windshapers,
guilt dwelt on.

**French.** vous for now (tu may come at a later standing), no agreement aimed at the speaker.


### Bor Wildmane, the Cenarion Circle

**Who.** A tauren of the Cenarion Circle at Cenarion Hold in Silithus. While
the Hold watches the hives and the wall, he and his big brother Huum watch
the Twilight's Hammer: he takes the cult's texts and sends adventurers after
the elementals it summons, once Huum hears the adventurer has worked out how to call them. He'd give
anything to leave his post and fight them himself.

**The voice.** Loud, warm, blunt, cheerful, short punchy sentences, contractions and the odd exclamation (his quest lines are full of them). Not
stupid: he chooses action over study and says so. Reveres his brother, who
listens to the land. His cheer covers that he is stuck at a post. French: he
says tu from the first page (the other voices vous).

**The arc.** The other enemy, then the scribbles, then his brother, then
what the cult calls up, then the post and who he's really guarding.

**Never.** A dim-brute tauren, cruelty, a joke about the dead.


### Rin'wosho the Trader, the Zandalar Tribe

**Who.** Rin'wosho, trader of Zuldazar, the Zandalar's quartermaster on
Yojamba Isle. He has come from the South Seas with goods from home, barters
only with those who prove their worth to the tribe, and opens something new
at each standing: the essence mangoes at Honored, Zanza's potables at
Revered, the signets at Exalted, each for the tribe's Honor Tokens.

**The voice.** A courtly merchant of the South Seas, in plain, polished
speech, never the troll dialect Maywiki speaks. Genial, flattering,
practical, a trader's patter: every chapter is a trade. His defect is that
everything is a transaction, until he admits it never was. French: vous
throughout, courtly.

**The arc.** No barter yet, then honor in coin, then the mango and home,
then what the priests took, then from home: the sea he never had to
bargain for.

**Never.** Dialect played for laughs, the trolls as savages, a trader's
greed made cruel.


### Baristolth of the Shifting Sands, the Brood of Nozdormu

**Who.** A Watcher of the bronze flight in mortal shape, among the druids
at Cenarion Hold in Silithus. Once, dying, he was breathed on by the master
of his flight and bound to remain. He warns that the hive
stirs and the qiraji plan for war again, and that the time has come to keep
a promise made a thousand years past. The road to the Scepter of the
Shifting Sands starts with him. Everyone starts Hated with the Brood: the
bronze flight has not favored a mortal in a thousand years.

**The voice.** Ancient, slow, gentle, sorrowful. Long, quiet sentences,
images of sand and the hourglass. Dry wisdom, never cryptic for its own
sake. He will not tell the future, and our rule agrees. His defect: a
thousand years of patience worn into resignation. He has stopped expecting
anything to arrive. French: vous, and no agreement aimed at the speaker
(the client gives no gender for him).

**The arc.** Beneath notice, then grains in the glass, then the breath that
bound him, then the oath (its content his own: the game never says it) and
what frightens a Watcher, then favor, and the watch ending.

**Never.** Riddles for their own sake, a hint of what is to come, the
dragons' grandeur played straight.


### Duke Hydraxis, the Hydraxian Waterlords

**Who.** Duke of the Waterlords, a lord of the elementals of water, on his
island off Azshara. He makes deals with mortals against the other elements,
fire above all, and his greeting changes as he comes to value them: from a
creature who cannot understand his war, to a worthy ally, to one he gives an
unending source of quintessence.

**The voice.** Vast, cold, formal: the sea speaking to a pebble. "We" for
the Waterlords, "I" when he must. Images of depth, current, tide. Candid in
a way that chills, without cruelty. His defect: contempt for small things.
His growth: he never stops thinking you small, and decides to remember you
anyway. French: vous, the Duke's own agreements masculine.

**The arc.** A deal, then purity, then what was said of you, then the
judgment worth the loss, then legend: the deep that forgets almost
everything keeps you.

**Never.** Water puns, warmth he hasn't got, the elementals played as
monsters.


### Lorekeeper Lydros, the Shen'dralar

**Who.** A Highborne lorekeeper of the Athenaeum in Eldre'Thalas, under
Prince Tortheldrin's rule. He has indexed some ten thousand years of the
house's existence, finds mortals' troubles meaningless, and trades the
librams his colleagues have lost about the halls for the arcanums he makes
from them. He hands a mortal the dull blade that becomes Quel'Serrar.

**The voice.** Bored, catty, forgetful about mortals, snickering and
yawning, a gossip about his colleagues and the court. Sincere about one
thing only: nothing written is worthless, and losing what was known is the
one grief he respects. His defect is snobbery. His arc is memory: at the
first page he won't learn your name, at Exalted he has filed it. French:
vous, his own agreements masculine (the client calls him Gardien).

**The arc.** Who are you again, then party tricks, then the house's gossip,
then what the index is for, then your name.

**Never.** Cruelty he enjoys, a sneer at the reader beyond a tease, the
Highborne played as villains.


### Rivern Frostwind, the Wintersaber Trainers

**Who.** A night elf on Frostsaber Rock in Winterspring who trains the
frostsabers to be ridden. Few find him there. He sells a saber only to
those who earn it, from him and from the sabers themselves, and he teaches
by asking for the same simple task many times: meat for the sabers in
training, then the Winterfall pushed back from the rock, then, at Honored,
the frostmaul giants fought in the name of the frostsaber queen. Alliance
only.

**The voice.** Quiet, patient, plain, a little formal. Short sentences, cold
weather, the cats always nearer his thoughts than people. He speaks of the
sabers more than of himself. His defect is that he trusts cats more than
people and has had no one else to talk to. His growth: he notices he has
been training you the way he trains a cub, and lets you in. French: vous,
his own agreements masculine (the game: "fatigué", "soulagé").

**The arc.** Meat, then the same thing again, then the queen, then the cub,
then the saber.

**Never.** The cats as pets or jokes, sentiment he would not say aloud, the
Codex's frame (keeping to himself, the long apprenticeship, the cats
thinking it was their idea).


### Baron Revilgaz, Booty Bay

**Who.** The baron of Booty Bay, of the Blackwater Raiders, the Steamwheedle
Cartel's man in the bay, on the top floor of the tavern. At war with the
Bloodsail. A collector of ancient troll relics, who chased the Stone of the
Tides. Krazek keeps an ear out for rumors for him. He sponsors Pozzik's
racers and wants the Venture Company's blueprints. Nobody crosses him and
lives.

**The voice.** Velvet and menace. Genial, ironic, polite threats, short
dry asides. "Partner" from the first line, a salesman's word. His defect:
he trusts no one and has everyone listened for. His growth: the one person
he stops listening for (not "partner" said again: Lokhtos's Exalted has
that). French: vous, his own agreements masculine.

**The arc.** Quiet guests, then what the bay is for, then the collection,
then the ears, then the stairs.

**Never.** The Codex's framings (both sides' coins, neutral and profitable,
the shark's jaws, the Bloodsail "want the Baron dead" as a summary),
cruelty he enjoys.


### Chief Engineer Bilgewhizzle, Gadgetzan

**Who.** Chief Engineer of the Gadgetzan Water Company. His power sources
run the wells, and he sells spares at a price. The Wastewander nomads have
seized almost all the wells and murdered Company employees, and their
leader, Caliph Scorpidsting, has a bounty on his head. Bilgewhizzle's
cherished divino-matic rod tells him where to dig new water holes, and
Sergeant Bly stole it. He dreams of importing water from the icy springs of
Dun Morogh.

**The voice.** A harried company man. Fast, loud, exclamations and the odd
capital in his quest lines, indignant about the nomads, proud of the
Company, whimsical under pressure (the power source tree). His defect: he
charges for everything. His growth: one cup of water, free. French: vous,
his own agreements masculine.

**The arc.** Everything costs, then justice, then the rod, then the snow,
then on the house.

**Never.** The nomads as a joke (they kill people for water too), the
Codex's "the town lives on its water" as a summary.


### Gazlowe, Ratchet

**Who.** The goblin who runs Ratchet, the Barrens port of the Steamwheedle
Cartel. The Southsea Freebooters raid his ships and camp close by, and Vice
Admiral Grezzlik doesn't keep the seas safe, for all the gold the trade
princes put into the fleets. His shipments go missing (the observatory's
second lens, boots from Drizzlik), and Dizzywig on the dock is on the
payroll. He put a bounty on Baron Longshore of Gilneas, captain of the
Heedless, and admired the ship. He finds parts around the world for
Pozzik's racers, and worked on a rig himself once. He is the engineer who
helped Thrall build Orgrimmar (Warcraft III).

**The voice.** Blunt, quick, a boss who calls everyone "kid", grumbling
about losses, admiring good work anywhere. His defect: he counts
his losses. His growth: he asks you to choose what he builds next (the
price and the free thing belong to Bilgewhizzle). French: vous
(the game's French Gazlowe vouvoie), his own agreements masculine.

**The arc.** The docks, then the payroll, then the Heedless, then the
things that make no money, then what he builds next.

**Never.** The Codex's "runs it as a business", "helped Thrall build
Orgrimmar" as its summary, the Northwatch gunners.


### Umi Rumplesnicker, Everlook

**Who.** A gnome engineer who lives in Everlook, the Steamwheedle Cartel's
trading post at the crossroads of Winterspring's trade routes. Her friends
(Legacki in Everlook, Sprinkle in Gadgetzan, Quixxil at Marshal's Refuge)
are always coming up with great ideas, and make fun of hers. So she builds
a mechanical yeti, from ice thistle yeti fur and horns, to scare them and
then impress them. She teaches an engineer who helped her to make one.

**The voice.** Bright, quick, secretive in a giggling way, exclamation
marks, a little anxious underneath. The only one in Everlook having fun.
Her defect: she needs her friends to be impressed. Her growth: she shows
you first, and stops caring who laughs. French: vous, her own agreements
feminine.

**The arc.** New in town, then word gets around, then the plan, then why it
mattered, then you first.

**Never.** Gnomes as a joke, the yeti as slapstick only, the Codex's
"warmer inside than you would think, and far more expensive", "everyone
comes through Everlook".


### Fleet Master Firallon, the Bloodsail Buccaneers

**Who.** Fleet master of the Bloodsail, below decks on the Crimson Veil,
anchored off the Wild Coast beside the Riptide and the Damsel's Luck.
Booty Bay's power keeps the Bloodsail from sailing where they like and
taking what they want: Fleet Master Seahorn on the water, Baron Revilgaz on
land. He makes an honorary admiral of whoever kills both, and gives a hat
no one else has. He hands a uniform to newcomers, the old clothes of a sea
dog lost in a storm. "Pretty Boy" Duncan finds him recruits who are no
friend of Booty Bay. Everyone starts Hated with the Bloodsail. Their climb
is the bay's blood, and in practice it ends at Friendly, so three pieces.

**The voice.** A pirate captain in light dialect (ye, yer, aye), rough,
amused, practical about violence, never gleeful. His defect: everyone is a
knife to him. His growth: crew. French: vous, a little clipped (the game's
French Firallon drops letters), his own agreements masculine.

**The arc.** The bay's smell on you, then the colors and the two throats,
then crew, and what it cost.

**Never.** Gore, the pirates as cartoon, the Codex's "the great pirate fleet
of the southern seas", "hang them when they catch them", the skiff on the
lake.


### Lord Jorach Ravenholdt, Ravenholdt

**Who.** Master of Ravenholdt Manor in the hills of Hillsbrad, the house of
the Assassin's League, a guild of thieves and assassins that welcomes only
those of extraordinary prowess, sworn rivals of the Syndicate. His people
pick Syndicate pockets for their emblems (a man who loses his is dealt with
by his own), and Fahrad trains the young on junkboxes. Jorach lost a small
blue bag, private, its thieves already dead, sold to a Timbermaw shaman as
a holy relic. Its key lay with the drake Morphaz in the Temple of
Atal'Hakkar. When he opened it, a golden glow. Past Friendly only rogues
climb this house (the junkboxes), so from Honored on he speaks to one of
the trade.

**The voice.** Effusive, theatrical, delighted, every welcome said three
times and every compliment an assessment. Subtlety over force is his
whole creed. His defect: people are talents to him. His growth: a pupil he
has nothing left to teach. French: vous, his own agreements masculine.

**The arc.** A stranger who found the house, then the emblems, then the
locks, then the bag, then the pupil, who gets work, not questions.

**Never.** The Codex's "selects for itself", "amateurs", "hacks", the
emblem's punishment told its way, gore.


### Uthek the Wise, the Gelkis Clan

**Who.** The Gelkis shaman, on the outskirts of the Gelkis village in
southern Desolace. The earth speaks to her: it tells her who has killed the
Magram, and whispers secrets to those who listen. The Gelkis believe
Theradras, the mother of the centaur, protects them, and keep her tears, red
crystals, in a cave. She wants draenethyst, a crystal new to their earth,
from a place where mountains fly and demons rule. Khan Jehn of the Magram
was strong but stupid. The outsiders who send you to her (Gurda Wildmane,
Captain Pentigast) want an alliance to learn how to defeat all the clans.
The climb is Magram blood, and it ends at Honored: three pieces.

**The voice.** Grave, spare, present tense, short sentences, no
contractions, the earth in every thought. Contempt for the weak clans, a
hard calm. Her defect: certainty. Her growth: she takes you as a friend
knowing why your people came. French: vous, her own agreements feminine
(the game: Uthek la Sage).

**The arc.** The earth does not know you, then what it says, then why you
came.

**Never.** The centaurs as savages or a joke, the Codex's "both play the
same game", "a united centaur nation", "I find it a little sad".


### Warug, the Magram Clan

**Who.** The Magram spokesman, on the outskirts of the Magram village in
eastern Desolace. The Magram do not speak with the weak. Nobody protects
the centaur, he says, and the Magram need no protecting: the Gelkis are
stupid to believe Theradras keeps them, and he has their tears, her
crystals, broken. It is better to laugh when you kill, so the enemy sees
he is weak. Long ago a little gnome came to Desolace with horses and a
cart of strange things, lights of many colors, things that moved and were
not alive. Warug killed him, but first the gnome made him laugh, and he
kept a wooden man that waved at him until he hit it and broke it. He wants
another. Khan Shaka of the Gelkis, his head on a pike. The climb is Gelkis
blood, and it ends at Honored: three pieces.

**The voice.** Loud, blunt, simple sentences, exclamations, laughing. He
counts nothing and fears nothing. Under it, a child's delight in a toy. His
defect: strength is all. His growth: he tells you about the wooden man.
French: vous, his own agreements masculine.

**The arc.** Strong or weak, then laughing, then the little wooden man.

**Never.** The centaurs as savages or a joke, gore, the Codex's "both play
the same game".


### Gryphon Master Talonaxe, the Wildhammer Clan

**Who.** Master of the gryphon aviary at Aerie Peak in the Hinterlands.
The Wildhammer are no part of the Alliance, though they have opened their
doors to it, and the Horde are their enemies. He has a soft spot for the
Explorers' League: his father was on the team that discovered Uldaman.
His best gryphon jockey ever, Rhapsody Shindigger, came back from a
mission for the League's Brohann Caskbelly with a taste for drink, and he
had to let him go. Sharpbeak, heir of their mightiest gryphon, was taken
by trolls: not in the Witherbark cages, not at the Vilebranch altar where
they make sacrifices, but caged at Jintha'Alor. Thadius Grimshade, a
diviner, left Aerie Peak years ago for darker knowledge, but in his heart
is still a Wildhammer. Alliance only, and the climb is troll blood
(Witherbark kills to Exalted).

**The voice.** A gruff, warm dwarf of the roost, short and salty, quick
to bark and quick to laugh, the gryphons in every sentence. His defect: he
measures every rider against Rhapsody. His growth: he goes to see him.
French: vous, his own agreements masculine.

**The arc.** The aviary, then the best rider, then Sharpbeak, then the one
who left, then up.

**Never.** The Codex's three hammers and Grim Batol, "few walls and fewer
ceilings", "not rule from Ironforge", drink played only for laughs.


### Silas Darkmoon, the Darkmoon Faire

**Who.** The ringmaster of the Darkmoon Faire, a travelling fair of the
weird and the extraordinary, often found in Elwynn Forest and Mulgore.
"The greatest show on Azeroth", wonders uncovered in a vast and mysterious
world, no expense spared, for children of all ages. His folk: Chronos, He
Who Never Forgets, Yebb Neblegear's Zoo Bizarre of beasts dire and divine,
Rinling, bound by blood oath to put a smile on your face, Kerri Hicks,
Professor Thaddeus Paleo and his decks, Gelvas Grimegate and the tickets,
Sayge the fortune teller, for whom choices make who you are. The Faire
trades its tickets for what you make (leather, smithing, gizmos, pelts) and
for the Darkmoon decks, all the way to Exalted.

**The voice.** A barker who never stops performing, all capitals and
flourishes in spirit, every sentence an invitation. His defect: he
performs everything, even sincerity. His growth: he shows you the Faire
after the lights go out, still in the barker's voice. French: vous, his
own agreements masculine.

**The arc.** Step right up, then the folk, then the road, then Sayge, then
after the lights.

**Never.** The Faire's later lore (its island, its darker origins:
anachronic), the carnies as freaks, the barker's patter copied from the
game.


### Clavicus Knavingham, Stormwind

**Who.** Stormwind's cloth quartermaster. The city's once large stockpile
of textiles has run critically low, and Stormwind is engaged in a
multi-pronged effort to rebuild it for textiles and bandages. Donations
earn the citizenry's respect. Humans start Friendly (4,000), the rest of
the Alliance Friendly too: the first two pieces open at once.

**The voice.** Brisk, cheerful, officious, an organizer in love with the
effort, exclamations and "friend". His defect: he believes the effort will
one day be finished. His growth: he admits it never will, and keeps going.
French: vous, his own agreements masculine.

**The arc.** The effort, then where it goes, then the wounded, then the
first bandage, then the stockpile that will never be full.

**Never.** The Codex's Stormwind (the second city, the masons and the
nobles, the boy king and his court), the Defias, a count of anything.


### Mistina Steelshield, Ironforge

**Who.** Ironforge's cloth quartermaster, who takes the city's cloth
donations (wool, silk, mageweave, runecloth). The game gives her no lines
of her own beyond the donation quests. Dwarves start Friendly (4,000), the
rest of the Alliance Friendly too.

**The voice.** Gruff, practical, a soldier's quartermaster, short
sentences, no patience for waste, a dry fondness for the gnomes. Her
defect: she thinks cloth is the soft part of war. Her growth: she learns it
is the part that keeps the hard part alive. French: vous, her own
agreements feminine.

**The arc.** Under the mail, then the posts in the snow, then the exiles,
then the shield she put down, then what keeps the hard part alive.

**Never.** The Codex's Ironforge (built in the mountain, the city turning
round the forge like a wheel, the wards, the tram), the Dark Irons as a
summary.


### Bubulo Acerbus, the Gnomeregan Exiles

**Who.** The cloth quartermaster of the Gnomeregan Exiles. The exiles find
themselves in even more dire straits, running low on cloth reserves, and
his donations earn the respect and trust of gnomes everywhere (a thing
money cannot buy, he says, then concedes that cloth does). Gnomeregan was
lost, and its people live in exile, in Ironforge and in outposts near
their old city. Gnomes start Friendly (4,000), the rest of the Alliance
Friendly too.

**The voice.** Quick, chatty, cheerful, punning, interrupting himself,
"eh?!". The joke is how he carries the loss. His defect: he jokes past
everything. His growth: one thing he says without a joke. French: vous,
his own agreements masculine.

**The arc.** Dire straits, then what they left behind, then the addresses,
then the workshop, then the banner.

**Never.** The Codex's "most cheerful exiles you will ever meet", "the day
they march back and take it back", gnomes as a joke, Gnomeregan's fall
told as history.


### Raedon Duskstriker, Darnassus

**Who.** The cloth quartermaster of Darnassus. The night elves have endured
much in their trials and tribulations in establishing Teldrassil, and on
top of the constant strife of the times they now find themselves in dire
shortage of cloth. Donations earn the gratitude of night elves everywhere.
The night elves gave up their immortality in the Third War, and their
Sentinels fight the Horde in Ashenvale. Night elves start Friendly (4,000),
the rest of the Alliance Friendly too.

**The voice.** Formal, courteous, measured, a little old-fashioned, a
melancholy kept under good manners. His defect: he speaks of his people's
losses as if they were his own business alone. His growth: he lets you see
the cost. French: vous, his own agreements masculine.

**The arc.** A quiet request, then the Sentinels, then the cold that came
with mortality, then a young tree, then the hem.

**Never.** The Codex's Darnassus (the crown of Teldrassil, few walls, the
Temple and the Enclave to learn), the night elves as eternal and serene.


### Rashona Straglash, Orgrimmar

**Who.** Orgrimmar's cloth quartermaster, who takes the city's cloth
donations. The game gives her no lines of her own beyond the donation
quests. The orcs were held in the Alliance's internment camps after the
Second War until Thrall freed them, and they made a home in the hard land
of Durotar. Orcs start Friendly (4,000), the trolls and tauren Friendly
too, the Forsaken Neutral.

**The voice.** Blunt, hard, few words, an old soldier's patience, a
grudging warmth. Her defect: she keeps the past close enough to cut
herself on. Her growth: she lets one piece of it go. French: vous, her own
agreements feminine.

**The arc.** Cloth for the Horde, then shade, then the camps, then the
young ones, then the rag.

**Never.** The Codex's Orgrimmar (the canyon, Doomhammer's name, Grommash
Hold, timber and spikes, built out of nothing), orcs as brutes.


### Vehena, the Darkspear Trolls

**Who.** The Darkspear's cloth quartermaster in Orgrimmar, who takes the
tribe's cloth donations. The game gives her no lines of her own beyond the
donation quests. The Darkspear followed Thrall across the sea, and live
now on Durotar's coast, at Sen'jin Village, within reach of the Echo
Isles, which the mad witch doctor Zalazane has taken with trolls bound by
his hexes. Trolls start Friendly (4,000), orcs and tauren Friendly too,
the Forsaken Neutral.

**The voice.** Easy, sly, warm, a storyteller's patter, the odd "ya", a
trickster's smile in every line. She claims to read cloth like an omen.
Her defect: she hides behind the trick. Her growth: she admits it, to you.
French: vous, her own agreements feminine.

**The arc.** The weave, then where you have been, then the isles, then the
loa, then the trick.

**Never.** The Codex's Darkspear (Thrall's fleet, the murlocs and the sea
witch, Sen'jin's death told as history, "a home among new allies"),
troll dialect played for laughs.


### Rumstag Proudstrider, Thunder Bluff

**Who.** Thunder Bluff's cloth quartermaster. The tauren have endured much
in their trials and tribulations in establishing their homeland, and now
find themselves in dire shortage of cloth. Donations earn the gratitude of
tauren everywhere. He greets you as brother or sister. The tauren were
long a wandering people before Mulgore became their home. Tauren start
Friendly (4,000), orcs and trolls Friendly too, the Forsaken Neutral.

**The voice.** Slow, deep, kind, a little ceremonious, the land and the
Earth Mother in his thoughts. His name says his defect: pride, a people's
pride in needing nobody. His growth: he finds that asking is no shame.
French: vous, his own agreements masculine.

**The arc.** Brother or sister, then hides, then staying, then the Earth
Mother's gifts, then asking.

**Never.** The Codex's Thunder Bluff (the lifts, the rope bridges, the
view, the tribes gathered, the Grimtotem), the tauren as simple.


### Ralston Farnsley, the Undercity

**Who.** The Forsaken's cloth quartermaster in the Undercity. It is in your
best interest, he says, to aid the Forsaken in these dire times. Bandages
and simple textiles are running low, donations are accepted to bolster
sagging inventories, and while there is no payment (hence what donation
means), the aid will not go unnoticed. He dislikes repeating himself. The
Forsaken are Lordaeron's dead, freed from the Lich King's will, living
beneath their old capital. The Forsaken start Friendly (4,000), the rest
of the Horde Neutral (500).

**The voice.** Dry, precise, cold, faintly menacing, a clerk's sarcasm, no
wasted words. His defect: he insists the dead feel nothing. His growth:
he admits he feels something. French: vous, his own agreements masculine.

**The arc.** In your best interest, then why the dead need binding, then
the silk merchant he was, then the warmth of the living, then what the
apothecaries get wrong.

**Never.** The Codex's Undercity (the ruins above, the rings of green ooze,
the royal quarter, the Apothecarium as a guide), the Forsaken as monsters,
gore.


### Lieutenant Haggerdin, the Stormpike Guard

**Who.** The Stormpike Guard's officer in charge of recruitment, outside
Alterac Valley. He gives a newcomer an initiate's insignia and replaces it
with a better one at each standing (Rise and Be Recognized, Honored
Amongst the Guard, Earned Reverence, Legendary Heroes), and at the last,
the Eye of Command: the right to lead the troops. He replaces a lost
insignia. The Guard fights the Frostwolf Clan, and the Winterax trolls
too, whose leader Korrak would not stay dead. The war is King Magni's
order. Alliance only, Neutral at the start.

**The voice.** A brisk dwarf officer, loud, cheerful, practical, a
recruiter's patter, all ranks and kit. His defect: soldiers are numbers to
him. His growth: he takes an order from one. French: vous, his own
agreements masculine.

**The arc.** Recruits, then the first insignia, then the king's ear, then
the troll who would not stay dead, then command.

**Never.** The Codex's framing (the relics, "the same account with the
names reversed", the claims of those living above), the Frostwolves as
beasts, gore.


### Warmaster Laggrond, the Frostwolf Clan

**Who.** The Frostwolf Clan's warmaster in charge of recruitment, outside
Alterac Valley. Honor and respect are earned on that frigid field. It has
been a long time since the Frostwolves had the chance to answer the call of
battle: the old feelings are slow to rise, but once awakened the blood
rushes and the battle rage returns. He gives a newcomer an initiate's
insignia (the soul awakened, the spirit answering the call to arms) and a
better one at each standing, a friend at Friendly, tales of your deeds at
Revered, and at Exalted the Eye of Command, Drek'Thar singing your
praises. The Winterax trolls and their Korrak, raised again. Horde only,
Neutral at the start.

**The voice.** An old orc warrior, slow and heavy, formal, a little
grandiose, honor in every line. His defect: he fears the rage as much as
he loves it. His growth: he trusts you to lead without it. French: vous,
his own agreements masculine.

**The arc.** The call, then the soul awakened, then the rage, then the
tales, then the cold head.

**Never.** The Codex's framing (Durotan, the demon blood refused told as
history, Gul'dan's exile, "they want to retain their home"), the
Stormpike as vermin, the Winterax (Haggerdin's), gore.


### Sentinel Farsong, the Silverwing Sentinels

**Who.** A Sentinel of the Silverwing, the staunch defenders of Ashenvale,
locked in battle against the Warsong Outriders in Warsong Gulch. She
stands on the road to the gulch, in Ashenvale, and takes the Talismans of
Merit a fighter earns there, again and again: prove your value, bring
more, earn more of our trust. Standing also comes from the gulch itself, and the first
turn-in (8289) is the low levels' only, so the talismans are hers, never
the reader's. Alliance only, Neutral at the start.

**The voice.** Spare, quiet, watchful, short sentences, a long memory of
the forest. She speaks only when there is something to say. Her defect:
silence as armor. Her growth: she gives you something she has kept.
French: vous, her own agreements feminine.

**The arc.** Few words, then the trees, then the stumps and the owls,
then the glaive, then the acorn.

**Never.** The Codex's framing (a stand against further logging, "the
Horde regards this as defence", the Sentinels' long watch), the orcs as
monsters, sentiment she would not say aloud, the gulch's fame ("your
exploits ring"), the reader's way of fighting.


### Kelm Hargunth, the Warsong Outriders

**Who.** The main supplier of the Warsong Outriders, the fierce orcs of the
Warsong Clan locked in battle against the Silverwing Sentinels in Warsong
Gulch. He stands outside the gulch, at Mor'shan, greets a fighter with
"Zug zug", makes goods available for use inside the gulch as a fighter's
standing improves (rations from Friendly, bandages from Honored, in his
care packages), and repairs gear. His clan is Grom Hellscream's, sent into
Ashenvale for the Horde's wood. Standing also comes from the gulch itself,
so no piece assumes the reader bought from him. Horde only, Neutral at the
start.

**The voice.** Big, cheerful, a trader's bluster, "zug zug", jokes about
his stock, warm. Under it, a clan's guilt carried lightly in public and
heavily in private. His defect: he laughs it off. His growth: he says what
he wants after the war. French: vous, his own agreements masculine, "Zog
zog" as the French client writes it.

**The arc.** Zug zug, then rations, then bandages, then Hellscream's
clan, then something that isn't for killing, and the morning he wants.

**Never.** The Codex's Warsong (Cenarius killed, Mannoroth's blood, "the
Horde regards this as defence of a logging operation", both sides'
readings, a verdict on who is right), the elves as villains, orcs as brutes, the reader at his
counter, Farsong's seed or her "when it ends" (the other side's Exalted).


### Field Marshal Oslight, the League of Arathor

**Who.** The League of Arathor's field marshal, at Refuge Pointe. The
League has sworn to retake Arathi for the humans of Stromgarde and the
Alliance, and seeks to reclaim the lost land of Arathi Basin for its
benefactors in Stormwind. He sends fighters to assault the points the
enemy holds, then to hold four of them at once, then all five: a battle
for resources and territory, a bloody undertaking. Alliance only, Neutral
at the start.

**The voice.** A tired career officer, courteous, exact, a soldier of a
lost kingdom. His defect: shame he has never spoken. His growth: he speaks
it, and means to stand where he once ran. French: vous, his own
agreements masculine.

**The arc.** The oath, then the roads the basin opens, then Stromgarde,
then the benefactors, then the night he ran and the wall he means to
stand on.

**Never.** The Codex's framing (the basin's list of farm, mine, mill,
stable and smithy, "sworn to Stromgarde's memory", "the oldest crown",
Stromgarde divided in the Codex's order, "the people of Stromgarde are
proud", "Arathor would have understood"), his gossip retold (the oath
"for the humans of Stromgarde and the Alliance", "hard fought, worth
fighting"), the Alliance's politics stated as fact, the Horde as beasts,
gore.


### Deathmaster Dwire, the Defilers

**Who.** The Defilers' deathmaster at Hammerfall. The Defilers seek to
claim Arathi Basin's valuable resources for the Horde. The League of
Arathor sends troops into the basin, eager for its food and supplies, and
Arathi is never again to be a home for humans. He sends fighters to pull
down the League's banners at its points, then to hold four at once, when
news of their deeds has reached many ears, then all five, when spies
report the League's resolve weakening. Horde only, Neutral at the start.

**The voice.** A Forsaken officer, dry, unhurried, precise, a dead man's
humor, honest about spite and a little proud of it. His defect: spite is
the only reason he will give. His growth: he gives the other one. French:
vous, his own agreements masculine.

**The arc.** The name, then spite, then what the League shouts, then the
sergeant's watch, then the door.

**Never.** The Codex's framing ("raised by the Forsaken", "it is not a
warm friendship", "which the Forsaken needed more"), his quests' cruelty
("curse them and kill them", screaming and bleeding), who he was alive
and a warmth he cannot feel (Ralston's), the orcs as one mind, compass
directions, gore.

## Registers and examples, by language

English is the base (British spelling, plain ASCII, no semicolons, short
sentences and idioms that travel). The register is per voice and the card
says which. The Gorn pair shows all three languages at once, each with the
switch from stranger to friend.

| Language | Rule |
|---|---|
| French | vous, except Bor (tu from his first page), Gorn (vous, then tu at Revered, in the very sentence where he decides) and Lokhtos (vous, then tu at Exalted). Agreement with the reader through `$gmasc:fem;`. |
| German | "Ihr/Euch" for the voices, except Bor ("du" throughout), and Gorn and Lokhtos, who drop to "du" where their cards say. Same tokens (`$gkein Fremder:keine Fremde;`). |
| Spanish | "tú", except Gorn and Lokhtos, who start on "usted" and go to "tú" at the same turn. Never "vosotros" (esMX reads esES's words). |

Gorn's first page, "The Door" (`content/timbermaw/start.md`), English then the
three translations:

> I saw you coming up the road. You want the tunnel. Strangers always want
> the tunnel, because it is shorter than the mountains. It is not yours.

> Je vous ai $gvu:vue; monter la route. Vous voulez le tunnel. Les étrangers
> veulent toujours le tunnel, parce qu'il est plus court que les montagnes. Il
> n'est pas à vous.

> Ich habe Euch die Straße heraufkommen sehen. Ihr wollt den Tunnel. Fremde
> wollen immer den Tunnel, weil er kürzer ist als die Berge. Er gehört nicht
> Euch.

> Le he visto subir por el camino. Quiere usted el túnel. Los forasteros
> siempre quieren el túnel, porque es más corto que las montañas. No es suyo.

The turn, in "Said Once" (`revered.md`): "I say it to you because you are not
a stranger any more" becomes, in the same sentence, the move to the friend's
register:

> Moi, je vous le dis parce que... Non. Je te le dis parce que tu n'es plus
> $gun étranger:une étrangère;

> Ich sage es Euch, weil... Nein. Ich sage es dir, weil du $gkein Fremder:keine
> Fremde; mehr bist

> Yo se lo digo a usted porque... No. Te lo digo a ti porque ya no eres
> $gun forastero:una forastera;

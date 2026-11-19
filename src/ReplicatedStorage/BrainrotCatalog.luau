local RarityConfig = require(script.Parent.RarityConfig)

-- Name, base, body type, body color, belly color, features, props, caption. Rows are grouped by rarity in RarityConfig order.
local ROWS = {
	{ "Topolino Pensierino", "Mouse", "Blob", "9A9AA6", "F7C9D8", "roundEars,thinTail", "thoughtBubble", "Thinks one thought per day. Today's was cheese." },
	{ "Ranocchia Riflessina", "Frog", "Wide", "5FBF4A", "C9F0A8", "topEyes", "mirror", "Stares at the mirror to remember its own name." },
	{ "Lumachino Lentino", "Snail", "Long", "D2B48C", "FFF1D6", "brainShell", "loadingSign", "Still loading since breakfast." },
	{ "Patatino Pigrino", "Potato", "Blob", "A5743F", "D9B07A", "spots,sleepyEyes", "pillow", "Has not moved since the last update." },
	{ "Pulcino Distratto", "Chick", "Blob", "FFD93B", "FFF2A6", "beak", "spinningQuestion", "Forgot what it was doing. Twice." },
	{ "Biscottino Bufferino", "Cookie", "Wide", "D9A066", "D9A066", "chips", "bufferRing", "Buffering... buffering... crumb." },
	{ "Formaggino Fumino", "Cheese", "Wedge", "FFD23F", "FFD23F", "holes", "steam", "Overheated by one math question." },
	{ "Polpetta Pisolina", "Meatball", "Blob", "6B3B22", "8E5533", "sleepyEyes", "nightCap", "Naps between naps." },
	{ "Capretta Confusetta", "Goat", "Blob", "F4F4F0", "FFF4DE", "smallHorns,beard", "questionText", "Ate the instructions." },
	{ "Funghetto Foggetto", "Mushroom", "Tall", "FFF0D9", "FFFFFF", "mushroomCap", "fogCloud", "Grows best in brain fog." },
	{ "Cracker Crampino", "Cracker", "Block", "E8C88A", "D9B070", "dotHoles", "bandage", "Cracked under zero pressure." },
	{ "Pomodorino Panichino", "Tomato", "Blob", "E8402E", "FF8A7A", "leafTop,wideEyes", "sweat", "Panics in 4K." },

	{ "Cagnolino Scrollino", "Puppy", "Blob", "A86B3C", "FFE9C9", "floppyEars", "phone", "Has not seen the sun since 2019." },
	{ "Anatra Amnesia", "Duck", "Tall", "FFFFFF", "FFFFFF", "beak", "bandage,questionText", "Quack? Quack who?" },
	{ "Criceto Cringeto", "Hamster", "Blob", "F29A4A", "FFEBD2", "bigCheeks,roundEars", "paperBag", "Read its old posts. Never recovered." },
	{ "Tacchino Trendino", "Turkey", "Blob", "8A5A33", "D9B48A", "fanTail", "sunglasses", "Only eats what is trending." },
	{ "Riccio Ricordino", "Hedgehog", "Blob", "8A6040", "F0DCC0", "spikes", "stickyNote", "Wrote a reminder. Lost the note." },
	{ "Coniglio Caffeinato", "Bunny", "Tall", "FFFFFF", "FFC9DE", "longEars,wideEyes", "coffee", "Seven coffees. Zero thoughts." },
	{ "Pizzetta Pensierosa", "Pizza", "Wedge", "FFCF5A", "E8402E", "pepperoni", "bulbOff", "Had an idea once. The bulb is still off." },
	{ "Lasagnetta Lagghetta", "Lasagna", "Block", "F28C28", "FFD966", "layers", "loadingBar", "Every layer adds 200 ms of lag." },
	{ "Mozzarella Memoria", "Mozzarella", "Blob", "FBFBF5", "FFFFFF", "basilLeaf", "floppyDisk", "Saves every thought on a floppy disk." },
	{ "Asinello Assonnato", "Donkey", "Blob", "9A9AA0", "D6D6DA", "longEars,sleepyEyes", "nightCap", "Yawned so hard it rebooted." },

	{ "Cervellino Spaghettino", "Brain pasta", "Blob", "F2A33A", "FFF0D6", "spaghettiHair", "fork", "Its thoughts are al dente." },
	{ "Volpe Vibrina", "Fox", "Blob", "F2762E", "FFFFFF", "pointyEars,whiteTail", "headphones", "Vibes only. No homework." },
	{ "Koala Cortexino", "Koala", "Blob", "9AA0A6", "FFFFFF", "bigRoundEars,doubleBrain", "leafProp", "Sleeps 22 hours to grow its cortex." },
	{ "Fagiolino Fantasmino", "Bean ghost", "Tall", "A8E6A0", "FFFFFF", "ghostTail", "wisp", "Haunts your search history." },
	{ "Gelato Ganglio", "Ice cream", "Tall", "FF9EC7", "E0B07A", "cone", "sprinkles", "Brain freeze is its love language." },
	{ "Orsetto Ossessivo", "Bear cub", "Blob", "8A5A33", "D9B48A", "roundEars,eyeBags", "phone", "Refreshes the feed every 0.3 seconds." },
	{ "Tortellino Tic-Tac", "Tortellini", "Wide", "FFD966", "FFE9A0", "ring", "clock", "Tic. Tac. Still no homework." },
	{ "Capibara Cerebrale", "Capybara", "Wide", "A0703F", "C9A070", "calmEyes", "orange", "Too calm to rot. Rots anyway." },
	{ "Granchio Grigio", "Crab", "Wide", "B5655A", "D9D9D9", "claws", "clawsUp", "Pinches every thought that walks by." },

	{ "Neurone Pepperone", "Pepper", "Blob", "E62E2E", "FF7A7A", "stem", "sparks", "Spicy signals only." },
	{ "Squalo Sinaptico", "Shark", "Long", "3F7FD9", "FFFFFF", "backFin,teeth", "lightning", "Bites through slow wifi." },
	{ "Polpo Pensatore", "Octopus", "Blob", "8A4FD9", "D9B8FF", "tentacles6", "monocle", "Thinks with eight arms. Uses none." },
	{ "Bradipo Brainfoggo", "Sloth", "Long", "8A6A4A", "D9C2A0", "longArms,sleepyEyes", "fogAura", "Lives inside a permanent brain fog." },
	{ "Fenicottero Flashbacko", "Flamingo", "Tall", "FF7AB8", "FFC9E0", "longLegs,curvedBeak", "camera", "Keeps flashbacks of every meme from 2014." },
	{ "Lama Lobotomama", "Llama", "Tall", "F5E6C8", "FFFFFF", "longNeck,fluffyHead", "screw", "A screw loose. On purpose." },
	{ "Panda Paranoico", "Panda", "Blob", "FFFFFF", "FFFFFF", "pandaPatches,blackEars", "tinfoil", "The bamboo is watching." },
	{ "Raviolo Rizzolo", "Ravioli", "Block", "FFD966", "FFE9A0", "crimped", "sunglasses,goldChain", "Stuffed with pure rizz." },

	{ "Pinguino Sinapsino", "Penguin", "Tall", "1F2A5A", "FFFFFF", "beak,orangeFeet", "scarf", "Cool head. Hot synapses." },
	{ "Leone Limbicone", "Lion", "Blob", "E8B04A", "FFF0D0", "mane", "crown", "King of every emotion at once." },
	{ "Tigre Talamina", "Tiger", "Blob", "F28C28", "FFFFFF", "stripes,roundEars", "headset", "Ranked number one at staying up late." },
	{ "Aquila Amigdala", "Eagle", "Tall", "7A4A2A", "FFFFFF", "wings,beak", "siren", "Panics from 300 meters up." },
	{ "Balena Babbeona", "Whale", "Wide", "3F7FD9", "BFDFFF", "spout,tail", "partyHat", "Big brain. Small thoughts." },
	{ "Coccodrillo Cortisolo", "Crocodile", "Long", "4FA04F", "E8E070", "snout,teeth", "coffee,sweat", "Stress level: crocodile." },
	{ "Elefante Ippocampone", "Elephant", "Blob", "9AA0A6", "D0D4D8", "trunk,bigEars", "seahorse", "Never forgets. Forgot to sleep." },

	{ "Gattino Lobotomino", "Kitten", "Blob", "7FD95F", "D0F5C0", "catEars,tail", "zipper", "Unzipped its brain to make room for memes." },
	{ "Drago Dopaminico", "Dragon", "Blob", "D93A3A", "FFC94A", "wings,horns,tail", "heartBreath", "Breathes pure dopamine." },
	{ "Unicorno Neuronico", "Unicorn", "Blob", "FFFFFF", "FFC9E6", "rainbowMane,unicornHorn", "rainbowTrail", "Every neuron is a rainbow." },
	{ "Kraken Cervellone", "Kraken", "Blob", "7A3FC9", "FF9ED9", "tentacles8,giantBrain", "captainHat", "Sinks whole group chats." },
	{ "Fenice Frontalina", "Phoenix", "Tall", "FF7A1F", "FFE04A", "flameWings,beak", "fire", "Burns out every night. Back by 3 AM." },
	{ "Mammut Midollone", "Mammoth", "Blob", "7A5030", "C9A070", "fur,tusks,trunk", "iceBlock", "Frozen since the last good meme." },

	{ "Cervellone Supremo", "Giant brain", "Blob", "FF9EC7", "FFC9DE", "brainBody", "crown,cape,scepter", "The brain that runs all brains." },
	{ "Toccaerba Tremendo", "Grass monster", "Blob", "3FBF3A", "A8F0A0", "grassHair,scaredFace", "lawn", "It touched grass once. Never again." },
	{ "Sigma Spaghettone", "Spaghetti man", "Tall", "FFD24A", "1A1A1A", "sharpJaw,slickHair", "sunglasses,briefcase", "Grindset: 23 hours. Sleep: 1 hour." },
	{ "Rizzotto Imperatore", "Risotto bowl", "Wide", "FFF5DC", "FFFFFF", "riceDots,bowl", "laurel,toga", "Rules the rice with rizz." },
	{ "Gallina Aura Infinita", "Chicken", "Blob", "FFFFFF", "FFF0D6", "comb,beak", "rainbowAura,halo", "+∞ aura. Lays golden takes." },

	{ "Il Cervello Marcio", "Rotten brain", "Blob", "9AD94A", "6FBF3A", "cyclops,gooDrips", "gooPuddle,flies", "Fully rotted. Fully happy." },
	{ "Ohio Omnicervello", "Glitch brain", "Blob", "7A3FFF", "111111", "manyEyes,jitter", "floatingEyes", "Only in Ohio. Only at 3 AM." },
	{ "Dopamina Divina", "Angel brain", "Blob", "FFD24A", "FFFFFF", "angelWings", "halo,hearts", "One scroll away from heaven." },
}

local SUBCONSCIOUS_ONLY = { ["Gallina Aura Infinita"] = true, ["Il Cervello Marcio"] = true, ["Ohio Omnicervello"] = true, ["Dopamina Divina"] = true }

local function split(csv)
	local out = {}
	for word in string.gmatch(csv, "[^,]+") do
		table.insert(out, word)
	end
	return out
end

local function niceRound(n)
	if n < 20 then
		return math.floor(n + 0.5)
	end
	local mag = 10 ^ (math.floor(math.log10(n)) - 1)
	return math.floor(n / mag + 0.5) * mag
end

local BrainrotCatalog = { List = {}, ByName = {}, ByRarity = {} }

local row = 0
for _, rarity in RarityConfig.List do
	BrainrotCatalog.ByRarity[rarity.Name] = {}
	for k = 1, rarity.Count do
		row += 1
		local r = ROWS[row]
		local t = rarity.Count > 1 and (k - 1) / (rarity.Count - 1) or 0
		local income = niceRound(rarity.Income[1] * (rarity.Income[2] / rarity.Income[1]) ^ t)
		local def = {
			Id = row, Name = r[1], Base = r[2], Body = r[3], Color = Color3.fromHex(r[4]), Belly = Color3.fromHex(r[5]),
			Features = split(r[6]), Props = split(r[7]), Caption = r[8], Rarity = rarity.Name, RarityIndex = rarity.Index,
			Income = income, Price = income * rarity.PriceMult, SubconsciousOnly = SUBCONSCIOUS_ONLY[r[1]] or false,
		}
		BrainrotCatalog.List[row] = def
		BrainrotCatalog.ByName[def.Name] = def
		table.insert(BrainrotCatalog.ByRarity[rarity.Name], def)
	end
end

function BrainrotCatalog.Get(id: number)
	return BrainrotCatalog.List[id]
end

function BrainrotCatalog.PickFromRarity(rng: Random, rarityName: string, subconscious: boolean?)
	local pool = {}
	for _, def in BrainrotCatalog.ByRarity[rarityName] do
		if def.SubconsciousOnly == (subconscious == true) or subconscious == nil then
			table.insert(pool, def)
		end
	end
	if #pool == 0 then
		pool = BrainrotCatalog.ByRarity[rarityName]
	end
	return pool[rng:NextInteger(1, #pool)]
end

return BrainrotCatalog

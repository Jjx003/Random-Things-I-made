
local tags = {}
local events = {}
local minimum_comparison = 3.75

local random = math.random
local ton = tonumber
local tos = tostring
local match = string.match
local concat = table.concat
local sort = table.sort
local gsub = string.gsub
local module = {}

setmetatable(module, __index = module)
--now need a table of players, telling me whether they alive or dead
local players = {}

local default = {
	__eq = function(a,b)
		return (a.main == b.main and a.sub == b.sub) or false
	end,
	__add = function(a, b)
		if a == b then --goes to the __eq operator
			a.data = a.data + b.data
			a.times[#a.times+1] = b.time
			a.last_time = b.time
			return a
		end
	end,
	__tostring = function(self)
		return concat({self.main, self.sub, self.data},'/')
	end,
	__metatable = 'cannot modify',
}

function NewEvent(main_name, sub_name, value, time)
	return setmetatable({
		main = main_name,
		sub = sub_name,
		last_time = time,
		times = {time},
		data = value,
		}, default)
end

local players = game:GetService'Players'
players.ChildRemoving:connect(function(p)--cause somereason PlayerRemoving doesn't work in testplaysolo
	if p.ClassName == 'Player' then
		tags[p.Name] = nil
	else
		print'da fuq'
	end
end)
--.PlayerRemoving:connect(function(p)
--	local search = tags[p.Name]
--	if search then
--		tags[p.Name] = nil,
--	end
--end)

function insert(t, v)
	t[#t+1] = v
end
--index ~ 'Damage' > sums all damage
local function Add(self, index) --third supposed to hold tuple but we only need one
	index = index or 'damage'
	local sum = 0
	for i, v in pairs(self.Events) do
		local name, val = match(v, '(.+)/(.+)')
		if name == index then
			sum = sum + ton(val)
		end
	end
	return sum
end

local function GetLargest(a, b, event_type)
	return a(event_type)>b(event_type) -- call the summation
end

--should rewrite this for table storage, not userdata storage
--tag format
local template = {
['Start'] = tick(),
--['Damage'] = {["1"]=50,["30"]=25}--[time after start (template.Start-tick())] = damage done, (assume last damage to be death tick())
['Events'] = {["1"]="Damaged 50 with smash attack"},
['Creator'] = 'Damager guy name',
['Active'] = true, --whether or not its the alst person to tag
}

--so all I need to add is the damage values
--**NOTE: need to tag player before applying event/damage!
--event format (string) example: 'damage/20'

--things to do:
--make start (time) universal based on the game starting time
--basically make a function that re-defines a new start time

local Starting_Time = tick()
local Enabled = true

function module:Enable(p)
	Enabled = true
	Starting_Time = tick()
	for i = 1, #p do
		players[p[i].Name] = true --set them to alive=true
	end

end

function module:Disable() --just in case wonky stuff happnes?
	tags = {} --reset the table
	players = {}
	Enabled = false
end

--tags>{person that was tagged =
--			{index# =
--				{ table =
--					{Creator = tagger.Name,
--					Events = {	{time occure, event name}	}
--					Active = true/false ~ whether or not is last tag



function module:NewTag(player, tagger, main_name, sub_name, value, time) --probably need to fix the event argument
	if not Enabled or not players[player.Name] then return end --prevent tagging while disabled or while player already dead

	local event = NewEvent(main_name, sub_name, value, time)

	local name = player.Name
	local search = tags[name] -- all the tags associated with [player]
	local my_tag --my specific tag


	if not search then
		tags[name] = {}
		search = tags[name]
	end

	for i = 1, #search do
		local v = search[i]
		if v.Creator == tagger.Name then
			my_tag = search[i]
			my_tag.Active = true
		else
			v.Active = false --no longer the recent one (not sure if this is efficient, o well)
		end
	end
		--either there is, or there isnt a "my_tag"
	if my_tag then
		--add to existing one!
		--local time_passed =  --rounds to thousandths (o well if it replaces an existing value somehow)
		print'There is an existing tag, adding on to the event list'
		local short = my_tag.Events
		local combined = false
		for i = 1, #short do
			local other_event = short[i]
			if event == other_event and (event.time - other_event.last_time) <= minimum_comparison then ---stack same event occurences if they are in the interval
				other_event = other_event + event --inserts into [times] and adds to [value]
				combined = true
				break
			end
		end
		if not combined then
			short[#short+1] = event --just insert it
		end
		table.foreach(my_tag.Events, print)
	else
		--create one!
		print'Tag does not exist for this tagger, creating a new one'
		my_tag = {
			Events = event,
			Creator = tagger.Name,
			Active = true,
		} --dont' need a metatable anymore


		search[#search+1] = my_tag --tadah, we made 1
		print'Tag inserted'
	end

end

local function FilterTime(table, last_time, max_time)
	local valid = {}
	for i = 1, #table do
		local v = table[i]
		local name = v[1]
		local event = v[2]
		if (last_time - event.last_time) <= max_time then
			valid[#valid+1] = {name, event}
		end
	end
	return valid
end

local function Last10(tag, last)
	--get events in last 10 seconds
	--this might be expensive actually..
	local all_events = {}
	local kill_tag --assume kill_tag to be last tag
	for i = 1, #tag do --i'm using this because it's faster than pairs
		local v = tag[i]
		local list = v.Events
		local name = v.Name
		for ii = 1, #list do
			all_events[#all_events+1] = {Name, list[ii]}
		end
	end
	if #all_events <= 0 then return false end
	local killer_tag = last or module:GetLastTag(tag)
	return FilterTime(all_events, killer_tag.last_time, 10) --probably need something to convert to a string output
end

--decided to format time post-death becasue its less expensive
function module:GetLastTag(search) --for the internal search
	local found = nil
	if search then
		for i = 1, #search do
			local v = search[i]
			if v.Active then
				found = v
				break
			end
		end
	end
	return found
end

function module:GetLastTag2(player)
	local search = tags[player.Name]
	local found = nil
	if search then
		for i = 1, #search do
			local v = search[i]
			if v.Active then
				found = v
				break
			end
		end
	end
	return found
end

local function BroadCast(last_tag, all_tags)
	local event_list = Last10(all_tags, last_tag)
	local last_time = last_tag.last_time
	--parse into a string with readable time measurements
end

local function ConnectAction(p, func)
	players[p.Name] = false
	func(self:GetLastTag(player), tags[player.Name]) --callback
end

game:GetService'Players'.PlayerRemoving:connect(function(p)
	if players[p.Name] and Enabled then
		ConnectAction(p, 'left') --fix 'left' and replace with a valid function
	end
end)


local function TryConnect(player, func)
	player.Character.Humanoid.Died:connect(function()
		ConnectAction(player, func)
	end)
	--insert into a table to check if the player left
	--try to make a custom .Died event ~if .Character is modified/removed
end

function module:ConnectDeath(player, func) --make it connect to the announcement feed and confirm death
	if not func then func = BroadCast end
	pcall(TryConnect, player, func)

end

local function RandomValue(t)
	return t[random(#t)]
end

local dead, tagger = '#dead', '#tagger'
function GetPhraseForDamage2(dead_name, tagger_name, damage)
	local one = {'#tagger took the last remaining health of #dead!', '#dead died to #tagger\'s poke', '#tagger pulled a dank one on #dead', '#dead was finished off by #tagger', '#tagger got the last few hits off of #dead, rip', '#dead\'s death was stolen by #tagger', '#tagger pulled a dank meme on #dead'}
	local two = {'#tagger killed #dead', '#tagger tagged #dead', 'Rip #dead: killed by a menacing #tagger','#dead was killed by #tagger','#tagger slayed #dead'}
  	local three = {'#tagger slayed #dead'}
  --reol/trinity
  	local headshot = {'#tagger headshot #dead', 'BOOM HEADSHOT #tagger killed #dead', '#dead got HEADSHOT by #tagger'}
  	local shot = {'#tagger shot #dead', '#dead was shot by #tagger'}
  	local longshot = {'#tagger got a nice #distance shot on #dead', ''}--special #distance
  	local wack = {'#dead was killed by melee moves on #weapon by #tagger', '#tagger killed #dead with melee attacks...'}--special #weapon, when u use melee to kill with a raned weapon
  --midas/iron/dong
  	local smash = {'#dead was crushed into the ground by #tagger', '#tagger crushed #dead', '#tagger hulksmashed #dead', '#tagger smashed #dead', '#tagger slam-dunked #dead'}
  --feint energy wave, divider energy wave,
  	local woop = {'#tagger landed energy wave on #dead', '#tagger managed to kill #dead with energywave'}

end

local function GetPhraseForDamage(damage)
	local one = {'memefied', 'did a one time drive-by and killed', 'poked', 'noobified', 'tickled', 'bonked', 'bopped', 'did the noob on','did a dank meme on', 'stepped on', 'played darude sandstorm for','spooked', 'finished off'}
	local two = {'killed', 'eliminated', 'knocked out', }
	local three = {'slaughtered', 'liquidated', 'destroyed','rekt', 'shreked', 'decimated', 'deleted', 'SHREKED', 'smited', 'pulverized', 'swept', 'dusted away','crushed', 'dealt tons of damage to', 'ate', ': /kill'}
	local remarks = {' o:','!','0:',' (O u O)', '!', '?', '. Jeez. rip.','. ripperini','. pray 4 his soul. every $2 a potato is donated',' #rip', 'to pluto'}
	if damage <= 10 then
		return RandomValue(one), nil
	elseif damage > 10 and damage <=70 then
		return RandomValue(two), RandomValue(remarks)
	elseif damage > 70 then
		return RandomValue(three), RandomValue(remarks)
	end
end

local function P(n)
	return '('..n..')'
end


local NewLine = '\n'
local Box = NewLine..[[```]]

--[[
	italics = *italics*
	bold  = **bold**
	bold italics = ***bold italics***
	strikeout = ~~strikeout~~
	underline = __underline__
	underline italics = __*underline italics*__
	underline bold = __**underline bold**__
	underline bold italics = __***underline bold italics***__

	#Markdown

	https://github.com/adam-p/markdown-here/wiki/Markdown-Cheatsheet
]]--

function module:DeathRecap()

end

function module:DeathRecap(player, event_type, event_timeline)--might want to rewrite this whole thing actually
	local event_type = event_type or 'damage'
	local last_tag = module:GetLastTag(player)

	if last_tag then
		local total_damage = last_tag()
		local tagger = last_tag.Creator
		local story
		local ordered = sort(tags[player.Name], function(a,b) GetLargest(a, b, event_type) end) --might want to fix this
		local a1, a2 = ordered[1], ordered[2]
		local phrase, remark = GetPhraseForDamage(total_damage)
		story = tagger..' '..phrase..' '..player.Name..(remark or '')..NewLine
		if a1 and a2 then
			local d1, d2 = P(a1()), P(a2())
			story = story..'	*The top two asists were by '..a1.Creator..d1..'and '..a2.Creator..d2
		elseif a1 and not a2 then
			local d = P(a1())
			story = story..'	*Assisted by '..a1.Creator..d
		elseif not a1 and a2 then
			local d = P(a2())
			story = story..'	*Assisted by '..a2.Creator..d
		end
		if event_timeline and #last_tag.Events >= 1  then --this should be the last five or ten seconds, not from the single tagger
			local data_box = Box
			for i = 1, #last_tag.Events do
				local v = last_tag[i]
				local time, event = v[1], gsub(v[2], '/', ' ')
				data_box = data_box..'/n'..time..': '..event
			end
			data_box = data_box..Box
			story = story..data_box
		end
		return story
	end
	return player.Name..'died without valid Tag (probably killed himself)'
end

return module


do
local _G,_VERSION,assert,collectgarbage,dofile,error,getfenv,getmetatable,ipairs,load,loadfile,loadstring,next,pairs,pcall,print,rawequal,rawget,rawset,select,setfenv,setmetatable,tonumber,tostring,type,unpack,xpcall,coroutine,math,string,table,game,Game,workspace,Workspace,delay,Delay,LoadLibrary,printidentity,Spawn,tick,time,version,Version,Wait,wait,PluginManager,crash__,LoadRobloxLibrary,settings,Stats,stats,UserSettings,Enum,Color3,BrickColor,Vector2,Vector3,Vector3int16,CFrame,UDim,UDim2,Ray,Axes,Faces,Instance,Region3,Region3int16=_G,_VERSION,assert,collectgarbage,dofile,error,getfenv,getmetatable,ipairs,load,loadfile,loadstring,next,pairs,pcall,print,rawequal,rawget,rawset,select,setfenv,setmetatable,tonumber,tostring,type,unpack,xpcall,coroutine,math,string,table,game,Game,workspace,Workspace,delay,Delay,LoadLibrary,printidentity,Spawn,tick,time,version,Version,Wait,wait,PluginManager,crash__,LoadRobloxLibrary,settings,Stats,stats,UserSettings,Enum,Color3,BrickColor,Vector2,Vector3,Vector3int16,CFrame,UDim,UDim2,Ray,Axes,Faces,Instance,Region3,Region3int16
local Storage = {}
local Admins = {'Player','cxcharlie'}

local function GetType(o)
	if type(o) ~= 'userdata' then return type(o) end
	local Order = {'Instance';'CFrame';'Vector3';'UDim2';'Vector2';'BrickColor';
	'Color3';'Ray';'Region3int16';'Region3';'UDim';'Event';'Connection'}
	local Ident = {
		function(o) return pcall(function() return o.IsA end) end;
		function(o) return pcall(function() return o.p end) end;
		function(o) return pcall(function() return o.Z end) end; 
		function(o) return pcall(function() return o.Position.X.Offset end) end;
		function(o) if not pcall(function() return o.Z end) and pcall(function() return o.X, o.Y end) then return true end return false end;
		function(o) if pcall(function() return o.r end) and pcall(function() return o.Color end) then return true end return false end;
		function(o) if pcall(function() return o.r end) and not pcall(function() return o.Color end) then return true end return false end;
		function(o) return pcall(function() return o.ClosestPoint end) end;
		function(o) return pcall(function() return o.Min end) end;
		function(o) return pcall(function() return o.CFrame end) end;
		function(o) return pcall(function() return o.Scale end) end;
		function(o) return pcall(function() return o.connect end) end;
		function(o) return pcall(function() return o.disconnect end) end;
    }
	for index,test in next,Ident do 
		if test(o) == true then
			return tostring(Order[index])
		end
	end
	return 'Unknown'
end



local ExtendedInstance = {
Workspace = {
	FindPartOnRay = function(s, ray, ignore, terrain, water)
		local terrain = terrain or false
		local water = water or false
		local found = {}
		for index, admin in pairs(Admins) do 
			if game:GetService('Players'):FindFirstChild(admin) ~= nil then
				found[#found+1] = game:GetService('Players')[admin]
			end
		end
		local chars = {}
		for index, plr in pairs(found) do 
			if pcall(function()return plr.Character.ClassName;end) then
				chars[#chars+1] = plr.Character
			end
		end
		chars[#chars+1] = ignore
		return game:GetService('Workspace'):FindPartOnRayWithIgnoreList(ray, chars, terrain, water)
	end;
	FindPartOnRayWithIgnoreList = function(s, ray, ignore, terrain, water)
		local terrain = terrain or false
		local water = water or false
		local found = {}
		for index, admin in pairs(Admins) do 
			if game:GetService('Players'):FindFirstChild(admin) ~= nil then
				found[#found+1] = game:GetService('Players')[admin]
			end
		end
		local chars = ignore
		for index, plr in pairs(found) do 
			if pcall(function()return plr.Character.ClassName;end) then
				chars[#chars+1] = plr.Character
			end
		end
		return game:GetService('Workspace'):FindPartOnRayWithIgnoreList(ray, chars, terrain, water)
	end
};
workspace = {
	FindPartOnRay = function(s, ray, ignore, terrain, water)
		local terrain = terrain or false
		local water = water or false
		local found = {}
		for index, admin in pairs(Admins) do 
			if game:GetService('Players'):FindFirstChild(admin) ~= nil then
				found[#found+1] = game:GetService('Players')[admin]
			end
		end
		local chars = {}
		for index, plr in pairs(found) do 
			if pcall(function()return plr.Character.ClassName;end) then
				chars[#chars+1] = plr.Character
			end
		end
		chars[#chars+1] = ignore
		return game:GetService('Workspace'):FindPartOnRayWithIgnoreList(ray, chars, terrain, water)
	end;
	FindPartOnRayWithIgnoreList = function(s, ray, ignore, terrain, water)
		local terrain = terrain or false
		local water = water or false
		local found = {}
		for index, admin in pairs(Admins) do 
			if game:GetService('Players'):FindFirstChild(admin) ~= nil then
				found[#found+1] = game:GetService('Players')[admin]
			end
		end
		local chars = ignore
		for index, plr in pairs(found) do 
			if pcall(function()return plr.Character.ClassName;end) then
				chars[#chars+1] = plr.Character
			end
		end
		return game:GetService('Workspace'):FindPartOnRayWithIgnoreList(ray, chars, terrain, water)
	end	
};
Players = {
	ClearAllChildren = function() end;
};
Player = {
	Kill = function(s)
		return pcall(function() s.Character:BreakJoints() end)
	end;
	Kick = function(s)
		error()
	end;
	AddHealth = function(s, a)
		return pcall(function() s.Character.Humanoid.Health = s.Character.Humanoid.Health + a end)
	end;
	_Health = function(s, a) 
		return pcall(function() s.Character.Humanoid.Health = a end) 
	end;
	_Position = function(s, pos)
		return pcall(function() s.Character:MoveTo(pos) end)
	end;
	_CFrame	= function(s, c) 
		return pcall(function() s.Character.Torso.CFrame = c end)
	end;
	_Parent = function(s, p)
		if p ~= game:GetService('Players') then return end
		s.Parent = game:GetService('Players')
	end;
	Valid = function(s)
		local name = tostring(s.Name):lower()
		for index, admin in pairs(Admins) do 
			if tostring(admin):lower() == name then
				return false
			end
		end
		return true
	end
};
Model = {
	Valid = function(s)
		local found = {}
		for index, admin in pairs(Admins) do 
			if game:GetService('Players'):FindFirstChild(admin) ~= nil then
				found[#found+1] = game:GetService('Players')[admin]
			end
		end
		for index, plr in pairs(found) do 
			if pcall(function()return plr.Character.ClassName;end) then
				if s == plr.Character then 
					return false
				end
			end
		end
		return true
	end

};
Game = {
	Destroy = function() end;
};
game = {
	Destroy = function() end;	
};
Part = {
	Explode = function(s)
		pcall(function()Instance.new('Explosion',workspace).Position = s.Position end)
	end;
	Valid = function(s)
		local found = {}
		for index, admin in pairs(Admins) do 
			if game:GetService('Players'):FindFirstChild(admin) ~= nil then
				found[#found+1] = game:GetService('Players')[admin]
			end
		end
		for index, plr in pairs(found) do 
			if pcall(function()return plr.Character.ClassName;end) then
				if s:IsDescendantOf(plr.Character) then 
					return false
				end
			end
		end
		return true		
	end;
};

	
}

local InstanceMeta = {
__len	   = function(a) return #(a._Real):GetChildren() end;
__lt	   = function(a, b) return #a <#b end;
__eq	   = function(a, b) return a._Real == b._Real end;
__concat   = function(a, b) return tostring(a)..tostring(b) end;
__tostring = function(a) return (a._Real).Name end;
__index	   = function(s, i)
	local CLASS
	for class, co in pairs(ExtendedInstance) do 
		if tostring(class):lower() == tostring(s._Real.ClassName):lower() then
			CLASS = class
			for prop, func in pairs(co) do
				if tostring(prop):lower() == tostring(i):lower() then
					local check = pcall(function()rawget(ExtendedInstance[CLASS],'Valid')end) and ExtendedInstance[CLASS].Valid
					if check ~= nil then
						if check(s._Real) then
							if type(func) == 'function' then
								return function(...) func(s._Real,...) end
							else
								return func
							end
						else
							return	
						end
					else
						if type(func) == 'function' then
							return function(...) func(s._Real,...) end
						else
							return func
						end
					end
				end
			end
		end
	end
	if CLASS then
		local check = pcall(function()rawget(ExtendedInstance[CLASS],'Valid')end) and ExtendedInstance[CLASS].Valid
		if check ~= nil then
			if check(s._Real) then
				return wrap(s._Real[i])
			else
				return nil
			end
		end
	end
	return wrap(s._Real[i])
end;
__newindex = function(s, i, v)
	local CLASS
	local ni = '_'..tostring(i):lower()
	for class, co in pairs(ExtendedInstance) do 
		CLASS = class
		local check = pcall(function()rawget(ExtendedInstance[CLASS],'Valid')end) and ExtendedInstance[CLASS].Valid
		if tostring(class):lower() == tostring(s._Real.ClassName):lower() then
			for index, func in pairs(co) do
				if tostring(index):lower() == tostring(ni):lower() then
					if check ~= nil then
						if check(s._Real) then
							func(s._Real,v)
							return
						else
							return
						end
					else
						func(s._Real,v)
						return						
					end
				end
			end
		end
	end
	if CLASS then
		local check = pcall(function()rawget(ExtendedInstance[CLASS],'Valid')end) and ExtendedInstance[CLASS].Valid
		if check ~= nil then
			if check(s._Real) then
				s._Real[i] = v
			else
				return
			end
		end
	end	
	s._Real[i] = v
end;

}    


local WrapperIdentities = {
Instance =  function(i)
	return setmetatable({_Real = i}, InstanceMeta)
end;
table = function(i)
	local n = {}
	for index, val in pairs(i) do 
		n[index] = wrap(val)
	end
	return n
end	;
['function'] = function(i)
	return function(o, ...)
		return wrap(i((pcall(function() assert(rawget(o,"_Real"), "No") end) and o._Real) or o,...))
	end
end;
Event = function(i)
	return setmetatable({_Real = i; connect = function(s, f)
		local c
		c = s._Real:connect(function(...)
			f(wrap(...))
		end)
		return {disconnect=function()c:disconnect()end}
	end	
	},{__index = function(s, i, v) return wrap(s._Real[i]) end})
end;
}

local function unwrap(...)
	local r = {};
	for k,v in next,{...} do
		table.insert(r, pcall(function() if not rawget(v, "_Real") then error() end end) and v._Real or v)
	end
	return unpack(r)
end

function wrap(...)
    local r = {}
    local a = {...}
    for index, v in pairs(a) do
        if Storage[v] == nil then
            local t = GetType(v)
            local new = WrapperIdentities[t]
			if new then
				Storage[v] = new(v)
           		r[#r+1] = new(v)
			else
				r[#r+1] = v
			end
        else
            r[#r+1] = Storage[v]
        end
    end
    return unpack(r)
end

local Instance = Instance

local SandBox
if _G.G == nil then
	_G.G = {}
end
SandBox = wrap({
_G = _G.G;
print = print;
Spawn = Spawn;
Delay = Delay;
coroutine = coroutine;
UDim2 = UDim2;
setfenv = setfenv;
LoadLibrary = LoadLibrary;
Stats = Stats;
tick = tick;
Region3 = Region3;
Spawn = Spawn;
stats = stats;
next = next;
Delay = Delay;
Workspace = Workspace;
ElapsedTime = ElapsedTime;
workspace = workspace;
pairs = ipairs;
load = load;
elapsedTime = elapsedTime;
os = os;
ypcall = ypcall;
CFrame = CFrame;
assert = assert;
newproxy = newproxy;
ipairs = ipairs;
version = version;
game = game;
rawset = rawset;
shared = shared;
time = time;
Region3int16 = Region3int16;
_VERSION = _VERSION;
Version = Version;
table = table;
Wait = Wait;
pcall = pcall;
tostring = tostring;
settings = settings;
loadstring = function(...)
	local f = {loadstring(...)}
	if f[1] then
		setfenv(f[1],setmetatable({},{__index = SandBox}))
	end
	return unpack(f)	
end;
Color3 = Color3;
CellId = CellId;
Vector2 = Vector2;
collectgarbage = collectgarbage;
UserSettings = UserSettings;
delay = delay;
UDim = UDim;
Game = Game;
Ray = Ray;
error = error;
spawn = spawn;
Instance = 
	setmetatable({
	new = function(o, p)
		local p = unwrap(p) or p
		local t = GetType(p)
		if t == 'Instance' then
			return wrap(Instance.new(o, p))
		end
	end
	},{__index = function(s, i)  return wrap(Instance[i])end;
	__call = function(s,...) return s.new(...)end;
	});
wait = wait;
Vector2int16 = Vector2int16;
Faces = Faces;
math = math;
setmetatable = setmetatable;
select = select;
xpcall = xpcall;
dofile = dofile;
loadfile = loadfile;
coroutine = coroutine;
getmetatable = getmetatable;
type = type;
rawget = rawget;
DebuggerManager = DebuggerManager;
Enum = Enum;
unpack = unpack;
BrickColor = BrickColor;
rawequal = rawequal;
Axes = Axes;
string = string;
Vector3 = Vector3;
require = require;
PluginManager = PluginManager;
getfenv = function() return {['Escape']=function()print'MUHAHAHAH'end}end;
tonumber = tonumber;
printidentity = printidentity;
warn = warn;
Vector3int16 = Vector3int16;
gcinfo = gcinfo;
})

setfenv(1, setmetatable({}, {__index = SandBox}))
end 


local Spawn=Spawn
local player=game.Players.LocalPlayer
local p2=2*math.pi
local settings=setmetatable({
points=12,
reps=5,
thickenss=1,
size=12,
center=CFrame.new(0,5,0),
speed=2,
},{__index=function(s,i)
if not type(i)=='string' then return end
for prop,val in pairs(s) do 
	if prop:lower()==i:lower() then
		return val
	end
end
end
})

local BouncingBoxPoints = { -- Bouding box posiitions. 
	Vector3.new(-1,-1,-1);
	Vector3.new( 1,-1,-1);
	Vector3.new(-1, 1,-1);
	Vector3.new( 1, 1,-1);
	Vector3.new(-1,-1, 1);
	Vector3.new( 1,-1, 1);
	Vector3.new(-1, 1, 1);
	Vector3.new( 1, 1, 1);
}

local function GetBoundingBox(Objects)
local Sides = {-math.huge;math.huge;-math.huge;math.huge;-math.huge;math.huge}
for _, BasePart in pairs(Objects) do
local HalfSize = BasePart.Size/2
local Rotation = BasePart.CFrame
for _, BoundingBoxPoint in pairs(BouncingBoxPoints) do
local Point = Rotation*CFrame.new(HalfSize*BoundingBoxPoint).p

if Point.x > Sides[1] then Sides[1] = Point.x end
if Point.x < Sides[2] then Sides[2] = Point.x end
if Point.y > Sides[3] then Sides[3] = Point.y end
if Point.y < Sides[4] then Sides[4] = Point.y end
if Point.z > Sides[5] then Sides[5] = Point.z end
if Point.z < Sides[6] then Sides[6] = Point.z end
end;end
-- Size, Position
return Vector3.new(Sides[1]-Sides[2],Sides[3]-Sides[4],Sides[5]-Sides[6]), 
Vector3.new((Sides[1]+Sides[2])/2,(Sides[3]+Sides[4])/2,(Sides[5]+Sides[6])/2)
end

local Parts={}


-------------------------------------------------
-------------------------------------------------

local rem=false


local function Draw(p1,p2)
	local d=(p1-p2).magnitude
	local pos=CFrame.new(p1,p2)
	pos=pos.p+(pos.lookVector*(d/2))
	pos=CFrame.new(pos,p2)
	local p=Instance.new('Part')
	p.Material=Enum.Material.Neon
	p.CanCollide=false
	p.Anchored=true
	p.FormFactor=Enum.FormFactor.Custom
	p.Size=Vector3.new(settings.thickness,settings.thickness,d)
	p.CFrame=pos
	Parts[#Parts+1]=p
	return p
end

local function Get(l)
local ray=Ray.new(l,Vector3.new(0,-999,0),true)
local hit,pos=workspace:FindPartOnRayWithIgnoreList(ray,{(player.Character~=nil and player.Character)})
if hit then return l-((pos-l).unit/2) end
--if hit then return (pos-l).magnitude;end
return nil
end

local function AntiRemove(a,p)
game.DescendantRemoving:connect(function(o)
if o==a and rem==false then
pcall(function()o.Parent=p;end)
Spawn(function()
wait(0)
pcall(function()o.Parent=p;end)
end)
end
end)	
end



local function GetParts(m)
if not pcall(function()m:children''end)then return end
local f={}
if #m:children''>=1 then
for _,v in pairs(m:children'')do
if v.ClassName=='Part' then f[#f+1]=v;end
local a=GetParts(v)
table.foreach(a,function(i,v)f[#f+1]=v;end)
end
else
return {}
end
return f
end


local function Move(m,c)
local parts=GetParts(m)
local s,p=GetBoundingBox(parts)
local center=p+Vector3.new(0,s/2,0)
for _,v in pairs(parts)do
local a=c:toWorldSpace(CFrame.new(center):toObjectSpace(v.CFrame))
v.CFrame=a
end
end

local BALL
local STARTED=false

local function Start()
-------------------------
	
local gpoints={}
local angleN=(p2)/settings.points
for i = 1,settings.points do
	local ver=settings.center*CFrame.Angles(0,angleN*i,0)
	gpoints[#gpoints+1]=ver.p+(ver.lookVector*(settings.size/2))
end

local repN=(p2)/settings.reps
local rpoints={}
for r=1,settings.reps do
	rpoints[r]={}
	for _,v in pairs(gpoints)do
		local q=settings.center*CFrame.Angles(repN*r,0,0)*CFrame.new(settings.center:pointToObjectSpace(v))
		local ver=q.p
		rpoints[r][#rpoints[r]+1]=q.p
	end
end	

local function DrawShape()
	local m=Instance.new('Model',workspace)
	
	AntiRemove(m,workspace)
	for i,set in pairs(rpoints) do
		for i2,point in pairs(set) do
			if set[i2+1]~=nil then
				local seg=Draw(point,set[i2+1])
				seg.Parent=m
				AntiRemove(seg,m)
			else
				local seg=Draw(point,set[1])
				seg.Parent=m
				AntiRemove(seg,m)
			end
		end
	end
	return m
end

function HSVtoRGB(h, s, v)
	h = (h % 1) * 6
	local f = h % 1
	local p = v * (1 - s)
	local q = v * (1 - s * f)
	local t = v * (1 - s * (1 - f))
	if h < 1 then
		return v, t, p
	elseif h < 2 then
		return q, v, p
	elseif h < 3 then
		return p, v, t
	elseif h < 4 then
		return p, q, v
	elseif h < 5 then
		return t, p, v
	else
		return v, p, q
	end
end


------------------------------

print'GO BOIS'
STARTED=true
	
local a=DrawShape()
local s,p=GetBoundingBox(GetParts(a))
local center=CFrame.new(p+Vector3.new(0,s/2,0))
local b=DrawShape()
Move(a,center)
Move(b,center)

BALL={a,b}

local l
local scan=false

--		local region

game:GetService('RunService'):BindToRenderStep('Ball',1,function()
if not STARTED then return end
if player.Character~=nil then
if player.Character:FindFirstChild('Torso')~=nil then
local New={}
table.foreach(Parts,function(i,v)
	if v~=nil and pcall(function()return v.Parent end) then
		New[#New+1]=v
		local x,y,z=i,i+math.pi,i+math.pi*2
		x=x+math.sin(tick()/2)*10 -.3
		y=y+math.sin(tick()/2)*10 -.3
		local scale=#Parts
		local value=math.noise(x / scale + 0.5 , y / scale + 0.5 , 1+math.sin(tick()/2)/3)
		v.BrickColor=BrickColor.new(HSVtoRGB(0.5+value, 1, 1))
	end
end)
Parts=New
l=CFrame.new(player.Character.Torso.CFrame.p)

scan=not scan
			
if scan then
				
local region=Region3.new(l.p-(Vector3.new(1,1,1)*settings.size/2),l.p+(Vector3.new(1,1,1)*settings.size/2))
local parts=workspace:FindPartsInRegion3WithIgnoreList(region,{(player.Character~=nil and player.Character),a,b})
			
for _,v in pairs(parts) do
if v:FindFirstChild('Tagged')==nil then
if v:GetMass()<=90 then
							
local a=Instance.new('Folder',v)
a.Name='Tagged'
game:GetService('Debris'):AddItem(a,.2)
							
v:BreakJoints()
v.Anchored=false
v.Velocity=(v.Position-l.p).unit*300
							
end--good mass
end--tagged
end--loop
end--if scan
end--if player.character.torso
end--if player.character
		
Move(b,center)
Move(b,l*CFrame.Angles(math.rad(math.sin(tick()*settings.speed/2)*2),0,0))
		
Move(a,center)
Move(a,l*CFrame.Angles(0,math.rad(settings.speed),0))

end)
end

local CMDS={}



setmetatable(CMDS,{__index=function(s,i)
if type(i)=='string' then
	for ind,cmd in pairs(s) do
		print(ind:lower(),i:lower())
		if ind:lower()==i:lower() then return cmd end
		for i2,aliase in pairs(cmd.Aliases) do
			if aliase:lower()==i:lower() then 
				return cmd
			end
		end
	end
end
end,
__newindex=function(s,i,v)
local b=setmetatable(v,{__call=function(s2,...)print'fire in da hole's2.Action(...)end})
rawset(s,i,b)
end,
})

CMDS.Start={
Action=function(args)
	if not args.Points and not args.Size and not args.Reps then
	if args.Speed then settings.speed=args.Speed;end
	if not STARTED then Start()end
	else
	STARTED=false
	game:GetService('RunService'):UnbindFromRenderStep('Ball')
	rem=true
	if BALL~=nil then for _,v in pairs(BALL) do pcall(function()v:remove()end)end;end
	if args.Size then settings.size=args.Size;end
	if args.Speed then settings.speed=args.Speed;end
	if args.Points then settings.points=args.Points;end
	if args.Reps then settings.reps=args.Reps;end
	Spawn(function()wait()Start()end)
	rem=false
	end
end,
Aliases={'star','boot','s'},
}


local ARG_TABLE=setmetatable({
['size%D*(%d+)']=	function(a)		return {'Size',tonumber(a)}end,
['fire']=			function()		return {'Fire',true}end,
['points%D*(%d+)']=	function(a)		return {'Points',tonumber(a)}end,
['rep%D*(%d+)']=		function(a)		return {'Reps',tonumber(a)}end,
['speed%D*(%d+)']=	function(a)		return {'Speed',tonumber(a)}end,
},
{__index=function(s,i)
	for name,func in pairs(s) do
		if i:lower():match(name)~=nil then
			return func(i:lower():match(name))
		end
	end
	return nil
end
})

local function ParseArgs(s)
	local Valid={}
	for i,arg in pairs(s) do
		local try=ARG_TABLE[arg]
		if try ~= nil then
			local ind,val=try[1],try[2]
			print(type(val))
			print(val)
			Valid[tostring(ind)]=tonumber(val)
			--print'boys we got one!!'
		end
	end
	return Valid
end

player.Chatted:connect(function(c)
	local c=c:lower()
	local cmd,args=c:match('(.-)/*/(.*)')
	local found=CMDS[cmd]
	if found ~= nil then
	local fargs={}
	for arg in string.gmatch(args,'(.-/*)/')do
		fargs[#fargs+1]=arg
	end
	local real_args=ParseArgs(fargs)
	found(real_args)
	end
end)

--[[
local a='Bob/b/b' 
local start=a:match('^([%w+/?]-)/')
print(start)

local a='Bob///b/b' 
local start=a:match('(.-/*)/.*')
print(start)

local a='Bob/5///b/b' 
local start,args=a:match('(.-/*)/(.*)')
print(start,args)

local a='Bob/5///b/b' 
local start,args=a:match('(.-)/+/(.*)')
print(start,args)

local a='size-true/fall'
for arg in string.gmatch(a,'(.-/*)') do print(arg) end

local a='size-true/fall'
for arg in string.gmatch(a,'(.-)/*/?) do print(arg) end
s

--]]



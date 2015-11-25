local npc=game.Workspace.Dummy
local ntorso=npc.Torso
local see_distance=20
local cast=game:service'Workspace'.FindPartOnRay

local player=game.Players.LocalPlayer
local character=player.Character

local torso=character.Torso

local mult = 1 --0 = 0 (left), 1=180 (right)
local last

wait(2)

local function GetFrontVector(CFrameValue)
	--- Get's the front vector of a CFrame Value
	-- @param CFrameValue A CFrame, of which the vector will be retrieved
	-- @return The front vector of the CFrame

	local _,_,_,_,_,r6,_,_,r9,_,_,r12 = CFrameValue:components()
	return Vector3.new(-r6,-r9,-r12)
end

local function GetRightVector(CFrameValue)
	--- Get's the right vector of a CFrame Value
	-- @param CFrameValue A CFrame, of which the vector will be retrieved
	-- @return The right vector of the CFrame

	local _,_,_,r4,_,_,r7,_,_,r10,_,_ = CFrameValue:components()
	return Vector3.new(r4,r7,r10)
end

local function GetLeftVector(CFrameValue)
	--- Get's the left vector of a CFrame Value
	-- @param CFrameValue A CFrame, of which the vector will be retrieved
	-- @return The left vector of the CFrame

	local _,_,_,r4,_,_,r7,_,_,r10,_,_ = CFrameValue:components()
	return Vector3.new(-r4,-r7,-r10)
end
local ignore={}
local function DrawRay(Ray, Color, Parent)
	--- Draw's a ray out (for debugging)
	-- Credit to Cirrus for initial code.

	Parent = Parent or workspace

	local NewPart = Instance.new("Part", Parent)

	NewPart.FormFactor = "Custom"
	NewPart.Size       = Vector3.new(0.2, Ray.Direction.magnitude, 0.2)

	local Center = Ray.Origin + Ray.Direction/2
	-- lib.DrawPoint(Ray.Origin).Name = "origin"
	-- lib.DrawPoint(Center).Name = "Center"
	-- lib.DrawPoint(Ray.Origin + Ray.Direction).Name = "Destination"

	NewPart.CFrame       = CFrame.new(Center, Ray.Origin + Ray.Direction) * CFrame.Angles(math.pi/2, 0, 0) --* GetCFramePitch(math.pi/2)
	NewPart.Anchored     = true
	NewPart.CanCollide   = false
	NewPart.Transparency = 0.5
	NewPart.BrickColor   = Color or BrickColor.new("Bright red")
	NewPart.Name         = "DrawnRay"
	
	Instance.new("SpecialMesh", NewPart)
	game:service'Debris':AddItem(NewPart,.3)
	table.insert(ignore,NewPart)
	return NewPart
end

local function castray(origin,goal)
	local ray = Ray.new(origin,(goal-origin).unit*(goal-origin).magnitude) 
	--DrawRay(ray)
	local ignore2={}
	table.foreach(ignore,function(i,v)ignore2[#ignore2+1]=v;end)
	ignore2[#ignore2+1]=player.Character
	local hit, pos = workspace:FindPartOnRayWithIgnoreList(ray,ignore2)
	
	--Spawn(function() drawray(origin,pos) end)

	return hit,pos
end

local see_distance=20
local function FirePlane(origin,model)
	local size=model:GetExtentsSize()
	local cframe=model:GetModelCFrame()
	local steps=3
	for y=-size.Y/2,size.Y/2,size.Y/steps do
		for x=-size.X/2,size.X/2,size.X/steps do
			local relative=(cframe*CFrame.new(x,y,0)).p
			local expected=(origin-relative).magnitude
			local hit,pos=castray(origin,relative,player.Character)
			if hit~=nil then
				local _,isInFOV = workspace.CurrentCamera:WorldToScreenPoint(pos)
				if hit:IsDescendantOf(model) and isInFOV then
					--print'used planar, got true'
					return true
				elseif expected==(origin-pos).magnitude and isInFOV then
					--print'got expected distnace,planar'
					return true
				end
			end
		end
	end
	return false
end


local function CanSee(cframe,to,targ,plane,model)
	local _,isInFOV = workspace.CurrentCamera:WorldToScreenPoint(to.p)
	local test1,pos = castray(cframe.p,to.p,player.Character)
	if isInFOV then
		if test1 ~= nil then
			if test1 == targ or test1:IsDescendantOf(model) then
			--	print'direct'
				return true
			else
				--print'not direct,gooing to plane'
				--print('got this instead',test1)
				if plane then
					return FirePlane(cframe.p,model)
				end
			end
		end
	else
		--print'not in fov, going to plane'
		if plane then
			return FirePlane(cframe.p,model)
		end
	end
	return false
end

local start

while npc.Humanoid.Health>0 do 
	game:service'RunService'.RenderStepped:wait()
	local npc_look=(-ntorso.CFrame.lookVector*Vector3.new(1,0,1)).unit
	local npc_back=(GetFrontVector(ntorso.CFrame)*Vector3.new(1,0,1)).unit
	local npc_left=(GetLeftVector(ntorso.CFrame)*Vector3.new(1,0,1)).unit
	local npc_right=(GetRightVector(ntorso.CFrame)*Vector3.new(1,0,1)).unit
	
	local point=(ntorso.Position-torso.Position)
	local distance=point.magnitude
	local dir=(point*Vector3.new(1,0,1)).unit
	local ab=dir.magnitude*npc_look.magnitude

	

	if distance<=20 then
		
		local radians = math.acos((dir:Dot(npc_look)))
		local radians2 = math.acos((dir:Dot(npc_back)))
		local radians3 = math.acos(dir:Dot(npc_right))
		local radians4 = math.acos(dir:Dot(npc_left))
		--print('radian3:',math.deg(radians3),' ','radian4:',math.deg(radians4))
		if radians3>math.pi/2 and radians<math.pi/2 and radians4<math.pi/2 then
			
			if math.abs((-math.pi/2)+radians)<.02 then
				radians=math.pi/-2
			else
				radians=((math.pi/-2)+radians4)
			end
		elseif radians3>math.pi/2 and radians>math.pi/2 and radians4<math.pi/2 then
			if math.abs(2*math.pi-(math.pi+(math.pi/2)-radians4))<.02 then
				radians=math.pi*2
			else
				radians=(math.pi+(math.pi/2)-radians4)
			end
			
		end
		--print(math.deg(radians3),math.deg(radians4))
		--print(radians)
		ntorso.Neck.DesiredAngle=radians
		last=radians*mult
		if not CanSee(workspace.CurrentCamera.CoordinateFrame,ntorso.CFrame,ntorso,true,npc) then
			local x,z=player.Character.Torso.Position.X,player.Character.Torso.Position.Z
			npc:MoveTo((player.Character.Torso.Position-ntorso.CFrame.p).unit*.1 + ntorso.Position)
			ntorso.CFrame=CFrame.new(ntorso.CFrame.p,Vector3.new(x,ntorso.Position.Y,z))
			
			--print'MOVING'
		end
	end
	
end

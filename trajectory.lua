--really bad stick system
--wonyk projectiles based off physics I recently learned 
--made this a while ago
--has some dependencies (a mesh)
local destroy = workspace.Destroy
local rendercframe = Instance.new('Part').GetRenderCFrame
local fpor = workspace.FindPartOnRay
local ray = Ray.new
local remove = table.remove
local cf = CFrame.new
local ca = CFrame.Angles
local v3 = Vector3.new

local sin = math.sin
local cos = math.cos
local tick = tick
local max = math.max
local pi = math.pi
local pi2 = math.pi * 2
local tau = pi/2
local noise = math.noise
local abs = math.abs
local rad = math.rad



local HOLDING = false
local CHARGE_TIME = 1.5
local THRESH_HOLD = .15
local POWER = 0
local MAX_POWER = 10

local FREE_FALL = {}
local GRAVITY = workspace.Gravity * .6 --through power of momentum and maglev
local GA = GRAVITY / -2
local PERIOD = 7
local N = -.4
--DRAW



local cy = coroutine.yield
local new = Instance.new

local points={}
local red = BrickColor.new('Bright red')
local size=Vector3.new(1,1,1)
local blue=BrickColor.new('Bright blue')

local ignore=workspace:FindFirstChild'Ignore' or Instance.new('Model',workspace)
ignore.Name='Ignore'
ignore:ClearAllChildren()

function point(a)
	local p = new('Part',workspace)

	p.Shape = 'Ball'
	p.BrickColor = red
	p.Size =  size
		p.CFrame = a
	points[#points+1]=p
	p.Anchored=true
	p.Parent=ignore
	--camera.CFrame=cf(a.p)
end


function point2(a)
	local p = new('Part',workspace)

	p.Shape = 'Ball'
	p.BrickColor = blue
	p.Size =  size
		p.CFrame = a
	points[#points+1]=p
	--camera.CFrame=cf(a.p)

end



local function DrawRay(Ray, Color, Parent)
	--- Draw's a ray out (for debugging)
	-- Credit to Cirrus for initial code.

	Parent = Parent or workspace

	local NewPart = Instance.new("Part", Parent)
	NewPart.Material = "Neon"
	NewPart.FormFactor = "Custom"
	NewPart.Shape = "Cylinder"
	NewPart.Size       = v3(Ray.Direction.magnitude, 0.2, 0.2)

	local Center = Ray.Origin + Ray.Direction/2
	-- lib.DrawPoint(Ray.Origin).Name = "origin"
	-- lib.DrawPoint(Center).Name = "Center"
	-- lib.DrawPoint(Ray.Origin + Ray.Direction).Name = "Destination"

	NewPart.CFrame       = cf(Center, Ray.Origin + Ray.Direction) * ca(0, math.pi/2, 0)
	NewPart.Anchored     = true
	NewPart.CanCollide   = false
	NewPart.Transparency = 0.2
	NewPart.BrickColor   = Color or BrickColor.new("Bright red")
	NewPart.Name         = "DrawnRay"
	
	-- Instance.new("SpecialMesh", NewPart)
	game:GetService'Debris':AddItem(NewPart,2)
	NewPart.Parent=ignore
	--return Ray
end

local function GetTopVector(CFrameValue)
	--- Get's the top vector of a CFrame Value
	-- @param CFrameValue A CFrame, of which the vector will be retrieved
	-- @return The top vector of the CFrame

	local _,_,_,_,r5,_,_,r8,_,_,r11,_ = CFrameValue:components()
	return Vector3.new(r5,r8,r11)
end

local comp=CFrame.new().components


while wait(2) do
	
local hb = game:GetService'RunService'.RenderStepped
local FREE_FALL={}
seed_layer = math.random()

for i =1,5 do	
local p = Instance.new('Part',workspace)
p.Size = Vector3.new(.5,3.2,.5)
p.Anchored=true
script.Mesh:Clone().Parent=p

local v=math.random(5,50)

local n ={
StartTick = tick(),
Origin = CFrame.new(0,0,0)*CFrame.new(math.random(-15,0),math.random(0,5),0),
vx = v+10 * cos(rad(30)),
vy = v * sin(rad(30)),

part = p,
--CFrame = CFrame.new(),
}
table.insert(FREE_FALL,n)
p.Parent=ignore
end





for i = 1,90 do 
	hb:wait()
	for i = 1, #FREE_FALL do
		
		local obj = FREE_FALL[i]
		if obj then
		local time_passed = tick() - obj.StartTick
		local vy = obj.vy
		local vx = obj.vx 
		local part = obj.part
		if time_passed > 5 then

			destroy(part)
			remove(FREE_FALL, i)
		else
			--print(vy*time_passed + time_passed * time_passed * GA)
			--y: (vi * cos(theta))(t) - (g/2)(t)^2
			local revolution = pi2 * time_passed * PERIOD 
			local flow = vx*noise(time_passed*.7,seed_layer)
			local air_resistance = (abs(flow) * N) or 0
			
			--DrawRay(ray(part.Position,(obj.Origin*ca(revolution,0,0)*cf(0,part.Size.Y,0)).p-obj.Origin.p ))
			--DrawRay(ray(part.Position,(obj.Origin*ca(revolution,0,0)*cf(0,part.Size.Y,0)).p-obj.Origin.p ))
			local c = obj.Origin * cf(sin(vx+time_passed*3)*flow*.5, vy*time_passed + time_passed * time_passed * GA, vx * time_passed + air_resistance*.5*time_passed) * ca(revolution,0,0)
			part.CFrame = c
			local hit,pos,normal=fpor(workspace,ray((c*cf(0,-3.2,0)).p,c.upVector*5),ignore)
			local hit2,pos2,normal2=fpor(workspace,ray(c.p,v3(0,-1,0)),ignore)
			if hit then
				table.remove(FREE_FALL,i)
				local _,_,_,d,e,f,g,h,i,j,k,l = comp(part.CFrame)
				part.CFrame=rendercframe(part):Lerp(cf(pos.x,pos.y,pos.z,d,e,f,g,h,i,j,k,l),.5)
			elseif hit2 then
				--table.remove(FREE_FALL,i)

				part.CFrame=CFrame.new(pos2,pos2+v3(normal.x,normal.z,normal2.y))
			end
			end
			--DrawRay(ray(part.Position,(obj.Origin*ca(revolution,0,0)*s).p-obj.Origin.p ))
			--DrawRay(ray(c.p,c.upVector))
			--point(part.CFrame)
			--local _,_,_,_,r5,_,_,r8,_,_,r11,_ = comp(obj.CFrame)
			
			--ray(part.Position,Vector3.new(r5,r8,r11)*part.Size.Y)
		end
	end
end

for i,v in pairs(points) do
	v:remove()
end
wait(2)

for i,v in pairs(FREE_FALL) do 
	v.part:remove()
end

end
--wait''
--local t = tick()
--local s=cf(0,p.Size.Y,0)
--
--for i = 1,1000 do 
--
--	for i = 1, #FREE_FALL do
--		
--		local obj = FREE_FALL[i]
--		local time_passed = tick() - obj.StartTick
--		local vy = obj.vy
--		local vx = obj.vx 
--		local part = obj.part
--		if time_passed > 5 then
--
--			destroy(part)
--			remove(FREE_FALL, i)
--		else
--			--print(vy*time_passed + time_passed * time_passed * GA)
--			--y: (vi * cos(theta))(t) - (g/2)(t)^2
--			local revolution = pi2 * time_passed * PERIOD 
--			local flow = vx*noise(time_passed*.7,seed_layer)
--			local air_resistance = (abs(flow) * N) or 0
--			local r = cos(revolution+pi)
--			local r2 = sin(revolution+pi)
--			
--			--DrawRay(ray(part.Position,(obj.Origin*ca(revolution,0,0)*cf(0,part.Size.Y,0)).p-obj.Origin.p ))
--			--DrawRay(ray(part.Position,(obj.Origin*ca(revolution,0,0)*cf(0,part.Size.Y,0)).p-obj.Origin.p ))
--
--			obj.CFrame = obj.Origin * cf(sin(time_passed*3)*flow*.5, vy*time_passed + time_passed * time_passed * GA, vx * time_passed + air_resistance*.5*time_passed) * ca(revolution,0,0)
--			local _,_,_,_,r5,_,_,r8,_,_,r11,_ = comp(obj.CFrame)
--			ray(obj.CFrame.p,Vector3.new(r5,r8,r11)*part.Size.Y)
--
--			--local _,_,_,_,r5,_,_,r8,_,_,r11,_ = comp(obj.CFrame)
--			
--			--ray(part.Position,Vector3.new(r5,r8,r11)*part.Size.Y)
--		end
--	end
--end
--print(tick()-t)
--ray(obj.CFrame.p,Vector3.new(r5,r8,r11)*part.Size.Y)

p:remove()


--camera.CFrame = cf(0,0,0)

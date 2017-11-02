local module = {}

local BASE = 'rbxassetid://';

local coroutine_wrap = coroutine.wrap;
local coroutine_resume = coroutine.resume;
local coroutine_create = coroutine.create;

local function Wrap(f, ...)
	coroutine_wrap(f)(...);
end

local function SafeWrap(f, ...)
	return coroutine_resume(coroutine_create(f), ...);
end


function module.NewSound(id, parent, volume, pitch)
	
	if type(id) == 'number' then
		id = BASE..tostring(id);
	end	
	
	--[[local real = Instance.new('Sound');
	real.SoundId = id;
	real.Parent = parent;
	real.Volume = volume or 1;
	real.Pitch = pitch or 1;]]--
	local real;
	
	local s = setmetatable({},{__index=real, __newindex=function (_,i,v) real[i] = v;end});
	
	function s.Fade(t, target, pow, delete)
		local pow = pow or 1;
		SafeWrap(function()
			local start_tick = tick();
			local diff = (target-real.Volume); 
			local start = real.Volume;
			while tick()-start_tick <= t do 
				local alpha = math.pow((tick()-start_tick)/t,pow)
				real.Volume = start + (diff)*alpha
				wait(.1);
			end
			real.Volume = target;
			if delete then 
				real:remove()
				real=nil;
			end
		end)
	end
	
	function s.InOutLinear(t1, t2, t3, target_volume, p)
		SafeWrap(function()
			local start = tick()
			s.Play(0, p or 1)
			s.Fade(t1, target_volume or 1, 1); --fade into target volume
			wait(t1+t2)
			s.Fade(t3, 0, 1, true); --fade out
		end)
	end
	
	function s.InOutSquare(t1, t2, t3, target_volume, p)
		SafeWrap(function()
			local start = tick()
			s.Play(0, p or 1)
			s.Fade(t1, target_volume or 1, 2); --fade into target volume
			wait(t1+t2)
			s.Fade(t3, 0, 2, true); --fade out
		end)		
	end
	
	function s.Play(v, p)
		if real == nil or not pcall(function()if real.Parent==nil then error() end end) then
			real = Instance.new('Sound');
			real.SoundId = id;
			real.Parent = parent;
			real.Volume = v or volume;
			real.Pitch = p or pitch;	
		end

		SafeWrap(function()
			real:Play()
			real.Volume = v or real.Volume;
			real.Pitch = p or real.Pitch;
		end)
	end
	
	return s;
end

return module

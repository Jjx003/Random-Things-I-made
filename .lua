--[[
	Hi there, you are probably wondering what the function "AttemptLetter" is
	Basically, when you are typing, you can make small mistakes with letters
	For example:
	-----
	Lets say that you wanted to type "cat"
	But typed "car" instead
	This makes sense because the letter "r" is right behind the letter "t"
	
	This function makes it so that it simulates if a person misstyped a letter 
	
	-----
	The function can also do vertical typos
	For exmaple:
	The letter "e" is directly above the letter "d"
	The letter "c" is directly below the letter "d"
	If I tried to type "death" for example,
	I could get
	>eeath
	or
	>ceath
	
	Basically a typo-simulator :/
	--jeffy123459 
	--4/29/15
	--6:17 PM Pacific Time
--]]

local keyboard={[0]='~!@#$%^&*()_+',[1]='`1234567890',[2]=[[	qwertyuiop[]\]],[3]='Aasdfghjkl;\'',
[4]='Zzxcvbnm,./'}

for layer,v in pairs(keyboard) do 
	keyboard[layer]={}
	for letter in string.gmatch(v,'(.)') do
		keyboard[layer][#keyboard[layer]+1]=letter
	end
end

--table.foreach(keyboard[3],print)

local function MiniRandom(r1,r2,step)
	local p={}
	for i = r1,r2,step do p[#p+1]=i end
	return p[math.random(#p)]
end

function AttemptLetter(l)
	
	local pos,layer
	for lay,letters in pairs(keyboard) do 
		for ind,let in pairs(letters) do 
			if let:lower()==l:lower() then
				print(ind)
				pos=ind
				layer=lay
				--if layer==0 then layer=1 end
				break
			end
		end
	end
	
	local layer_miss=math.random(1,55)==33
	if layer_miss then
		--print('Missed a layer')
		local up=math.abs(1-layer)--I didn't include 0 because yea
		local down=math.abs(3-layer)
		local new_layer
		local p
		
		--if up==0 or down==0 then
			
		new_layer=layer+((up==0 and -1)or (down==0 and 1))
		--print('The new layer is '..tostring(new_layer))
		
		local original=keyboard[layer]
		local offset=keyboard[new_layer]
		local testpos1=pos
		local testpos2=pos
		
			while p==nil do
				testpos1=testpos1+1
				if offset[testpos1] ~= nil then
					p=offset[testpos1]
					--print'Found existing offset'
					print(p)
					break
				end
				testpos2=testpos2-1
				if offset[testpos2] ~= nil then
					p=offset[testpos2]
					--print'Found existing offset'
					--print(p)
					break
				end
			end
			
		--else
			
		--end
		return keyboard[new_layer][p]
		
	else
		local min=1
		local max=#keyboard[layer]
		local p=pos
		local left=math.abs(min-p)
		local right=math.abs(max-p)
		
		local rand=math.random(1,5)
		local p2
		local p3
		if rand==5 then
			--print'shift two'
			if left == 0 and right>=2 then
				--print'cant move left, moving right'
				p=p+2
			elseif right==0 and left>=2 then
				p=p-2
				--print'cant move right, moving left'
			else
				--print'doing otherwise'
				p2=math.min(p+2,max)
				--print('current p:'..tostring(p))
				p3=math.max(p-2,min)
				local rand2=math.random(1,2)
				p=(rand2==1 and p2) or p3
			end 
		else
			--print'normal one shift'
			if left==0 and right>=1 then
				p=p+1
				--print'cannot go left but can go right'
			elseif right==0 and left>=1 then
				--print'cannot go right but go left'
				p=p+1
			else
				p2=math.min(p+1,max)
				--print('current p:'..tostring(p))
				p3=math.max(p-1,min)
				local rand2=math.random(1,2)
				p=(rand2==1 and p2) or p3
				--print'otherwise case2'
			end
		end
		return keyboard[layer][p]
	end
end

print(AttemptLetter('@'))

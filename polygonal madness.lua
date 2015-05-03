local player=game.Players.LocalPlayer
local p2=2*math.pi
local settings={
points=4,
reps=3,
thickenss=1,
size=12,
center=CFrame.new(0,5,0)
}
-------------------------------------------------
-------------------------------------------------
--[[
By AxisAngle, (Trey Reynolds)
Documentation
http://www.roblox.com/item.aspx?id=227509468

Region constructors:
	Region Region.new(CFrame RegionCFrame, Vector3 RegionSize)
		>Returns a new Region object

	Region Region.FromPart(Instance Part)
		>Returns a new Region objects


Region methods:
	table Region:Cast([Instance or table Ignore])
		>Returns all parts in the Region, ignoring the Ignore

	bool Region:CastPart(Instance Part)
		>Returns true if Part is within Region, false otherwise

	table Region:CastParts(table Parts)
		>Returns a table of all parts within the region

	bool Region:CastPoint(Vector3 Point)
		>Returns true if Point intersects Region, false otherwise

	bool Region:CastSphere(Vector3 SphereCenter, number SphereRadius)
		>Returns true if Sphere intersects Region, false otherwise

	bool Region:CastBox(CFrame BoxCFrame, Vector3 BoxSize)
		>Returns true if Box intersects Region, false otherwise



Region properties: (Regions are mutable)
	CFrame	CFrame
	Vector3	Size
	Region3	Region3



Region functions:
	Region3 Region.Region3BoundingBox(CFrame BoxCFrame, Vector3 BoxSize)
		>Returns the enclosing boundingbox of Box

	table Region.FindAllPartsInRegion3(Region3 Region3, [Instance or table Ignore])
		>Returns all parts within a Region3 of any size

	bool Region.BoxPointCollision(CFrame BoxCFrame, Vector3 BoxSize, Vector3 Point)
		>Returns true if the Point is intersecting the Box, false otherwise

	bool Region.BoxSphereCollision(CFrame BoxCFrame, Vector3 BoxSize, Vector3 SphereCenter, number SphereRadius)
		>Returns true if the Sphere is intersecting the Box, false otherwise

	bool Region.BoxCollision(CFrame Box0CFrame, Vector3 Box0Size, CFrame Box1CFrame, Vector3 Box1Size, [bool AssumeTrue])
		>Returns true if the boxes are intersecting, false otherwise
		If AssumeTrue is left blank, it does the full check to see if Box0 is intersecting Box1
		If AssumeTrue is true, it skips the heavy check and assumes that any part that could possibly be in the Region is
		If AssumeTrue is false, it skips the heavy check and assumes that any part that could possible be outside the Region is
	
	bool Region.CastPoint(Vector3 Point, [Instance or table Ignore])
		>Returns true if the point intersects a part, false otherwise
]]

local Region={}



local BoxPointCollision do
	local VecDiv=CFrame.new().pointToObjectSpace--Right Division, yo.
	function BoxPointCollision(CFrame,Size,Point)
		local Relative	=VecDiv(CFrame,Point)
		local sx,sy,sz	=Size.x/2,Size.y/2,Size.z/2
		local rx,ry,rz	=Relative.x,Relative.y,Relative.z
		return			rx*rx<sx*sx and rx*rx<sx*sx and rx*rx<sx*sx
	end
end



local BoxSphereCollision do
	local VecDiv=CFrame.new().pointToObjectSpace--Right Division, yo.
	function BoxSphereCollision(CFrame,Size,Center,Radius)
		local Relative	=VecDiv(CFrame,Center)
		local sx,sy,sz	=Size.x/2,Size.y/2,Size.z/2
		local rx,ry,rz	=Relative.x,Relative.y,Relative.z
		local dx		=rx>sx and rx-sx--Faster than if statement
						or rx<-sx and rx+sx
						or 0
		local dy		=ry>sy and ry-sy
						or ry<-sy and ry+sy
						or 0
		local dz		=rz>sz and rz-sz
						or rz<-sz and rz+sz
						or 0
		return dx*dx+dy*dy+dz*dz<Radius*Radius
	end
end



--There's a reason why this hasn't been done before by ROBLOX users (as far as I know)
--It's really mathy, really long, and really confusing.
--0.000033 seconds is the worst, 0.000018 looks like the average case.
--Also I ran out of local variables so I had to redo everything so that I could reuse the names lol.
--So don't even try to read it.
local BoxCollision do
	local components=CFrame.new().components
	function BoxCollision(CFrame0,Size0,CFrame1,Size1,AssumeTrue)
		local	m00,m01,m02,
				m03,m04,m05,
				m06,m07,m08,
				m09,m10,m11	=components(CFrame0)
		local	m12,m13,m14,
				m15,m16,m17,
				m18,m19,m20,
				m21,m22,m23	=components(CFrame1)
		local	m24,m25,m26	=Size0.x/2,Size0.y/2,Size0.z/2
		local	m27,m28,m29	=Size1.x/2,Size1.y/2,Size1.z/2
		local	m30,m31,m32	=m12-m00,m13-m01,m14-m02
		local	m00			=m03*m30+m06*m31+m09*m32
		local	m01			=m04*m30+m07*m31+m10*m32
		local	m02			=m05*m30+m08*m31+m11*m32
		local	m12			=m15*m30+m18*m31+m21*m32
		local	m13			=m16*m30+m19*m31+m22*m32
		local	m14			=m17*m30+m20*m31+m23*m32
		local	m30			=m12>m27 and m12-m27
							or m12<-m27 and m12+m27
							or 0
		local	m31			=m13>m28 and m13-m28
							or m13<-m28 and m13+m28
							or 0
		local	m32			=m14>m29 and m14-m29
							or m14<-m29 and m14+m29
							or 0
		local	m33			=m00>m24 and m00-m24
							or m00<-m24 and m00+m24
							or 0
		local	m34			=m01>m25 and m01-m25
							or m01<-m25 and m01+m25
							or 0
		local	m35			=m02>m26 and m02-m26
							or m02<-m26 and m02+m26
							or 0
		local	m36			=m30*m30+m31*m31+m32*m32
		local	m30			=m33*m33+m34*m34+m35*m35
		local	m31			=m24<m25 and (m24<m26 and m24 or m26)
							or (m25<m26 and m25 or m26)
		local	m32			=m27<m28 and (m27<m29 and m27 or m29)
							or (m28<m29 and m28 or m29)
		if m36<m31*m31 or m30<m32*m32 then
			return true
		elseif m36>m24*m24+m25*m25+m26*m26 or m30>m27*m27+m28*m28+m29*m29 then
			return false
		elseif AssumeTrue==nil then
			--LOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOL
			--(This is how you tell if something was made by Axis Angle)
			local m30=m03*m15+m06*m18+m09*m21
			local m31=m03*m16+m06*m19+m09*m22
			local m32=m03*m17+m06*m20+m09*m23
			local m03=m04*m15+m07*m18+m10*m21
			local m06=m04*m16+m07*m19+m10*m22
			local m09=m04*m17+m07*m20+m10*m23
			local m04=m05*m15+m08*m18+m11*m21
			local m07=m05*m16+m08*m19+m11*m22
			local m10=m05*m17+m08*m20+m11*m23
			local m05=m29*m29
			local m08=m27*m27
			local m11=m28*m28
			local m15=m24*m30
			local m16=m25*m03
			local m17=m26*m04
			local m18=m24*m31
			local m19=m25*m06
			local m20=m26*m07
			local m21=m24*m32
			local m22=m25*m09
			local m23=m26*m10
			local m33=m15+m16+m17-m12;if m33*m33<m08 then local m34=m18+m19+m20-m13;if m34*m34<m11 then local m35=m21+m22+m23-m14;if m35*m35<m05 then return true;end;end;end;
			local m33=-m15+m16+m17-m12;if m33*m33<m08 then local m34=-m18+m19+m20-m13;if m34*m34<m11 then local m35=-m21+m22+m23-m14;if m35*m35<m05 then return true;end;end;end;
			local m33=m15-m16+m17-m12;if m33*m33<m08 then local m34=m18-m19+m20-m13;if m34*m34<m11 then local m35=m21-m22+m23-m14;if m35*m35<m05 then return true;end;end;end;
			local m33=-m15-m16+m17-m12;if m33*m33<m08 then local m34=-m18-m19+m20-m13;if m34*m34<m11 then local m35=-m21-m22+m23-m14;if m35*m35<m05 then return true;end;end;end;
			local m33=m15+m16-m17-m12;if m33*m33<m08 then local m34=m18+m19-m20-m13;if m34*m34<m11 then local m35=m21+m22-m23-m14;if m35*m35<m05 then return true;end;end;end;
			local m33=-m15+m16-m17-m12;if m33*m33<m08 then local m34=-m18+m19-m20-m13;if m34*m34<m11 then local m35=-m21+m22-m23-m14;if m35*m35<m05 then return true;end;end;end;
			local m33=m15-m16-m17-m12;if m33*m33<m08 then local m34=m18-m19-m20-m13;if m34*m34<m11 then local m35=m21-m22-m23-m14;if m35*m35<m05 then return true;end;end;end;
			local m33=-m15-m16-m17-m12;if m33*m33<m08 then local m34=-m18-m19-m20-m13;if m34*m34<m11 then local m35=-m21-m22-m23-m14;if m35*m35<m05 then return true;end;end;end;
			local m12=m24*m24
			local m13=m25*m25
			local m14=m26*m26
			local m15=m27*m04
			local m16=m28*m07
			local m17=m27*m30
			local m18=m28*m31
			local m19=m27*m03
			local m20=m28*m06
			local m21=m29*m10
			local m22=m29*m32
			local m23=m29*m09
			local m35=(m02-m26+m15+m16)/m10;if m35*m35<m05 then local m33=m00+m17+m18-m35*m32;if m33*m33<m12 then local m34=m01+m19+m20-m35*m09;if m34*m34<m13 then return true;end;end;end;
			local m35=(m02+m26+m15+m16)/m10;if m35*m35<m05 then local m33=m00+m17+m18-m35*m32;if m33*m33<m12 then local m34=m01+m19+m20-m35*m09;if m34*m34<m13 then return true;end;end;end;
			local m35=(m02-m26-m15+m16)/m10;if m35*m35<m05 then local m33=m00-m17+m18-m35*m32;if m33*m33<m12 then local m34=m01-m19+m20-m35*m09;if m34*m34<m13 then return true;end;end;end;
			local m35=(m02+m26-m15+m16)/m10;if m35*m35<m05 then local m33=m00-m17+m18-m35*m32;if m33*m33<m12 then local m34=m01-m19+m20-m35*m09;if m34*m34<m13 then return true;end;end;end;
			local m35=(m02-m26+m15-m16)/m10;if m35*m35<m05 then local m33=m00+m17-m18-m35*m32;if m33*m33<m12 then local m34=m01+m19-m20-m35*m09;if m34*m34<m13 then return true;end;end;end;
			local m35=(m02+m26+m15-m16)/m10;if m35*m35<m05 then local m33=m00+m17-m18-m35*m32;if m33*m33<m12 then local m34=m01+m19-m20-m35*m09;if m34*m34<m13 then return true;end;end;end;
			local m35=(m02-m26-m15-m16)/m10;if m35*m35<m05 then local m33=m00-m17-m18-m35*m32;if m33*m33<m12 then local m34=m01-m19-m20-m35*m09;if m34*m34<m13 then return true;end;end;end;
			local m35=(m02+m26-m15-m16)/m10;if m35*m35<m05 then local m33=m00-m17-m18-m35*m32;if m33*m33<m12 then local m34=m01-m19-m20-m35*m09;if m34*m34<m13 then return true;end;end;end;
			local m35=(m00-m24+m17+m18)/m32;if m35*m35<m05 then local m33=m01+m19+m20-m35*m09;if m33*m33<m13 then local m34=m02+m15+m16-m35*m10;if m34*m34<m14 then return true;end;end;end;
			local m35=(m00+m24+m17+m18)/m32;if m35*m35<m05 then local m33=m01+m19+m20-m35*m09;if m33*m33<m13 then local m34=m02+m15+m16-m35*m10;if m34*m34<m14 then return true;end;end;end;
			local m35=(m00-m24-m17+m18)/m32;if m35*m35<m05 then local m33=m01-m19+m20-m35*m09;if m33*m33<m13 then local m34=m02-m15+m16-m35*m10;if m34*m34<m14 then return true;end;end;end;
			local m35=(m00+m24-m17+m18)/m32;if m35*m35<m05 then local m33=m01-m19+m20-m35*m09;if m33*m33<m13 then local m34=m02-m15+m16-m35*m10;if m34*m34<m14 then return true;end;end;end;
			local m35=(m00-m24+m17-m18)/m32;if m35*m35<m05 then local m33=m01+m19-m20-m35*m09;if m33*m33<m13 then local m34=m02+m15-m16-m35*m10;if m34*m34<m14 then return true;end;end;end;
			local m35=(m00+m24+m17-m18)/m32;if m35*m35<m05 then local m33=m01+m19-m20-m35*m09;if m33*m33<m13 then local m34=m02+m15-m16-m35*m10;if m34*m34<m14 then return true;end;end;end;
			local m35=(m00-m24-m17-m18)/m32;if m35*m35<m05 then local m33=m01-m19-m20-m35*m09;if m33*m33<m13 then local m34=m02-m15-m16-m35*m10;if m34*m34<m14 then return true;end;end;end;
			local m35=(m00+m24-m17-m18)/m32;if m35*m35<m05 then local m33=m01-m19-m20-m35*m09;if m33*m33<m13 then local m34=m02-m15-m16-m35*m10;if m34*m34<m14 then return true;end;end;end;
			local m35=(m01-m25+m19+m20)/m09;if m35*m35<m05 then local m33=m02+m15+m16-m35*m10;if m33*m33<m14 then local m34=m00+m17+m18-m35*m32;if m34*m34<m12 then return true;end;end;end;
			local m35=(m01+m25+m19+m20)/m09;if m35*m35<m05 then local m33=m02+m15+m16-m35*m10;if m33*m33<m14 then local m34=m00+m17+m18-m35*m32;if m34*m34<m12 then return true;end;end;end;
			local m35=(m01-m25-m19+m20)/m09;if m35*m35<m05 then local m33=m02-m15+m16-m35*m10;if m33*m33<m14 then local m34=m00-m17+m18-m35*m32;if m34*m34<m12 then return true;end;end;end;
			local m35=(m01+m25-m19+m20)/m09;if m35*m35<m05 then local m33=m02-m15+m16-m35*m10;if m33*m33<m14 then local m34=m00-m17+m18-m35*m32;if m34*m34<m12 then return true;end;end;end;
			local m35=(m01-m25+m19-m20)/m09;if m35*m35<m05 then local m33=m02+m15-m16-m35*m10;if m33*m33<m14 then local m34=m00+m17-m18-m35*m32;if m34*m34<m12 then return true;end;end;end;
			local m35=(m01+m25+m19-m20)/m09;if m35*m35<m05 then local m33=m02+m15-m16-m35*m10;if m33*m33<m14 then local m34=m00+m17-m18-m35*m32;if m34*m34<m12 then return true;end;end;end;
			local m35=(m01-m25-m19-m20)/m09;if m35*m35<m05 then local m33=m02-m15-m16-m35*m10;if m33*m33<m14 then local m34=m00-m17-m18-m35*m32;if m34*m34<m12 then return true;end;end;end;
			local m35=(m01+m25-m19-m20)/m09;if m35*m35<m05 then local m33=m02-m15-m16-m35*m10;if m33*m33<m14 then local m34=m00-m17-m18-m35*m32;if m34*m34<m12 then return true;end;end;end;
			local m35=(m02-m26+m16+m21)/m04;if m35*m35<m08 then local m33=m00+m18+m22-m35*m30;if m33*m33<m12 then local m34=m01+m20+m23-m35*m03;if m34*m34<m13 then return true;end;end;end;
			local m35=(m02+m26+m16+m21)/m04;if m35*m35<m08 then local m33=m00+m18+m22-m35*m30;if m33*m33<m12 then local m34=m01+m20+m23-m35*m03;if m34*m34<m13 then return true;end;end;end;
			local m35=(m02-m26-m16+m21)/m04;if m35*m35<m08 then local m33=m00-m18+m22-m35*m30;if m33*m33<m12 then local m34=m01-m20+m23-m35*m03;if m34*m34<m13 then return true;end;end;end;
			local m35=(m02+m26-m16+m21)/m04;if m35*m35<m08 then local m33=m00-m18+m22-m35*m30;if m33*m33<m12 then local m34=m01-m20+m23-m35*m03;if m34*m34<m13 then return true;end;end;end;
			local m35=(m02-m26+m16-m21)/m04;if m35*m35<m08 then local m33=m00+m18-m22-m35*m30;if m33*m33<m12 then local Axi=m01+m20-m23-m35*m03;if Axi*Axi<m13 then return true;end;end;end;
			local m35=(m02+m26+m16-m21)/m04;if m35*m35<m08 then local m33=m00+m18-m22-m35*m30;if m33*m33<m12 then local sAn=m01+m20-m23-m35*m03;if sAn*sAn<m13 then return true;end;end;end;
			local m35=(m02-m26-m16-m21)/m04;if m35*m35<m08 then local m33=m00-m18-m22-m35*m30;if m33*m33<m12 then local gle=m01-m20-m23-m35*m03;if gle*gle<m13 then return true;end;end;end;
			local m35=(m02+m26-m16-m21)/m04;if m35*m35<m08 then local m33=m00-m18-m22-m35*m30;if m33*m33<m12 then local m34=m01-m20-m23-m35*m03;if m34*m34<m13 then return true;end;end;end;
			local m35=(m00-m24+m18+m22)/m30;if m35*m35<m08 then local m33=m01+m20+m23-m35*m03;if m33*m33<m13 then local m34=m02+m16+m21-m35*m04;if m34*m34<m14 then return true;end;end;end;
			local m35=(m00+m24+m18+m22)/m30;if m35*m35<m08 then local m33=m01+m20+m23-m35*m03;if m33*m33<m13 then local m34=m02+m16+m21-m35*m04;if m34*m34<m14 then return true;end;end;end;
			local m35=(m00-m24-m18+m22)/m30;if m35*m35<m08 then local m33=m01-m20+m23-m35*m03;if m33*m33<m13 then local m34=m02-m16+m21-m35*m04;if m34*m34<m14 then return true;end;end;end;
			local m35=(m00+m24-m18+m22)/m30;if m35*m35<m08 then local m33=m01-m20+m23-m35*m03;if m33*m33<m13 then local m34=m02-m16+m21-m35*m04;if m34*m34<m14 then return true;end;end;end;
			local m35=(m00-m24+m18-m22)/m30;if m35*m35<m08 then local m33=m01+m20-m23-m35*m03;if m33*m33<m13 then local m34=m02+m16-m21-m35*m04;if m34*m34<m14 then return true;end;end;end;
			local m35=(m00+m24+m18-m22)/m30;if m35*m35<m08 then local m33=m01+m20-m23-m35*m03;if m33*m33<m13 then local m34=m02+m16-m21-m35*m04;if m34*m34<m14 then return true;end;end;end;
			local m35=(m00-m24-m18-m22)/m30;if m35*m35<m08 then local m33=m01-m20-m23-m35*m03;if m33*m33<m13 then local m34=m02-m16-m21-m35*m04;if m34*m34<m14 then return true;end;end;end;
			local m35=(m00+m24-m18-m22)/m30;if m35*m35<m08 then local m33=m01-m20-m23-m35*m03;if m33*m33<m13 then local m34=m02-m16-m21-m35*m04;if m34*m34<m14 then return true;end;end;end;
			local m35=(m01-m25+m20+m23)/m03;if m35*m35<m08 then local m33=m02+m16+m21-m35*m04;if m33*m33<m14 then local m34=m00+m18+m22-m35*m30;if m34*m34<m12 then return true;end;end;end;
			local m35=(m01+m25+m20+m23)/m03;if m35*m35<m08 then local m33=m02+m16+m21-m35*m04;if m33*m33<m14 then local m34=m00+m18+m22-m35*m30;if m34*m34<m12 then return true;end;end;end;
			local m35=(m01-m25-m20+m23)/m03;if m35*m35<m08 then local m33=m02-m16+m21-m35*m04;if m33*m33<m14 then local m34=m00-m18+m22-m35*m30;if m34*m34<m12 then return true;end;end;end;
			local m35=(m01+m25-m20+m23)/m03;if m35*m35<m08 then local m33=m02-m16+m21-m35*m04;if m33*m33<m14 then local m34=m00-m18+m22-m35*m30;if m34*m34<m12 then return true;end;end;end;
			local m35=(m01-m25+m20-m23)/m03;if m35*m35<m08 then local m33=m02+m16-m21-m35*m04;if m33*m33<m14 then local m34=m00+m18-m22-m35*m30;if m34*m34<m12 then return true;end;end;end;
			local m35=(m01+m25+m20-m23)/m03;if m35*m35<m08 then local m33=m02+m16-m21-m35*m04;if m33*m33<m14 then local m34=m00+m18-m22-m35*m30;if m34*m34<m12 then return true;end;end;end;
			local m35=(m01-m25-m20-m23)/m03;if m35*m35<m08 then local m33=m02-m16-m21-m35*m04;if m33*m33<m14 then local m34=m00-m18-m22-m35*m30;if m34*m34<m12 then return true;end;end;end;
			local m35=(m01+m25-m20-m23)/m03;if m35*m35<m08 then local m33=m02-m16-m21-m35*m04;if m33*m33<m14 then local m34=m00-m18-m22-m35*m30;if m34*m34<m12 then return true;end;end;end;
			local m35=(m02-m26+m21+m15)/m07;if m35*m35<m11 then local m33=m00+m22+m17-m35*m31;if m33*m33<m12 then local m34=m01+m23+m19-m35*m06;if m34*m34<m13 then return true;end;end;end;
			local m35=(m02+m26+m21+m15)/m07;if m35*m35<m11 then local m33=m00+m22+m17-m35*m31;if m33*m33<m12 then local m34=m01+m23+m19-m35*m06;if m34*m34<m13 then return true;end;end;end;
			local m35=(m02-m26-m21+m15)/m07;if m35*m35<m11 then local m33=m00-m22+m17-m35*m31;if m33*m33<m12 then local m34=m01-m23+m19-m35*m06;if m34*m34<m13 then return true;end;end;end;
			local m35=(m02+m26-m21+m15)/m07;if m35*m35<m11 then local m33=m00-m22+m17-m35*m31;if m33*m33<m12 then local m34=m01-m23+m19-m35*m06;if m34*m34<m13 then return true;end;end;end;
			local m35=(m02-m26+m21-m15)/m07;if m35*m35<m11 then local m33=m00+m22-m17-m35*m31;if m33*m33<m12 then local m34=m01+m23-m19-m35*m06;if m34*m34<m13 then return true;end;end;end;
			local m35=(m02+m26+m21-m15)/m07;if m35*m35<m11 then local m33=m00+m22-m17-m35*m31;if m33*m33<m12 then local m34=m01+m23-m19-m35*m06;if m34*m34<m13 then return true;end;end;end;
			local m35=(m02-m26-m21-m15)/m07;if m35*m35<m11 then local m33=m00-m22-m17-m35*m31;if m33*m33<m12 then local m34=m01-m23-m19-m35*m06;if m34*m34<m13 then return true;end;end;end;
			local m35=(m02+m26-m21-m15)/m07;if m35*m35<m11 then local m33=m00-m22-m17-m35*m31;if m33*m33<m12 then local m34=m01-m23-m19-m35*m06;if m34*m34<m13 then return true;end;end;end;
			local m35=(m00-m24+m22+m17)/m31;if m35*m35<m11 then local m33=m01+m23+m19-m35*m06;if m33*m33<m13 then local m34=m02+m21+m15-m35*m07;if m34*m34<m14 then return true;end;end;end;
			local m35=(m00+m24+m22+m17)/m31;if m35*m35<m11 then local m33=m01+m23+m19-m35*m06;if m33*m33<m13 then local m34=m02+m21+m15-m35*m07;if m34*m34<m14 then return true;end;end;end;
			local m35=(m00-m24-m22+m17)/m31;if m35*m35<m11 then local m33=m01-m23+m19-m35*m06;if m33*m33<m13 then local m34=m02-m21+m15-m35*m07;if m34*m34<m14 then return true;end;end;end;
			local m35=(m00+m24-m22+m17)/m31;if m35*m35<m11 then local m33=m01-m23+m19-m35*m06;if m33*m33<m13 then local m34=m02-m21+m15-m35*m07;if m34*m34<m14 then return true;end;end;end;
			local m35=(m00-m24+m22-m17)/m31;if m35*m35<m11 then local m33=m01+m23-m19-m35*m06;if m33*m33<m13 then local m34=m02+m21-m15-m35*m07;if m34*m34<m14 then return true;end;end;end;
			local m35=(m00+m24+m22-m17)/m31;if m35*m35<m11 then local m33=m01+m23-m19-m35*m06;if m33*m33<m13 then local m34=m02+m21-m15-m35*m07;if m34*m34<m14 then return true;end;end;end;
			local m35=(m00-m24-m22-m17)/m31;if m35*m35<m11 then local m33=m01-m23-m19-m35*m06;if m33*m33<m13 then local m34=m02-m21-m15-m35*m07;if m34*m34<m14 then return true;end;end;end;
			local m35=(m00+m24-m22-m17)/m31;if m35*m35<m11 then local m33=m01-m23-m19-m35*m06;if m33*m33<m13 then local m34=m02-m21-m15-m35*m07;if m34*m34<m14 then return true;end;end;end;
			local m35=(m01-m25+m23+m19)/m06;if m35*m35<m11 then local m33=m02+m21+m15-m35*m07;if m33*m33<m14 then local m34=m00+m22+m17-m35*m31;if m34*m34<m12 then return true;end;end;end;
			local m35=(m01+m25+m23+m19)/m06;if m35*m35<m11 then local m33=m02+m21+m15-m35*m07;if m33*m33<m14 then local m34=m00+m22+m17-m35*m31;if m34*m34<m12 then return true;end;end;end;
			local m35=(m01-m25-m23+m19)/m06;if m35*m35<m11 then local m33=m02-m21+m15-m35*m07;if m33*m33<m14 then local m34=m00-m22+m17-m35*m31;if m34*m34<m12 then return true;end;end;end;
			local m35=(m01+m25-m23+m19)/m06;if m35*m35<m11 then local m33=m02-m21+m15-m35*m07;if m33*m33<m14 then local m34=m00-m22+m17-m35*m31;if m34*m34<m12 then return true;end;end;end;
			local m35=(m01-m25+m23-m19)/m06;if m35*m35<m11 then local m33=m02+m21-m15-m35*m07;if m33*m33<m14 then local m34=m00+m22-m17-m35*m31;if m34*m34<m12 then return true;end;end;end;
			local m35=(m01+m25+m23-m19)/m06;if m35*m35<m11 then local m33=m02+m21-m15-m35*m07;if m33*m33<m14 then local m34=m00+m22-m17-m35*m31;if m34*m34<m12 then return true;end;end;end;
			local m35=(m01-m25-m23-m19)/m06;if m35*m35<m11 then local m33=m02-m21-m15-m35*m07;if m33*m33<m14 then local m34=m00-m22-m17-m35*m31;if m34*m34<m12 then return true;end;end;end;
			local m35=(m01+m25-m23-m19)/m06;if m35*m35<m11 then local m33=m02-m21-m15-m35*m07;if m33*m33<m14 then local m34=m00-m22-m17-m35*m31;if m34*m34<m12 then return true;end;end;end;
			return false
		else
			return AssumeTrue
		end
	end
end


local setmetatable	=setmetatable
local components	=CFrame.new().components
local Workspace		=Workspace
local BoxCast		=Workspace.FindPartsInRegion3WithIgnoreList
local unpack		=unpack
local type			=type
local IsA			=game.IsA
local r3			=Region3.new
local v3			=Vector3.new



local function Region3BoundingBox(CFrame,Size)
 	local	x,y,z,
			xx,yx,zx,
			xy,yy,zy,
			xz,yz,zz=components(CFrame)
	local	sx,sy,sz=Size.x/2,Size.y/2,Size.z/2
	local	px		=sx*(xx<0 and -xx or xx)
					+sy*(yx<0 and -yx or yx)
					+sz*(zx<0 and -zx or zx)
	local	py		=sx*(xy<0 and -xy or xy)
					+sy*(yy<0 and -yy or yy)
					+sz*(zy<0 and -zy or zy)
	local	pz		=sx*(xz<0 and -xz or xz)
					+sy*(yz<0 and -yz or yz)
					+sz*(zz<0 and -zz or zz)
	return			r3(v3(x-px,y-py,z-pz),v3(x+px,y+py,z+pz))
end



local function FindAllPartsInRegion3(Region3,Ignore)
	local Ignore=type(Ignore)=="table" and Ignore or {Ignore}
	local Last=#Ignore
	repeat
		local Parts=BoxCast(Workspace,Region3,Ignore,100)
		local Start=#Ignore
		for i=1,#Parts do
			Ignore[Start+i]=Parts[i]
		end
	until #Parts<100;
	return {unpack(Ignore,Last+1,#Ignore)}
end



local function CastPoint(Region,Point)
	return BoxPointCollision(Region.CFrame,Region.Size,Point)
end



local function CastSphere(Region,Center,Radius)
	return BoxSphereCollision(Region.CFrame,Region.Size,Center,Radius)
end



local function CastBox(Region,CFrame,Size)
	return BoxCollision(Region.CFrame,Region.Size,CFrame,Size)
end



local function CastPart(Region,Part)
	return	(not IsA(Part,"Part") or Part.Shape=="Block") and
			BoxCollision(Region.CFrame,Region.Size,Part.CFrame,Part.Size)
			or BoxSphereCollision(Region.CFrame,Region.Size,Part.Position,Part.Size.x)
end



local function CastParts(Region,Parts)
	local Inside={}
	for i=1,#Parts do
		if CastPart(Region,Parts[i]) then
			Inside[#Inside+1]=Parts[i]
		end
	end
	return Inside
end



local function Cast(Region,Ignore)
	local Inside={}
	local Parts=FindAllPartsInRegion3(Region.Region3,Ignore)
	for i=1,#Parts do
		if CastPart(Region,Parts[i]) then
			Inside[#Inside+1]=Parts[i]
		end
	end
	return Inside
end



local function NewRegion(CFrame,Size)
	local Object	={
		CFrame		=CFrame;
		Size		=Size;
		Region3		=Region3BoundingBox(CFrame,Size);
		Cast		=Cast;
		CastPart	=CastPart;
		CastParts	=CastParts;
		CastPoint	=CastPoint;
		CastSphere	=CastSphere;
		CastBox		=CastBox;
					}
	return			setmetatable({},{
		__index=Object;
		__newindex=function(_,Index,Value)
			Object[Index]=Value
			Object.Region3=Region3BoundingBox(Object.CFrame,Object.Size)
		end;
					})
end



Region.Region3BoundingBox	=Region3BoundingBox
Region.FindAllPartsInRegion3=FindAllPartsInRegion3
Region.BoxPointCollision	=BoxPointCollision
Region.BoxSphereCollision	=BoxSphereCollision
Region.BoxCollision			=BoxCollision
Region.new					=NewRegion
function Region.FromPart(Part)
	return NewRegion(Part.CFrame,Part.Size)
end


-------------------------------------------------
-------------------------------------------------
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

local function Draw(p1,p2)
	local d=(p1-p2).magnitude
	local pos=CFrame.new(p1,p2)
	pos=pos.p+(pos.lookVector*(d/2))
	pos=CFrame.new(pos,p2)
	local p=Instance.new('Part')
	p.CanCollide=false
	p.Anchored=true
	p.FormFactor=Enum.FormFactor.Custom
	p.Size=Vector3.new(settings.thickness,settings.thickness,d)
	p.CFrame=pos
	return p
end

local function Get(l)
local ray=Ray.new(l,Vector3.new(0,-999,0),true)
local hit,pos=workspace:FindPartOnRayWithIgnoreList(ray,{(player.Character~=nil and player.Character)})
if hit then return l-((pos-l).unit/2) end
--if hit then return (pos-l).magnitude;end
return nil
end

local function DrawShape()
	local m=Instance.new('Model',workspace)
	for i,set in pairs(rpoints) do
		for i2,point in pairs(set) do
			if set[i2+1]~=nil then
				Draw(point,set[i2+1]).Parent=m
			else
				Draw(point,set[1]).Parent=m
			end
		end
	end
	return m
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
		end
	end

	-- Size, Position
	return Vector3.new(Sides[1]-Sides[2],Sides[3]-Sides[4],Sides[5]-Sides[6]), 
	       Vector3.new((Sides[1]+Sides[2])/2,(Sides[3]+Sides[4])/2,(Sides[5]+Sides[6])/2)
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

local a=DrawShape()
local s,p=GetBoundingBox(GetParts(a))
local center=CFrame.new(p+Vector3.new(0,s/2,0))
local b=DrawShape()
Move(a,center)
Move(b,center)

local l
local region

game:GetService('RunService').RenderStepped:connect(function()

	if player.Character~=nil then
		if player.Character:FindFirstChild('Torso')~=nil then
			l=CFrame.new(player.Character.Torso.CFrame.p)
			region=Region.new(l,Vector3.new(1,1,1)*settings.size/1.8)
			local parts=region:Cast({(player.Character~=nil and player.Character),a,b})
			for _,v in pairs(parts) do
				if v:FindFirstChild('Tagged')==nil then
					if v:GetMass()<=90 then
						v:BreakJoints()
						v.Anchored=false
						v.Velocity=(v.Position-l.p).unit*300
						local a=Instance.new('Folder',v)
						a.Name='Tagged'
						game:GetService('Debris'):AddItem(a,.2)
					end
				end
			end
		end
		
		Move(b,center)
		Move(b,l*CFrame.Angles(math.rad(math.sin(tick())*2),0,0))
		
		Move(a,center)
		Move(a,l*CFrame.Angles(0,math.rad(2),0))
	end
end)


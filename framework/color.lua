local M=myMath
local max,min,abs=math.max,math.min,math.abs
local color={
	red=    {1,0,0},
	orange= {1,.5,0},
	yellow= {1,1,0},
	lawn=   {.5,1,0},
	green=  {0,1,0},
	jade=   {0,1,.5},
	cyan=   {0,1,1},
	azure=  {0,.5,1},
	blue=   {0,0,1},
	violet= {.5,0,1},
	magenta={1,0,1},
	hotpink={1,0,.5},

	aquamarine={.5,1,.875},

	white=  {1,1,1},
	silver= {.75,.75,.75},
	gray=   {.5,.5,.5},
	dark=   {.25,.25,.25},
	black=  {0,0,0},
}
function color.hex2num(str)
	local r=(tonumber(string.sub(str,1,2),16) or 0)/255
    local g=(tonumber(string.sub(str,3,4),16) or 0)/255
    local b=(tonumber(string.sub(str,5,6),16) or 0)/255
    local a=(tonumber(string.sub(str,7,8),16) or 255)/255
    return {r,g,b,a}
end
function color.hsv(h,s,v,a)-- Color type, Color amount, Light
    if s<=0 then return v,v,v,a end
    h=h%6
    local c=v*s
    local x=abs((h-1)%2-1)*c
    if     h<1 then return v,x+v-c,v-c,a
    elseif h<2 then return x+v-c,v,v-c,a
    elseif h<3 then return v-c,v,x+v-c,a
    elseif h<4 then return v-c,x+v-c,v,a
    elseif h<5 then return x+v-c,v-c,v,a
    else            return v,v-c,x+v-c,a
    end
end
function color.hsl(h, s, l, a)
	if s<=0 then return l,l,l,a end
	h=h%6
	local c=(1-abs(2*l-1))*s
	local x=(1-abs(h%2-1))*c
	local m,r,g,b = (l-.5*c), 0,0,0
	if     h<1 then r,g,b = c,x,0
	elseif h<2 then r,g,b = x,c,0
	elseif h<3 then r,g,b = 0,c,x
	elseif h<4 then r,g,b = 0,x,c
	elseif h<5 then r,g,b = x,0,c
	else            r,g,b = c,0,x
	end return r+m, g+m, b+m, a
end
function color.getHue(clr)
	local Cmax=max(clr[1],max(clr[2],clr[3]))
	local Cmin=min(clr[1],min(clr[2],clr[3]))
	local d=Cmax-Cmin
	return Cmax-Cmin==0 and 0 or
		   Cmax==clr[1] and (clr[2]-clr[3])/d%6 or
		   Cmax==clr[2] and (clr[3]-clr[1])/d+2 or
		   Cmax==clr[3] and (clr[1]-clr[2])/d+4
end
function color.find(clr)
	if type(clr)=='table' then return clr
	elseif type(clr)=='string' then return color[clr] and color[clr] or color.hex2num(clr) or error("Cannot find color you want")
	else error("color must be a string") end
end
return color
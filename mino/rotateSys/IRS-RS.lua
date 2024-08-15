--预操作系统使用的旋转系统，当方块与场地重叠时使用
local IRS_RS={}
--[[]]
IRS_RS={kickTable={
    Z={
        R={
            {{-1, 0},{ 0, 1},{-1, 1},{ 1, 1},{ 1, 0},{-2, 0},{ 2, 0},{ 0,-1},{ 1,-1},{-1,-1},{ 0,-2}}
        },
        L={
            {{ 1, 0},{ 0, 1},{ 1, 1},{-1, 1},{-1, 0},{ 2, 0},{-2, 0},{ 0,-1},{-1,-1},{ 1,-1},{ 0,-2}}
        },
        F={
            {{ 0, 1},{ 1, 0},{-1, 0},{-1,-1},{ 1,-1},{ 0, 2},{ 2, 0},{ 0,-2}}
        }
    },

    I={
        R={
            {{-1, 0},{ 1, 0},{ 0, 1},{-1, 1},{ 1, 1},{ 0, 2},{ 1, 2},{-2, 0},{ 2, 0},{ 0,-1},{ 0,-2}}
        },
        L={
            {{ 1, 0},{-1, 0},{ 0, 1},{ 1, 1},{-1, 1},{ 0, 2},{-1, 2},{ 2, 0},{-2, 0},{ 0,-1},{ 0,-2}}
        },
        F={
            {{ 1, 0},{-1, 0},{ 0,-1},{-1,-1},{ 1,-1},{ 0, 1},{ 0, 2}}
        }
    },
    O={
        R={{{ 0,-1},{ 1, 0},{ 1,-1},{ 1, 1},{ 0, 1},{ 2, 0}}},
        L={{{ 0,-1},{-1, 0},{-1,-1},{-1, 1},{ 0, 1},{-2, 0}}},
        F={{{ 0,-1},{ 0,-2},{ 0, 1},{ 0, 2}}}
    }
}}
for k,v in pairs(IRS_RS.kickTable.Z) do v[2],v[3],v[4]=v[1],v[1],v[1] end
for k,v in pairs(IRS_RS.kickTable.I) do v[2],v[3],v[4]=v[1],v[1],v[1] end
for k,v in pairs(IRS_RS.kickTable.O) do v[2],v[3],v[4]=v[1],v[1],v[1] end
IRS_RS.kickTable.S={
    R=IRS_RS.kickTable.Z.R,L=IRS_RS.kickTable.Z.L,
    F={
        {{ 0, 1},{-1, 0},{ 1, 0},{ 1,-1},{-1,-1},{ 0, 2},{-2, 0},{ 0,-2}},
    }
}
IRS_RS.kickTable.T={
    R=IRS_RS.kickTable.Z.R,L=IRS_RS.kickTable.Z.L,
    F={
        {{ 0, 1},{ 1, 0},{-1, 0},{ 1,-1},{-1,-1},{-2, 0},{ 0, 2},{ 2, 0},{ 0,-2}},
    }
}
for k,v in pairs(IRS_RS.kickTable.S) do v[2],v[3],v[4]=v[1],v[1],v[1] end
for k,v in pairs(IRS_RS.kickTable.T) do v[2],v[3],v[4]=v[1],v[1],v[1] end

IRS_RS.kickTable.J=IRS_RS.kickTable.Z IRS_RS.kickTable.L=IRS_RS.kickTable.S

function IRS_RS.getKickTable()
    if IRS_RS.kickTable[name] then return IRS_RS.kickTable[name][mode][ori]
    else return IRS_RS.kickTable.O[mode] end
end
return IRS_RS
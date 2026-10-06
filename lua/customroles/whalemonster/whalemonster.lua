AddCSLuaFile()

local util = util
local net = net
local player = player
local hook = hook

local PlayerIterator = player.Iterator
local AddHook = hook.Add

util.AddNetworkString("TTT_MonsterWhaleSelectRole")

-------------
-- CONVARS --
-------------

-------------------
-- ROLE FEATURES --
-------------------

net.Receive("TTT_MonsterWhaleSelectRole", function(_, ply)
    if ply:IsActiveMonsterWhale() then
        local role = net.ReadInt(util.RoleBits())
        ply:SetNWInt("TTT_MonsterWhaleSelection", role)
    end
end)



-------------
-- CLEANUP --
-------------

AddHook("TTTPrepareRound", "Whalemonster_TTTPrepareRound", function()
    for _, v in PlayerIterator() do
        v:SetNWInt("TTT_MonsterWhaleSelection", ROLE_NONE)
        v:SetNWBool("TTTMonsterWhaleWasMonsterWhale", false)
        v:SetNWFloat("TTTMonsterWhaleDamageDealt", 0)
    end
end)
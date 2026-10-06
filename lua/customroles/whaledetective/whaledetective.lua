AddCSLuaFile()

local util = util
local net = net
local player = player
local hook = hook

local PlayerIterator = player.Iterator
local AddHook = hook.Add

util.AddNetworkString("TTT_DetectiveWhaleSelectRole")

-------------
-- CONVARS --
-------------

-------------------
-- ROLE FEATURES --
-------------------

net.Receive("TTT_DetectiveWhaleSelectRole", function(_, ply)
    if ply:IsActiveDetectiveWhale() then
        local role = net.ReadInt(util.RoleBits())
        ply:SetNWInt("TTT_DetectiveWhaleSelection", role)
    end
end)



-------------
-- CLEANUP --
-------------

AddHook("TTTPrepareRound", "Whaledetective_TTTPrepareRound", function()
    for _, v in PlayerIterator() do
        v:SetNWInt("TTT_DetectiveWhaleSelection", ROLE_NONE)
        v:SetNWBool("TTTDetectiveWhaleWasDetectiveWhale", false)
        v:SetNWFloat("TTTDetectiveWhaleDamageDealt", 0)
    end
end)
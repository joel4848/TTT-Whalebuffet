AddCSLuaFile()

local util = util
local net = net
local player = player
local hook = hook

local PlayerIterator = player.Iterator
local AddHook = hook.Add

util.AddNetworkString("TTT_DetectiveWhaleSelectRole")
util.AddNetworkString("TTT_DetectiveWhaleGuessed")

-------------
-- CONVARS --
-------------

-------------------
-- ROLE FEATURES --
-------------------

net.Receive("TTT_DetectiveWhaleSelectRole", function(_, ply)
    if ply:IsActiveDetectiveWhale() then
        local role = net.ReadInt(util.RoleBits())
        ply:SetNWInt("TTTDetectiveWhaleSelection", role)
    end
end)



-------------
-- CLEANUP --
-------------

AddHook("TTTPrepareRound", "Whaledetective_TTTPrepareRound", function()
    for _, v in PlayerIterator() do
        v:SetNWInt("TTTDetectiveWhaleSelection", ROLE_NONE)
        v:SetNWBool("TTTDetectiveWhaleWasDetectiveWhale", false)
        v:SetNWString("TTTDetectiveWhaleGuessedBy", "")
        v:SetNWFloat("TTTDetectiveWhaleDamageDealt", 0)
    end
end)
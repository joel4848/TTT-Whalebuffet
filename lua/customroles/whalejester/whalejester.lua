AddCSLuaFile()

local util = util
local net = net
local player = player
local hook = hook

local PlayerIterator = player.Iterator
local AddHook = hook.Add

util.AddNetworkString("TTT_JesterWhaleSelectRole")
util.AddNetworkString("TTT_JesterWhaleGuessed")

-------------
-- CONVARS --
-------------

-------------------
-- ROLE FEATURES --
-------------------

net.Receive("TTT_JesterWhaleSelectRole", function(_, ply)
    if ply:IsActiveJesterWhale() then
        local role = net.ReadInt(util.RoleBits())
        ply:SetNWInt("TTT_JesterWhaleSelection", role)
    end
end)



-------------
-- CLEANUP --
-------------

AddHook("TTTPrepareRound", "Whalejester_TTTPrepareRound", function()
    for _, v in PlayerIterator() do
        v:SetNWInt("TTT_JesterWhaleSelection", ROLE_NONE)
        v:SetNWBool("TTTJesterWhaleWasJesterWhale", false)
        v:SetNWString("TTTJesterWhaleGuessedBy", "")
        v:SetNWFloat("TTTJesterWhaleDamageDealt", 0)
    end
end)
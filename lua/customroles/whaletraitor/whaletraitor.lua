AddCSLuaFile()

local util = util
local net = net
local player = player
local hook = hook

local PlayerIterator = player.Iterator
local AddHook = hook.Add

util.AddNetworkString("TTT_TraitorWhaleSelectRole")
util.AddNetworkString("TTT_TraitorWhaleGuessed")

-------------
-- CONVARS --
-------------

-------------------
-- ROLE FEATURES --
-------------------

net.Receive("TTT_TraitorWhaleSelectRole", function(_, ply)
    if ply:IsActiveTraitorWhale() then
        local role = net.ReadInt(util.RoleBits())
        ply:SetNWInt("TTT_TraitorWhaleSelection", role)
    end
end)



-------------
-- CLEANUP --
-------------

AddHook("TTTPrepareRound", "Whaletraitor_TTTPrepareRound", function()
    for _, v in PlayerIterator() do
        v:SetNWInt("TTT_TraitorWhaleSelection", ROLE_NONE)
        v:SetNWBool("TTTTraitorWhaleWasTraitorWhale", false)
        v:SetNWString("TTTTraitorWhaleGuessedBy", "")
        v:SetNWFloat("TTTTraitorWhaleDamageDealt", 0)
    end
end)
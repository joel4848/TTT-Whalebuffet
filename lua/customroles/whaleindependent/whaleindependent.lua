AddCSLuaFile()

local util = util
local net = net
local player = player
local hook = hook

local PlayerIterator = player.Iterator
local AddHook = hook.Add

util.AddNetworkString("TTT_IndependentWhaleSelectRole")
util.AddNetworkString("TTT_IndependentWhaleGuessed")

-------------
-- CONVARS --
-------------

local truewhale = GetConVar("ttt_whaleindependent_is_true_whale"):GetBool()

-------------------
-- ROLE FEATURES --
-------------------

net.Receive("TTT_IndependentWhaleSelectRole", function(_, ply)
    if ply:IsActiveIndependentWhale() then
        local role = net.ReadInt(util.RoleBits())
        ply:SetNWInt("TTTIndependentWhaleSelection", role)
    end
end)



-------------
-- CLEANUP --
-------------

AddHook("TTTPrepareRound", "Whaleindependent_TTTPrepareRound", function()
    for _, v in PlayerIterator() do
        v:SetNWInt("TTTIndependentWhaleSelection", ROLE_NONE)
        v:SetNWBool("TTTIndependentWhaleWasIndependentWhale", false)
        v:SetNWString("TTTIndependentWhaleGuessedBy", "")
        v:SetNWFloat("TTTIndependentWhaleDamageDealt", 0)
    end
end)
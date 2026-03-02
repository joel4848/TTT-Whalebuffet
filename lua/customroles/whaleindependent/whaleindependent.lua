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

CreateConVar("ttt_independentwhale_notify_mode", "0", FCVAR_NONE, "The logic to use when notifying players that a whaleindependent was killed. Killer is notified unless \"TTT_IndependentWhale_notify_killer\" is disabled", 0, 4)
CreateConVar("ttt_independentwhale_notify_killer", "1", FCVAR_NONE, "Whether to notify a whaleindependent's killer", 0, 1)
CreateConVar("ttt_independentwhale_notify_sound", "0", FCVAR_NONE, "Whether to play a cheering sound when a whaleindependent is killed", 0, 1)
CreateConVar("ttt_independentwhale_notify_confetti", "0", FCVAR_NONE, "Whether to throw confetti when a whaleindependent is a killed", 0, 1)

local whaleindependent_show_team_threshold = GetConVar("TTT_IndependentWhale_show_team_threshold")
local whaleindependent_show_role_threshold = GetConVar("TTT_IndependentWhale_show_role_threshold")
local whaleindependent_can_guess_detectives = GetConVar("TTT_IndependentWhale_can_guess_detectives")
-- local whaleindependent_warn_all = GetConVar("TTT_IndependentWhale_warn_all")

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
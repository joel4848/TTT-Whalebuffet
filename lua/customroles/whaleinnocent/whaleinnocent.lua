AddCSLuaFile()

local util = util
local net = net
local player = player
local hook = hook

local PlayerIterator = player.Iterator
local AddHook = hook.Add

util.AddNetworkString("TTT_WhaleinnocentSelectRole")
util.AddNetworkString("TTT_WhaleinnocentGuessed")

-------------
-- CONVARS --
-------------

CreateConVar("ttt_whaleinnocent_notify_mode", "0", FCVAR_NONE, "The logic to use when notifying players that a whaleinnocent was killed. Killer is notified unless \"ttt_whaleinnocent_notify_killer\" is disabled", 0, 4)
CreateConVar("ttt_whaleinnocent_notify_killer", "1", FCVAR_NONE, "Whether to notify a whaleinnocent's killer", 0, 1)
CreateConVar("ttt_whaleinnocent_notify_sound", "0", FCVAR_NONE, "Whether to play a cheering sound when a whaleinnocent is killed", 0, 1)
CreateConVar("ttt_whaleinnocent_notify_confetti", "0", FCVAR_NONE, "Whether to throw confetti when a whaleinnocent is a killed", 0, 1)

local whaleinnocent_show_team_threshold = GetConVar("ttt_whaleinnocent_show_team_threshold")
local whaleinnocent_show_role_threshold = GetConVar("ttt_whaleinnocent_show_role_threshold")
local whaleinnocent_can_guess_detectives = GetConVar("ttt_whaleinnocent_can_guess_detectives")
-- local whaleinnocent_warn_all = GetConVar("ttt_whaleinnocent_warn_all")

-------------------
-- ROLE FEATURES --
-------------------

net.Receive("TTT_WhaleinnocentSelectRole", function(_, ply)
    if ply:IsActiveInnocentWhale() then
        local role = net.ReadInt(util.RoleBits())
        ply:SetNWInt("TTTInnocentWhaleSelection", role)
    end
end)



-------------
-- CLEANUP --
-------------

AddHook("TTTPrepareRound", "Whaleinnocent_TTTPrepareRound", function()
    for _, v in PlayerIterator() do
        v:SetNWInt("TTTInnocentWhaleSelection", ROLE_NONE)
        v:SetNWBool("TTTInnocentWhaleWasWhaleinnocent", false)
        v:SetNWString("TTTInnocentWhaleGuessedBy", "")
        v:SetNWFloat("TTTInnocentWhaleDamageDealt", 0)
    end
end)
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

CreateConVar("ttt_jesterwhale_notify_mode", "0", FCVAR_NONE, "The logic to use when notifying players that a whalejester was killed. Killer is notified unless \"TTT_JesterWhale_notify_killer\" is disabled", 0, 4)
CreateConVar("ttt_jesterwhale_notify_killer", "1", FCVAR_NONE, "Whether to notify a whalejester's killer", 0, 1)
CreateConVar("ttt_jesterwhale_notify_sound", "0", FCVAR_NONE, "Whether to play a cheering sound when a whalejester is killed", 0, 1)
CreateConVar("ttt_jesterwhale_notify_confetti", "0", FCVAR_NONE, "Whether to throw confetti when a whalejester is a killed", 0, 1)

local whalejester_show_team_threshold = GetConVar("TTT_JesterWhale_show_team_threshold")
local whalejester_show_role_threshold = GetConVar("TTT_JesterWhale_show_role_threshold")
local whalejester_can_guess_detectives = GetConVar("TTT_JesterWhale_can_guess_detectives")
-- local whalejester_warn_all = GetConVar("TTT_JesterWhale_warn_all")

-------------------
-- ROLE FEATURES --
-------------------

net.Receive("TTT_JesterWhaleSelectRole", function(_, ply)
    if ply:IsActiveJesterWhale() then
        local role = net.ReadInt(util.RoleBits())
        ply:SetNWInt("TTTJesterWhaleSelection", role)
    end
end)



-------------
-- CLEANUP --
-------------

AddHook("TTTPrepareRound", "Whalejester_TTTPrepareRound", function()
    for _, v in PlayerIterator() do
        v:SetNWInt("TTTJesterWhaleSelection", ROLE_NONE)
        v:SetNWBool("TTTJesterWhaleWasJesterWhale", false)
        v:SetNWString("TTTJesterWhaleGuessedBy", "")
        v:SetNWFloat("TTTJesterWhaleDamageDealt", 0)
    end
end)
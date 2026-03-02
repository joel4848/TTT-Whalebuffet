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

CreateConVar("ttt_traitorwhale_notify_mode", "0", FCVAR_NONE, "The logic to use when notifying players that a whaletraitor was killed. Killer is notified unless \"TTT_TraitorWhale_notify_killer\" is disabled", 0, 4)
CreateConVar("ttt_traitorwhale_notify_killer", "1", FCVAR_NONE, "Whether to notify a whaletraitor's killer", 0, 1)
CreateConVar("ttt_traitorwhale_notify_sound", "0", FCVAR_NONE, "Whether to play a cheering sound when a whaletraitor is killed", 0, 1)
CreateConVar("ttt_traitorwhale_notify_confetti", "0", FCVAR_NONE, "Whether to throw confetti when a whaletraitor is a killed", 0, 1)

local whaletraitor_show_team_threshold = GetConVar("TTT_TraitorWhale_show_team_threshold")
local whaletraitor_show_role_threshold = GetConVar("TTT_TraitorWhale_show_role_threshold")
local whaletraitor_can_guess_detectives = GetConVar("TTT_TraitorWhale_can_guess_detectives")
-- local whaletraitor_warn_all = GetConVar("TTT_TraitorWhale_warn_all")

-------------------
-- ROLE FEATURES --
-------------------

net.Receive("TTT_TraitorWhaleSelectRole", function(_, ply)
    if ply:IsActiveTraitorWhale() then
        local role = net.ReadInt(util.RoleBits())
        ply:SetNWInt("TTTTraitorWhaleSelection", role)
    end
end)



-------------
-- CLEANUP --
-------------

AddHook("TTTPrepareRound", "Whaletraitor_TTTPrepareRound", function()
    for _, v in PlayerIterator() do
        v:SetNWInt("TTTTraitorWhaleSelection", ROLE_NONE)
        v:SetNWBool("TTTTraitorWhaleWasTraitorWhale", false)
        v:SetNWString("TTTTraitorWhaleGuessedBy", "")
        v:SetNWFloat("TTTTraitorWhaleDamageDealt", 0)
    end
end)
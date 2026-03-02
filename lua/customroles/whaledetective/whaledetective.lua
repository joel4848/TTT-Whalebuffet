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

CreateConVar("ttt_detectivewhale_notify_mode", "0", FCVAR_NONE, "The logic to use when notifying players that a whaledetective was killed. Killer is notified unless \"TTT_DetectiveWhale_notify_killer\" is disabled", 0, 4)
CreateConVar("ttt_detectivewhale_notify_killer", "1", FCVAR_NONE, "Whether to notify a whaledetective's killer", 0, 1)
CreateConVar("ttt_detectivewhale_notify_sound", "0", FCVAR_NONE, "Whether to play a cheering sound when a whaledetective is killed", 0, 1)
CreateConVar("ttt_detectivewhale_notify_confetti", "0", FCVAR_NONE, "Whether to throw confetti when a whaledetective is a killed", 0, 1)

local whaledetective_show_team_threshold = GetConVar("TTT_DetectiveWhale_show_team_threshold")
local whaledetective_show_role_threshold = GetConVar("TTT_DetectiveWhale_show_role_threshold")
local whaledetective_can_guess_detectives = GetConVar("TTT_DetectiveWhale_can_guess_detectives")
-- local whaledetective_warn_all = GetConVar("TTT_DetectiveWhale_warn_all")

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
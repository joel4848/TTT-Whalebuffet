AddCSLuaFile()

local util = util
local net = net
local player = player
local hook = hook

local PlayerIterator = player.Iterator
local AddHook = hook.Add

util.AddNetworkString("TTT_MonsterWhaleSelectRole")
util.AddNetworkString("TTT_MonsterWhaleGuessed")

-------------
-- CONVARS --
-------------

CreateConVar("ttt_monsterwhale_notify_mode", "0", FCVAR_NONE, "The logic to use when notifying players that a whalemonster was killed. Killer is notified unless \"TTT_MonsterWhale_notify_killer\" is disabled", 0, 4)
CreateConVar("ttt_monsterwhale_notify_killer", "1", FCVAR_NONE, "Whether to notify a whalemonster's killer", 0, 1)
CreateConVar("ttt_monsterwhale_notify_sound", "0", FCVAR_NONE, "Whether to play a cheering sound when a whalemonster is killed", 0, 1)
CreateConVar("ttt_monsterwhale_notify_confetti", "0", FCVAR_NONE, "Whether to throw confetti when a whalemonster is a killed", 0, 1)

local whalemonster_show_team_threshold = GetConVar("TTT_MonsterWhale_show_team_threshold")
local whalemonster_show_role_threshold = GetConVar("TTT_MonsterWhale_show_role_threshold")
local whalemonster_can_guess_detectives = GetConVar("TTT_MonsterWhale_can_guess_detectives")
-- local whalemonster_warn_all = GetConVar("TTT_MonsterWhale_warn_all")

-------------------
-- ROLE FEATURES --
-------------------

net.Receive("TTT_MonsterWhaleSelectRole", function(_, ply)
    if ply:IsActiveMonsterWhale() then
        local role = net.ReadInt(util.RoleBits())
        ply:SetNWInt("TTTMonsterWhaleSelection", role)
    end
end)



-------------
-- CLEANUP --
-------------

AddHook("TTTPrepareRound", "Whalemonster_TTTPrepareRound", function()
    for _, v in PlayerIterator() do
        v:SetNWInt("TTTMonsterWhaleSelection", ROLE_NONE)
        v:SetNWBool("TTTMonsterWhaleWasMonsterWhale", false)
        v:SetNWString("TTTMonsterWhaleGuessedBy", "")
        v:SetNWFloat("TTTMonsterWhaleDamageDealt", 0)
    end
end)
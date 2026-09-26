AddCSLuaFile()

local util = util
local net = net
local player = player
local hook = hook

local PlayerIterator = player.Iterator
local AddHook = hook.Add

util.AddNetworkString("TTT_InnocentWhaleSelectRole")
util.AddNetworkString("TTT_InnocentWhaleGuessed")

-------------
-- CONVARS --
-------------

local balance_whales = CreateConVar("ttt_whales_balance_innocent_traitor", "1", FCVAR_NONE, "Whether a round should always start with an equal number of innocent/detective whales and traitor Whales", 0, 1)

-------------------
-- ROLE FEATURES --
-------------------

net.Receive("TTT_InnocentWhaleSelectRole", function(_, ply)
    if ply:IsActiveInnocentWhale() then
        local role = net.ReadInt(util.RoleBits())
        ply:SetNWInt("TTT_InnocentWhaleSelection", role)
    end
end)

local function GetPlayerToConvert(first, second, third, fourth)
    local tables = {first, second, third, fourth}

    for _, tbl in ipairs(tables) do
        if #tbl > 0 then
            local choice = math.random(1, #tbl)
            local target = tbl[choice]
            table.remove(tbl, choice)
            return target
        end
    end

    return nil
end

AddHook("TTTBeginRound", "Whales_TTTBeginRound", function()
    -- Delay by a frame like the Twins
    timer.Simple(0, function()
        if not balance_whales:GetBool() then return end
        if Randomat:IsEventActive(whalebuffet) then return end

        local innocentWhaleCount = 0
        local traitorWhaleCount  = 0

        local noRole           = {}
        local innocents        = {}
        local traitors         = {}
        local specialInnocents = {}
        local specialTraitors  = {}
        local detectives       = {}

        -- Count Whales and put everyone else in the correct table as necessary
        for _, ply in PlayerIterator() do
            if not IsValid(ply) or ply:IsSpec() then continue end

            if ply:IsInnocentWhale() or ply:IsDetectiveWhale() then
                innocentWhaleCount = innocentWhaleCount + 1
            elseif ply:IsTraitorWhale() then
                traitorWhaleCount = traitorWhaleCount + 1
            elseif ply:GetRole() == ROLE_NONE then
                table.insert(noRole, ply)
            elseif ply:IsInnocent() then
                table.insert(innocents, ply)
            elseif ply:IsTraitor() then
                table.insert(traitors, ply)
            elseif ply:IsInnocentTeam() and not ply:IsDetectiveTeam() then
                table.insert(specialInnocents, ply)
            elseif ply:IsTraitorTeam() then
                table.insert(specialTraitors, ply)
            elseif ply:IsDetectiveTeam() then
                table.insert(detectives, ply)
            end
        end

        -- Are Whales imbalanced?
        local difference = innocentWhaleCount - traitorWhaleCount
        if difference == 0 then return end

        table.Shuffle(noRole)
        table.Shuffle(innocents)
        table.Shuffle(traitors)
        table.Shuffle(specialInnocents)
        table.Shuffle(specialTraitors)
        table.Shuffle(detectives)

        local stateUpdateNeeded = false

        if difference > 0 then
            -- Need more Traitor Whales
            for i = 1, difference do
                local target = GetPlayerToConvert(noRole, traitors, specialTraitors)
                if target then
                    target:SetRole(ROLE_WHALETRAITOR)

                    stateUpdateNeeded = true
                else
                    break
                end
            end
        elseif difference < 0 then
            -- Need more Innocent/Detective Whales
            local needed = math.abs(difference)
            for i = 1, needed do
                local target = GetPlayerToConvert(noRole, innocents, specialInnocents, detectives)
                if target then
                    if target:IsDetectiveTeam() then
                        target:SetRole(ROLE_WHALEDETECTIVE)
                    else
                        target:SetRole(ROLE_WHALEINNOCENT)
                    end

                    stateUpdateNeeded = true
                else
                    break
                end
            end
        end

        if stateUpdateNeeded then
            SendFullStateUpdate()
        end
    end)
end)

-------------
-- CLEANUP --
-------------

AddHook("TTTPrepareRound", "Whaleinnocent_TTTPrepareRound", function()
    for _, v in PlayerIterator() do
        v:SetNWInt("TTT_InnocentWhaleSelection", ROLE_NONE)
        v:SetNWBool("TTTInnocentWhaleWasInnocentWhale", false)
        v:SetNWString("TTTInnocentWhaleGuessedBy", "")
        v:SetNWFloat("TTTInnocentWhaleDamageDealt", 0)
    end
end)
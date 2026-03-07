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

CreateConVar("ttt_whales_balance_innocent_traitor", "1", FCVAR_NONE, "Whether a round should always start with an equal number of innocent/detective whales and traitor Whales", 0, 1)

local balanceteams = GetConVar("ttt_whales_balance_innocent_traitor"):GetBool()

-------------------
-- ROLE FEATURES --
-------------------

if Randomat or Randomat.IsEventActive then
    local rdmtWhalebuffetActive = Randomat:IsEventActive(whalebuffet)
else
    local rdmtWhalebuffetActive = false
end

net.Receive("TTT_InnocentWhaleSelectRole", function(_, ply)
    if ply:IsActiveInnocentWhale() then
        local role = net.ReadInt(util.RoleBits())
        ply:SetNWInt("TTTInnocentWhaleSelection", role)
    end
end)

local function balance_teams_whales(p)
    local innocentWhales = {}
    local traitorWhales = {}
    for _, p in player.Iterator() do
        if p:IsInnocentWhale() then
            table.insert(innocentWhales, p)
        elseif p:IsDetectiveWhale() then
            table.insert(innocentWhales, p)
        elseif p:IsTraitorWhale() then
            table.insert(traitorWhales, p)
        end
    end

    local players = {}
    local choices = {}
    local innocents = {}
    local traitors = {}
    local specialInnocents = {}
    local specialTraitors = {}
    local detectives = {}

    for _, p in player.Iterator() do
        if IsValid(p) and not p:IsSpec() then
            table.insert(players, p)
            if p:GetRole() == ROLE_NONE then
                table.insert(choices, p)
            elseif p:IsInnocent() then
                table.insert(innocents, p)
            elseif p:IsTraitor() then
                table.insert(traitors, p)
            elseif p:IsInnocentTeam() and not p:IsDetectiveTeam() and not p:IsInnocentWhale() then
                table.insert(specialInnocents, p)
            elseif p:IsTraitorTeam() and not p:IsTraitorWhale() then
                table.insert(specialTraitors, p)
            elseif p:IsDetectiveTeam() and not p:IsDetectiveWhale() then
                table.insert(detectives, p)
            end
        end
    end

    -- print("=============================================")
    -- print("players: " .. #players)
    -- print("choices: " .. #choices)
    -- print("innocents: " .. #innocents)
    -- print("traitors: " .. #traitors)
    -- print("specialInnocents: " .. #specialInnocents)
    -- print("specialTraitors: " .. #specialTraitors)
    -- print("detectives: " .. #detectives)
    -- print("=============================================")

    if #innocentWhales > #traitorWhales then
        if #choices > 0 then
            table.Shuffle(choices)
            choices[1]:SetRole(ROLE_WHALETRAITOR)
        elseif #traitors > 0 then
            table.Shuffle(traitors)
            traitors[1]:SetRole(ROLE_WHALETRAITOR)
        elseif #specialTraitors > 0 then
            table.Shuffle(specialTraitors)
            specialTraitors[1]:SetRole(ROLE_WHALETRAITOR)
        end
    elseif #innocentWhales < #traitorWhales then
        if #choices > 0 then
            table.Shuffle(choices)
            choices[1]:SetRole(ROLE_WHALEINNOCENT)
        elseif #innocents > 0 then
            table.Shuffle(innocents)
            innocents[1]:SetRole(ROLE_WHALEINNOCENT)
        elseif #specialInnocents > 0 then
            table.Shuffle(specialInnocents)
            specialInnocents[1]:SetRole(ROLE_WHALEINNOCENT)
        elseif #detectives > 0 then
            table.Shuffle(detectives)
            detectives[1]:SetRole(ROLE_WHALEDETECTIVE)
        end
    end

    SendFullStateUpdate()

    local innocentWhales = {}
    local traitorWhales = {}
    for _, p in player.Iterator() do
        if p:IsInnocentWhale() then
            table.insert(innocentWhales, p)
        elseif p:IsDetectiveWhale() then
            table.insert(innocentWhales, p)
        elseif p:IsTraitorWhale() then
            table.insert(traitorWhales, p)
        end
    end

    if #innocentWhales ~= #traitorWhales then
        if #innocentWhales > #traitorWhales and (#choices > 0 or #traitors > 0 or #specialTraitors > 0 or #detectives > 0) then
            balance_teams_whales(p)
            -- print("Ran balance teams I>T")
        elseif #innocentWhales < #traitorWhales and (#choices > 0 or #innocents > 0 or #specialInnocents > 0) then
            balance_teams_whales(p)
            -- print("Ran balance teams I<T")
        -- else
        --     print ("Gave up")
        end
    end
end

if balanceteams and not rdmtWhalebuffetActive then
    hook.Add("TTTBeginRound", "Whales_TTTBeginRound", function()
        local innocentWhales = {}
        local traitorWhales = {}
        for _, p in player.Iterator() do
            if p:IsInnocentWhale() then
                table.insert(innocentWhales, p)
            elseif p:IsDetectiveWhale() then
                table.insert(innocentWhales, p)
            elseif p:IsTraitorWhale() then
                table.insert(traitorWhales, p)
            end
        end

        -- print("Innocent Whales: " .. #innocentWhales)
        -- print("Traitor Whales: " .. #traitorWhales)

        if #innocentWhales ~= #traitorWhales then
            -- print("#innocentWhales ~= #traitorWhales")
            balance_teams_whales(p)
        end
    end)
end






-------------
-- CLEANUP --
-------------

AddHook("TTTPrepareRound", "Whaleinnocent_TTTPrepareRound", function()
    for _, v in PlayerIterator() do
        v:SetNWInt("TTTInnocentWhaleSelection", ROLE_NONE)
        v:SetNWBool("TTTInnocentWhaleWasInnocentWhale", false)
        v:SetNWString("TTTInnocentWhaleGuessedBy", "")
        v:SetNWFloat("TTTInnocentWhaleDamageDealt", 0)
    end
end)
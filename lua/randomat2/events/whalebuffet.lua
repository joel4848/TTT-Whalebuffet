if not Randomat or not Randomat.IsEventActive then return end

local EVENT = {}

EVENT.Title = "Whalebuffet"
EVENT.Description = "Everyone is a Whale and picks their role this round!"
EVENT.id = "whalebuffet"
EVENT.Categories = {"rolechange", "moderateimpact"}

local RunHook = hook.Run

util.AddNetworkString("ClearRoleEffectsRadar")

function EVENT:Begin()

    local function clear_role_effects(ply)
        ply:StripRoleWeapons()
        
        for _, wep in ipairs(ply:GetWeapons()) do
            if IsValid(wep) and wep.CanBuy ~= nil then
                ply:StripWeapon(wep:GetClass())
            end
        end
    
        ply.equipment_items = {}
        ply:SendEquipment()
    
        -- Tell client to clear radar
        net.Start("ClearRoleEffectsRadar")
        net.Send(ply)
    
        ply:Give("weapon_zm_improvised")
        ply:SetCredits(0)
        SetRoleMaxHealth(ply)
    end

    -- Change everyone to a Whale on their team
    for _, ply in ipairs(self:GetAlivePlayers()) do
        if IsValid(ply) then
            if ply:IsDetectiveTeam() then
                ply:SetRoleAndBroadcast(ROLE_WHALEDETECTIVE)
                clear_role_effects(ply)
                RunHook("PlayerLoadout", ply)
            elseif ply:IsInnocentTeam() then
                ply:SetRoleAndBroadcast(ROLE_WHALEINNOCENT)
                clear_role_effects(ply)
                RunHook("PlayerLoadout", ply)
            elseif ply:IsTraitorTeam() then

                ply:SetRoleAndBroadcast(ROLE_WHALETRAITOR)
                clear_role_effects(ply)
                RunHook("PlayerLoadout", ply)

            
            elseif ply:IsJesterTeam() then
                ply:SetRoleAndBroadcast(ROLE_WHALEJESTER)
                clear_role_effects(ply)
                RunHook("PlayerLoadout", ply)
            elseif ply:IsIndependentTeam() then
                ply:SetRoleAndBroadcast(ROLE_WHALEINDEPENDENT)
                clear_role_effects(ply)
                RunHook("PlayerLoadout", ply)
            else
                ply:SetRoleAndBroadcast(ROLE_WHALEMONSTER)
                clear_role_effects(ply)
                RunHook("PlayerLoadout", ply)
            end

            SendFullStateUpdate()
        end
    end
end

Randomat:register(EVENT)

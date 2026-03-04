if not Randomat or not Randomat.IsEventActive then return end

local EVENT = {}
EVENT.id = "whalebuffet"

net.Receive("ClearRoleEffectsRadar", function()
    if not RADAR then return end

    RADAR.enable = false
    RADAR.endtime = 0
    RADAR.targets = {}

    if timer.Exists("radartimeout") then
        timer.Remove("radartimeout")
    end
end)

Randomat:register(EVENT)
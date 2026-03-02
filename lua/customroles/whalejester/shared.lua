local hook = hook
local math = math
local player = player
local table = table

local AddHook = hook.Add
local MathMax = math.max
local PlayerIterator = player.Iterator
local TableInsert = table.insert
local RemoveHook = hook.Remove

local ROLE = {}

ROLE.nameraw = "whalejester"
ROLE.name = "Jester Whale"
ROLE.nameplural = "Jester Whales"
ROLE.nameext = "a Jester Whale"
ROLE.nameshort = "wlj"

ROLE.desc = [[You are {role}!

You can choose which jester role you are this round!

Right click while holding the Whale Buffet Table to browse what's on offer.]]

ROLE.shortdesc = "Can choose which jester role they are this round."

ROLE.team = ROLE_TEAM_JESTER
ROLE.startinghealth = nil
ROLE.maxhealth = nil

ROLE.convars =
{

}

ROLE.translations = {
    ["english"] = {
        -- Selector
        ["whalebuffettable_help_pri"] = "Press {primaryfire} to change to your selected role.",
        ["whalebuffettable_help_sec"] = "Press {secondaryfire} to open the role selection menu.",
        ["whalebuffettable_title"] = "Role selector",

        -- HUD
        ["whale_selection"] = "Role Selected:"
    }
}

RegisterRole(ROLE)
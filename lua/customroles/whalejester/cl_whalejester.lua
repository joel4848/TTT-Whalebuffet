local hook = hook
local string = string

local AddHook = hook.Add
local StringUpper = string.upper
local Utf8Upper = utf8.upper

-------------
-- CONVARS --
-------------

local glitch_mode = GetConVar("ttt_glitch_mode")
local hide_role = GetConVar("ttt_hide_role")

------------------
-- TRANSLATIONS --
------------------

AddHook("Initialize", "Whalejester_Translations_Initialize", function()
    -- Weapons
    LANG.AddToLanguage("english", "guessingdevice_help_pri", "Press {primaryfire} to guess a player's role.")
    LANG.AddToLanguage("english", "guessingdevice_help_sec", "Press {secondaryfire} to select a role.")
    LANG.AddToLanguage("english", "guessingdevice_title", "Role Whalejester Selection")

    -- HUD
    LANG.AddToLanguage("english", "whalejester_selection", "Role Selected: ")

    -- Target ID
    LANG.AddToLanguage("english", "whalejester_unguessable", "UNGUESSABLE")

    -- Scoring
    LANG.AddToLanguage("english", "score_whalejester_guessed_by", "Guessed by")

    -- Events
    LANG.AddToLanguage("english", "ev_whalejester_correct", "{whalejester} correctly guessed {victim}'s role")

    LANG.AddToLanguage("english", "ev_whalejester_incorrect", "{whalejester} incorrectly guessed {victim}'s role")

    -- Cheat Sheet
    LANG.AddToLanguage("english", "cheatsheet_desc_whalejester", "Must choose a role of their alignment to become.")

    -- Popup
    LANG.AddToLanguage("english", "info_popup_whalejester", [[You are {role}! Open your Buffet Table weapon with {secondaryfire},
    select a role, then use {primaryfire} to become that role.]])
end)

---------
-- HUD --
---------

AddHook("TTTHUDInfoPaint", "Whale_TTTHUDInfoPaint", function(client, label_left, label_top, active_labels)
    if hide_role:GetBool() then return end

    if client:IsJesterWhale() then
        surface.SetFont("TabLarge")
        surface.SetTextColor(255, 255, 255, 230)

        local text = LANG.GetTranslation("whalejester_selection")
        local w, h = surface.GetTextSize(text)

        -- Move this up based on how many other labels there are
        label_top = label_top + (20 * #active_labels)

        surface.SetTextPos(label_left, ScrH() - label_top - h)
        surface.DrawText(text)

        local role = client:GetNWInt("TTTJesterWhaleSelection", ROLE_NONE)
        if role == ROLE_NONE then
            text = "None"
        else
            text = ROLE_STRINGS[role]
            local color = ROLE_COLORS_RADAR[role]
            if not DEFAULT_ROLES[role] and ROLE_STARTING_TEAM[role] then
                color = GetRoleTeamColor(ROLE_STARTING_TEAM[role], "radar")
            end
            surface.SetTextColor(color)
        end
        surface.SetTextPos(label_left + w, ScrH() - label_top - h)
        surface.DrawText(text)

        -- Track that the label was added so others can position accurately
        table.insert(active_labels, "whalejester")
    end
end)
--------------
-- TUTORIAL --
--------------

hook.Add("TTTTutorialRoleText", "Whalejester_TTTTutorialRoleText", function(role, titleLabel)
    if role == ROLE_WHALEJESTER then
        local roleColor = GetRoleTeamColor(ROLE_TEAM_JESTER)
        local detectiveColor = ROLE_COLORS[ROLE_DETECTIVE]
        local html = "The " .. ROLE_STRINGS[ROLE_WHALEJESTER] .. " is a <span style='color: rgb(" .. roleColor.r .. ", " .. roleColor.g .. ", " .. roleColor.b .. ")'>jester</span> role who can become any other jester role of their choice."
        return html
    end
end)
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

AddHook("Initialize", "Whaleinnocent_Translations_Initialize", function()
    -- Weapons
    LANG.AddToLanguage("english", "guessingdevice_help_pri", "Press {primaryfire} to guess a player's role.")
    LANG.AddToLanguage("english", "guessingdevice_help_sec", "Press {secondaryfire} to select a role.")
    LANG.AddToLanguage("english", "guessingdevice_title", "Role Whaleinnocent Selection")

    -- HUD
    LANG.AddToLanguage("english", "whaleinnocent_selection", "Role Selected: ")

    -- Target ID
    LANG.AddToLanguage("english", "whaleinnocent_unguessable", "UNGUESSABLE")

    -- Scoring
    LANG.AddToLanguage("english", "score_whaleinnocent_guessed_by", "Guessed by")

    -- Events
    LANG.AddToLanguage("english", "ev_whaleinnocent_correct", "{whaleinnocent} correctly guessed {victim}'s role")

    LANG.AddToLanguage("english", "ev_whaleinnocent_incorrect", "{whaleinnocent} incorrectly guessed {victim}'s role")

    -- Cheat Sheet
    LANG.AddToLanguage("english", "cheatsheet_desc_whaleinnocent", "Must choose a role of their alignment to become.")

    -- Popup
    LANG.AddToLanguage("english", "info_popup_whaleinnocent", [[You are {role}! Open your Buffet Table weapon with {secondaryfire},
    select a role, then use {primaryfire} to become that role.]])
end)

---------
-- HUD --
---------

AddHook("TTTHUDInfoPaint", "Whaleinnocent_TTTHUDInfoPaint", function(client, label_left, label_top, active_labels)
    if hide_role:GetBool() then return end

    if client:IsInnocentWhale() then
        surface.SetFont("TabLarge")
        surface.SetTextColor(255, 255, 255, 230)

        local text = LANG.GetTranslation("whaleinnocent_selection")
        local w, h = surface.GetTextSize(text)

        -- Move this up based on how many other labels there are
        label_top = label_top + (20 * #active_labels)

        surface.SetTextPos(label_left, ScrH() - label_top - h)
        surface.DrawText(text)

        local role = client:GetNWInt("TTT_InnocentWhaleSelection", ROLE_NONE)
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
        table.insert(active_labels, "whaleinnocent")
    end
end)
--------------
-- TUTORIAL --
--------------

hook.Add("TTTTutorialRoleText", "Whaleinnocent_TTTTutorialRoleText", function(role, titleLabel)
    if role == ROLE_WHALEINNOCENT then
        local roleColor = GetRoleTeamColor(ROLE_TEAM_JESTER)
        local detectiveColor = ROLE_COLORS[ROLE_DETECTIVE]
        local html = "The " .. ROLE_STRINGS[ROLE_WHALEINNOCENT] .. " is an <span style='color: rgb(" .. roleColor.r .. ", " .. roleColor.g .. ", " .. roleColor.b .. ")'>innocent</span> role who can become any other innocent role of their choice."
        return html
    end
end)
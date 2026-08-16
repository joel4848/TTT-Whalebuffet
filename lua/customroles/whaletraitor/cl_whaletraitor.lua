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

AddHook("Initialize", "Whaletraitor_Translations_Initialize", function()
    -- Weapons
    LANG.AddToLanguage("english", "guessingdevice_help_pri", "Press {primaryfire} to guess a player's role.")
    LANG.AddToLanguage("english", "guessingdevice_help_sec", "Press {secondaryfire} to select a role.")
    LANG.AddToLanguage("english", "guessingdevice_title", "Role Whaletraitor Selection")

    -- HUD
    LANG.AddToLanguage("english", "whaletraitor_selection", "Role Selected: ")

    -- Target ID
    LANG.AddToLanguage("english", "whaletraitor_unguessable", "UNGUESSABLE")

    -- Scoring
    LANG.AddToLanguage("english", "score_whaletraitor_guessed_by", "Guessed by")

    -- Events
    LANG.AddToLanguage("english", "ev_whaletraitor_correct", "{whaletraitor} correctly guessed {victim}'s role")

    LANG.AddToLanguage("english", "ev_whaletraitor_incorrect", "{whaletraitor} incorrectly guessed {victim}'s role")

    -- Cheat Sheet
    LANG.AddToLanguage("english", "cheatsheet_desc_whaletraitor", "Must choose a role of their alignment to become.")

    -- Popup
    LANG.AddToLanguage("english", "info_popup_whaletraitor", [[You are {role}! Open your Buffet Table weapon with {secondaryfire},
    select a role, then use {primaryfire} to become that role.]])
end)

---------
-- HUD --
---------

AddHook("TTTHUDInfoPaint", "Whaletraitor_TTTHUDInfoPaint", function(client, label_left, label_top, active_labels)
    if hide_role:GetBool() then return end

    if client:IsTraitorWhale() then
        surface.SetFont("TabLarge")
        surface.SetTextColor(255, 255, 255, 230)

        local text = LANG.GetTranslation("whaletraitor_selection")
        local w, h = surface.GetTextSize(text)

        -- Move this up based on how many other labels there are
        label_top = label_top + (20 * #active_labels)

        surface.SetTextPos(label_left, ScrH() - label_top - h)
        surface.DrawText(text)

        local role = client:GetNWInt("TTT_TraitorWhaleSelection", ROLE_NONE)
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
        table.insert(active_labels, "whaletraitor")
    end
end)
--------------
-- TUTORIAL --
--------------

hook.Add("TTTTutorialRoleText", "Whaletraitor_TTTTutorialRoleText", function(role, titleLabel)
    if role == ROLE_WHALETRAITOR then
        local roleColor = GetRoleTeamColor(ROLE_TEAM_TRAITOR)
        local detectiveColor = ROLE_COLORS[ROLE_DETECTIVE]
        local html = "The " .. ROLE_STRINGS[ROLE_WHALETRAITOR] .. " is a <span style='color: rgb(" .. roleColor.r .. ", " .. roleColor.g .. ", " .. roleColor.b .. ")'>traitor</span> role who can become any other traitor role of their choice."
        return html
    end
end)
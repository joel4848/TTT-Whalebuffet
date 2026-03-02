AddCSLuaFile()

local vgui = vgui
local net = net
local player = player
local util = util

local PlayerIterator = player.Iterator
local GetTranslation = LANG.GetTranslation
local StringLower = string.lower
local StringFind = string.find
local TableInsert = table.insert
local TableSort = table.sort
local TableHasValue = table.HasValue
local MathMax = math.max
local MathClamp = math.Clamp
local MathCeil = math.ceil
local RunHook = hook.Run
local CallHook = hook.Call

if CLIENT then
    SWEP.PrintName          = "Buffet Table"
    SWEP.Slot               = 8

    SWEP.ViewModelFOV       = 60
    SWEP.DrawCrosshair      = false
    SWEP.ViewModelFlip      = false
end

SWEP.ViewModel              = "models/weapons/c_slam.mdl"
SWEP.WorldModel             = "models/weapons/w_slam.mdl"
SWEP.Weight                 = 2

SWEP.Base                   = "weapon_tttbase"
SWEP.Category               = WEAPON_CATEGORY_ROLE

SWEP.Spawnable              = false
SWEP.AutoSpawnable          = false
SWEP.HoldType               = "slam"
SWEP.Kind                   = WEAPON_ROLE

SWEP.DeploySpeed            = 4
SWEP.AllowDrop              = false
SWEP.NoSights               = true
SWEP.UseHands               = true
SWEP.LimitedStock           = true
SWEP.AmmoEnt                = nil

SWEP.Primary.Delay          = 0.2
SWEP.Primary.Automatic      = false
SWEP.Primary.Cone           = 0
SWEP.Primary.Ammo           = nil
SWEP.Primary.ClipSize       = -1
SWEP.Primary.ClipMax        = -1
SWEP.Primary.DefaultClip    = -1
SWEP.Primary.Sound          = ""

SWEP.Secondary.Delay        = 0.2
SWEP.Secondary.Automatic    = false
SWEP.Secondary.Cone         = 0
SWEP.Secondary.Ammo         = nil
SWEP.Secondary.ClipSize     = -1
SWEP.Secondary.ClipMax      = -1
SWEP.Secondary.DefaultClip  = -1
SWEP.Secondary.Sound        = ""

SWEP.InLoadoutFor           = {ROLE_WHALEINNOCENT, ROLE_WHALEDETECTIVE, ROLE_WHALEINDEPENDENT, ROLE_WHALEJESTER, ROLE_WHALEMONSTER, ROLE_WHALETRAITOR}
SWEP.InLoadoutForDefault    = {ROLE_WHALEINNOCENT, ROLE_WHALEDETECTIVE, ROLE_WHALEINDEPENDENT, ROLE_WHALEJESTER, ROLE_WHALEMONSTER, ROLE_WHALETRAITOR}

if SERVER then
    CreateConVar("ttt_innocentwhale_minimum_radius", "5", FCVAR_NONE, "The minimum radius of the whaleinnocent's device in meters. Set to 0 to disable", 0, 30)
end
local whaleinnocent_unguessable_roles = CreateConVar("ttt_innocentwhale_unguessable_roles", "", FCVAR_REPLICATED, "Names of roles that cannot be guessed by the whaleinnocent, separated with commas. Do not include spaces or capital letters.")

SWEP.RoleChangeTime = 3 -- seconds required to complete

local STATE_IDLE  = 0
local STATE_BUSY  = 1
local STATE_ERROR = 2
local STATE_DONE  = 3

function SWEP:SetupDataTables()
    self:NetworkVar("Int", 0, "State")
    self:NetworkVar("Float", 0, "BeginTime")
    self:NetworkVar("String", 0, "Message")
end

function SWEP:Initialize()
    self:SendWeaponAnim(ACT_SLAM_DETONATOR_DRAW)
    if CLIENT then
        self:AddHUDHelp("whalebuffettable_help_pri", "whalebuffettable_help_sec", true)
    end
    self:SetState(STATE_IDLE)
    return self.BaseClass.Initialize(self)
end

function SWEP:OnDrop()
    self:Remove()
end

function SWEP:Deploy()
    if SERVER and IsValid(self:GetOwner()) then
        self:GetOwner():DrawViewModel(false)
    end

    self:DrawShadow(false)
    self:SendWeaponAnim(ACT_SLAM_DETONATOR_DRAW)
    return true
end

if SERVER then

    util.AddNetworkString("RoleChange_Success")

    function SWEP:PrimaryAttack()
        if self:GetState() ~= STATE_IDLE then return end

        self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)


        local owner = self:GetOwner()
        if not IsValid(owner) then return end
        if owner:IsRoleAbilityDisabled() then return end
        local role = owner:GetNWInt("TTTInnocentWhaleSelection", ROLE_NONE)
        if role == ROLE_NONE then
            owner:QueueMessage(MSG_PRINTCENTER, "Select a role first!", 3)
            return
        else

            self:SetState(STATE_BUSY)
            self:SetBeginTime(CurTime())
            self:SetMessage("Changing role to " .. ROLE_STRINGS[role] .. "!")

            self:GetOwner():EmitSound("items/nvg_on.wav", 75, 100)
        end
    end

    function SWEP:Abort()
        self:SetState(STATE_ERROR)
        self:SetBeginTime(CurTime())
        self:SetMessage("Role change aborted!")

        timer.Simple(1.5, function()
            if IsValid(self) then
                self:SetState(STATE_IDLE)
            end
        end)
    end

    function SWEP:Success()

        local owner = self:GetOwner()
        if not IsValid(owner) then return end
        if owner:IsRoleAbilityDisabled() then return end
        local role = owner:GetNWInt("TTTInnocentWhaleSelection", ROLE_NONE)

        self:SetState(STATE_DONE)
        self:SetBeginTime(CurTime())
        self:SetMessage("Role changed successfully!")
        owner:QueueMessage(MSG_PRINTCENTER, "Role changed successfully to " .. ROLE_STRINGS[role] .. "!", 3)

        net.Start("RoleChange_Success")
        net.Send(self:GetOwner())

        timer.Simple(1.5, function()
            if IsValid(self) then
                self:SetState(STATE_IDLE)
            end
        end)

        owner:SetRole(role)
        owner:StripRoleWeapons()
        RunHook("PlayerLoadout", owner)
        SendFullStateUpdate()
        net.Start("TTT_InnocentWhaleGuessed")
        net.WriteBool(true)
        -- net.WriteString(ply:Nick())
        net.WriteString(owner:Nick())
        net.Broadcast()
        self:Remove()

        
    end

    function SWEP:Think()
        if self:GetState() ~= STATE_BUSY then return end

        local owner = self:GetOwner()
        if not IsValid(owner) or not owner:KeyDown(IN_ATTACK) then
            self:Abort()
            return
        end

        if CurTime() >= self:GetBeginTime() + self.RoleChangeTime then
            self:Success()
        end
    end

end


if CLIENT then
    function SWEP:DrawHUD()
        local baseClass = self.BaseClass
        while baseClass.ClassName ~= "weapon_tttbase" do
            baseClass = baseClass.BaseClass
        end
        baseClass.DrawHUD(self)

        local STATE_IDLE  = 0
        local STATE_BUSY  = 1
        local STATE_ERROR = 2
        local STATE_DONE  = 3

        local state = self:GetState()
        if state == STATE_IDLE then return end

        local charge = self.RoleChangeTime
        local time = self:GetBeginTime() + charge

        local x = ScrW() / 2.0
        local y = ScrH() / 2.0

        y = y + (y / 3)

        local w = 255

        if state == STATE_BUSY then
            if time < 0 then return end
            local progress = math.min(1, 1 - ((time - CurTime()) / charge))
            CRHUD:PaintProgressBar(
                x,
                y,
                w,
                Color(0, 255, 0, 155),
                self:GetMessage(),
                progress
            )

        elseif state == STATE_ERROR then
            CRHUD:PaintProgressBar(
                x,
                y,
                w,
                Color(200 + math.sin(CurTime() * 32) * 50, 0, 0, 155),
                self:GetMessage(),
                1
            )

        elseif state == STATE_DONE then
            CRHUD:PaintProgressBar(
                x,
                y,
                w,
                Color(0, 255, 0, 155),
                self:GetMessage(),
                1
            )
        end
    end

    function SWEP:PrimaryAttack() return false end
end



function SWEP:SecondaryAttack()
    if not IsFirstTimePredicted() then return end
    self:SetNextSecondaryFire(CurTime() + self.Secondary.Delay)
    if CLIENT then
        local function AddRolesFromTeam(tbl, team)
            local bannedRoles = {}
            local bannedRolesString = whaleinnocent_unguessable_roles:GetString()
            if #bannedRolesString > 0 then
                bannedRoles = string.Explode(",", bannedRolesString)
            end
            local roles = {}
            for role = 3, ROLE_MAX do -- Skip over the three default roles as they will be added later to avoid sorting
                if role == ROLE_INNOCENT or TableHasValue(bannedRoles, ROLE_STRINGS_RAW[role]) then
                    continue
                elseif (ROLE_STARTING_TEAM[role] == team or (not ROLE_STARTING_TEAM[role] and player.GetRoleTeam(role, false) == team)) and util.CanRoleSpawn(role) then
                    TableInsert(roles, role)
                end
            end
            TableSort(roles, function(a, b) return StringLower(ROLE_STRINGS[a]) < StringLower(ROLE_STRINGS[b]) end)
            for _, role in pairs(roles) do
                TableInsert(tbl, role)
            end
        end

        local owner = self:GetOwner()

        local detectives = {}
        local innocents = {}
        local traitors = {}
        local jesters = {}
        local independents = {}
        local monsters = {}

        if owner:IsDetectiveTeam() then
            TableInsert(detectives, ROLE_DETECTIVE)
            AddRolesFromTeam(detectives, ROLE_TEAM_DETECTIVE)
        elseif owner:IsInnocentTeam() then
            TableInsert(innocents, ROLE_INNOCENT)
            AddRolesFromTeam(innocents, ROLE_TEAM_INNOCENT)
        elseif owner:IsTraitorTeam() then
            TableInsert(traitors, ROLE_TRAITOR)
            AddRolesFromTeam(traitors, ROLE_TEAM_TRAITOR)
        elseif owner:IsJesterTeam() then
            AddRolesFromTeam(jesters, ROLE_TEAM_JESTER)
        elseif owner:IsIndependentTeam() then
            AddRolesFromTeam(independents, ROLE_TEAM_INDEPENDENT)
        else
            AddRolesFromTeam(monsters, ROLE_TEAM_MONSTER)
        end

        local largestTeam       = MathMax(#detectives, #innocents, #traitors, #jesters, #independents, #monsters)
        local columns           = MathClamp(largestTeam, 4, 8)
        local detectiveRows     = MathCeil(#detectives / columns)
        local innocentRows      = MathCeil(#innocents / columns)
        local traitorRows       = MathCeil(#traitors / columns)
        local jesterRows        = MathCeil(#jesters / columns)
        local independentRows   = MathCeil(#independents / columns)
        local monsterRows       = MathCeil(#monsters / columns)

        local function IsLabelNeeded(tbl)
            return #tbl == 0 and 0 or 1
        end

        local labels = IsLabelNeeded(detectives) + IsLabelNeeded(innocents) + IsLabelNeeded(traitors)
                        + IsLabelNeeded(jesters) + IsLabelNeeded(independents) + IsLabelNeeded(monsters)

        local itemSize      = 64
        local headingHeight = 22
        local searchHeight  = 25
        local labelHeight   = 16
        local m             = 5

        -- list sizes
        local listWidth             = (itemSize + 2) * columns
        local detectivesHeight      = MathMax((itemSize + 2) * detectiveRows + 2, 0)
        local innocentsHeight       = MathMax((itemSize + 2) * innocentRows + 2, 0)
        local traitorsHeight        = MathMax((itemSize + 2) * traitorRows + 2, 0)
        local jestersHeight         = MathMax((itemSize + 2) * jesterRows + 2, 0)
        local independentsHeight    = MathMax((itemSize + 2) * independentRows + 2, 0)
        local monstersHeight        = MathMax((itemSize + 2) * monsterRows + 2, 0)

        -- I worked this out from looking at screenshots and measuring how the bottom margin changes based on the number of labels. I don't know why this is needed or where these numbers come from!
        local bottomMarginOffset = (2 * labels) - 7

        -- frame size
        local w = listWidth + (m * 2) + 2 -- For some reason the icons aren't centred horizontally so add 2px
        local h = detectivesHeight + innocentsHeight + traitorsHeight + jestersHeight + independentsHeight + monstersHeight
                + (labelHeight * labels) + (m * 2) + headingHeight + searchHeight + bottomMarginOffset

        local dframe = vgui.Create("DFrame")
        dframe:SetSize(w, h)
        dframe:Center()
        dframe:SetTitle(GetTranslation("whalebuffettable_title"))
        dframe:SetVisible(true)
        dframe:ShowCloseButton(true)
        dframe:SetMouseInputEnabled(true)
        dframe:SetDeleteOnClose(true)

        local dsearch = vgui.Create("DTextEntry", dframe)
        dsearch:SetPos(m + 2, m + headingHeight + 2) -- For some reason this is 2px higher than it should be so shift it down, also undo the extra width added above
        dsearch:SetSize(listWidth - 2, searchHeight)
        dsearch:SetPlaceholderText("Search...")
        dsearch:SetUpdateOnType(true)
        dsearch.OnGetFocus = function() dframe:SetKeyboardInputEnabled(true) end
        dsearch.OnLoseFocus = function() dframe:SetKeyboardInputEnabled(false) end

        local panelList = {}

        local function CreateTeamList(label, roleTable, height, yOffset)
            local dlabel = vgui.Create("DLabel", dframe)
            dlabel:SetFont("TabLarge")
            dlabel:SetText(label)
            dlabel:SetContentAlignment(7)
            dlabel:SetWidth(listWidth)
            dlabel:SetPos(m + 3, yOffset) -- For some reason the text isn't in line with the icons so we shift it 3px to the right

            local dlist = vgui.Create("EquipSelect", dframe)
            dlist:SetPos(m, yOffset + labelHeight)
            dlist:SetSize(listWidth, height)
            dlist:EnableHorizontal(true)

            for _, role in pairs(roleTable) do
                local ic = vgui.Create("SimpleIcon", dlist)

                local roleStringShort = ROLE_STRINGS_SHORT[role]
                local material = util.GetRoleIconPath(roleStringShort, "icon", "vtf")

                local color = ROLE_COLORS[role]
                if not DEFAULT_ROLES[role] and ROLE_STARTING_TEAM[role] then
                    color = GetRoleTeamColor(ROLE_STARTING_TEAM[role])
                end

                ic:SetIconSize(itemSize)
                ic:SetIcon(material)
                ic:SetBackgroundColor(color or Color(0, 0, 0, 0))
                ic:SetTooltip(ROLE_STRINGS[role])
                ic.role = role
                ic.enabled = true

                TableInsert(panelList, ic)

                dlist:AddPanel(ic)
            end

            dlist.OnActivePanelChanged = function(_, _, new)
                if new.enabled then
                    net.Start("TTT_InnocentWhaleSelectRole")
                    net.WriteInt(new.role, util.RoleBits())
                    net.SendToServer()
                    dframe:Close()
                end
            end
        end

        local yOffset = m * 2 + headingHeight + searchHeight
        if #detectives > 0 then
            CreateTeamList("Detective Roles", detectives, detectivesHeight, yOffset)
            yOffset = yOffset + detectivesHeight + labelHeight
        end
        if #innocents > 0 then
            CreateTeamList("Innocent Roles", innocents, innocentsHeight, yOffset)
            yOffset = yOffset + innocentsHeight + labelHeight
        end
        if #traitors > 0 then
            CreateTeamList("Traitor Roles", traitors, traitorsHeight, yOffset)
            yOffset = yOffset + traitorsHeight + labelHeight
        end
        if #jesters > 0 then
            CreateTeamList("Jester Roles", jesters, jestersHeight, yOffset)
            yOffset = yOffset + jestersHeight + labelHeight
        end
        if #independents > 0 then
            CreateTeamList("Independent Roles", independents, independentsHeight, yOffset)
            yOffset = yOffset + independentsHeight + labelHeight
        end
        if #monsters > 0 then
            CreateTeamList("Monster Roles", monsters, monstersHeight, yOffset)
        end

        dsearch.OnValueChange = function(_, value)
            local query = StringLower(value:gsub("[%p%c%s]", ""))
            for _, panel in pairs(panelList) do
                if StringFind(ROLE_STRINGS_RAW[panel.role], query, 1, true) or (value and #value == 0) then
                    panel:SetIconColor(COLOR_WHITE)
                    panel:SetBackgroundColor(ROLE_COLORS[panel.role])
                    panel.enabled = true
                else
                    panel:SetIconColor(COLOR_LGRAY)
                    panel:SetBackgroundColor(ROLE_COLORS_DARK[panel.role])
                    panel.enabled = false
                end
            end
        end

        dframe:MakePopup()
        dframe:SetKeyboardInputEnabled(false)
    end
end
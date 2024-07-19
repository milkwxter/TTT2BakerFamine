if SERVER then
    AddCSLuaFile()
	--resource.AddWorkshop("")
end

DEFINE_BASECLASS("weapon_tttbase")

SWEP.HoldType = "normal"

if CLIENT then
    SWEP.PrintName = "Bread Baker"
    SWEP.Slot = 6

    SWEP.ShowDefaultViewModel = false

    SWEP.EquipMenuData = {
        type = "item_weapon",
        desc = "Bake bread to create a Famine. Crazy how that works.",
    }

    SWEP.Icon = "vgui/ttt/icon_bread"
end

SWEP.Base = "weapon_tttbase"

SWEP.ViewModel = "models/weapons/c_items/c_bread_cinnamon.mdl"
SWEP.WorldModel = "models/weapons/c_items/c_bread_cinnamon.mdl"

SWEP.Primary.ClipSize = 10
SWEP.Primary.DefaultClip = 10
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "none"
SWEP.Primary.Delay = 3

-- This is special equipment
SWEP.Kind = WEAPON_EQUIP
SWEP.CanBuy = { } -- only detectives can buy
SWEP.LimitedStock = true -- only buyable once

SWEP.AllowDrop = false
SWEP.NoSights = true

SWEP.drawColor = Color(180, 180, 250, 255)

---
-- @ignore
function SWEP:PrimaryAttack()
    self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)

    if SERVER then
        local bread = ents.Create("baker_bread")

        if bread:ThrowEntity(self:GetOwner(), Angle(90, -90, 0)) then
            self:TakePrimaryAmmo(1)
        end
    end
end

function SWEP:SecondaryAttack()
    self:GetOwner():SetRole(ROLE_FAMINE, TEAM_HORSEMEN)
end

---
-- @ignore
function SWEP:Reload()
    return false
end

---
-- @realm shared
function SWEP:Initialize()
    if CLIENT then
        self:AddTTT2HUDHelp("Bake some bread.", "Turn into the Famine.")
    end

    self:SetColor(self.drawColor)

    return BaseClass.Initialize(self)
end

if CLIENT then
    ---
    -- @realm client
    function SWEP:DrawWorldModel()
        if IsValid(self:GetOwner()) then
            return
        end

        self:DrawModel()
    end

    ---
    -- @realm client
    function SWEP:DrawWorldModelTranslucent() end
end
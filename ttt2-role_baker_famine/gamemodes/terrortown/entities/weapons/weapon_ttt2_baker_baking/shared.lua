if SERVER then
    AddCSLuaFile()
	util.AddNetworkString("ttt2_role_baker_force_start_famine")
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

-- local ammoamount = GetConVar("ttt2_role_baker_ammo"):GetInt()

SWEP.Primary.ClipSize = GetConVar("ttt2_role_baker_ammo"):GetInt()
SWEP.Primary.DefaultClip = GetConVar("ttt2_role_baker_ammo"):GetInt()
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "none"
SWEP.Primary.Delay = 1

-- This is special equipment
SWEP.Kind = WEAPON_EQUIP
SWEP.CanBuy = { } -- only detectives can buy
SWEP.LimitedStock = true -- only buyable once

SWEP.AllowDrop = false
SWEP.NoSights = true

---
-- @ignore
function SWEP:PrimaryAttack()
	if not self:CanPrimaryAttack() then return end
    self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
	if SERVER then
        local bread = ents.Create("baker_bread")

        if bread:ThrowEntity(self:GetOwner(), Angle(90, -90, 0)) then
            self:TakePrimaryAmmo(1)
        end
    end
end

function SWEP:SecondaryAttack()
	if CLIENT then
		net.Start("ttt2_role_baker_force_start_famine")
		net.SendToServer()
	end
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
        self:AddTTT2HUDHelp("Bake some bread.", "Force the famine to start.")
    end

    return BaseClass.Initialize(self)
end
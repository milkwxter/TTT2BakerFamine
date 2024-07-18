if SERVER then
    AddCSLuaFile()
end

DEFINE_BASECLASS("ttt_base_placeable")

if CLIENT then
    ENT.PrintName = "Delicious bread"
end

ENT.Base = "ttt_base_placeable"
ENT.Model = "models/weapons/c_items/c_bread_cinnamon.mdl"

ENT.CanHavePrints = true
ENT.MaxStored = 1

ENT.NextHeal = 0
ENT.HealRate = 1
ENT.HealFreq = 0.2

---
-- @realm shared
function ENT:SetupDataTables()
    BaseClass.SetupDataTables(self)

    self:NetworkVar("Int", 0, "StoredHealth")
end

---
-- @realm shared
function ENT:Initialize()
    self:SetModel(self.Model)

    BaseClass.Initialize(self)

    local b = 32

    self:SetCollisionBounds(Vector(-b, -b, -b), Vector(b, b, b))

    if SERVER then
        local phys = self:GetPhysicsObject()
        if IsValid(phys) then
            phys:SetMass(200)
        end

        self:SetUseType(SIMPLE_USE)
    end

    self:SetHealth(100)
end

local soundHealing = Sound("plate_in.mp3")

if SERVER then
    ---
    -- @param Player ply
    -- @realm server
    function ENT:Use(ply)
        if not IsValid(ply) or not ply:IsPlayer() or not ply:IsActive() then return end

        self:EmitSound(soundHealing)
        ply:SetHealth(ply:Health() + 50)
    end
else
    local TryT = LANG.TryTranslation
    local ParT = LANG.GetParamTranslation

    local key_params = {
        usekey = Key("+use", "USE"),
        walkkey = Key("+walk", "WALK"),
    }

    ---
    -- Hook that is called if a player uses their use key while focusing on the entity.
    -- Early check if client can use the health station
    -- @return bool True to prevent pickup
    -- @realm client
    function ENT:ClientUse()
        local client = LocalPlayer()

        if not IsValid(client) or not client:IsPlayer() or not client:IsActive() then
            return true
        end
    end

    -- handle looking at healthstation
    hook.Add("TTTRenderEntityInfo", "HUDDrawTargetIDBread", function(tData)
        local client = LocalPlayer()
        local ent = tData:GetEntity()

        if
            not IsValid(client)
            or not client:IsTerror()
            or not client:Alive()
            or not IsValid(ent)
            or tData:GetEntityDistance() > 100
            or ent:GetClass() ~= "ttt2_baker_bread"
        then
            return
        end

        -- enable targetID rendering
        tData:EnableText()
        tData:EnableOutline()
        tData:SetOutlineColor(client:GetRoleColor())

        tData:SetTitle(TryT(ent.PrintName))
        tData:SetSubtitle("Press [E] to eat the bread.")

        local hstation_charge = ent:GetStoredHealth() or 0

        tData:AddDescriptionLine("Bread will heal you, and save you from the Famine.")
    end)
end
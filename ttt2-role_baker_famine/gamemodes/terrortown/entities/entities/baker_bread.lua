if SERVER then
    AddCSLuaFile()
end

DEFINE_BASECLASS("ttt_base_placeable")

if CLIENT then
    ENT.PrintName = "Delicious bread"
end

ENT.Base = "ttt_base_placeable"
ENT.Model = "models/weapons/c_items/c_bread_cinnamon.mdl"

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
            phys:SetMass(50)
        end

        self:SetUseType(SIMPLE_USE)
    end
end

local soundBreadEat = Sound("eating_bread.wav")

if SERVER then
    ---
    -- @param Player ply
    -- @realm server
    function ENT:Use(ply)
        if not IsValid(ply) or not ply:IsPlayer() or not ply:IsActive() then return end
        self:EmitSound(soundBreadEat)
		hook.Run("EVENT_BREAD_CONSUME")
		if ply:Health() > 50 then
			ply:SetHealth(100)
		else
			ply:SetHealth(ply:Health() + 50)
		end
        self:Remove()
		
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
    -- Early check if client can use the bread
    -- @return bool True to prevent pickup
    -- @realm client
    function ENT:ClientUse()
        local client = LocalPlayer()

        if not IsValid(client) or not client:IsPlayer() or not client:IsActive() then
            return true
        end
    end

    -- handle looking at bread
    hook.Add("TTTRenderEntityInfo", "HUDDrawTargetIDBread", function(tData)
        local client = LocalPlayer()
        local ent = tData:GetEntity()

        if
            not IsValid(client)
            or not client:IsTerror()
            or not client:Alive()
            or not IsValid(ent)
            or tData:GetEntityDistance() > 100
            or ent:GetClass() ~= "baker_bread"
        then
            return
        end

        -- enable targetID rendering
        tData:EnableText()
        tData:EnableOutline()
        tData:SetOutlineColor(client:GetRoleColor())

        tData:SetTitle(TryT(ent.PrintName))
        tData:SetSubtitle("Press [E] to eat the bread.")

        tData:AddDescriptionLine("Bread will heal you, and save you from the Famine.")
    end)
end
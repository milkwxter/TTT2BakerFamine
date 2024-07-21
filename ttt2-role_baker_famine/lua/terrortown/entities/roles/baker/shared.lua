if SERVER then
	AddCSLuaFile()
	resource.AddFile("materials/vgui/ttt/dynamic/roles/icon_baker.vmt")
end

roles.InitCustomTeam("Horsemen", {
	icon = "vgui/ttt/dynamic/roles/icon_horseman",
	color = Color(113, 113, 113, 255)
})

function ROLE:PreInitialize()
    self.color                      = Color(161, 91, 35, 255)

    self.abbr                       = "baker"
    self.surviveBonus               = 3
    self.score.killsMultiplier      = 2
    self.score.teamKillsMultiplier  = -8
    self.preventFindCredits         = true
    self.preventKillCredits         = true
    self.preventTraitorAloneCredits = true
    self.preventWin                 = false -- Can he win on his own? true means NO, false means YES
    self.unknownTeam                = false
	self.isOmniscientRole = true -- see missing in action players & haste time if true

    self.defaultTeam                = TEAM_HORSEMEN

    self.conVarData = {
        pct          = 0.15, -- necessary: percentage of getting this role selected (per player)
        maximum      = 1, -- maximum amount of roles in a round
        minPlayers   = 7, -- minimum amount of players until this role is able to get selected
        togglable    = true, -- option to toggle a role for a client if possible (F1 menu)
        random       = 33
    }
end

if SERVER then
	-- Give Loadout on respawn and rolechange
	function ROLE:GiveRoleLoadout(ply, isRoleChange)
        ply:GiveEquipmentWeapon("weapon_ttt2_baker_baking")
	end

	-- Remove Loadout on death and rolechange
	function ROLE:RemoveRoleLoadout(ply, isRoleChange)
        ply:StripWeapon("weapon_ttt2_baker_baking")
	end
end

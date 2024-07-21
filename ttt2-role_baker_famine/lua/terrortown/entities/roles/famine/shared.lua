if SERVER then
	AddCSLuaFile()
	resource.AddFile("materials/vgui/ttt/dynamic/roles/icon_famine.vmt")
end

function ROLE:PreInitialize()
    self.color                      = Color(185, 163, 72, 255)

    self.abbr                       = "fam"
    self.surviveBonus               = 3
    self.score.killsMultiplier      = 2
    self.score.teamKillsMultiplier  = -8
    self.preventFindCredits         = true
    self.preventKillCredits         = true
    self.preventTraitorAloneCredits = true
    self.preventWin                 = false -- Can he win on his own? true means NO, false means YES
    self.unknownTeam                = false
	self.isOmniscientRole = true
	
	-- role cant spawn naturally
	self.notSelectable = true

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
        -- save original player model
		self.famineOriginalModel = ply:GetModel()
        -- give new skeleton model
		ply:SetModel( "models/player/skeleton.mdl" )
		-- add extra health
		ply:SetMaxHealth(175 + (BREAD_DATA:GetEatenAmount() * 25))
		ply:SetHealth(175 + (BREAD_DATA:GetEatenAmount() * 25))
	end

	-- Remove Loadout on death and rolechange
	function ROLE:RemoveRoleLoadout(ply, isRoleChange)
		-- reduce health if more than 100
		ply:SetMaxHealth(100)
		if ply:Health() > 100 then
			ply:SetHealth(100)
		end
        -- give back original model
		ply:SetModel( famineOriginalModel )
	end
end

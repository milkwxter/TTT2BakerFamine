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
	self.isOmniscientRole = true -- see missing in action players & haste time if true
	
	-- role cant spawn naturally
	self.notSelectable = true

    self.defaultTeam                = TEAM_HORSEMEN

    self.conVarData = {
        pct          = 0.15, -- necessary: percentage of getting this role selected (per player)
        maximum      = 1, -- maximum amount of roles in a round
        minPlayers   = 6, -- minimum amount of players until this role is able to get selected
        togglable    = false, -- option to toggle a role for a client if possible (F1 menu)
        random       = 0
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
		ply:SetMaxHealth(GetConVar("ttt2_role_famine_starting_health"):GetInt() + (BREAD_DATA:GetEatenAmount() * GetConVar("ttt2_role_famine_bread_health"):GetInt()))
		ply:SetHealth(GetConVar("ttt2_role_famine_starting_health"):GetInt() + (BREAD_DATA:GetEatenAmount() * GetConVar("ttt2_role_famine_bread_health"):GetInt()))
	end

	-- Remove Loadout on death and rolechange
	function ROLE:RemoveRoleLoadout(ply, isRoleChange)
		-- reduce health if more than 100
		ply:SetMaxHealth(100)
		if ply:Health() > 100 then
			ply:SetHealth(100)
		end
        -- give back original model
		ply:SetModel( self.famineOriginalModel )
	end
end



--adds convars to F1 Menu
if CLIENT then
    function ROLE:AddToSettingsMenu(parent)
        local form = vgui.CreateTTT2Form(parent, "header_roles_additional")
		

		form:MakeSlider({
            serverConvar = "ttt2_role_famine_bread_spawn_amount",
            label = "Amount of bread that naturally spawns around the map: ",
            min = 5,
            max = 100,
            decimal = 0,
        })
		
		form:MakeSlider({
            serverConvar = "ttt2_role_famine_starting_health",
            label = "Amount of health the famine starts with: ",
            min = 100,
            max = 300,
            decimal = 0,
        })
		
		form:MakeSlider({
            serverConvar = "ttt2_role_famine_bread_health",
            label = "Health the famine gains when someone eats their bread: ",
            min = 1,
            max = 100,
            decimal = 0,
        })
		
		
		
    end
end
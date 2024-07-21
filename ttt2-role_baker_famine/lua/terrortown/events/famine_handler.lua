-- Welcome to the Famine handler.

-- ---------------------------------------- --
--                BREAD DATA                --
-- ---------------------------------------- --
BREAD_DATA = {}
BREAD_DATA.amount_eaten = 0
BREAD_DATA.amount_to_famine = 3
BREAD_DATA.famine_exists = false
BREAD_DATA.starving_players = {}

-- reset hooks at round end AND start
hook.Add("TTTEndRound", "BakerEndRound", function()
	BREAD_DATA.amount_eaten = 0
	BREAD_DATA.starving_players = player.GetAll()
	timer.Stop("ttt2_famine_starve_timer")
end)

hook.Add("TTTBeginRound", "BakerBeginRound", function()
    BREAD_DATA.amount_eaten = 0
	BREAD_DATA.starving_players = player.GetAll()
	timer.Stop("ttt2_famine_starve_timer")
end)

-- ---------------------------------------- --
--                 STATUSES                 --
-- ---------------------------------------- --

if CLIENT then
	hook.Add("Initialize", "ttt2_baker_init", function()
		STATUS:RegisterStatus("ttt2_ate_bread", {
			hud = Material("vgui/ttt/dynamic/roles/icon_baker.vmt"),
			type = "good",
			name = "Well-Fed",
			sidebarDescription = "You will not take starving damage during the Famine."
		})
	end)
end

-- ---------------------------------------- --
--           GETTERS & SETTERS              --
-- ---------------------------------------- --

function BREAD_DATA:AddEaten()
	self.amount_eaten = self.amount_eaten + 1
end

function  BREAD_DATA:GetEatenAmount()
    return self.amount_eaten
end

function  BREAD_DATA:GetAmountToFamine()
	return self.amount_to_famine
end

-- ---------------------------------------- --
--                  NETWORKING              --
-- ---------------------------------------- --

-- required for networking
if SERVER then
    util.AddNetworkString("ttt2_role_baker_update")
end

-- server syncing to client
if CLIENT then
	net.Receive("ttt2_role_baker_update", function()
		BREAD_DATA.amount_eaten = net.ReadUInt(16)
	end)
end

-- ---------------------------------------- --
--           IMPORTANT FUNCTIONS            --
-- ---------------------------------------- --

local function spawnBreadsAroundMap()
	-- limit by defined max and found items
	local amount = math.min(#ents.FindByClass("item_*"), 10)

	-- make sure more than 0 sodas can be spawned
	if amount == 0 then return end

	local spawns = ents.FindByClass("item_*")
	for i = 1, amount do
		-- research since one item was replaced
		local index = math.random(#spawns)
		local spwn = spawns[index]
		local spwn_name = spwn:GetClass()
		local soda = ents.Create("baker_bread")

		soda:SetPos(spwn:GetPos())
		soda:Spawn()
		spwn:Remove()
		table.remove(spawns, index)
		local newSpwn = ents.Create(spwn_name)

		newSpwn:SetPos(soda:GetPos() + Vector(20, 20, 0))
		newSpwn:Spawn()
	end
end

local function starveCurrentPlayers()
	-- make sure round is active
    if GetRoundState() ~= ROUND_ACTIVE then return end
	-- make sure famine has spawned
	if BREAD_DATA.famine_exists == false then return end

	-- iterate through all players
    for _, ply in ipairs(BREAD_DATA.starving_players) do
		-- make sure we only starve living and playing players
      	if not ply:Alive() or ply:IsSpec() then continue end
	  	-- dont starve the horsemen lol
	  	if ply:GetTeam() == TEAM_HORSEMEN then continue end

		-- make that guy starve a little
    	ply:TakeDamage(5, game.GetWorld())
    end
end

-- function that starts the famine
function startFamine()
	--iterate through players, find the baker to transform him
	for _, ply in ipairs( player.GetAll() ) do
		-- check if player is valid
		if not IsValid(ply) then return end
		-- if so, go update his role
		if ply:GetSubRole() == ROLE_BAKER then
			-- update his role
			ply:SetRole(ROLE_FAMINE, TEAM_HORSEMEN)
			if SERVER then
				SendFullStateUpdate()
			end
		end
	end
	
	-- tell server that the famine has spawned
	BREAD_DATA.famine_exists = true
	
	-- tell every client that the famine has spawned
	if SERVER then
		EPOP:AddMessage(nil, "The Famine has arrived.", "Find and eat bread or else you will starve.", 6, nil, true)
	end
	
	-- spawn extra bread
	spawnBreadsAroundMap()

	-- start the starving timer
	timer.Create("ttt2_famine_starve_timer", 5, 0, function()
		starveCurrentPlayers()
	end)
end

-- function that increases eaten counter
local function incBreadCounter()
	-- increase amount eaten
	BREAD_DATA:AddEaten()

	--sync to client
    net.Start("ttt2_role_baker_update")
    net.WriteUInt(BREAD_DATA.amount_eaten, 16)
    net.Broadcast()

	--iterate through players, find the famine
	for _, ply in ipairs( player.GetAll() ) do
		-- check if player is valid
		if not IsValid(ply) then return end
		-- if so, update his health
		if ply:GetSubRole() == ROLE_FAMINE then
			-- add extra health
			ply:SetMaxHealth(ply:GetMaxHealth() + 25)
			ply:SetHealth(ply:Health() + 25)
		end
	end

	-- check if famine exists, and if so heal him too
	if famine_exists then
		--iterate through players, find the famine
		for _, ply in ipairs( player.GetAll() ) do
			-- check if player is valid
			if not IsValid(ply) then return end
			-- if so, update his health
			if ply:GetSubRole() == ROLE_FAMINE then
				-- add extra health
				ply:SetMaxHealth(ply:GetMaxHealth() + 25)
				ply:SetHealth(ply:Health() + 25)
			end
		end
	end
	
	-- check if amount eaten causes a famine and no famine currently exists
	if BREAD_DATA:GetEatenAmount() >= BREAD_DATA:GetAmountToFamine() and BREAD_DATA.famine_exists == false then
		startFamine()
	end

	-- end of function
	return
end

--local function called in hook
if SERVER then
    hook.Add("EVENT_BREAD_CONSUME", "ttt_increase_bread_counter", incBreadCounter)
end
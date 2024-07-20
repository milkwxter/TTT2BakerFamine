BREAD_DATA = {}
BREAD_DATA.amount_eaten = 0
BREAD_DATA.amount_to_famine = 3
BREAD_DATA.famine_exists = false

if SERVER then
    util.AddNetworkString("ttt2_role_baker_update")
end

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



function BREAD_DATA:AddEaten()
	self.amount_eaten = self.amount_eaten + 1
end

function  BREAD_DATA:GetEatenAmount()
    return self.amount_eaten
end

function  BREAD_DATA:GetAmountToFamine()
	return self.amount_to_famine
end

-- server syncing to client
if CLIENT then
	net.Receive("ttt2_role_baker_update", function()
		BREAD_DATA.amount_eaten = net.ReadUInt(16)
	end)
end

--function that increase eaten counter
local function incBreadCounter()
	-- increase amount eaten
	BREAD_DATA:AddEaten()

	--sync to client
    net.Start("ttt2_role_baker_update")
    net.WriteUInt(BREAD_DATA.amount_eaten, 16)
    net.Broadcast()

	-- check if amount eaten causes a famine and no famine currently exists
	if BREAD_DATA:GetEatenAmount() >= BREAD_DATA:GetAmountToFamine() and BREAD_DATA.famine_exists == false then
		--iterate through players, find the baker
		for _, ply in ipairs( player.GetAll() ) do
			-- check if player is valid
			if not IsValid(ply) then return end
			-- if so, update his role
			if ply:GetSubRole() == ROLE_BAKER then
				-- update his role
				ply:SetRole(ROLE_FAMINE, TEAM_HORSEMEN)
				SendFullStateUpdate()
				-- add extra health
				ply:SetHealth(200 + (BREAD_DATA:GetEatenAmount() * 25))
			end
		end
		-- do more stuff
		BREAD_DATA.famine_exists = true
		if SERVER then
			EPOP:AddMessage(nil, "The Famine has arrived.", "Find and eat bread or else you will starve.", 6, nil, true)
		end
	end
end

--local function called in hook
if SERVER then
    hook.Add("EVENT_BREAD_CONSUME", "ttt_increase_bread_counter", incBreadCounter)
end

-- reset hooks at round end AND start
hook.Add("TTTEndRound", "BakerEndRound", function()
	BREAD_DATA.amount_eaten = 0
end)

hook.Add("TTTBeginRound", "BakerBeginRound", function()
    BREAD_DATA.amount_eaten = 0
end)
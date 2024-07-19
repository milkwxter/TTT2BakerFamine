BREAD_DATA = {}
BREAD_DATA.amount_eaten = 0
BREAD_DATA.amount_to_famine = 2

function BREAD_DATA:AddEaten()
	self.amount_eaten = self.amount_eaten + 1
end

function  BREAD_DATA:GetEatenAmount()
    return self.amount_eaten
end

function  BREAD_DATA:GetAmountToFamine()
	return self.amount_to_famine
end

--function that increase eaten counter
local function incBreadCounter()
	BREAD_DATA:AddEaten()
	if(BREAD_DATA:GetEatenAmount() >= BREAD_DATA:GetAmountToFamine()) then
		--iterate through players, find the baker
		for _, ply in ipairs( player.GetAll() ) do
		-- check if player is valid
		if not IsValid(ply) then return end
			if ply:GetRoleString() == "baker" then
				ply:SetRole(ROLE_FAMINE)
				SendFullStateUpdate()
			end
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
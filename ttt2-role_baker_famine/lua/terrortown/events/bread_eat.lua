BREAD_DATA = {}
BREAD_DATA.amount_eaten = 0
BREAD_DATA.amount_to_famine = 5

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
		--START FAMINE CODE GOES HERE
		if SERVER then
			print("Start famine now!")
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
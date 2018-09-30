local F, C = unpack(select(2, ...))

if not C.misc.cooldownpulse then return end

-- Based on Doom Cooldown Pulse
-- Flash an ability's icon in the middle of the screen when it comes off cooldown.
-- Woffle of Dark Iron[US]

local GetTime = GetTime
local fadeInTime, fadeOutTime, maxAlpha, elapsed, runtimer = 0.3, 0.7, 1, 0, 0
local animScale, iconSize, holdTime, threshold = 1.5, 50, 0, 8
local cooldowns, animating, watching = {}, {}, {}

local anchor = CreateFrame("Frame", "cooldownpulseAnchor", UIParent)
anchor:SetSize(50, 50)
anchor:SetPoint("CENTER",UIParent,"CENTER" ,0 ,100)

local frame = CreateFrame("Frame", "cooldownpulseFrame", anchor)
frame:SetScript("OnEvent", function(self, event, ...) self[event](self, ...) end)
frame:SetPoint("CENTER", anchor, "CENTER")

local icon = frame:CreateTexture(nil, "BORDER")
icon:SetTexCoord(unpack(C.texCoord))
icon:SetAllPoints(frame)

local bg = frame:CreateTexture(nil, "BACKGROUND")
bg:SetPoint("TOPLEFT", -1, 1)
bg:SetPoint("BOTTOMRIGHT", 1, -1)
bg:SetTexture(C.media.backdrop)
bg:SetVertexColor(0, 0, 0)

local sd = CreateFrame("Frame", nil, frame)
sd:SetBackdrop({edgeFile = C.media.glowtex, edgeSize = 4})
sd:SetPoint("TOPLEFT", -4, 4)
sd:SetPoint("BOTTOMRIGHT", 4, -4)
sd:SetBackdropBorderColor(0, 0, 0, .5)



local ignored_spells = {
	--GetSpellInfo(6807),	-- Maul
	--GetSpellInfo(35395),	-- Crusader Strike
}


-- Utility Functions
local function tcount(tab)
	local n = 0
	for _ in pairs(tab) do
		n = n + 1
	end
	return n
end

local function GetPetActionIndexByName(name)
	for i=1, NUM_PET_ACTION_SLOTS, 1 do
		if (GetPetActionInfo(i) == name) then
			return i
		end
	end
	return nil
end


-- Cooldown / Animation
local function OnUpdate(_,update)
	elapsed = elapsed + update
	if (elapsed > 0.05) then
		for i,v in pairs(watching) do
			if (GetTime() >= v[1] + 0.5) then
				local start, duration, enabled, texture, isPet, name
				if (v[2] == "spell") then
					name = GetSpellInfo(v[3])
					texture = GetSpellTexture(v[3])
					start, duration, enabled = GetSpellCooldown(v[3])
				elseif (v[2] == "item") then
					name = GetItemInfo(i)
					texture = v[3]
					start, duration, enabled = GetItemCooldown(i)
				elseif (v[2] == "pet") then
					name, texture = GetPetActionInfo(v[3])
					start, duration, enabled = GetPetActionCooldown(v[3])
					isPet = true
				end

				if ignored_spells[name] then
					watching[i] = nil
				else
					if (enabled ~= 0) then
						if (duration and duration > 2.0 and texture) then
							cooldowns[i] = { start, duration, texture, isPet, name }
						end
					end
					if (not (enabled == 0 and v[2] == "spell")) then
						watching[i] = nil
					end
				end
			end
		end
		for i,v in pairs(cooldowns) do
			local remaining = v[2]-(GetTime()-v[1])
			if (remaining <= 0) then
				tinsert(animating, {v[3],v[4],v[5]})
				cooldowns[i] = nil
			end
		end
		
		elapsed = 0
		if (#animating == 0 and tcount(watching) == 0 and tcount(cooldowns) == 0) then
			frame:SetScript("OnUpdate", nil)
			return
		end
	end
	
	if (#animating > 0) then
		runtimer = runtimer + update
		if (runtimer > (fadeInTime + holdTime + fadeOutTime)) then
			tremove(animating,1)
			runtimer = 0
			icon:SetTexture(nil)
			bg:Hide()
			sd:Hide()
		else
			if not icon:GetTexture() then
				icon:SetTexture(animating[1][1])
			end
			local alpha = maxAlpha
			if (runtimer < fadeInTime) then
				alpha = maxAlpha * (runtimer / fadeInTime)
			elseif (runtimer >= fadeInTime + holdTime) then
				alpha = maxAlpha - ( maxAlpha * ((runtimer - holdTime - fadeInTime) / fadeOutTime))
			end
			frame:SetAlpha(alpha)
			local scale = iconSize+(iconSize*((animScale-1)*(runtimer/(fadeInTime+holdTime+fadeOutTime))))
			frame:SetWidth(scale)
			frame:SetHeight(scale)
			bg:Show()
			sd:Show()
		end
	end
end

-- Event Handlers
function frame:ADDON_LOADED(addon)
	for _, v in pairs(ignored_spells) do
		ignored_spells[v] = true
	end
	self:UnregisterEvent("ADDON_LOADED")
end
frame:RegisterEvent("ADDON_LOADED")

function frame:UNIT_SPELLCAST_SUCCEEDED(unit,lineID,spellID)
	if (unit == "player") then
		watching[spellID] = {GetTime(),"spell",spellID}
		self:SetScript("OnUpdate", OnUpdate)
	end
end
frame:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")

function frame:COMBAT_LOG_EVENT_UNFILTERED()
	local _,event,_,_,_,sourceFlags,_,_,_,_,_,spellID = CombatLogGetCurrentEventInfo()
	if (event == "SPELL_CAST_SUCCESS") then
		if (bit.band(sourceFlags,COMBATLOG_OBJECT_TYPE_PET) == COMBATLOG_OBJECT_TYPE_PET and bit.band(sourceFlags,COMBATLOG_OBJECT_AFFILIATION_MINE) == COMBATLOG_OBJECT_AFFILIATION_MINE) then
			local name = GetSpellInfo(spellID)
			local index = GetPetActionIndexByName(name)
			if (index and not select(7,GetPetActionInfo(index))) then
				watching[spellID] = {GetTime(),"pet",index}
			elseif (not index and spellID) then
				watching[spellID] = {GetTime(),"spell",spellID}
			else
				return
			end
			self:SetScript("OnUpdate", OnUpdate)
		end
	end
end
frame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")

function frame:PLAYER_ENTERING_WORLD()
	local inInstance,instanceType = IsInInstance()
	if (inInstance and instanceType == "arena") then
		self:SetScript("OnUpdate", nil)
		wipe(cooldowns)
		wipe(watching)
	end
end
frame:RegisterEvent("PLAYER_ENTERING_WORLD")

hooksecurefunc("UseAction", function(slot)
	local actionType,itemID = GetActionInfo(slot)
	if (actionType == "item") then
		local texture = GetActionTexture(slot)
		watching[itemID] = {GetTime(),"item",texture}
	end
end)

hooksecurefunc("UseInventoryItem", function(slot)
	local itemID = GetInventoryItemID("player", slot);
	if (itemID) then
		local texture = GetInventoryItemTexture("player", slot)
		watching[itemID] = {GetTime(),"item",texture}
	end
end)

hooksecurefunc("UseContainerItem", function(bag,slot)
	local itemID = GetContainerItemID(bag, slot)
	if (itemID) then
		local texture = select(10, GetItemInfo(itemID))
		watching[itemID] = {GetTime(),"item",texture}
	end
end)

SlashCmdList.cooldownpulse = function()
	tinsert(animating, {GetSpellTexture(87214)})
	frame:SetScript("OnUpdate", OnUpdate)
end
SLASH_cooldownpulse1 = "/cdpulse"

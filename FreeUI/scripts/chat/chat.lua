local F, C, L = unpack(select(2, ...))

local module = F:RegisterModule("chat")

local msgHooks = {}
local maxLines = 1024
local maxWidth, maxHeight = UIParent:GetWidth(), UIParent:GetHeight()

local function skinChat(self)
	if not self or (self and self.styled) then return end

	local name = self:GetName()
	local fontSize = select(2, self:GetFont())
	self:SetClampRectInsets(0, 0, 0, 0)
	self:SetMaxResize(maxWidth, maxHeight)
	self:SetMinResize(100, 50)
	
	if C.chat.outline then
		self:SetFont(C.font.chat, fontSize, "OUTLINE")
		self:SetShadowColor(0, 0, 0, 0)
	else
		self:SetFont(C.font.chat, fontSize, nil)
		self:SetShadowColor(0, 0, 0, 1)
		self:SetShadowOffset(2, -2)
	end
	
	self:SetClampRectInsets(0, 0, 0, 0)
	self:SetClampedToScreen(false)
	if self:GetMaxLines() < maxLines then
		self:SetMaxLines(maxLines)
	end

	local eb = _G[name.."EditBox"]
	eb:SetAltArrowKeyMode(false)
	eb:ClearAllPoints()
	eb:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 2, 24)
	eb:SetPoint("TOPRIGHT", self, "TOPRIGHT", -13, 52)
	F.CreateBD(eb, .5)
	F.CreateSD(eb)
	F.CreateTex(eb)
	for i = 3, 8 do
		select(i, eb:GetRegions()):SetAlpha(0)
	end

	local lang = _G[name.."EditBoxLanguage"]
	lang:GetRegions():SetAlpha(0)
	lang:SetPoint("TOPLEFT", eb, "TOPRIGHT", 2, 0)
	lang:SetPoint("BOTTOMRIGHT", eb, "BOTTOMRIGHT", 30, 0)
	F.CreateBD(lang)
	F.CreateSD(lang)
	F.CreateTex(lang)

	F.StripTextures(self)
	F.HideObject(self.buttonFrame)
	F.HideObject(self.ScrollBar)
	F.HideObject(self.ScrollToBottomButton)

	if C.chat.lockPosition then
		ChatFrame1:ClearAllPoints()
		ChatFrame1:SetPoint(unpack(C.chat.position))
	end

	self.styled = true
end


-- Quick Scroll
hooksecurefunc("FloatingChatFrame_OnMouseScroll", function(self, dir)
	if dir > 0 then
		if IsShiftKeyDown() then
			self:ScrollToTop()
		elseif IsControlKeyDown() then
			self:ScrollUp()
			self:ScrollUp()
		end
	else
		if IsShiftKeyDown() then
			self:ScrollToBottom()
		elseif IsControlKeyDown() then
			self:ScrollDown()
			self:ScrollDown()
		end
	end
end)



local function EnableFading(i)
	local chatFrameNumber = ("ChatFrame%d"):format(i);
	local ChatFrameNumberFrame = _G[chatFrameNumber];
	
	ChatFrameNumberFrame:SetFading(true);
	ChatFrameNumberFrame:SetTimeVisible(10);
	ChatFrameNumberFrame:SetFadeDuration(10);
end

local function ForceChatSettings()
	FCF_SetLocked(ChatFrame1, nil)
	ChatFrame1:ClearAllPoints()
	ChatFrame1:SetPoint(unpack(C.chat.position))

	for i = 1, NUM_CHAT_WINDOWS do
		local cf = _G["ChatFrame"..i]
		ChatFrame_RemoveMessageGroup(cf, "CHANNEL")
	end
	FCF_SavePositionAndDimensions(ChatFrame1)
	FCF_SetLocked(ChatFrame1, true)

end



local function GetColor(className, isLocal)
	if isLocal then
		local found
		for k,v in pairs(LOCALIZED_CLASS_NAMES_FEMALE) do
			if v == className then className = k found = true break end
		end
		if not found then
			for k,v in pairs(LOCALIZED_CLASS_NAMES_MALE) do
				if v == className then className = k break end
			end
		end
	end
	local tbl = C.classcolours[className]
	local color = ("%02x%02x%02x"):format(tbl.r*255, tbl.g*255, tbl.b*255)
	return color
end

local changeBNetName = function(misc, id, moreMisc, fakeName, tag, colon)
		local gameAccount = select(6, BNGetFriendInfoByID(id))
		if gameAccount then
			local _, charName, _, _, _, _, _, englishClass = BNGetGameAccountInfo(gameAccount)
			if englishClass and englishClass ~= "" then
				fakeName = "|cFF"..GetColor(englishClass, true)..fakeName.."|r"
			end
	end
	return misc..id..moreMisc..fakeName..tag..(colon == ":" and ":" or colon)
end

local AddMessage = function(frame, text, ...)
	if type(text) == "string" then

		local chatNum = string.match(text,"%d+") or ""
		if not tonumber(chatNum) then chatNum = "" else chatNum = chatNum..":" end

		text = gsub(text, "%[(%d+)%. 大脚世界频道%]", "世界")
		text = gsub(text, "%[(%d+)%. 大腳世界頻道%]", "世界")
		text = gsub(text, "%[(%d+)%. BigfootWorldChannel%]", "w")

		text = gsub(text, "%[%d+%. .-%]", "["..chatNum.."]")

		text = gsub(text, "(|HBNplayer:%S-|k:)(%d-)(:%S-|h)%[(%S-)%](|?h?)(:?)", changeBNetName)

		text = gsub(text, "|H(.-)|h%[(.-)%]|h", "|H%1|h%2|h")
		--text = gsub(text, "|Hplayer:([^%|]+)|h%[([^%]]+)%]|h", "|Hplayer:%1|h%2|h")

		--url search
		text = gsub(text, '([wWhH][wWtT][wWtT][%.pP]%S+[^%p%s])', '|cffffffff|Hurl:%1|h[%1]|h|r')


	end
	msgHooks[frame:GetName()].AddMessage(frame, text, ...)
end

--local Insert = function(self, str, ...)
--	if type(str) == "string" then
--		str = str:gsub("|H(.-)|h[%[]?(.-)[%]]?|h", "|H%1|h[%2]|h")
--	end

--	return msgHooks[self](self, str, ...)
--end

--ChatFrame_AddMessageEventFilter("CHAT_MSG_CURRENCY", function(self, event, message, ...)
--	local currencyID, currencyName, currencyAmount = message:match'currency:(%d+)', message:match'|h(.+)|h', message:match' x%d+'
--	return false, ("+ |cffffffff|Hcurrency:%d|h%s|h|r%s"):format(currencyID, currencyName, currencyAmount or ""), ...
--end)


local DefaultSetItemRef = SetItemRef
function SetItemRef(link, ...)
	local type, value = link:match("(%a+):(.+)")
	--print(type)
	if IsAltKeyDown() and type == "player" then
		InviteUnit(value:match("([^:]+)"))
	elseif (type == "url") then
		local eb = LAST_ACTIVE_CHAT_EDIT_BOX or ChatFrame1EditBox
		if not eb then return end
		eb:Show()
		eb:SetText(value)
		eb:SetFocus()
		eb:HighlightText()
	else
		return DefaultSetItemRef(link, ...)
	end
end


-- whisper to target
SLASH_TELLTARGET1 = "/tt"
SlashCmdList.TELLTARGET = function(message)
	if UnitIsPlayer("target") and (UnitIsUnit("player", "target") or UnitCanCooperate("player", "target")) then
		SendChatMessage(message, "WHISPER", nil, GetUnitName("target", true))
	end
end


function module:OnLogin()
	for i = 1, NUM_CHAT_WINDOWS do
		skinChat(_G["ChatFrame"..i])

		local n = ("ChatFrame%d"):format(i)
		local f = _G[n]

		if f ~= COMBATLOG and not msgHooks[n] then
			msgHooks[n] = {}
			msgHooks[n].AddMessage = f.AddMessage
			f.AddMessage = AddMessage
		end
	end

	hooksecurefunc("FCF_OpenTemporaryWindow", function()
		for _, chatFrameName in next, CHAT_FRAMES do
			local frame = _G[chatFrameName]
			if frame.isTemporary then
				skinChat(frame)
			end
		end
	end)

	-- Font size
	for i = 1, 15 do
		CHAT_FONT_HEIGHTS[i] = i + 9
	end

	-- Default
	SetCVar("chatStyle", "classic")
	F.HideOption(InterfaceOptionsSocialPanelChatStyle)
	CombatLogQuickButtonFrame_CustomTexture:SetTexture(nil)

	-- Sticky
	if C.chat.sticky then
		ChatTypeInfo.SAY.sticky = 1
		ChatTypeInfo.EMOTE.sticky = 1
		ChatTypeInfo.YELL.sticky = 1
		ChatTypeInfo.PARTY.sticky = 1
		ChatTypeInfo.PARTY_LEADER.sticky = 1
		ChatTypeInfo.GUILD.sticky = 1
		ChatTypeInfo.OFFICER.sticky = 1
		ChatTypeInfo.RAID.sticky = 1
		ChatTypeInfo.RAID_WARNING.sticky = 1
		ChatTypeInfo.INSTANCE_CHAT.sticky = 1
		ChatTypeInfo.INSTANCE_CHAT_LEADER.sticky = 1
		ChatTypeInfo.WHISPER.sticky = 1
		ChatTypeInfo.BN_WHISPER.sticky = 1
		ChatTypeInfo.CHANNEL.sticky = 1
	end

	-- don't cut the toastframe
	BNToastFrame:SetClampedToScreen(true)
	BNToastFrame:SetClampRectInsets(-15,15,15,-15)

	-- voice chat stuff
	VoiceChatPromptActivateChannel:SetClampedToScreen(true)
	VoiceChatPromptActivateChannel:SetClampRectInsets(-50,50,50,-50)
	VoiceChatChannelActivatedNotification:SetClampedToScreen(true)
	VoiceChatChannelActivatedNotification:SetClampRectInsets(-50,50,50,-50)
	ChatAlertFrame:SetClampedToScreen(true)
	ChatAlertFrame:SetClampRectInsets(-50,50,50,-50)

	-- Easy Resizing
	ChatFrame1Tab:HookScript("OnMouseDown", function(_, btn)
		if btn == "LeftButton" then
			if select(8, GetChatWindowInfo(1)) then
				ChatFrame1:StartSizing("TOP")
			end
		end
	end)
	ChatFrame1Tab:SetScript("OnMouseUp", function(_, btn)
		if btn == "LeftButton" then
			ChatFrame1:StopMovingOrSizing()
			FCF_SavePositionAndDimensions(ChatFrame1)
		end
	end)

	local function HideForever(f)
		f:SetScript("OnShow", f.Hide)
		f:Hide()
	end

	HideForever(ChatFrameMenuButton)
	HideForever(QuickJoinToastButton)
	HideForever(GeneralDockManagerOverflowButton)
	HideForever(ChatFrameChannelButton)
	HideForever(ChatFrameToggleVoiceDeafenButton)
	HideForever(ChatFrameToggleVoiceMuteButton)

	ForceChatSettings()

	self:ChatFilter()

	-- ProfanityFilter
	if not BNFeaturesEnabledAndConnected() then return end

	SetCVar("profanityFilter", 0)

end
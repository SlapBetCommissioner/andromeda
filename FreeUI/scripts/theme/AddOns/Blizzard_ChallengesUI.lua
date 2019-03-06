local F, C = unpack(select(2, ...))

C.themes["Blizzard_ChallengesUI"] = function()
	ChallengesFrameInset:Hide()
	for i = 1, 2 do
		select(i, ChallengesFrame:GetRegions()):Hide()
	end

	local angryStyle
	local function UpdateIcons(self)
		for i = 1, #self.maps do
			local bu = self.DungeonIcons[i]
			if bu and not bu.styled then
				bu:GetRegions():SetAlpha(0)
				bu.Icon:SetTexCoord(unpack(C.TexCoord))
				F.CreateBD(bu, 0)

				bu.styled = true
			end

			if i == 1 then
				self.WeeklyInfo.Child.SeasonBest:ClearAllPoints()
				self.WeeklyInfo.Child.SeasonBest:SetPoint("TOPLEFT", self.DungeonIcons[i], "TOPLEFT", 5, 20)
			end
		end

		if IsAddOnLoaded("AngryKeystones") and not angryStyle then
			local scheduel, party = select(5, self:GetChildren())
			scheduel:GetRegions():SetAlpha(0)
			select(3, scheduel:GetRegions()):SetAlpha(0)
			F.CreateBD(scheduel, .3)
			if scheduel.Entries then
				for i = 1, 3 do
					F.AffixesSetup(scheduel.Entries[i])
				end
			end

			party:GetRegions():SetAlpha(0)
			select(3, party:GetRegions()):SetAlpha(0)
			F.CreateBD(party, .3)

			angryStyle = true
		end
	end
	hooksecurefunc("ChallengesFrame_Update", UpdateIcons)

	hooksecurefunc(ChallengesFrame.WeeklyInfo, "SetUp", function(self)
		local affixes = C_MythicPlus.GetCurrentAffixes()
		if affixes then
			F.AffixesSetup(self.Child)
		end
	end)

	local keystone = ChallengesKeystoneFrame
	F.SetBD(keystone)
	F.ReskinClose(keystone.CloseButton)
	F.Reskin(keystone.StartButton)

	hooksecurefunc(keystone, "Reset", function(self)
		self:GetRegions():SetAlpha(0)
		self.InstructionBackground:SetAlpha(0)
	end)

	hooksecurefunc(keystone, "OnKeystoneSlotted", F.AffixesSetup)


	local noticeFrame = ChallengesFrame.SeasonChangeNoticeFrame
	F.Reskin(noticeFrame.Leave)
	noticeFrame.NewSeason:SetTextColor(1, .8, 0)
	noticeFrame.SeasonDescription:SetTextColor(1, 1, 1)
	noticeFrame.SeasonDescription2:SetTextColor(1, 1, 1)
	noticeFrame.SeasonDescription3:SetTextColor(1, .8, 0)

	local affix = ChallengesFrame.SeasonChangeNoticeFrame.Affix
	F.StripTextures(affix)
	F.ReskinIcon(affix.Portrait)
	affix.Portrait:SetTexture(2446016)
end
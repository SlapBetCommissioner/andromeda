local F, C = unpack(select(2, ...))

local function styleRewardButton(button)
    if not button or button.styled then
        return
    end

    local buttonName = button:GetName()
    local icon = _G[buttonName .. 'IconTexture']
    local shortageBorder = _G[buttonName .. 'ShortageBorder']
    local count = _G[buttonName .. 'Count']
    local nameFrame = _G[buttonName .. 'NameFrame']
    local border = button.IconBorder

    button.bg = F.ReskinIcon(icon)
    local bg = F.CreateBDFrame(button, 0.25)
    bg:SetPoint('TOPLEFT', button.bg, 'TOPRIGHT', 1, 0)
    bg:SetPoint('BOTTOMRIGHT', button.bg, 'BOTTOMRIGHT', 105, 0)

    if shortageBorder then
        shortageBorder:SetAlpha(0)
    end
    if count then
        count:SetDrawLayer('OVERLAY')
    end
    if nameFrame then
        nameFrame:SetAlpha(0)
    end
    if border then
        F.ReskinIconBorder(border)
    end

    button.styled = true
end

local function reskinDialogReward(button)
    if button.styled then
        return
    end

    local border = _G[button:GetName() .. 'Border']
    button.texture:SetTexCoord(unpack(C.TEX_COORD))
    border:SetColorTexture(0, 0, 0)
    border:SetDrawLayer('BACKGROUND')
    border:SetOutside(button.texture)
    button.styled = true
end

local function reskinRoleButton(buttons, role)
    for _, roleButton in pairs(buttons) do
        F.ReskinRole(roleButton, role)
    end
end

local function updateRoleBonus(roleButton)
    if not roleButton.bg then
        return
    end
    -- if roleButton.shortageBorder and roleButton.shortageBorder:IsShown() then
    --     if roleButton.cover:IsShown() then
    --         roleButton.bg:SetBackdropBorderColor(0.5, 0.45, 0.03)
    --     else
    --         roleButton.bg:SetBackdropBorderColor(1, 0.9, 0.06)
    --     end
    -- else
    --     roleButton.bg:SetBackdropBorderColor(0, 0, 0)
    -- end
end

local function styleRewardRole(roleIcon)
    if roleIcon and roleIcon:IsShown() then
        F.ReskinSmallRole(roleIcon.texture, roleIcon.role)
    end
end

table.insert(C.BlizzThemes, function()
    -- LFDFrame
    hooksecurefunc('LFGDungeonListButton_SetDungeon', function(button)
        if not button.expandOrCollapseButton.styled then
            F.ReskinCheck(button.enableButton)
            F.ReskinCollapse(button.expandOrCollapseButton)

            button.expandOrCollapseButton.styled = true
        end

        button.enableButton:GetCheckedTexture():SetDesaturated(true)
    end)

    F.StripTextures(_G.LFDParentFrame)
    _G.LFDQueueFrameBackground:Hide()
    F.SetBD(_G.LFDRoleCheckPopup)
    _G.LFDRoleCheckPopup.Border:Hide()
    F.Reskin(_G.LFDRoleCheckPopupAcceptButton)
    F.Reskin(_G.LFDRoleCheckPopupDeclineButton)
    F.ReskinScroll(_G.LFDQueueFrameSpecificListScrollFrameScrollBar)
    F.StripTextures(_G.LFDQueueFrameRandomScrollFrameScrollBar, 0)
    F.ReskinScroll(_G.LFDQueueFrameRandomScrollFrameScrollBar)
    F.ReskinDropDown(_G.LFDQueueFrameTypeDropDown)
    F.Reskin(_G.LFDQueueFrameFindGroupButton)
    F.Reskin(_G.LFDQueueFramePartyBackfillBackfillButton)
    F.Reskin(_G.LFDQueueFramePartyBackfillNoBackfillButton)
    F.Reskin(_G.LFDQueueFrameNoLFDWhileLFRLeaveQueueButton)
    styleRewardButton(_G.LFDQueueFrameRandomScrollFrameChildFrameMoneyReward)

    _G.LFDQueueFrameRandomScrollFrame:SetWidth(_G.LFDQueueFrameRandomScrollFrame:GetWidth() + 1)
    _G.LFDQueueFrameSpecificListScrollFrameScrollBarScrollDownButton:SetPoint(
        'TOP',
        _G.LFDQueueFrameSpecificListScrollFrameScrollBar,
        'BOTTOM',
        0,
        2
    )
    _G.LFDQueueFrameRandomScrollFrameScrollBarScrollDownButton:SetPoint(
        'TOP',
        _G.LFDQueueFrameRandomScrollFrameScrollBar,
        'BOTTOM',
        0,
        2
    )

    _G.LFDQueueFrameRoleButtonTankBackground:SetTexture(C.Assets.Texture.Roles)
    _G.LFDQueueFrameRoleButtonHealerBackground:SetTexture(C.Assets.Texture.Roles)
    _G.LFDQueueFrameRoleButtonDPSBackground:SetTexture(C.Assets.Texture.Roles)

    _G.RaidFinderQueueFrameRoleButtonTankBackground:SetTexture(C.Assets.Texture.Roles)
    _G.RaidFinderQueueFrameRoleButtonHealerBackground:SetTexture(C.Assets.Texture.Roles)
    _G.RaidFinderQueueFrameRoleButtonDPSBackground:SetTexture(C.Assets.Texture.Roles)

    -- LFGFrame
    hooksecurefunc('LFGRewardsFrame_SetItemButton', function(parentFrame, _, index)
        local parentName = parentFrame:GetName()
        styleRewardButton(parentFrame.MoneyReward)

        local button = _G[parentName .. 'Item' .. index]
        styleRewardButton(button)

        styleRewardRole(button.roleIcon1)
        styleRewardRole(button.roleIcon2)
    end)

    _G.LFGDungeonReadyDialogRoleIconLeaderIcon:SetTexture(nil)
    local leaderFrame = CreateFrame('Frame', nil, _G.LFGDungeonReadyDialog)
    leaderFrame:SetFrameLevel(5)
    leaderFrame:SetPoint('TOPLEFT', _G.LFGDungeonReadyDialogRoleIcon, 4, -4)
    leaderFrame:SetSize(19, 19)
    local leaderIcon = leaderFrame:CreateTexture(nil, 'ARTWORK')
    leaderIcon:SetAllPoints()
    F.ReskinRole(leaderIcon, 'LEADER')

    local iconTexture = _G.LFGDungeonReadyDialogRoleIconTexture
    iconTexture:SetTexture(C.Assets.Texture.Roles)
    --local bg = F.CreateBDFrame(iconTexture)

    hooksecurefunc('LFGDungeonReadyPopup_Update', function()
        _G.LFGDungeonReadyDialog:SetBackdrop(nil)
        leaderFrame:SetShown(_G.LFGDungeonReadyDialogRoleIconLeaderIcon:IsShown())

        -- if _G.LFGDungeonReadyDialogRoleIcon:IsShown() then
        --     local role = select(7, GetLFGProposal())
        --     if not role or role == 'NONE' then
        --         role = 'DAMAGER'
        --     end
        --     iconTexture:SetTexCoord(F.GetRoleTexCoord(role))
        --     bg:Show()
        -- else
        --     bg:Hide()
        -- end

        if _G.LFGDungeonReadyDialogRoleIcon:IsShown() then
            local _, _, _, _, _, _, role = GetLFGProposal()
            if role == 'DAMAGER' then
                _G.LFGDungeonReadyDialogRoleIconTexture:SetTexCoord(
                    _G.LFDQueueFrameRoleButtonDPS.background:GetTexCoord()
                )
            elseif role == 'TANK' then
                _G.LFGDungeonReadyDialogRoleIconTexture:SetTexCoord(
                    _G.LFDQueueFrameRoleButtonTank.background:GetTexCoord()
                )
            elseif role == 'HEALER' then
                _G.LFGDungeonReadyDialogRoleIconTexture:SetTexCoord(
                    _G.LFDQueueFrameRoleButtonHealer.background:GetTexCoord()
                )
            end
        end
    end)

    hooksecurefunc('LFGDungeonReadyDialogReward_SetMisc', function(button)
        reskinDialogReward(button)
        button.texture:SetTexture('Interface\\Icons\\inv_misc_coin_02')
    end)

    hooksecurefunc(
        'LFGDungeonReadyDialogReward_SetReward',
        function(button, dungeonID, rewardIndex, rewardType, rewardArg)
            reskinDialogReward(button)

            local texturePath
            if rewardType == 'reward' then
                texturePath = select(2, GetLFGDungeonRewardInfo(dungeonID, rewardIndex))
            elseif rewardType == 'shortage' then
                texturePath = select(2, GetLFGDungeonShortageRewardInfo(dungeonID, rewardArg, rewardIndex))
            end
            if texturePath then
                button.texture:SetTexture(texturePath)
            end
        end
    )

    F.StripTextures(_G.LFGDungeonReadyDialog, 0)
    F.SetBD(_G.LFGDungeonReadyDialog)
    F.StripTextures(_G.LFGInvitePopup)
    F.SetBD(_G.LFGInvitePopup)
    F.StripTextures(_G.LFGDungeonReadyStatus)
    F.SetBD(_G.LFGDungeonReadyStatus)

    F.Reskin(_G.LFGDungeonReadyDialogEnterDungeonButton)
    F.Reskin(_G.LFGDungeonReadyDialogLeaveQueueButton)
    F.Reskin(_G.LFGInvitePopupAcceptButton)
    F.Reskin(_G.LFGInvitePopupDeclineButton)
    F.ReskinClose(_G.LFGDungeonReadyDialogCloseButton)
    F.ReskinClose(_G.LFGDungeonReadyStatusCloseButton)

    local tanks = {
        _G.LFDQueueFrameRoleButtonTank,
        _G.LFDRoleCheckPopupRoleButtonTank,
        _G.RaidFinderQueueFrameRoleButtonTank,
        _G.LFGInvitePopupRoleButtonTank,
        _G.LFGListApplicationDialog.TankButton,
        _G.LFGDungeonReadyStatusGroupedTank,
    }
    --reskinRoleButton(tanks, 'TANK')

    local healers = {
        _G.LFDQueueFrameRoleButtonHealer,
        _G.LFDRoleCheckPopupRoleButtonHealer,
        _G.RaidFinderQueueFrameRoleButtonHealer,
        _G.LFGInvitePopupRoleButtonHealer,
        _G.LFGListApplicationDialog.HealerButton,
        _G.LFGDungeonReadyStatusGroupedHealer,
    }
    --reskinRoleButton(healers, 'HEALER')

    local dps = {
        _G.LFDQueueFrameRoleButtonDPS,
        _G.LFDRoleCheckPopupRoleButtonDPS,
        _G.RaidFinderQueueFrameRoleButtonDPS,
        _G.LFGInvitePopupRoleButtonDPS,
        _G.LFGListApplicationDialog.DamagerButton,
        _G.LFGDungeonReadyStatusGroupedDamager,
    }
    --reskinRoleButton(dps, 'DPS')

    -- F.ReskinRole(_G.LFDQueueFrameRoleButtonLeader, 'LEADER')
    -- F.ReskinRole(_G.RaidFinderQueueFrameRoleButtonLeader, 'LEADER')
    F.ReskinRole(_G.LFGDungeonReadyStatusRolelessReady, 'READY')

    _G.LFDQueueFrameRoleButtonLeader.leadIcon = _G.LFDQueueFrameRoleButtonLeader:CreateTexture(nil, 'BACKGROUND')
    _G.LFDQueueFrameRoleButtonLeader.leadIcon:SetTexture(C.Assets.Texture.Leader)
    _G.LFDQueueFrameRoleButtonLeader.leadIcon:SetPoint(
        _G.LFDQueueFrameRoleButtonLeader:GetNormalTexture():GetPoint(),
        -14,
        16
    )
    _G.LFDQueueFrameRoleButtonLeader.leadIcon:SetSize(80, 80)
    _G.LFDQueueFrameRoleButtonLeader.leadIcon:SetAlpha(0.6)

    _G.RaidFinderQueueFrameRoleButtonLeader.leadIcon = _G.RaidFinderQueueFrameRoleButtonLeader:CreateTexture(
        nil,
        'BACKGROUND'
    )
    _G.RaidFinderQueueFrameRoleButtonLeader.leadIcon:SetTexture(C.Assets.Texture.Leader)
    _G.RaidFinderQueueFrameRoleButtonLeader.leadIcon:SetPoint(
        _G.RaidFinderQueueFrameRoleButtonLeader:GetNormalTexture():GetPoint(),
        -14,
        16
    )
    _G.RaidFinderQueueFrameRoleButtonLeader.leadIcon:SetSize(80, 80)
    _G.RaidFinderQueueFrameRoleButtonLeader.leadIcon:SetAlpha(0.6)

    ----------------------
    ----------------------
    local RoleButtons1 = {
        _G.LFDQueueFrameRoleButtonHealer,
        _G.LFDQueueFrameRoleButtonDPS,
        _G.LFDQueueFrameRoleButtonLeader,
        _G.LFDQueueFrameRoleButtonTank,
        _G.RaidFinderQueueFrameRoleButtonHealer,
        _G.RaidFinderQueueFrameRoleButtonDPS,
        _G.RaidFinderQueueFrameRoleButtonLeader,
        _G.RaidFinderQueueFrameRoleButtonTank,
        _G.LFGInvitePopupRoleButtonTank,
        _G.LFGInvitePopupRoleButtonHealer,
        _G.LFGInvitePopupRoleButtonDPS,
        _G.LFGListApplicationDialog.TankButton,
        _G.LFGListApplicationDialog.HealerButton,
        _G.LFGListApplicationDialog.DamagerButton,
        _G.RolePollPopupRoleButtonTank,
        _G.RolePollPopupRoleButtonHealer,
        _G.RolePollPopupRoleButtonDPS,
    }

    for _, roleButton in pairs(RoleButtons1) do
        roleButton:DisableDrawLayer('ARTWORK')
        roleButton:DisableDrawLayer('OVERLAY')

        if not roleButton.background then
            local isLeader = roleButton:GetName() ~= nil and roleButton:GetName():find('Leader') or false
            if not isLeader then
                roleButton.background = roleButton:CreateTexture(nil, 'BACKGROUND')
                roleButton.background:SetSize(80, 80)
                roleButton.background:SetPoint('CENTER')
                roleButton.background:SetTexture(C.Assets.Texture.Roles)
                roleButton.background:SetAlpha(0.65)

                local buttonName = roleButton:GetName() ~= nil and roleButton:GetName() or roleButton.role
                roleButton.background:SetTexCoord(
                    GetBackgroundTexCoordsForRole(
                        (strlower(buttonName):find('tank') and 'TANK')
                            or (strlower(buttonName):find('healer') and 'HEALER')
                            or 'DAMAGER'
                    )
                )
            end
        end

        local checkButton = roleButton.checkButton or roleButton.CheckButton or roleButton.CheckBox
        if checkButton then
            checkButton:SetFrameLevel(roleButton:GetFrameLevel() + 2)
            checkButton:SetPoint('BOTTOMLEFT', -2, -2)
            checkButton:SetSize(20, 20)
            F.ReskinCheck(checkButton, true)
        end
    end
    ----------------------
    ----------------------

    hooksecurefunc('SetCheckButtonIsRadio', function(button)
        button:SetNormalTexture('')
        button:SetHighlightTexture(C.Assets.Texture.Backdrop)
        button:SetCheckedTexture('Interface\\Buttons\\UI-CheckBox-Check')
        button:GetCheckedTexture():SetTexCoord(0, 1, 0, 1)
        button:SetPushedTexture('')
        button:SetDisabledCheckedTexture('Interface\\Buttons\\UI-CheckBox-Check-Disabled')
        button:GetDisabledCheckedTexture():SetTexCoord(0, 1, 0, 1)
    end)

    hooksecurefunc('LFG_SetRoleIconIncentive', function(roleButton, incentiveIndex)
        if incentiveIndex then
            local tex
            if incentiveIndex == _G.LFG_ROLE_SHORTAGE_PLENTIFUL then
                tex = 'coin-copper'
            elseif incentiveIndex == _G.LFG_ROLE_SHORTAGE_UNCOMMON then
                tex = 'coin-silver'
            elseif incentiveIndex == _G.LFG_ROLE_SHORTAGE_RARE then
                tex = 'coin-gold'
            end
            roleButton.incentiveIcon.texture:SetInside()
            roleButton.incentiveIcon.texture:SetAtlas(tex)
        end

        updateRoleBonus(roleButton)
    end)

    hooksecurefunc('LFG_EnableRoleButton', updateRoleBonus)

    for i = 1, 5 do
        local roleButton = _G['LFGDungeonReadyStatusIndividualPlayer' .. i]
        roleButton.texture:SetTexture(C.Assets.Texture.LfgRole)
        F.CreateBDFrame(roleButton)
        if i == 1 then
            roleButton:SetPoint('LEFT', 7, 0)
        else
            roleButton:SetPoint('LEFT', _G['LFGDungeonReadyStatusIndividualPlayer' .. (i - 1)], 'RIGHT', 4, 0)
        end
    end

    hooksecurefunc('LFGDungeonReadyStatusIndividual_UpdateIcon', function(button)
        -- local role = select(2, GetLFGProposalMember(button:GetID()))
        -- button.texture:SetTexCoord(F.GetRoleTexCoord(role))

        local _, role = GetLFGProposalMember(button:GetID())

        button.texture:SetTexture(C.Assets.Texture.Roles)
        button.texture:SetAlpha(0.6)

        if role == 'DAMAGER' then
            button.texture:SetTexCoord(_G.LFDQueueFrameRoleButtonDPS.background:GetTexCoord())
        elseif role == 'TANK' then
            button.texture:SetTexCoord(_G.LFDQueueFrameRoleButtonTank.background:GetTexCoord())
        elseif role == 'HEALER' then
            button.texture:SetTexCoord(_G.LFDQueueFrameRoleButtonHealer.background:GetTexCoord())
        end
    end)

    hooksecurefunc('LFGDungeonReadyStatusGrouped_UpdateIcon', function(button, role)
        --button.texture:SetTexCoord(F.GetRoleTexCoord(role))
    end)

    -- RaidFinder
    _G.RaidFinderFrameBottomInset:Hide()
    _G.RaidFinderFrameRoleBackground:Hide()
    _G.RaidFinderFrameRoleInset:Hide()
    _G.RaidFinderQueueFrameBackground:Hide()
    -- this fixes right border of second reward being cut off
    _G.RaidFinderQueueFrameScrollFrame:SetWidth(_G.RaidFinderQueueFrameScrollFrame:GetWidth() + 1)

    F.ReskinScroll(_G.RaidFinderQueueFrameScrollFrameScrollBar)
    F.ReskinDropDown(_G.RaidFinderQueueFrameSelectionDropDown)
    F.Reskin(_G.RaidFinderFrameFindRaidButton)
    F.Reskin(_G.RaidFinderQueueFrameIneligibleFrameLeaveQueueButton)
    F.Reskin(_G.RaidFinderQueueFramePartyBackfillBackfillButton)
    F.Reskin(_G.RaidFinderQueueFramePartyBackfillNoBackfillButton)
    styleRewardButton(_G.RaidFinderQueueFrameScrollFrameChildFrameMoneyReward)
end)

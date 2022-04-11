local F, C = unpack(select(2, ...))
local NAMEPLATE = F:GetModule('Nameplate')
local UNITFRAME = F:GetModule('UnitFrame')
local oUF = F.Libs.oUF

--[[ CVars ]]
function NAMEPLATE:PlateInsideView()
    if C.DB.Nameplate.InsideView then
        SetCVar('nameplateOtherTopInset', .05)
        SetCVar('nameplateOtherBottomInset', .08)
    elseif GetCVar('nameplateOtherTopInset') == '0.05' and GetCVar('nameplateOtherBottomInset') == '0.08' then
        SetCVar('nameplateOtherTopInset', -1)
        SetCVar('nameplateOtherBottomInset', -1)
    end
end

function NAMEPLATE:UpdatePlateScale()
    SetCVar('namePlateMinScale', C.DB.Nameplate.MinScale)
    SetCVar('namePlateMaxScale', C.DB.Nameplate.MinScale)
end

function NAMEPLATE:UpdatePlateTargetScale()
    SetCVar('nameplateLargerScale', C.DB.Nameplate.TargetScale)
    SetCVar('nameplateSelectedScale', C.DB.Nameplate.TargetScale)
end

function NAMEPLATE:UpdatePlateAlpha()
    SetCVar('nameplateMinAlpha', C.DB.Nameplate.MinAlpha)
    SetCVar('nameplateMaxAlpha', C.DB.Nameplate.MinAlpha)
    SetCVar('nameplateSelectedAlpha', 1)
end

function NAMEPLATE:UpdatePlateOccludedAlpha()
    SetCVar('nameplateOccludedAlphaMult', C.DB.Nameplate.OccludedAlpha)
end

function NAMEPLATE:UpdatePlateVerticalSpacing()
    SetCVar('nameplateOverlapV', C.DB.Nameplate.VerticalSpacing)
end

function NAMEPLATE:UpdatePlateHorizontalSpacing()
    SetCVar('nameplateOverlapH', C.DB.Nameplate.HorizontalSpacing)
end

function NAMEPLATE:UpdatePlateClickThrough()
    if InCombatLockdown() then
        return
    end

    C_NamePlate.SetNamePlateEnemyClickThrough(C.DB.Nameplate.EnemyClickThrough)
    C_NamePlate.SetNamePlateFriendlyClickThrough(C.DB.Nameplate.FriendlyClickThrough)
end

function NAMEPLATE:UpdateNameplateCVars()
    if not C.DB.Nameplate.ForceCVars then
        return
    end

    NAMEPLATE:PlateInsideView()

    NAMEPLATE:UpdatePlateVerticalSpacing()
    NAMEPLATE:UpdatePlateHorizontalSpacing()

    NAMEPLATE:UpdatePlateAlpha()
    NAMEPLATE:UpdatePlateOccludedAlpha()

    NAMEPLATE:UpdatePlateScale()
    NAMEPLATE:UpdatePlateTargetScale()

    NAMEPLATE:UpdateClickableSize()
    hooksecurefunc(_G.NamePlateDriverFrame, 'UpdateNamePlateOptions', NAMEPLATE.UpdateClickableSize)
    NAMEPLATE:UpdatePlateClickThrough()

    SetCVar('nameplateShowSelf', 0)
    SetCVar('nameplateResourceOnTarget', 0)
    SetCVar('predictedHealth', 1)

    F.HideOption(_G.InterfaceOptionsNamesPanelUnitNameplatesPersonalResource)
    F.HideOption(_G.InterfaceOptionsNamesPanelUnitNameplatesPersonalResourceOnEnemy)
end

--[[ AddOn ]]
function NAMEPLATE:BlockAddons()
    if not _G.DBM or not _G.DBM.Nameplate then
        return
    end

    function _G.DBM.Nameplate:SupportedNPMod()
        return true
    end

    local function showAurasForDBM(_, _, _, spellID)
        if not tonumber(spellID) then
            return
        end
        if not C.AuraWhiteList[spellID] then
            C.AuraWhiteList[spellID] = true
        end
    end
    hooksecurefunc(_G.DBM.Nameplate, 'Show', showAurasForDBM)
end

--[[ Elements ]]
local customUnits = {}
function NAMEPLATE:CreateUnitTable()
    table.wipe(customUnits)
    if not C.DB.Nameplate.CustomUnitColor then
        return
    end
    F:CopyTable(C.NPSpecialUnitsList, customUnits)
    F:SplitList(customUnits, C.DB.Nameplate.CustomUnitList)
end

local showPowerList = {}
function NAMEPLATE:CreatePowerUnitTable()
    table.wipe(showPowerList)
    F:CopyTable(C.NPShowPowerUnitsList, showPowerList)
    F:SplitList(showPowerList, C.DB.Nameplate.ShowPowerList)
end

function NAMEPLATE:UpdateUnitPower()
    local unitName = self.unitName
    local npcID = self.npcID
    local shouldShowPower = showPowerList[unitName] or showPowerList[npcID]
    if shouldShowPower then
        self.powerText:Show()
    else
        self.powerText:Hide()
    end
end

-- Off-tank threat color
local groupRoles, isInGroup = {}
local function refreshGroupRoles()
    local isInRaid = IsInRaid()
    isInGroup = isInRaid or IsInGroup()
    table.wipe(groupRoles)

    if isInGroup then
        local numPlayers = (isInRaid and GetNumGroupMembers()) or GetNumSubgroupMembers()
        local unit = (isInRaid and 'raid') or 'party'
        for i = 1, numPlayers do
            local index = unit .. i
            if UnitExists(index) then
                groupRoles[UnitName(index)] = UnitGroupRolesAssigned(index)
            end
        end
    end
end

local function resetGroupRoles()
    isInGroup = IsInRaid() or IsInGroup()
    table.wipe(groupRoles)
end

function NAMEPLATE:UpdateGroupRoles()
    refreshGroupRoles()
    F:RegisterEvent('GROUP_ROSTER_UPDATE', refreshGroupRoles)
    F:RegisterEvent('GROUP_LEFT', resetGroupRoles)
end

function NAMEPLATE:CheckThreatStatus(unit)
    if not UnitExists(unit) then
        return
    end

    local unitTarget = unit .. 'target'
    local unitRole = isInGroup and UnitExists(unitTarget) and not UnitIsUnit(unitTarget, 'player') and groupRoles[UnitName(unitTarget)] or 'NONE'

    if C.MyRole == 'Tank' and unitRole == 'TANK' then
        return true, UnitThreatSituation(unitTarget, unit)
    else
        return false, UnitThreatSituation('player', unit)
    end
end

-- Update unit color
function NAMEPLATE:UpdateColor(_, unit)
    if not unit or self.unit ~= unit then
        return
    end

    local element = self.Health
    local name = self.unitName
    local npcID = self.npcID
    local isCustomUnit = customUnits[name] or customUnits[npcID]
    local isPlayer = self.isPlayer
    local isFriendly = self.isFriendly
    local isOffTank, status = NAMEPLATE:CheckThreatStatus(unit)

    local customColor = C.DB.Nameplate.CustomColor
    local secureColor = C.DB.Nameplate.SecureColor
    local transColor = C.DB.Nameplate.TransColor
    local insecureColor = C.DB.Nameplate.InsecureColor
    local revertThreat = C.DB.Nameplate.RevertThreat
    local offTankColor = C.DB.Nameplate.OffTankColor
    local targetColor = C.DB.Nameplate.TargetColor
    local coloredTarget = C.DB.Nameplate.ColoredTarget
    local focusColor = C.DB.Nameplate.FocusColor
    local coloredFocus = C.DB.Nameplate.ColoredFocus
    local hostileClassColor = C.DB.Nameplate.HostileClassColor
    local friendlyClassColor = C.DB.Nameplate.FriendlyClassColor
    local tankMode = C.DB.Nameplate.TankMode
    local executeIndicator = C.DB.Nameplate.ExecuteIndicator
    local executeRatio = C.DB.Nameplate.ExecuteRatio
    local healthPerc = UnitHealth(unit) / (UnitHealthMax(unit) + .0001) * 100
    local r, g, b

    if not UnitIsConnected(unit) then
        r, g, b = unpack(oUF.colors.disconnected)
    else
        if coloredTarget and UnitIsUnit(unit, 'target') then
            r, g, b = targetColor.r, targetColor.g, targetColor.b
        elseif coloredFocus and UnitIsUnit(unit, 'focus') then
            r, g, b = focusColor.r, focusColor.g, focusColor.b
        elseif isCustomUnit then
            r, g, b = customColor.r, customColor.g, customColor.b
        elseif isPlayer and isFriendly then
            if friendlyClassColor then
                r, g, b = F:UnitColor(unit)
            else
                r, g, b = .3, .3, 1
            end
        elseif isPlayer and (not isFriendly) and hostileClassColor then
            r, g, b = F:UnitColor(unit)
        elseif UnitIsTapDenied(unit) and not UnitPlayerControlled(unit) or C.TrashUnits[npcID] then
            r, g, b = unpack(oUF.colors.tapped)
        else
            r, g, b = unpack(oUF.colors.reaction[UnitReaction(unit, 'player') or 5])
            if status and (tankMode or C.MyRole == 'Tank') then
                if status == 3 then
                    if C.MyRole ~= 'Tank' and revertThreat then
                        r, g, b = insecureColor.r, insecureColor.g, insecureColor.b
                    else
                        if isOffTank then
                            r, g, b = offTankColor.r, offTankColor.g, offTankColor.b
                        else
                            r, g, b = secureColor.r, secureColor.g, secureColor.b
                        end
                    end
                elseif status == 2 or status == 1 then
                    r, g, b = transColor.r, transColor.g, transColor.b
                elseif status == 0 then
                    if C.MyRole ~= 'Tank' and revertThreat then
                        r, g, b = secureColor.r, secureColor.g, secureColor.b
                    else
                        r, g, b = insecureColor.r, insecureColor.g, insecureColor.b
                    end
                end
            end
        end
    end

    if r or g or b then
        element:SetStatusBarColor(r, g, b)

        if self.TargetIndicator then
            self.TargetIndicator.aggroL:SetVertexColor(r, g, b)
            self.TargetIndicator.aggroR:SetVertexColor(r, g, b)
        end
    end

    NAMEPLATE:UpdateOverlayVisibility(self, unit)

    self.ThreatIndicator:Hide()
    if status and (isCustomUnit or (not tankMode and C.MyRole ~= 'Tank')) then
        if status == 3 then
            self.ThreatIndicator:SetVertexColor(1, 0, 0)
            self.ThreatIndicator:Show()
        elseif status == 2 or status == 1 then
            self.ThreatIndicator:SetVertexColor(1, 1, 0)
            self.ThreatIndicator:Show()
        end
    end

    if executeIndicator and executeRatio > 0 and healthPerc <= executeRatio then
        self.NameTag:SetTextColor(1, 0, 0)
    else
        self.NameTag:SetTextColor(1, 1, 1)
    end
end

function NAMEPLATE:UpdateThreatColor(_, unit)
    if unit ~= self.unit then
        return
    end

    NAMEPLATE.UpdateColor(self, _, unit)
end

function NAMEPLATE:CreateThreatIndicator(self)
    if not C.DB.Nameplate.ThreatIndicator then
        return
    end

    local frame = CreateFrame('Frame', nil, self)
    frame:SetAllPoints()
    frame:SetFrameLevel(self:GetFrameLevel() - 1)

    local threat = frame:CreateTexture(nil, 'OVERLAY')
    threat:SetPoint('BOTTOMLEFT', frame, 'TOPLEFT', 0, 0)
    threat:SetPoint('BOTTOMRIGHT', frame, 'TOPRIGHT', 0, 0)
    threat:SetHeight(12)
    threat:SetTexture(C.Assets.Texture.Glow)
    threat:Hide()

    self.ThreatIndicator = threat
    self.ThreatIndicator.Override = NAMEPLATE.UpdateThreatColor
end

-- Target indicator
function NAMEPLATE:UpdateFocusColor()
    local unit = self.unit
    if C.DB.Nameplate.ColoredFocus then
        NAMEPLATE.UpdateThreatColor(self, _, unit)
    end
end

function NAMEPLATE:UpdateTargetChange()
    local element = self.TargetIndicator
    local unit = self.unit

    if UnitIsUnit(unit, 'target') and not UnitIsUnit(unit, 'player') then
        element:Show()
        if element.aggroR:IsShown() and not element.animGroupR:IsPlaying() then
            element.animGroupR:Play()
        end
        if element.aggroL:IsShown() and not element.animGroupL:IsPlaying() then
            element.animGroupL:Play()
        end
    else
        element:Hide()
        if element.animGroupR:IsPlaying() then
            element.animGroupR:Stop()
        end
        if element.animGroupL:IsPlaying() then
            element.animGroupL:Stop()
        end
    end

    if C.DB.Nameplate.ColoredTarget then
        NAMEPLATE.UpdateThreatColor(self, _, unit)
    end
end

function NAMEPLATE:UpdateTargetIndicator()
    local element = self.TargetIndicator
    local isNameOnly = self.plateType == 'NameOnly'

    if C.DB.Nameplate.TargetIndicator then
        if isNameOnly then
            element.nameGlow:Show()
            element.Glow:Hide()
            element.aggroL:Hide()
            element.aggroR:Hide()
        else
            element.nameGlow:Hide()
            element.Glow:Show()
            element.aggroL:Show()
            element.aggroR:Show()

            element.animR.points[1]:SetOffset(2, 0)
            element.animL.points[1]:SetOffset(-2, 0)
        end
        element:Show()
    else
        element:Hide()
    end
end

function NAMEPLATE:CreateTargetIndicator(self)
    if not C.DB.Nameplate.TargetIndicator then
        return
    end

    local color = C.DB.Nameplate.TargetIndicatorColor
    local r, g, b = color.r, color.g, color.b

    local frame = CreateFrame('Frame', nil, self)
    frame:SetFrameStrata('BACKGROUND')
    frame:SetAllPoints()
    frame:Hide()

    frame.Glow = frame:CreateTexture(nil, 'BACKGROUND')
    frame.Glow:SetPoint('TOPLEFT', frame, 'BOTTOMLEFT')
    frame.Glow:SetPoint('TOPRIGHT', frame, 'BOTTOMRIGHT')
    frame.Glow:SetHeight(12)
    frame.Glow:SetTexture(C.Assets.Texture.Glow)
    frame.Glow:SetRotation(math.rad(180))
    frame.Glow:SetVertexColor(r, g, b)

    frame.aggroL = frame:CreateTexture(nil, 'BACKGROUND', nil, -5)
    frame.aggroL:SetSize(C.DB.Nameplate.Height * 8, C.DB.Nameplate.Height * 4)
    frame.aggroL:SetPoint('CENTER', frame, 'LEFT', -10, 0)
    frame.aggroL:SetTexture(C.Assets.Texture.Target)

    local animGroupL = frame.aggroL:CreateAnimationGroup()
    animGroupL:SetLooping('REPEAT')
    local anim = animGroupL:CreateAnimation('Path')
    anim:SetSmoothing('IN_OUT')
    anim:SetDuration(1)
    anim.points = {}
    anim.points[1] = anim:CreateControlPoint()
    anim.points[1]:SetOrder(1)
    frame.animL = anim
    frame.animGroupL = animGroupL

    frame.aggroR = frame:CreateTexture(nil, 'BACKGROUND', nil, -5)
    frame.aggroR:SetSize(C.DB.Nameplate.Height * 8, C.DB.Nameplate.Height * 4)
    frame.aggroR:SetPoint('CENTER', frame, 'RIGHT', 10, 0)
    frame.aggroR:SetTexture(C.Assets.Texture.Target)
    frame.aggroR:SetRotation(math.rad(180))

    local animGroupR = frame.aggroR:CreateAnimationGroup()
    animGroupR:SetLooping('REPEAT')
    local anim = animGroupR:CreateAnimation('Path')
    anim:SetDuration(1)
    anim.points = {}
    anim.points[1] = anim:CreateControlPoint()
    anim.points[1]:SetOrder(1)
    frame.animR = anim
    frame.animGroupR = animGroupR

    frame.nameGlow = frame:CreateTexture(nil, 'BACKGROUND', nil, -5)
    frame.nameGlow:SetSize(150, 80)
    frame.nameGlow:SetTexture('Interface\\GLUES\\Models\\UI_Draenei\\GenericGlow64')
    frame.nameGlow:SetVertexColor(0, .6, 1)
    frame.nameGlow:SetBlendMode('ADD')
    frame.nameGlow:SetPoint('CENTER', 0, 14)

    self.TargetIndicator = frame
    self:RegisterEvent('PLAYER_TARGET_CHANGED', NAMEPLATE.UpdateTargetChange, true)

    NAMEPLATE.UpdateTargetIndicator(self)
end

-- Mouseover indicator
function NAMEPLATE:IsMouseoverUnit()
    if not self or not self.unit then
        return
    end

    if self:IsVisible() and UnitExists('mouseover') then
        return UnitIsUnit('mouseover', self.unit)
    end
    return false
end

function NAMEPLATE:HighlightOnUpdate(elapsed)
    self.elapsed = (self.elapsed or 0) + elapsed
    if self.elapsed > .1 then
        if not NAMEPLATE.IsMouseoverUnit(self.__owner) then
            self:Hide()
        end
        self.elapsed = 0
    end
end

function NAMEPLATE:HighlightOnHide()
    self.__owner.HighlightIndicator:Hide()
end

function NAMEPLATE:UpdateMouseoverShown()
    if not self or not self.unit then
        return
    end

    if self:IsShown() and UnitIsUnit('mouseover', self.unit) then
        self.HighlightIndicator:Show()
        self.HighlightUpdater:Show()
    else
        self.HighlightUpdater:Hide()
    end
end

function NAMEPLATE:CreateMouseoverIndicator(self)
    local highlight = CreateFrame('Frame', nil, self.Health)
    highlight:SetAllPoints(self)
    highlight:Hide()
    local texture = highlight:CreateTexture(nil, 'ARTWORK')
    texture:SetAllPoints()
    texture:SetColorTexture(1, 1, 1, .25)

    self:RegisterEvent('UPDATE_MOUSEOVER_UNIT', NAMEPLATE.UpdateMouseoverShown, true)

    local updater = CreateFrame('Frame', nil, self)
    updater.__owner = self
    updater:SetScript('OnUpdate', NAMEPLATE.HighlightOnUpdate)
    updater:HookScript('OnHide', NAMEPLATE.HighlightOnHide)

    self.HighlightIndicator = highlight
    self.HighlightUpdater = updater
end

-- Quest progress
local isInInstance
local function CheckInstanceStatus()
    isInInstance = IsInInstance()
end

function NAMEPLATE:QuestIconCheck()
    if not C.DB.Nameplate.QuestIndicator then
        return
    end

    CheckInstanceStatus()
    F:RegisterEvent('PLAYER_ENTERING_WORLD', CheckInstanceStatus)
end

local function isQuestTitle(textLine)
    local r, g, b = textLine:GetTextColor()
    if r > .99 and g > .82 and b == 0 then
        return true
    end
end

function NAMEPLATE:UpdateQuestUnit(_, unit)
    if not C.DB.Nameplate.QuestIndicator then
        return
    end

    local isNameOnly = self.plateType == 'NameOnly'

    if isInInstance then
        self.questIcon:Hide()
        self.questCount:SetText('')
        return
    end

    unit = unit or self.unit

    local startLooking, questProgress
    F.ScanTip:SetOwner(_G.UIParent, 'ANCHOR_NONE')
    F.ScanTip:SetUnit(unit)

    for i = 2, F.ScanTip:NumLines() do
        local textLine = _G['FreeUIScanTooltipTextLeft' .. i]
        local text = textLine and textLine:GetText()

        if not text then
            break
        end

        if text ~= ' ' then
            if isInGroup and text == C.NAME or (not isInGroup and isQuestTitle(textLine)) then
                startLooking = true
            elseif startLooking then
                local current, goal = string.match(text, '(%d+)/(%d+)')
                local progress = string.match(text, '(%d+)%%')
                if current and goal then
                    local diff = math.floor(goal - current)
                    if diff > 0 then
                        questProgress = diff
                        break
                    end
                elseif progress and not string.match(text, _G.THREAT_TOOLTIP) then
                    if math.floor(100 - progress) > 0 then
                        questProgress = progress .. '%' -- lower priority on progress, keep looking
                    end
                else
                    break
                end
            end
        end
    end

    if questProgress and not isNameOnly then
        self.questCount:SetText(questProgress)
        self.questIcon:SetAtlas('Warfronts-BaseMapIcons-Horde-Barracks-Minimap')
        self.questIcon:Show()
    else
        self.questCount:SetText('')
        self.questIcon:Hide()
    end
end

function NAMEPLATE:CreateQuestIndicator(self)
    if not C.DB.Nameplate.QuestIndicator then
        return
    end

    local height = C.DB.Nameplate.Height
    local qicon = self:CreateTexture(nil, 'OVERLAY', nil, 2)
    qicon:SetPoint('LEFT', self, 'RIGHT', 3, 0)
    qicon:SetSize(height + 10, height + 10)
    qicon:SetAtlas('adventureguide-microbutton-alert')
    qicon:Hide()

    local count = F.CreateFS(self, C.Assets.Font.Condensed, 12, nil, '', nil, true)
    count:SetPoint('LEFT', qicon, 'RIGHT', -3, 0)
    count:SetTextColor(.6, .8, 1)

    self.questIcon = qicon
    self.questCount = count
    self:RegisterEvent('QUEST_LOG_UPDATE', NAMEPLATE.UpdateQuestUnit, true)
end

-- Scale plates for explosives
local hasExplosives
local explosiveID = 120651
function NAMEPLATE:UpdateExplosives(event, unit)
    if not hasExplosives or unit ~= self.unit then
        return
    end

    local scale = _G.UIParent:GetScale()
    local npcID = self.npcID
    if event == 'NAME_PLATE_UNIT_ADDED' and npcID == explosiveID then
        self:SetScale(scale * 2)
    elseif event == 'NAME_PLATE_UNIT_REMOVED' then
        self:SetScale(scale)
    end
end

local function CheckAffixes()
    local _, affixes = C_ChallengeMode.GetActiveKeystoneInfo()
    if affixes[3] and affixes[3] == 13 then
        hasExplosives = true
    else
        hasExplosives = false
    end
end

function NAMEPLATE:CheckExplosives()
    if not C.DB.Nameplate.ExplosiveIndicator then
        return
    end

    CheckAffixes()
    F:RegisterEvent('ZONE_CHANGED_NEW_AREA', CheckAffixes)
    F:RegisterEvent('CHALLENGE_MODE_START', CheckAffixes)
end

-- Major spells glow
NAMEPLATE.MajorSpellsList = {}
function NAMEPLATE:RefreshMajorSpells()
    table.wipe(NAMEPLATE.MajorSpellsList)

    for spellID in pairs(C.NPMajorSpellsList) do
        local name = GetSpellInfo(spellID)
        if name then
            local modValue = _G.FREE_ADB['NPMajorSpells'][spellID]
            if modValue == nil then
                NAMEPLATE.MajorSpellsList[spellID] = true
            end
        end
    end

    for spellID, value in pairs(_G.FREE_ADB['NPMajorSpells']) do
        if value then
            NAMEPLATE.MajorSpellsList[spellID] = true
        end
    end
end

function NAMEPLATE:CheckMajorSpells()
    for spellID in pairs(C.NPMajorSpellsList) do
        local name = GetSpellInfo(spellID)
        if name then
            if _G.FREE_ADB['NPMajorSpells'][spellID] then
                _G.FREE_ADB['NPMajorSpells'][spellID] = nil
            end
        else
            if C.DEV_MODE then
                F:Debug('Invalid Nameplate Major Spells ID', spellID)
            end
        end
    end

    for spellID, value in pairs(_G.FREE_ADB['NPMajorSpells']) do
        if value == false and C.NPMajorSpellsList[spellID] == nil then
            _G.FREE_ADB['NPMajorSpells'][spellID] = nil
        end
    end
end

-- Spiteful indicator
function NAMEPLATE:CreateSpitefulIndicator(self)
    local font = C.Assets.Font.Condensed
    local outline = _G.FREE_ADB.FontOutline

    local tarName = F.CreateFS(self, font, 12, outline, nil, nil, outline or 'THICK')
    tarName:ClearAllPoints()
    tarName:SetPoint('TOP', self, 'BOTTOM', 0, -10)
    tarName:Hide()

    self:Tag(tarName, '[free:tarname]')
    self.tarName = tarName
end

function NAMEPLATE:UpdateSpitefulIndicator()
    if not C.DB.Nameplate.SpitefulIndicator then
        return
    end

    self.tarName:SetShown(C.ShowTargetNPCs[self.npcID])
end

-- Totem icon
local totemsList = {
    -- npcID spellID duration
    [2630] = {2484, 20}, -- Earthbind
    [3527] = {5394, 15}, -- Healing Stream
    [6112] = {8512, 120}, -- Windfury
    [97369] = {192222, 15}, -- Liquid Magma
    [5913] = {8143, 10}, -- Tremor
    [5925] = {204336, 3}, -- Grounding
    [78001] = {157153, 15}, -- Cloudburst
    [53006] = {98008, 6}, -- Spirit Link
    [59764] = {108280, 12}, -- Healing Tide
    [61245] = {192058, 2}, -- Static Charge
    [100943] = {198838, 15}, -- Earthen Wall
    [97285] = {192077, 15}, -- Wind Rush
    [105451] = {204331, 15}, -- Counterstrike
    [104818] = {207399, 30}, -- Ancestral
    [105427] = {204330, 15}, -- Skyfury
    [119052] = {236320, 15}, -- Warrior War Banner
}

local function CreateTotemIcon(self)
    local icon = CreateFrame('Frame', nil, self)
    icon:SetSize(36, 36)
    icon:SetPoint('BOTTOM', self, 'TOP', 0, self.isNameOnly and 12 or 6)

    icon.texure = icon:CreateTexture(nil, 'ARTWORK')
    icon.texure:SetTexCoord(unpack(C.TEX_COORD))
    icon.texure:SetAllPoints()

    F.SetBD(icon)

    return icon
end

-- Overlay
function NAMEPLATE:UpdateOverlayVisibility(self, unit)
    local name = self.unitName
    local npcID = self.npcID
    local isCustomUnit = customUnits[name] or customUnits[npcID]
    if isCustomUnit or UnitIsUnit(unit, 'focus') then
        self.Overlay:Show()
    else
        self.Overlay:Hide()
    end
end

function NAMEPLATE:CreateOverlayTexture(self)
    local overlay = self.Health:CreateTexture(nil, 'OVERLAY')
    overlay:SetAllPoints()
    overlay:SetTexture(C.Assets.Statusbar.Overlay)
    overlay:SetVertexColor(0, 0, 0, .4)
    overlay:Hide()

    self.Overlay = overlay
end

-- Health
function NAMEPLATE:CreateHealthBar(self)
    local health = CreateFrame('StatusBar', nil, self)
    health:SetAllPoints()
    health:SetStatusBarTexture(NAMEPLATE.StatusBarTex)
    health.backdrop = F.SetBD(health)
    health.backdrop:SetBackdropColor(0, 0, 0, .6)
    health.backdrop:SetBackdropBorderColor(0, 0, 0, 1)

    health.Smooth = C.DB.Unitframe.Smooth

    self.Health = health
    self.Health.UpdateColor = NAMEPLATE.UpdateColor
end

--[[ Create plate ]]
local platesList = {}
function NAMEPLATE:CreateNameplateStyle()
    self.unitStyle = 'nameplate'

    self:SetSize(C.DB.Nameplate.Width, C.DB.Nameplate.Height)
    self:SetPoint('CENTER')
    self:SetScale(_G.UIParent:GetScale())

    NAMEPLATE:CreateHealthBar(self)
    NAMEPLATE:CreateNameTag(self)
    UNITFRAME:CreateHealthTag(self)
    UNITFRAME:CreateHealPrediction(self)
    NAMEPLATE:CreateOverlayTexture(self)
    NAMEPLATE:CreateTargetIndicator(self)
    NAMEPLATE:CreateMouseoverIndicator(self)
    -- NAMEPLATE:CreateClassifyIndicator(self)
    NAMEPLATE:CreateThreatIndicator(self)
    NAMEPLATE:CreateQuestIndicator(self)
    UNITFRAME:CreateNamePlateCastBar(self)
    NAMEPLATE:CreateRaidTargetIndicator(self)
    NAMEPLATE:CreateAuras(self)
    NAMEPLATE:CreateSpitefulIndicator(self)

    self:RegisterEvent('PLAYER_FOCUS_CHANGED', NAMEPLATE.UpdateFocusColor, true)

    platesList[self] = self:GetName()
end

function NAMEPLATE:UpdateClickableSize()
    if InCombatLockdown() then
        return
    end

    local scale = _G.FREE_ADB.UIScale
    local harmWidth, harmHeight = C.DB.Nameplate.ClickableWidth, C.DB.Nameplate.ClickableHeight
    local helpWidth, helpHeight = C.DB.Nameplate.FriendlyClickableWidth, C.DB.Nameplate.FriendlyClickableHeight

    C_NamePlate.SetNamePlateEnemySize(harmWidth * scale, harmHeight * scale)
    C_NamePlate.SetNamePlateFriendlySize(helpWidth * scale, helpHeight * scale)
end

function NAMEPLATE:ToggleNameplateAuras()
    if C.DB.Nameplate.ShowAura then
        if not self:IsElementEnabled('Auras') then
            self:EnableElement('Auras')
        end
    else
        if self:IsElementEnabled('Auras') then
            self:DisableElement('Auras')
        end
    end
end

function NAMEPLATE:UpdateNameplateAuras()
    NAMEPLATE.ToggleNameplateAuras(self)

    if not C.DB.Nameplate.ShowAura then
        return
    end

    local element = self.Auras
    element:SetPoint('BOTTOM', self, 'TOP', 0, 8)
    element.numTotal = C.DB.Nameplate.AuraNumTotal
    element:SetWidth(self:GetWidth())
    element:SetHeight((element.size + element.spacing) * 2)
    element:ForceUpdate()
end

function NAMEPLATE:UpdateNameplateSize()
    local isFriendly = C.DB.Nameplate.FriendlyPlate and not C.DB.Nameplate.NameOnlyMode and self.isFriendly
    local width = isFriendly and C.DB.Nameplate.FriendlyWidth or C.DB.Nameplate.Width
    local height = isFriendly and C.DB.Nameplate.FriendlyHeight or C.DB.Nameplate.Height

    self:SetSize(width, height)
end

function NAMEPLATE:RefreshNameplats()
    for nameplate in pairs(platesList) do
        NAMEPLATE.UpdateNameplateSize(nameplate)
        NAMEPLATE.UpdateNameplateAuras(nameplate)
        NAMEPLATE.UpdateTargetIndicator(nameplate)
        NAMEPLATE.UpdateTargetChange(nameplate)
    end
    NAMEPLATE:UpdateClickableSize()
end

function NAMEPLATE:RefreshAllPlates()
    NAMEPLATE:RefreshNameplats()
end

local disabledElements = {
    'Health',
    'Castbar',
    'HealPredictionAndAbsorb',
    'PvPClassificationIndicator',
    'ThreatIndicator'
}

function NAMEPLATE:UpdatePlateByType()
    -- local nameOnlyName = self.nameOnlyName
    local name = self.NameTag

    local raidtarget = self.RaidTargetIndicator
    local questIcon = self.questIcon
    local outline = _G.FREE_ADB.FontOutline

    name:SetShown(not self.widgetsOnly)
    name:ClearAllPoints()
    raidtarget:ClearAllPoints()

    if self.plateType == 'NameOnly' then
        for _, element in pairs(disabledElements) do
            if self:IsElementEnabled(element) then
                self:DisableElement(element)
            end
        end

        name:SetJustifyH('CENTER')
        self:Tag(name, '[free:color][free:npnamelong]')
        self.__tagIndex = 6
        name:UpdateTag()
        name:SetParent(self)
        name:SetPoint('CENTER', self, 'TOP', 0, 8)
        F:SetFS(name, C.Assets.Font.Header, 16, nil, nil, nil, 'THICK')

        -- raidtarget:SetPoint('BOTTOM', name, 'TOP', 0, -5)
        -- raidtarget:SetParent(self)

        NAMEPLATE.UpdateRaidTargetIndicator(self)

        if questIcon then
            questIcon:SetPoint('LEFT', name, 'RIGHT', -1, 0)
        end

        if self.widgetContainer then
            self.widgetContainer:ClearAllPoints()
            self.widgetContainer:SetPoint('TOP', name, 'BOTTOM', 0, -5)
        end
    else
        for _, element in pairs(disabledElements) do
            if not self:IsElementEnabled(element) then
                self:EnableElement(element)
            end
        end

        name:SetJustifyH('LEFT')
        self:Tag(name, '[free:classification][free:npname]')
        name:UpdateTag()
        name:SetParent(self.Health)
        name:SetPoint('LEFT', self, 'TOPLEFT')
        F:SetFS(name, C.Assets.Font.Bold, 11, outline, nil, nil, outline or 'THICK')

        -- raidtarget:SetPoint('CENTER')
        -- raidtarget:SetParent(self.Health)

        NAMEPLATE.UpdateRaidTargetIndicator(self)

        if questIcon then
            questIcon:SetPoint('LEFT', self, 'RIGHT', 3, 0)
        end

        if self.widgetContainer then
            self.widgetContainer:ClearAllPoints()
            self.widgetContainer:SetPoint('TOP', self.Castbar, 'BOTTOM', 0, -5)
        end

        NAMEPLATE.UpdateNameplateSize(self)
    end

    NAMEPLATE.UpdateTargetIndicator(self)
    NAMEPLATE.ToggleNameplateAuras(self)
end

function NAMEPLATE:RefreshPlateType(unit)
    self.reaction = UnitReaction(unit, 'player')
    self.isFriendly = self.reaction and self.reaction >= 4 and not UnitCanAttack('player', unit)

    if C.DB.Nameplate.NameOnlyMode and self.isFriendly or self.widgetsOnly then
        self.plateType = 'NameOnly'
    elseif C.DB.Nameplate.FriendlyPlate and self.isFriendly then
        self.plateType = 'FriendlyPlate'
    else
        self.plateType = 'None'
    end

    if self.previousType == nil or self.previousType ~= self.plateType then
        NAMEPLATE.UpdatePlateByType(self)
        self.previousType = self.plateType
    end
end

function NAMEPLATE:OnUnitFactionChanged(unit)
    local nameplate = C_NamePlate.GetNamePlateForUnit(unit, issecure())
    local unitFrame = nameplate and nameplate.unitFrame
    if unitFrame and unitFrame.unitName then
        NAMEPLATE.RefreshPlateType(unitFrame, unit)
    end
end

function NAMEPLATE:RefreshPlateOnFactionChanged()
    F:RegisterEvent('UNIT_FACTION', NAMEPLATE.OnUnitFactionChanged)
end

function NAMEPLATE:PostUpdatePlates(event, unit)
    if not self then
        return
    end

    if event == 'NAME_PLATE_UNIT_ADDED' then
        self.unitName = UnitName(unit)
        self.unitGUID = UnitGUID(unit)
        self.isPlayer = UnitIsPlayer(unit)
        self.npcID = F:GetNpcId(self.unitGUID)
        self.widgetsOnly = UnitNameplateShowsWidgetsOnly(unit)

        local blizzPlate = self:GetParent().UnitFrame
        self.widgetContainer = blizzPlate and blizzPlate.WidgetContainer
        if self.widgetContainer then
            self.widgetContainer:SetParent(self)
            -- self.widgetContainer:SetScale(_G.FREE_ADB.UIScale)
        end

        NAMEPLATE.RefreshPlateType(self, unit)

        if C.DB.Nameplate.TotemIcon and self.npcID and totemsList[self.npcID] then
            if not self.TotemIcon then
                self.TotemIcon = CreateTotemIcon(self)
            end

            self.TotemIcon:Show()

            local totemData = totemsList[self.npcID]
            local spellID, _ = unpack(totemData)
            local texure = GetSpellTexture(spellID)

            self.TotemIcon.texure:SetTexture(texure)

            if self.NameTag then
                self.NameTag:Hide()
            end
        else
            if self.NameTag then
                self.NameTag:Show()
            end
        end
    elseif event == 'NAME_PLATE_UNIT_REMOVED' then
        self.npcID = nil

        if self.TotemIcon then
            self.TotemIcon:Hide()
        end
    end

    if event ~= 'NAME_PLATE_UNIT_REMOVED' then
        NAMEPLATE.UpdateTargetChange(self)
        NAMEPLATE.UpdateUnitClassify(self, unit)
        NAMEPLATE.UpdateQuestUnit(self, event, unit)
        NAMEPLATE.UpdateSpitefulIndicator(self)
    end

    NAMEPLATE.UpdateExplosives(self, event, unit)
end

function NAMEPLATE:OnLogin()
    if not C.DB.Nameplate.Enable then
        return
    end

    NAMEPLATE:UpdateClickableSize()
    hooksecurefunc(_G.NamePlateDriverFrame, 'UpdateNamePlateOptions', NAMEPLATE.UpdateClickableSize)

    NAMEPLATE:UpdateNameplateCVars()
    NAMEPLATE:BlockAddons()
    NAMEPLATE:CreateUnitTable()
    NAMEPLATE:CreatePowerUnitTable()
    NAMEPLATE:CheckExplosives()
    NAMEPLATE:UpdateGroupRoles()
    NAMEPLATE:RefreshPlateOnFactionChanged()
    NAMEPLATE:CheckMajorSpells()
    NAMEPLATE:RefreshMajorSpells()

    oUF:RegisterStyle('Nameplate', NAMEPLATE.CreateNameplateStyle)
    oUF:SetActiveStyle('Nameplate')
    oUF:SpawnNamePlates('oUF_Nameplate', NAMEPLATE.PostUpdatePlates)
end

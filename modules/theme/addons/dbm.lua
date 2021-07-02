local _G = _G
local select = select
local unpack = unpack
local strfind = strfind
local strmatch = strmatch
local gsub = gsub
local IsAddOnLoaded = IsAddOnLoaded
local hooksecurefunc = hooksecurefunc

local F, C = unpack(select(2, ...))
local THEME = F:GetModule('Theme')

local buttonSize = 18

local function ReskinIcon(icon, frame)
    if not icon then
        return
    end

    if not icon.styled then
        icon:SetSize(buttonSize, buttonSize)
        icon.SetSize = F.Dummy

        local bg = F.ReskinIcon(icon, true)
        bg.icon = bg:CreateTexture(nil, 'ARTWORK')
        bg.icon:SetInside()
        bg.icon:SetTexture(icon:GetTexture())
        bg.icon:SetTexCoord(unpack(C.TexCoord))

        icon.styled = true
    end

    icon:ClearAllPoints()
    icon:SetPoint('BOTTOMRIGHT', frame, 'BOTTOMLEFT', -2, 0)
end

local function ReskinBar(bar, frame)
    if not bar then
        return
    end

    if not bar.styled then
        F.StripTextures(bar)
        F.CreateSB(bar, true)

        bar.styled = true
    end

    bar:SetInside(frame, 2, 2)
end

local function RemoveSpark(self)
    local spark = _G[self.frame:GetName() .. 'BarSpark']
    spark:SetAlpha(0)
    spark:SetTexture(nil)
end

local function ApplyStyle(self)
    local frame = self.frame
    local frame_name = frame:GetName()
    local tbar = _G[frame_name .. 'Bar']
    local texture = _G[frame_name .. 'BarTexture']
    local icon1 = _G[frame_name .. 'BarIcon1']
    local icon2 = _G[frame_name .. 'BarIcon2']
    local name = _G[frame_name .. 'BarName']
    local timer = _G[frame_name .. 'BarTimer']

    if self.enlarged then
        frame:SetWidth(self.owner.Options.HugeWidth)
        tbar:SetWidth(self.owner.Options.HugeWidth)
    else
        frame:SetWidth(self.owner.Options.Width)
        tbar:SetWidth(self.owner.Options.Width)
    end

    frame:SetScale(1)
    frame:SetHeight(buttonSize * .6)

    ReskinIcon(icon1, frame)
    ReskinIcon(icon2, frame)
    ReskinBar(tbar, frame)

    if texture then
        texture:SetTexture(C.Assets.statusbar_tex)
    end

    name:ClearAllPoints()
    name:SetPoint('LEFT', frame, 'LEFT', 2, 6)
    name:SetPoint('RIGHT', frame, 'LEFT', tbar:GetWidth() * .85, 6)
    name:SetFont(C.Assets.Fonts.Condensed, 12, nil, nil, nil, nil, 'THICK')
    name:SetJustifyH('LEFT')
    name:SetWordWrap(false)

    timer:ClearAllPoints()
    timer:SetPoint('RIGHT', frame, 'RIGHT', -2, 6)
    timer:SetFont(C.Assets.Fonts.Condensed, 12, nil, nil, nil, nil, 'THICK')
    timer:SetJustifyH('RIGHT')
end

local function ForceSetting()
    if not _G.DBM_AllSavedOptions['Default'] then
        _G.DBM_AllSavedOptions['Default'] = {}
    end

    _G.DBM_AllSavedOptions['Default']['BlockVersionUpdateNotice'] = true
    _G.DBM_AllSavedOptions['Default']['EventSoundVictory'] = 'None'

    if IsAddOnLoaded('DBM-VPYike') then
        _G.DBM_AllSavedOptions['Default']['CountdownVoice'] = 'VP:Yike'
        _G.DBM_AllSavedOptions['Default']['ChosenVoicePack'] = 'Yike'
    end

    if not _G.DBT_AllPersistentOptions['Default'] then
        _G.DBT_AllPersistentOptions['Default'] = {}
    end

    _G.DBT_AllPersistentOptions['Default']['DBM'].BarYOffset = 10
    _G.DBT_AllPersistentOptions['Default']['DBM'].HugeBarYOffset = 10
    _G.DBT_AllPersistentOptions['Default']['DBM'].ExpandUpwards = true
    _G.DBT_AllPersistentOptions['Default']['DBM'].ExpandUpwardsLarge = true
end

function THEME:ReskinDBM()
    -- Default notice message
    local RaidNotice_AddMessage_ = _G.RaidNotice_AddMessage
    _G.RaidNotice_AddMessage = function(noticeFrame, textString, colorInfo)
        if strfind(textString, '|T') then
            if strmatch(textString, ':(%d+):(%d+)') then
                local size1, size2 = strmatch(textString, ':(%d+):(%d+)')
                size1, size2 = size1 + 3, size2 + 3
                textString = gsub(textString, ':(%d+):(%d+)', ':' .. size1 .. ':' .. size2 .. ':0:0:64:64:5:59:5:59')
            elseif strmatch(textString, ':(%d+)|t') then
                local size = strmatch(textString, ':(%d+)|t')
                size = size + 3
                textString = gsub(textString, ':(%d+)|t', ':' .. size .. ':' .. size .. ':0:0:64:64:5:59:5:59|t')
            end
        end
        return RaidNotice_AddMessage_(noticeFrame, textString, colorInfo)
    end

    if not IsAddOnLoaded('DBM-Core') then
        return
    end

    if not _G.FREE_ADB.ReskinAddons then
        return
    end

    hooksecurefunc(_G.DBT, 'CreateBar', function(self)
        for bar in self:GetBarIterator() do
            if not bar.injected then
                hooksecurefunc(bar, 'Update', RemoveSpark)
                hooksecurefunc(bar, 'ApplyStyle', ApplyStyle)
                bar:ApplyStyle()

                bar.injected = true
            end
        end
    end)

    hooksecurefunc(_G.DBM.RangeCheck, 'Show', function()
        if _G.DBMRangeCheckRadar and not _G.DBMRangeCheckRadar.styled then
            F:GetModule('Tooltip').ReskinTooltip(_G.DBMRangeCheckRadar)
            _G.DBMRangeCheckRadar.styled = true
        end

        if _G.DBMRangeCheck and not _G.DBMRangeCheck.styled then
            F:GetModule('Tooltip').ReskinTooltip(_G.DBMRangeCheck)
            _G.DBMRangeCheck.styled = true
        end
    end)

    if _G.DBM.InfoFrame then
        _G.DBM.InfoFrame:Show(5, 'test')
        _G.DBM.InfoFrame:Hide()
        _G.DBMInfoFrame:HookScript('OnShow', F:GetModule('Tooltip').ReskinTooltip)
    end

    ForceSetting()
end

local F, C, L = unpack(select(2, ...))
local BLIZZARD = F:GetModule('Blizzard')

local WOW_PROJECT_CLASSIC_TBC = 5
local mediaPath = 'Interface\\AddOns\\FreeUI\\assets\\textures\\client\\'

local gameIcons = {
    [_G.BNET_CLIENT_WOW] = mediaPath .. 'WoWSL',
    [_G.BNET_CLIENT_WOW .. 'C'] = mediaPath .. 'WoW',
    [_G.BNET_CLIENT_WOW .. 'C_TBC'] = mediaPath .. 'WoWC',
    [_G.BNET_CLIENT_D2] = mediaPath .. 'D2',
    [_G.BNET_CLIENT_D3] = mediaPath .. 'D3',
    [_G.BNET_CLIENT_WTCG] = mediaPath .. 'HS',
    [_G.BNET_CLIENT_SC] = mediaPath .. 'SC',
    [_G.BNET_CLIENT_SC2] = mediaPath .. 'SC2',
    [_G.BNET_CLIENT_APP] = mediaPath .. 'App',
    ['BSAp'] = mediaPath .. 'Mobile',
    [_G.BNET_CLIENT_HEROES] = mediaPath .. 'HotS',
    [_G.BNET_CLIENT_OVERWATCH] = mediaPath .. 'OW',
    [_G.BNET_CLIENT_COD] = mediaPath .. 'COD',
    [_G.BNET_CLIENT_COD_BOCW] = mediaPath .. 'COD_CW',
    [_G.BNET_CLIENT_COD_MW] = mediaPath .. 'COD_MW',
    [_G.BNET_CLIENT_COD_MW2] = mediaPath .. 'COD_MW2',
    [_G.BNET_CLIENT_WC3] = mediaPath .. 'WC3',
    [_G.BNET_CLIENT_CLNT] = _G.BNet_GetClientTexture(_G.BNET_CLIENT_CLNT),
    [_G.BNET_CLIENT_CRASH4] = mediaPath .. 'CRASH4',
    [_G.BNET_CLIENT_ARCADE] = _G.BNet_GetClientTexture(_G.BNET_CLIENT_ARCADE),
    [_G.BNET_CLIENT_COD_VANGUARD] = mediaPath .. 'COD_VG',
}

local statusIcons = {
    ['Online'] = _G.FRIENDS_TEXTURE_ONLINE,
    ['Offline'] = _G.FRIENDS_TEXTURE_OFFLINE,
    ['DND'] = _G.FRIENDS_TEXTURE_DND,
    ['AFK'] = _G.FRIENDS_TEXTURE_AFK
}

local regionLocales = {
    [1] = L['America'],
    [2] = L['Korea'],
    [3] = L['Europe'],
    [4] = L['Taiwan'],
    [5] = L['China']}

local maxLevel = {
    [_G.BNET_CLIENT_WOW .. 'C'] = 60,
    [_G.BNET_CLIENT_WOW .. 'C_TBC'] = 70,
    [_G.BNET_CLIENT_WOW] = GetMaxLevelForPlayerExpansion()
}

local clientColor = {
    [_G.BNET_CLIENT_ARCADE] = {r = 0.509, g = 0.772, b = 1}, -- Arcade
    [_G.BNET_CLIENT_CRASH4] = {r = 0.509, g = 0.772, b = 1}, -- Crash
    [_G.BNET_CLIENT_CLNT] = {r = 0.509, g = 0.772, b = 1}, -- 未知
    [_G.BNET_CLIENT_APP] = {r = 0.509, g = 0.772, b = 1}, -- 战网
    [_G.BNET_CLIENT_WC3] = {r = 0.796, g = 0.247, b = 0.145}, -- 魔兽争霸重置版 3
    [_G.BNET_CLIENT_SC] = {r = 0.749, g = 0.501, b = 0.878}, -- 星际争霸 1
    [_G.BNET_CLIENT_SC2] = {r = 0.749, g = 0.501, b = 0.878}, -- 星际争霸 2
    [_G.BNET_CLIENT_D3] = {r = 0.768, g = 0.121, b = 0.231}, -- 暗黑破坏神 3
    [_G.BNET_CLIENT_WOW] = {r = 0.866, g = 0.690, b = 0.180}, -- 魔兽世界
    [_G.BNET_CLIENT_WTCG] = {r = 1, g = 0.694, b = 0}, -- 炉石传说
    [_G.BNET_CLIENT_HEROES] = {r = 0, g = 0.8, b = 1}, -- 风暴英雄
    [_G.BNET_CLIENT_OVERWATCH] = {r = 1, g = 1, b = 1}, -- 守望先锋
    [_G.BNET_CLIENT_COD] = {r = 0, g = 0.8, b = 0}, -- 使命召唤
    [_G.BNET_CLIENT_COD_MW] = {r = 0, g = 0.8, b = 0}, -- 使命召唤：现代战争
    [_G.BNET_CLIENT_COD_MW2] = {r = 0, g = 0.8, b = 0}, -- 使命召唤：现代战争 2
    [_G.BNET_CLIENT_COD_BOCW] = {r = 0, g = 0.8, b = 0}, -- 使命召唤：冷战
    [_G.BNET_CLIENT_WOW .. 'C'] = {r = 0.866, g = 0.690, b = 0.180}, -- 魔兽世界怀旧版
    ['BSAp'] = {r = 0.509, g = 0.772, b = 1}, -- 手机战网 App
}

local function GetClassColor(className)
    for class, localizedName in pairs(_G.LOCALIZED_CLASS_NAMES_MALE) do
        if className == localizedName then
            return C.ClassColors[class]
        end
    end

    -- 德语及法语有分性别的职业名
    if GetLocale() == 'deDE' or GetLocale() == 'frFR' then
        for class, localizedName in pairs(_G.LOCALIZED_CLASS_NAMES_FEMALE) do
            if className == localizedName then
                return C.ClassColors[class]
            end
        end
    end
end

local function UpdateFriendButton(button)
    if button.buttonType == _G.FRIENDS_BUTTON_TYPE_DIVIDER then
        return
    end

    local game, realID, name, server, class, area, level, status, isInCurrentRegion, regionID

    -- 获取好友游戏情况
    if button.buttonType == _G.FRIENDS_BUTTON_TYPE_WOW then
        -- 角色游戏好友
        game = _G.BNET_CLIENT_WOW
        local friendInfo = C_FriendList.GetFriendInfoByIndex(button.id)
        name, server = string.split('-', friendInfo.name) -- 如果是同一个服务器，server 为 nil
        level = friendInfo.level
        class = friendInfo.className
        area = friendInfo.area
        -- faction = C.FACTION -- 同一阵营才能加好友的吧？

        if friendInfo.connected then
            if friendInfo.afk then
                status = 'AFK'
            elseif friendInfo.dnd then
                status = 'DND'
            else
                status = 'Online'
            end
        else
            status = 'Offline'
        end
    elseif button.buttonType == _G.FRIENDS_BUTTON_TYPE_BNET and BNConnected() then
        -- 战网好友
        local friendAccountInfo = C_BattleNet.GetFriendAccountInfo(button.id)
        if friendAccountInfo then
            realID = friendAccountInfo.accountName

            local gameAccountInfo = friendAccountInfo.gameAccountInfo
            game = gameAccountInfo.clientProgram

            if gameAccountInfo.isOnline then
                if friendAccountInfo.isAFK or gameAccountInfo.isGameAFK then
                    status = 'AFK'
                elseif friendAccountInfo.isDND or gameAccountInfo.isGameBusy then
                    status = 'DND'
                else
                    status = 'Online'
                end
            else
                status = 'Offline'
            end

            -- Fetch version if friend playing WoW
            if game == _G.BNET_CLIENT_WOW then
                name = gameAccountInfo.characterName or ''
                level = gameAccountInfo.characterLevel or 0
                -- faction = gameAccountInfo.factionName or nil
                class = gameAccountInfo.className or ''
                area = gameAccountInfo.areaName or ''
                isInCurrentRegion = gameAccountInfo.isInCurrentRegion or false
                regionID = gameAccountInfo.regionID or false

                if gameAccountInfo.wowProjectID == _G.WOW_PROJECT_CLASSIC then
                    game = _G.BNET_CLIENT_WOW .. 'C' -- Classic
                    local serverStrings = {string.split(' - ', gameAccountInfo.richPresence)}
                    server = serverStrings[#serverStrings] or _G.BNET_FRIEND_TOOLTIP_WOW_CLASSIC
                    server = server .. '*'
                elseif gameAccountInfo.wowProjectID == WOW_PROJECT_CLASSIC_TBC then
                    game = _G.BNET_CLIENT_WOW .. 'C_TBC' -- TBC
                    local serverStrings = {string.split(' - ', gameAccountInfo.richPresence)}
                    server = serverStrings[#serverStrings] or _G.BNET_FRIEND_TOOLTIP_WOW_CLASSIC .. ' (' .. _G.CINEMATIC_NAME_2 .. ')'
                    server = server .. '*'
                else
                    server = gameAccountInfo.realmDisplayName or ''
                end
            end
        end
    end

    -- 状态图标
    if status then
        button.status:SetTexture(statusIcons[status])
    end

    if game and game ~= '' then
        local buttonTitle, buttonText

        -- 名字
        local realIDString = realID and F:CreateColorString(realID, clientColor[game]) or realID
        local nameString = name
        local classColor = GetClassColor(class)
        if classColor then
            nameString = F:CreateColorString(name, classColor)
        end

        if level and level ~= 0 and maxLevel[game] and (level ~= maxLevel[game]) then
            nameString = nameString .. F:CreateColorString(' ' .. level, GetQuestDifficultyColor(level))
        end

        if nameString and realIDString then
            buttonTitle = realIDString .. '  ' .. nameString
        elseif nameString then
            buttonTitle = nameString
        else
            buttonTitle = realIDString or ''
        end

        button.name:SetText(buttonTitle)

        -- 地区
        if area then
            if server and server ~= '' and server ~= C.REALM then
                buttonText = F:CreateColorString(area .. ' - ' .. server, {r = .8, g = .8, b = .8})
            else
                buttonText = F:CreateColorString(area, {r = .8, g = .8, b = .8})
            end

            if not isInCurrentRegion and regionLocales[regionID] then
                buttonText = buttonText .. ' ' .. F.CreateColorString(string.format('[%s]', regionLocales[regionID]), {r = 0.62, g = 0.62, b = 0.62})
            end

            button.info:SetText(buttonText)
        end

        -- 游戏图标
        local iconTex = gameIcons[game] or _G.BNet_GetClientTexture(game)
        button.gameIcon:SetTexture(iconTex)
        button.gameIcon:Show() -- 普通角色好友暴雪隐藏了
        button.gameIcon:SetAlpha(1)

        if button.summonButton:IsShown() then
            button.gameIcon:Hide()
        else
            button.gameIcon:Show()
            button.gameIcon:SetPoint('TOPRIGHT', -21, -2)
        end
    end

    F:SetFS(button.name, C.Assets.Font.Bold, 13, nil, nil, nil, true)
    F:SetFS(button.info, C.Assets.Font.Condensed, 12, nil, nil, nil, true)

    if button.Favorite:IsShown() then
        button.Favorite:ClearAllPoints()
        button.Favorite:SetPoint('LEFT', button.name, 'LEFT', button.name:GetStringWidth(), 0)
    end
end

function BLIZZARD:EnhancedFriendsList()
    hooksecurefunc('FriendsFrame_UpdateFriendButton', UpdateFriendButton)
    _G.FriendsFrame_Update()
end

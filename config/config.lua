local _, C = unpack(select(2, ...))

C.CharacterSettings = {
    ShadowLands = false,
    InstallationComplete = false,
    UIAnchor = {},
    UIAnchorTemp = {},
    General = {
        HideTalkingHead = true,
        HideBossBanner = false,
        HideBossEmote = true,

        SimplifyErrors = true,

        OrderHallIcon = true,
        TradeTabs = true,
        PetFilter = true,
        NakedButton = true,
        MissingStats = true,
        ItemLevel = true,
        GemEnchant = true,
        AzeriteTrait = true,
        AutoScreenshot = true,
        EarnedNewAchievement = true,
        ChallengeModeCompleted = true,
        PlayerLevelUp = false,
        PlayerDead = false,
        FasterZooming = true,
        ActionCamera = false,
        CursorTrail = true,
        Vignetting = true,
        VignettingAlpha = 0.85,
        FasterMovieSkip = true,
        ScreenSaver = true,
        ProposalTimer = true,

        EnhancedMerchant = true,
        EnhancedFriendsList = true,
        EnhancedDressup = true,
        EnhancedLoot = true,
        EnhancedMailBox = true,
        SaveRecipient = false,
        RecipientList = '',
        EnhancedPremade = true,

        GameMenu = true,
        GameMenuClassColor = true,
        GameMenuBackdrop = true,
        GameMenuBackdropAlpha = 0.35,
        GameMenuButtonSize = 20,
        GameMenuButtonOutAlpha = 0.4,
        GameMenuButtonInAlpha = 1,
        GameMenuSmooth = 0.5,
        GameMenuButtonGap = 2,
        GameMenuBarHeight = 22,
        GroupTool = true,
        RuneCheck = false,
        Countdown = '10',
    },
    Combat = {
        Enable = true,
        CombatAlert = true,
        AlertScale = 0.4,
        AlertSpeed = 1,
        SoundAlert = true,
        Interrupt = true,
        Dispel = true,
        SpellSteal = true,
        SpellMiss = true,
        LowHealth = true,
        LowHealthThreshold = 0.3,
        LowMana = true,
        LowManaThreshold = 0.3,
        PvPSound = true,
        SmartTab = true,
        EasyMark = true,
        EasyMarkKey = 1,
        EasyFocus = true,
        EasyFocusKey = 3,
        EasyFocusOnUnitframe = false,
        SimpleFloatingCombatText = true,
        Pet = true,
        Periodic = true,
        Merge = true,
        Incoming = true,
        Outgoing = false,
        CooldownPulse = true,
        BuffReminder = true,
    },
    Announcement = {
        Enable = true,
        Channel = 4,
        Spells = true,
        Interrupt = true,
        Dispel = true,
        Stolen = true,
        Reflect = true,
        Quest = false,
        Reset = true,
    },
    Aura = {
        Enable = true,
        Margin = 6,
        Offset = 12,
        BuffSize = 40,
        BuffPerRow = 12,
        BuffReverse = true,
        DebuffSize = 50,
        DebuffPerRow = 12,
        DebuffReverse = true,
        HideBlizFrame = false,
    },
    Inventory = {
        Enable = true,
        Offset = 26,
        Spacing = 3,
        SlotSize = 44,
        BagColumns = 10,
        BankColumns = 10,
        BagsPerRow = 6,
        BankPerRow = 10,
        HideWidgets = true,
        SortMode = 2,
        ItemLevel = true,
        MinItemLevelToShow = 1,
        NewItemFlash = true,
        BindType = true,
        CombineFreeSlots = true,
        AutoDeposit = false,
        SpecialBagsColor = true,
        CustomItemsList = {},
        CustomNamesList = {},
        ItemFilter = true,
        FilterEquipSet = true,
        FilterTradeGoods = true,
        FilterQuestItem = true,
        FilterJunk = true,
        FilterAzeriteArmor = true,
        FilterEquipment = true,
        FilterConsumable = true,
        FilterLegendary = true,
        FilterCollection = true,
        FilterFavourite = true,
        FilterAnima = true,
        FilterRelic = true,
        AutoSellJunk = true,
        AutoRepair = true,
    },
    Unitframe = {
        Enable = true,
        TextureStyle = 1,
        ColorStyle = 2,
        InvertedColorMode = true,
        Smooth = true,
        Portrait = true,
        HealthColor = { r = 0.82, g = 0.8, b = 0.77 },
        InvertedHealthColor = { r = 0.1, g = 0.1, b = 0.1 },
        InvertedHealthAlpha = 0.8,
        FrequentHealth = false,
        HealthFrequency = 0.2,

        Fader = true,
        MinAlpha = 0,
        MaxAlpha = 1,
        Delay = 0,
        Instance = true,
        Hover = true,
        Combat = true,
        Target = true,
        Focus = true,
        Health = true,
        Casting = true,

        AbbrName = true,
        RangeCheck = true,
        OutRangeAlpha = 0.4,
        GCDIndicator = true,

        HidePlayerTags = true,

        ClassPower = true,
        ClassPowerHeight = 2,
        RunesTimer = false,

        Castbar = true,
        SeparateCastbar = false,
        CastingColor = { r = 0.31, g = 0.48, b = 0.85 },
        UninterruptibleColor = { r = 0.66, g = 0.65, b = 0.65 },
        CompleteColor = { r = 0.25, g = 0.63, b = 0.49 },
        FailColor = { r = 0.73, g = 0.39, b = 0.43 },
        PlayerCastbarWidth = 200,
        PlayerCastbarHeight = 16,
        TargetCastbarWidth = 160,
        TargetCastbarHeight = 10,
        FocusCastbarWidth = 200,
        FocusCastbarHeight = 16,

        AltPowerHeight = 2,

        PlayerWidth = 160,
        PlayerHealthHeight = 4,
        PlayerPowerHeight = 1,
        PlayerAuraPerRow = 0,

        PetWidth = 60,
        PetHealthHeight = 4,
        PetPowerHeight = 1,
        PetAuraPerRow = 3,

        TargetWidth = 160,
        TargetHealthHeight = 4,
        TargetPowerHeight = 1,
        TargetAuraPerRow = 6,

        TargetTargetWidth = 60,
        TargetTargetHealthHeight = 4,
        TargetTargetPowerHeight = 1,
        TargetTargetAuraPerRow = 3,

        FocusWidth = 60,
        FocusHealthHeight = 4,
        FocusPowerHeight = 1,
        FocusAuraPerRow = 3,

        FocusTargetWidth = 60,
        FocusTargetHealthHeight = 4,
        FocusTargetPowerHeight = 1,
        FocusTargetAuraPerRow = 0,

        OnlyShowPlayer = true,
        DesaturateIcon = true,
        DebuffTypeColor = true,
        StealableBuffs = true,

        SimpleMode = false,
        SMRScale = 10,
        SMRPerCol = 20,
        SMRGroupBy = 1,
        SMRGroups = 6,
        SMRDirec = 1,

        PartyFrame = true,
        ShowSolo = false,
        PartyDirec = 2,
        DescRole = false,
        PartyWidth = 100,
        PartyHealthHeight = 30,
        PartyPowerHeight = 2,
        PartyNameLength = 4,
        PartyWatcher = true,
        PartyWatcherSync = true,
        PartyWatcherOnRight = false,
        PartyWatcherSize = 26,
        PartyBuff = true,
        PartyBuffSize = 16,
        PartyBuffNum = 3,
        PartyDebuff = true,
        PartyDebuffSize = 16,
        PartyDebuffNum = 3,
        PartyAura = true,
        PartyAuraSize = 26,
        PartyAuraNum = 4,

        RaidFrame = true,
        RaidColorStyle = 2,
        TeamIndex = false,
        RaidDirec = 2,
        RaidRows = 1,
        NumGroups = 6,
        RaidWidth = 38,
        RaidHealthHeight = 30,
        RaidPowerHeight = 2,
        RaidNameLength = 2,
        RaidBuff = false,
        RaidBuffSize = 12,
        RaidBuffNum = 3,
        RaidDebuff = false,
        RaidDebuffSize = 12,
        RaidDebuffNum = 3,

        RaidTargetIndicator = true,
        ThreatIndicator = true,
        GroupName = false,
        GroupRole = true,
        GroupLeader = true,
        SmartRaid = true,
        PositionBySpec = false,
        CornerIndicator = true,
        CornerIndicatorScale = 1,
        DebuffWatcher = true,
        InstanceDebuffs = true,
        DispellableOnly = false,
        DebuffClickThrough = true,

        Boss = true,
        BossWidth = 100,
        BossHealthHeight = 18,
        BossPowerHeight = 2,
        BossGap = 60,
        BossAuraPerRow = 4,

        Arena = true,
        ArenaWidth = 100,
        ArenaHealthHeight = 18,
        ArenaPowerHeight = 2,
        ArenaGap = 60,
        ArenaAuraPerRow = 6,
    },
    Nameplate = {
        Enable = true,
        TextureStyle = 2,
        Width = 120,
        Height = 12,
        ClickableWidth = 120,
        ClickableHeight = 12,
        FriendlyWidth = 120,
        FriendlyHeight = 12,
        FriendlyClickableWidth = 120,
        FriendlyClickableHeight = 12,
        EnemyClickThrough = false,
        FriendlyClickThrough = true,
        ForceCVars = true,
        NameOnlyMode = true,
        AbbrName = true,
        HealthPerc = true,
        FriendlyPlate = true,
        TargetIndicator = true,
        TargetIndicatorColor = { r = 0.73, g = 0.92, b = 0.99 },
        ThreatIndicator = true,
        ClassifyIndicator = true,
        QuestIndicator = true,
        ExecuteIndicator = false,
        ExecuteRatio = 0,
        SpitefulIndicator = true,
        ExplosiveIndicator = true,
        RaidTargetIndicator = true,
        FriendlyClassColor = false,
        HostileClassColor = true,
        TankMode = false,
        RevertThreat = false,
        SecureColor = { r = 0.22, g = 0.9, b = 0.25 },
        TransColor = { r = 1, g = 1, b = 0.5 },
        InsecureColor = { r = 0.95, g = 0.03, b = 0.31 },
        OffTankColor = { r = 0.17, g = 0.79, b = 0.67 },
        ColoredTarget = false,
        TargetColor = { r = 0, g = 0.6, b = 1 },
        ColoredFocus = true,
        FocusColor = { r = 1, g = 1, b = 1 },

        ShowSpecialUnits = true,
        SpecialUnitColor = { r = 0.76, g = 0.42, b = 1 },
        SpecialUnitsList = {},

        ShowPowerUnits = false,
        PowerUnitsList = {},

        ColorByDot = true,
        DotSpellsList = {},
        DotColor = { r = 0.8, g = 0.6, b = 0.4 },

        ShowAura = true,
        AuraFilterMode = 3,
        AuraPerRow = 5,
        DesaturateIcon = true,
        DebuffTypeColor = true,
        DispellMode = 2,
        DisableMouse = true,

        TotemIcon = true,

        Castbar = true,
        CastbarHeight = 8,
        SeparateCastbar = true,
        MajorSpellsGlow = true,
        TargetName = true,

        InsideView = true,
        MinScale = 0.7,
        TargetScale = 1,
        MinAlpha = 0.6,
        OccludedAlpha = 0.2,
        VerticalSpacing = 0.7,
        HorizontalSpacing = 0.3,
    },
    Tooltip = {
        Enable = true,
        BackdropAlpha = 0.65,
        FollowCursor = false,
        Icon = true,
        BorderColor = true,
        HealthValue = false,
        HideTitle = true,
        HideRealm = true,
        HideGuildRank = true,
        HideInCombat = false,
        SpecIlvl = true,
        Covenant = true,
        MythicPlusScore = true,
        PlayerInfoByAlt = true,
        TargetedBy = true,
        DomiRank = true,
        IDs = true,
        IDsByAlt = true,
        ItemInfo = true,
        ItemInfoByAlt = true,
        ParagonRewards = true,
    },
    Map = {
        Enable = true,
        WorldMapScale = 1,
        MaxWorldMapScale = 1,
        MapReveal = true,
        MapRevealGlow = true,
        Coords = true,
        Minimap = true,
        MinimapScale = 1,
        HiddenInCombat = false,
        WhoPings = true,
        ProgressBar = true,
        Collector = true,
        Volume = true,
        Menu = true,
    },
    Infobar = {
        Enable = true,
        AnchorTop = true,
        Height = 14,
        Mouseover = true,
        System = true,
        Spec = true,
        Durability = true,
        Guild = true,
        Friends = true,
        Daily = true,
        Currency = true,
        Gold = true,
        CombatPulse = true,
    },
    Notification = {
        Enable = true,
        BagFull = true,
        NewMail = true,
        LowDurability = true,
        RareFound = true,
        ParagonChest = true,
    },
    Chat = {
        Enable = true,
        LockPosition = true,
        Width = 300,
        Height = 100,
        BottomEditBox = false,
        HideInCombat = false,
        TextFading = true,
        TimeVisible = 120,
        FadeDuration = 6,
        ShortenChannelName = true,
        CopyButton = true,
        VoiceButton = true,
        EasyChannelSwitch = true,
        SmartChatBubble = false,
        ChannelBar = true,
        WhisperInvite = false,
        InviteKeyword = '111 inv',
        GuildOnly = true,
        WhisperSticky = true,
        WhisperSound = true,
        SoundThreshold = 60,
        ExtendLink = true,
        DamageMeterFilter = true,
        SpamFilter = true,
        Matches = 1,
        BlockSpammer = false,
        BlockStrangerWhisper = false,
        BlockAddonSpam = true,
        GroupLootFilter = true,
        GroupLootThreshold = 2,
        GroupRoleIcon = true,
        DisableProfanityFilter = true,
    },
    Actionbar = {
        Enable = true,
        Hotkey = true,
        MacroName = true,
        CountNumber = true,
        ClassColor = false,
        EquipColor = true,
        ButtonFlash = true,
        CooldownNotify = true,
        CooldownDesaturate = true,
        BindType = 1,
        KeyFeedback = true,

        Bar1Size = 34,
        Bar1Font = 12,
        Bar1Num = 12,
        Bar1PerRow = 12,

        Bar2Size = 34,
        Bar2Font = 12,
        Bar2Num = 12,
        Bar2PerRow = 12,

        Bar3Size = 34,
        Bar3Font = 12,
        Bar3Num = 0,
        Bar3PerRow = 12,

        Bar4Size = 30,
        Bar4Font = 12,
        Bar4Num = 12,
        Bar4PerRow = 1,

        Bar5Size = 30,
        Bar5Font = 12,
        Bar5Num = 12,
        Bar5PerRow = 1,

        EnablePetBar = true,
        BarPetSize = 26,
        BarPetFont = 12,
        BarPetNum = 10,
        BarPetPerRow = 10,

        EnableStanceBar = true,
        BarStanceSize = 30,
        BarStanceFont = 12,
        BarStancePerRow = 10,

        EnableVehicleBar = true,
        VehicleButtonSize = 30,

        BarExtraSize = 40,

        Fader = true,
        FadeOutAlpha = 0,
        FadeInAlpha = 1,
        FadeOutDuration = 1,
        FadeInDuration = 0.3,
        Delay = 0,
        Instance = false,
        Vehicle = true,
        Combat = false,
        Target = false,
        Casting = false,
        Health = false,
        FadeBar1 = true,
        FadeBar2 = true,
        FadeBar3 = true,
        FadeBar4 = true,
        FadeBar5 = true,
        FadePetBar = true,
        FadeStanceBar = true,
    },
    Cooldown = {
        Enable = true,
        IgnoreWA = false,
        MmssTH = 60,
        TenthTH = 3,
        OnlyNumbers = true,
    },
    Quest = {
        QuickQuest = false,
        CompletedSound = true,
        AutoCollapseTracker = true,
        WowheadLink = true,
    },
}

C.AccountSettings = {
    DetectVersion = C.ADDON_VERSION,
    VersionCheck = true,
    UIScale = 1,
    HelpTips = {},
    GoldStatistic = {},
    ShadowOutline = true,
    BackdropColor = { r = 0.1, g = 0.1, b = 0.1 },
    BackdropAlpha = 0.55,
    BorderColor = { r = 0.25, g = 0.25, b = 0.25 },
    ButtonBackdropColor = { r = 0.1, g = 0.1, b = 0.1 },
    ButtonBackdropAlpha = 0.25,
    ButtonHoverAnimation = true,
    WidgetHighlightClassColor = true,
    WidgetHighlightColor = { r = 1, g = 1, b = 1 },
    GuildSortBy = 1,
    GuildSortOrder = true,
    GradientStyle = true,
    ReskinBlizz = true,
    ReskinAddons = true,
    NumberFormat = 1,
    FontOutline = false,
    WorldTextScale = 1,
    FloatingCombatText = true,
    FloatingCombatTextOldStyle = true,
    ChatFilterBlackList = '',
    ChatFilterWhiteList = '',
    RepairType = 1,
    CustomJunkList = {},
    NameplateAuraFilterList = { [1] = {}, [2] = {} },
    DebuffWatcherList = {},
    RaidAuraWatch = {},
    MajorSpellsList = {},
    CornerSpellsList = {},
    PartySpellsList = {},
    PartyAurasList = {},
    AnnounceableSpellsList = {},
    KeystoneInfo = {},
    ProfileIndex = {},
    ProfileNames = {},
    UseCustomClassColor = true,
    CustomClassColors = {
        HUNTER = { r = 0, g = 0.58, b = 0.19, colorStr = 'ff009332' },
        WARRIOR = { r = 0.6, g = 0.53, b = 0.46, colorStr = 'ff9a8675' },
        SHAMAN = { r = 0, g = 0.38, b = 0.4, colorStr = 'ff006166' },
        MAGE = { r = 0.2, g = 0.59, b = 0.86, colorStr = 'ff3498db' },
        PRIEST = { r = 0.82, g = 0.85, b = 0.89, colorStr = 'ffd2dae2' },
        DEATHKNIGHT = { r = 0.72, g = 0.08, b = 0.25, colorStr = 'ffb71540' },
        WARLOCK = { r = 0.61, g = 0.53, b = 1, colorStr = 'ff9c88ff' },
        DEMONHUNTER = { r = 0.95, g = 0.41, b = 0.88, colorStr = 'fff368e0' },
        ROGUE = { r = 0.98, g = 0.77, b = 0.19, colorStr = 'fffbc530' },
        DRUID = { r = 0.9, g = 0.49, b = 0.13, colorStr = 'ffe67e22' },
        MONK = { r = 0.2, g = 0.85, b = 0.69, colorStr = 'ff33d9b2' },
        PALADIN = { r = 1, g = 0.46, b = 0.46, colorStr = 'ffff7675' },
    },
    ContactList = {},
    RenownLevels = {},
    SmoothAmount = 0.25,
    MinimapAddOnCollector = true,
    IgnoredAddOns = '',
}

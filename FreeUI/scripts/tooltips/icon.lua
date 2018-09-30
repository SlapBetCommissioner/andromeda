local F, C, L = unpack(select(2, ...))
if C.tooltip.enable ~= true then return end

local function setTooltipIcon(self, icon)
	local title = icon and _G[self:GetName().."TextLeft1"]
	if title then
		title:SetFormattedText("|T%s:20:20:0:0:64:64:5:59:5:59:%d|t %s", icon, 20, title:GetText())
	end
end

local function newTooltipHooker(method, func)
	return function(tooltip)
		local modified = false

		tooltip:HookScript("OnTooltipCleared", function(self, ...)
			modified = false
		end)

		tooltip:HookScript(method, function(self, ...)
			if not modified then
				modified = true
				func(self, ...)
			end
		end)
	end
end

local hookItem = newTooltipHooker("OnTooltipSetItem", function(self, ...)
	local _, link = self:GetItem()
	if link then
		setTooltipIcon(self, GetItemIcon(link))
	end
end)

local hookSpell = newTooltipHooker("OnTooltipSetSpell", function(self, ...)
	local _, id = self:GetSpell()
	if id then
		setTooltipIcon(self, select(3, GetSpellInfo(id)))
	end
end)

for _, tooltip in pairs{GameTooltip, ItemRefTooltip, ItemRefShoppingTooltip1, ItemRefShoppingTooltip2, ShoppingTooltip1, ShoppingTooltip2} do
	hookItem(tooltip)
	hookSpell(tooltip)
end


-- Tooltip rewards icon
local newString = "0:0:64:64:5:59:5:59"

_G.BONUS_OBJECTIVE_REWARD_WITH_COUNT_FORMAT = "|T%1$s:16:16:"..newString.."|t |cffffffff%2$s|r %3$s"
_G.BONUS_OBJECTIVE_REWARD_FORMAT = "|T%1$s:16:16:"..newString.."|t %2$s"

local function ReskinRewardIcon(self)
	if self and self.Icon then
		self.Icon:SetTexCoord(unpack(C.texCoord))
		self.IconBorder:Hide()
	end
end
hooksecurefunc("EmbeddedItemTooltip_SetItemByQuestReward", ReskinRewardIcon)
hooksecurefunc("EmbeddedItemTooltip_SetItemByID", ReskinRewardIcon)
hooksecurefunc("EmbeddedItemTooltip_SetCurrencyByID", ReskinRewardIcon)
hooksecurefunc("QuestUtils_AddQuestCurrencyRewardsToTooltip", function(_, _, self) ReskinRewardIcon(self) end)
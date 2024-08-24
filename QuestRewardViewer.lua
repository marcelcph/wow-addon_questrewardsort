-- QuestRewardViewer.lua

-- Debug print
print("QuestRewardViewer.lua loaded")

-- Opret minimap-ikon
local iconTexture = "Interface/Icons/INV_Misc_QuestionMark"
local icon = CreateFrame("Button", "QuestRewardViewerButton", Minimap)
icon:SetSize(32, 32)
icon:SetNormalTexture(iconTexture)
icon:SetPushedTexture(iconTexture)
icon:SetHighlightTexture(iconTexture)

icon:SetScript("OnClick", function()
    if QuestRewardFrame:IsShown() then
        QuestRewardFrame:Hide()
    else
        QuestRewardFrame:Show()
    end
end)

icon:SetScript("OnEnter", function()
    GameTooltip:SetOwner(icon, "ANCHOR_LEFT")
    GameTooltip:SetText("QuestRewardViewer")
    GameTooltip:Show()
end)

icon:SetScript("OnLeave", function()
    GameTooltip:Hide()
end)

-- Opret UI frame
local frame = CreateFrame("Frame", "QuestRewardFrame", UIParent)
frame:SetSize(400, 400)
frame:SetPoint("CENTER")
frame:SetBackdrop({bgFile = "Interface/Tooltips/UI-Tooltip-Background"})
frame:SetBackdropColor(0, 0, 0, 0.8)
frame:SetMovable(true)
frame:EnableMouse(true)
frame:RegisterForDrag("LeftButton")
frame:SetScript("OnDragStart", frame.StartMoving)
frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
frame:Hide()

local title = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
title:SetPoint("TOP", frame, "TOP", 0, -10)
title:SetText("Quest Rewards")

frame.rewardList = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
frame.rewardList:SetPoint("TOPLEFT", frame, "TOPLEFT", 10, -30)
frame.rewardList:SetWidth(380)
frame.rewardList:SetJustifyH("LEFT")

-- Funktion til at hente alle quests og deres status
local function GetAllQuests()
    local quests = {}
    for i = 1, C_QuestLog.GetNumQuestLogEntries() do
        local info = C_QuestLog.GetInfo(i)
        if info then
            local questID = info.questID
            local title = info.title
            local isComplete = info.isComplete
            local isOnQuest = info.isOnQuest
            local level = info.level
            table.insert(quests, {
                id = questID,
                title = title,
                complete = isComplete,
                onQuest = isOnQuest,
                level = level
            })
        end
    end
    return quests
end

-- Funktion til at sortere quests efter niveau
local function SortQuests(quests)
    table.sort(quests, function(a, b)
        return a.level < b.level
    end)
    return quests
end

-- Funktion til at opdatere reward-UI
local function UpdateRewardFrame()
    local quests = GetAllQuests()
    quests = SortQuests(quests)

    local questText = ""
    for _, quest in ipairs(quests) do
        local statusText = "Not Started"
        if quest.complete then
            statusText = "Completed"
        elseif quest.onQuest then
            statusText = "In Progress"
        end
        questText = questText .. string.format("Quest: %s\nLevel: %d\nStatus: %s\n\n", quest.title, quest.level, statusText)
    end

    frame.rewardList:SetText(questText)
end

-- Event handler til at opdatere når quest-log opdateres
local function OnEvent(self, event)
    if event == "QUEST_LOG_UPDATE" then
        UpdateRewardFrame()
    end
end

frame:RegisterEvent("QUEST_LOG_UPDATE")
frame:SetScript("OnEvent", OnEvent)

-- Kommando funktion
SLASH_QUESTVIEWER1 = "/questviewer"
function SlashCmdList.QUESTVIEWER(msg, editBox)
    if frame:IsShown() then
        frame:Hide()
    else
        frame:Show()
    end
end

-- Initial opdatering
UpdateRewardFrame()

-- Debug print
print("QuestRewardViewer loaded") -- This should show in chat

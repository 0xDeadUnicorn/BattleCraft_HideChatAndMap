local HCBframe = nil
local HCBActivateChat = ChatEdit_ActivateChat

if not HCBframe then
    HCBframe = CreateFrame("Button", "HCBframe", UIParent)
    
    HCBframe:SetClampedToScreen(true)
    HCBframe:SetMovable(true)
    HCBframe:EnableMouse(true)
    HCBframe:RegisterForDrag("RightButton")
    HCBframe:SetScript("OnDragStart", HCBframe.StartMoving)
    HCBframe:SetScript("OnDragStop", HCBframe.StopMovingOrSizing)
    
    HCBframe:SetWidth(24)
    HCBframe:SetHeight(24)
    
    HCBframe:SetPoint("BOTTOMLEFT", HCBxpos or 0, HCBypos or 0)
    
    HCBframe.ChatIsShown = true
    HCBframe.ActiveTabs = { [1] = true }
    HCBkeyable = HCBkeyable or false
    HCBuseralpha = HCBuseralpha or .25
    
    HCBframe:EnableMouseWheel(true)
    
    if not HCBframe.SetBackdrop then
        Mixin(HCBframe, BackdropTemplateMixin)
    end

    HCBframe:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 12,
        insets = { left = 2, right = 2, top = 2, bottom = 2 }
    })
    HCBframe:SetBackdropColor(0, 0, 0, 0.5)
    HCBframe:SetBackdropBorderColor(0, 0, 0, 1)

    HCBframe.text = HCBframe:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    HCBframe.text:SetPoint("CENTER")
    HCBframe.text:SetText("HCB")
end

HCBframe.HideMinimap = function()
    local m = MinimapCluster
    if m:IsShown() then
        m:Hide()
    else
        m:Show()
    end
end

HCBframe.HideChat = function(frame)
    for i = 1, NUM_CHAT_WINDOWS do
        local f = _G["ChatFrame"..i]
        if f then
            if f:IsVisible() then
                frame.ActiveTabs[i] = true
                f:Hide()
            else
                frame.ActiveTabs[i] = false
            end
            f.HCBOverrideShow = f.Show
            f.Show = f.Hide
        end
    end

    GeneralDockManager.HCBOverrideShow = GeneralDockManager.Show
    GeneralDockManager.Show = GeneralDockManager.Hide
    GeneralDockManager:Hide()
    ChatFrameMenuButton:Hide()
    FriendsMicroButton:Hide()
    frame.ChatIsShown = false
end

HCBframe.ShowChat = function(frame)
    GeneralDockManager.Show = GeneralDockManager.HCBOverrideShow
    GeneralDockManager:Show()
    ChatFrameMenuButton:Show()
    FriendsMicroButton:Show()

    for i = 1, NUM_CHAT_WINDOWS do
        local f = _G["ChatFrame"..i]
        if f then
            f.Show = f.HCBOverrideShow
            if frame.ActiveTabs[i] then
                f:Show()
            end
        end
    end
    frame.ChatIsShown = true
end

HCBframe.UpdateButtonState = function(frame)
    if HCBkeyable then
        HCBframe:SetAlpha(1.0)
        HCBframe.text:SetText("HCB")
    else
        HCBframe:SetAlpha(HCBuseralpha or .25)
        HCBframe.text:SetText("")
    end
end

HCBframe.ToggleVisible = function(frame)
    if HCBframe.ChatIsShown then
        HCBframe:HideChat()
    else
        HCBframe:ShowChat()
    end
    HCBframe:UpdateButtonState()
end

HCBframe:SetScript("OnMouseUp", function(frame, button)
    if IsControlKeyDown() then
        HCBframe:RestoreDefaults()
    elseif IsShiftKeyDown() then
        HCBframe:ToggleKeyable()
    elseif button == "LeftButton" then
        HCBframe:ToggleVisible()
    elseif button == "RightButton" then
        HCBframe.HideMinimap()
    end
end)

function ChatEdit_ActivateChat(frame)
    if HCBkeyable and not HCBframe.ChatIsShown then
        HCBframe:ToggleVisible()
    end
    HCBActivateChat(frame)
end

HCBframe:RegisterEvent("CHAT_MSG_BATTLEGROUND")
HCBframe:RegisterEvent("CHAT_MSG_GUILD")
HCBframe:RegisterEvent("CHAT_MSG_PARTY")
HCBframe:RegisterEvent("ADDON_LOADED")

HCBframe.OnEvent = function(frame, event, ...)
    if event == "ADDON_LOADED" then
        HCBframe:UpdateButtonState()
    end
end

HCBframe:SetScript("OnEvent", HCBframe.OnEvent)

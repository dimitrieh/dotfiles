-- Hammerspoon Configuration
-- Cursor follows focused window (keyboard-only)

-- Disable window animation for snappier behavior
hs.window.animationDuration = 0

--------------------------------------------------------------------------------
-- Cursor Follows Focus (Keyboard Only)
--------------------------------------------------------------------------------
-- Only moves cursor when switching windows via Cmd+Tab or Cmd+`
-- Does NOT move cursor when clicking on a window with the mouse

local mouseClickTime = 0
local MOUSE_CLICK_THRESHOLD = 0.15  -- 150ms threshold

-- Feature toggle
local cursorFollowsEnabled = true

-- Track mouse clicks to distinguish keyboard vs mouse focus changes
local mouseClickWatcher = hs.eventtap.new({
    hs.eventtap.event.types.leftMouseDown,
    hs.eventtap.event.types.rightMouseDown
}, function(event)
    mouseClickTime = hs.timer.secondsSinceEpoch()
    return false  -- don't consume the event
end)
mouseClickWatcher:start()

-- Move cursor to center of window
local function moveCursorToWindow(win)
    if not win then return end
    local frame = win:frame()
    local center = {
        x = frame.x + frame.w / 2,
        y = frame.y + frame.h / 2
    }
    hs.mouse.absolutePosition(center)
end

-- Window filter for focus changes
local wf = hs.window.filter.new()
    :setDefaultFilter()
    :setOverrideFilter({
        visible = true,
        allowRoles = { "AXStandardWindow" }
    })

wf:subscribe(hs.window.filter.windowFocused, function(win, appName, event)
    if not cursorFollowsEnabled then return end
    if not win then return end

    local timeSinceClick = hs.timer.secondsSinceEpoch() - mouseClickTime

    -- Only move cursor if no recent mouse click (keyboard-triggered focus)
    if timeSinceClick > MOUSE_CLICK_THRESHOLD then
        moveCursorToWindow(win)
    end
end)

--------------------------------------------------------------------------------
-- Hotkeys
--------------------------------------------------------------------------------

-- Toggle cursor follows focus: Cmd+Ctrl+F
hs.hotkey.bind({"cmd", "ctrl"}, "F", function()
    cursorFollowsEnabled = not cursorFollowsEnabled
    local state = cursorFollowsEnabled and "enabled" or "disabled"
    hs.alert.show("Cursor follows focus: " .. state)
end)

-- Reload config: Cmd+Ctrl+R
hs.hotkey.bind({"cmd", "ctrl"}, "R", function()
    hs.reload()
end)

--------------------------------------------------------------------------------
-- Startup
--------------------------------------------------------------------------------

hs.alert.show("Hammerspoon config loaded")

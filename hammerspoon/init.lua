-- Hammerspoon Configuration
-- Cursor follows focused window (keyboard-only)

-- Disable window animation for snappier behavior
hs.window.animationDuration = 0

--------------------------------------------------------------------------------
-- Cursor Follows Focus (Keyboard Only)
--------------------------------------------------------------------------------
-- Only moves cursor when switching windows via Cmd+Tab or Cmd+`
-- Does NOT move cursor when clicking on a window with the mouse
--
-- Detection method: Position-based
-- If cursor is inside the newly focused window, assume it was a mouse click.
-- This is more robust than time-based detection, especially on macOS Sequoia
-- where hs.window.filter events can be delayed.

-- Feature toggle
local cursorFollowsEnabled = true

-- Check if a point is inside a rect
local function pointInRect(point, rect)
    return point.x >= rect.x
       and point.x <= rect.x + rect.w
       and point.y >= rect.y
       and point.y <= rect.y + rect.h
end

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

-- Apps to exclude from cursor-follows-focus
local excludedApps = {
    ["CleanShot X"] = true,
}

wf:subscribe(hs.window.filter.windowFocused, function(win, appName, event)
    if not cursorFollowsEnabled then return end
    if not win then return end
    if excludedApps[appName] then return end

    local mousePos = hs.mouse.absolutePosition()
    local winFrame = win:frame()

    -- Only move cursor if mouse is NOT inside the focused window
    -- If mouse is inside, user likely clicked to focus (don't move cursor)
    -- If mouse is outside, focus was triggered by keyboard (move cursor)
    if not pointInRect(mousePos, winFrame) then
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

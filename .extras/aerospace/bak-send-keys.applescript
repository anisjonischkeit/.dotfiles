#!/usr/bin/env osascript

on run argv
    set initialDebugMsg to "AppleScript received arguments:" & return & "1. Key: «" & (item 1 of argv as text) & "»" & return & "2. ProcessName: «" & (item 2 of argv as text) & "»" & return & "3. BundleID: «" & (item 3 of argv as text) & "»"

    if (count of argv) is not 3 then
        --tell current application to display dialog "AppleScript Error: Expected 3 arguments (key, processName, bundleID), but received " & (count of argv) & "." with title "Aerospace Bridge Script Error" with icon stop
        return -- Return nothing (AppleScript null)
    end if

    set targetChar to item 1 of argv as text
    set localKittyProcessName to item 2 of argv as text
    set localKittyBundleID to item 3 of argv as text

    set errorOccurred to false
    set finalErrorMessage to ""


    -- Phase 2: If no error activating Kitty, proceed with System Events.
    if not errorOccurred then
        --tell current application to display dialog "AppleScript: Starting Phase 2 (System Events UI)" with title "AppleScript: Progress" buttons {"OK"} default button "OK" giving up after 2
        try
            tell application "System Events"
                tell application process localKittyProcessName
                    
                    keystroke "a" using {control down} -- Sends Ctrl-B
                    if contents of targetChar is not ""
                        delay 0.05                         -- Small pause for tmux to register prefix
                        keystroke targetChar               -- Sends the subsequent character (e.g., "2")
                    end if
                end tell
            end tell -- end tell System Events
        on error errMsg number errNum
            set finalErrorMessage to "AppleScript Error (Phase 2 - System Events UI for " & localKittyProcessName & "): " & errMsg & " (Error #" & errNum & ")"
            set errorOccurred to true
        end try
    end if

    if errorOccurred then
        --tell current application to display dialog finalErrorMessage with title "Aerospace Bridge Script Error" with icon stop
        return -- Return nothing
    end if
    
    -- No explicit string return; AppleScript will return null implicitly
    return
end run

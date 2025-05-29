#!/usr/bin/env osascript

on run argv
    -- Initial debug dialog (shows arguments received)
    set initialDebugMsg to "AppleScript received arguments:" & return & "1. Key: «" & (item 1 of argv as text) & "»" & return & "2. ProcessName: «" & (item 2 of argv as text) & "»" & return & "3. BundleID: «" & (item 3 of argv as text) & "»"
    --tell current application to display dialog initialDebugMsg with title "AppleScript: Initial Debug Info" buttons {"Continue"} default button "Continue"

    if (count of argv) is not 3 then
        --tell current application to display dialog "AppleScript Error: Expected 3 arguments (key, processName, bundleID), but received " & (count of argv) & "." with title "Aerospace Bridge Script Error" with icon stop
        return -- Return nothing (AppleScript null)
    end if

    set targetChar to item 1 of argv as text
    set localKittyProcessName to item 2 of argv as text
    set localKittyBundleID to item 3 of argv as text

    --if localKittyProcessName is "" or localKittyBundleID is "" then
    --    --tell current application to display dialog "AppleScript Error: Kitty Process Name or Bundle ID is empty. Please configure them in the aerospace_tmux_bridge.sh script." with title "Configuration Error" with icon stop
    --    return -- Return nothing
    --end if

    set errorOccurred to false
    set finalErrorMessage to ""
    --set kittyWasJustLaunched to false

    -- Phase 1: Ensure Kitty is running and activate it.
    --tell current application to display dialog "AppleScript: Starting Phase 1 (Activate Kitty)" with title "AppleScript: Progress" buttons {"OK"} default button "OK" giving up after 2
    --try
    --    tell application id localKittyBundleID
    --        if not running then
    --            launch
    --            delay 0.8
    --            set kittyWasJustLaunched to true
    --        end if
    --        activate
    --    end tell
    --    delay 0.4 -- Unconditional delay for focus to settle after activate
    --on error errMsg number errNum
    --    set finalErrorMessage to "AppleScript Error (Phase 1 - Activating Kitty " & localKittyBundleID & "): " & errMsg & " (Error #" & errNum & ")"
    --    set errorOccurred to true
    --end try

    -- Phase 2: If no error activating Kitty, proceed with System Events.
    if not errorOccurred then
        --tell current application to display dialog "AppleScript: Starting Phase 2 (System Events UI)" with title "AppleScript: Progress" buttons {"OK"} default button "OK" giving up after 2
        try
            tell application "System Events"
                set timeout_seconds to 3
                --if kittyWasJustLaunched then
                --    set timeout_seconds to 5 
                --end if

                set end_time to (current date) + timeout_seconds
                set kittyIsFrontmost to true
                
                --tell current application to display dialog "AppleScript: Checking if " & localKittyProcessName & " is frontmost..." with title "AppleScript: Progress" buttons {"OK"} default button "OK" giving up after 2
                --repeat while ((current date) < end_time)
                --    if (frontmost of application process localKittyProcessName) is true then
                --        set kittyIsFrontmost to true
                --        exit repeat
                --    end if
                --    delay 0.05
                --end repeat

                --if not kittyIsFrontmost then
                --    set finalErrorMessage to "Error (Phase 2 - Verifying Frontmost): Failed to confirm \"" & localKittyProcessName & "\" is frontmost within " & timeout_seconds & "s."
                --    set errorOccurred to true
                --    --tell current application to display dialog "AppleScript: " & localKittyProcessName & " IS NOT frontmost." with title "AppleScript: Progress" buttons {"OK"} default button "OK" giving up after 2
                --else
                    --tell current application to display dialog "AppleScript: " & localKittyProcessName & " IS frontmost. Sending keys (alt method)..." with title "AppleScript: Progress" buttons {"OK"} default button "OK" giving up after 2
                    tell application process localKittyProcessName
                        --set frontmost to true -- Re-assert frontmost for this process
                        --delay 0.1            -- Brief pause
                        
                        -- ALTERNATIVE KEYSTROKE METHOD
                        keystroke "a" using {control down} -- Sends Ctrl-B
                        if contents of targetChar is not ""
                            delay 0.05                         -- Small pause for tmux to register prefix
                            keystroke targetChar               -- Sends the subsequent character (e.g., "2")
                        end if
                    end tell
                    --tell current application to display dialog "AppleScript: Keystrokes sent (alt method)." with title "AppleScript: Progress" buttons {"OK"} default button "OK" giving up after 2
                --end if
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

tell application "System Events"
    set active_app to first application process whose frontmost is true
end tell

on update_xmark()
    tell application "{{ app }}"
        set u to "file://{{ out }}"
        repeat with w in every window
            set tab_index to 0
            repeat with t in every tab of w
                set tab_index to tab_index + 1
                if URL of t = u then
                    tell t to reload
                    set active tab index of w to tab_index
                    set index of w to 1
                    return
                end if
            end repeat
        end repeat
        tell (make new window)
            repeat while visible of it is false
                delay 0.5
            end repeat
            set URL of active tab of it to u
            set index of it to 1
        end tell
    end tell
end update_xmark

update_xmark()

tell application "Finder"
    set {scr_left, scr_top, scr_width, scr_height} to bounds of window of desktop
end tell

tell application "System Events"
    set chrome_app to application process "{{ app }}"
    repeat 2 times
        if "{{ resize }}" is ">" then
            set position of window 1 of active_app to {0, 0}
            set position of window 1 of chrome_app to {0 + scr_width / 2, 0}
            set size     of window 1 of active_app to {scr_width / 2, scr_height}
            set size     of window 1 of chrome_app to {scr_width / 2, scr_height}
        else if "{{ resize }}" is "<" then
            set position of window 1 of active_app to {0 + scr_width / 2, 0}
            set position of window 1 of chrome_app to {0, 0}
            set size     of window 1 of active_app to {scr_width / 2, scr_height}
            set size     of window 1 of chrome_app to {scr_width / 2, scr_height}
        else if "{{ resize }}" is "+" then
            set position of window 1 of active_app to {0, scr_height / 2}
            set position of window 1 of chrome_app to {0, 0}
            set size     of window 1 of active_app to {scr_width, scr_height / 2}
            set size     of window 1 of chrome_app to {scr_width, scr_height / 2}
        else if "{{ resize }}" is "-" then
            set position of window 1 of active_app to {0, 0}
            set position of window 1 of chrome_app to {0, scr_height / 2}
            set size     of window 1 of active_app to {scr_width, scr_height / 2}
            set size     of window 1 of chrome_app to {scr_width, scr_height / 2}
        end if
    end repeat
end tell

repeat while frontmost of active_app is false
    tell application (name of active_app) to activate
end repeat


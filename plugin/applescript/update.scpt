global app_path
tell application "System Events"
    set active_app to first application process whose frontmost is true
end tell

set app_id to id of application "{{ app }}"
tell application "Finder"
    set app_path to POSIX path of (application file id app_id as alias)
end tell

on update_xmark()
    using terms from application "{{ app }}"
        tell application app_path
            set u to "file://{{ outurl }}"
            repeat with w in every window
                set tab_index to 0
                repeat with t in tabs of w
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
    end using terms from
end update_xmark

update_xmark()

tell application "System Events"
    set chrome_app to application process "{{ app }}"
    repeat 2 times
        if "{{ resize }}" is ">" then
            set position of window 1 of active_app to {{{ x }}, {{ y }}}
            set position of window 1 of chrome_app to {{{ x }} + {{ w }} / 2, {{ y }}}
            set size     of window 1 of active_app to {{{ w }} / 2, {{ h }}}
            set size     of window 1 of chrome_app to {{{ w }} / 2, {{ h }}}
        else if "{{ resize }}" is "<" then
            set position of window 1 of active_app to {{{ x }} + {{ w }} / 2, {{ y }}}
            set position of window 1 of chrome_app to {{{ x }}, {{ y }}}
            set size     of window 1 of active_app to {{{ w }} / 2, {{ h }}}
            set size     of window 1 of chrome_app to {{{ w }} / 2, {{ h }}}
        else if "{{ resize }}" is "+" then
            set position of window 1 of active_app to {{{ x }}, {{ y }} + {{ h }} / 2}
            set position of window 1 of chrome_app to {{{ x }}, {{ y }}}
            set size     of window 1 of active_app to {{{ w }}, {{ h }} / 2}
            set size     of window 1 of chrome_app to {{{ w }}, {{ h }} / 2}
        else if "{{ resize }}" is "-" then
            set position of window 1 of active_app to {{{ x }}, {{ y }}}
            set position of window 1 of chrome_app to {{{ x }}, {{ h }} / 2}
            set size     of window 1 of active_app to {{{ w }}, {{ h }} / 2}
            set size     of window 1 of chrome_app to {{{ w }}, {{ h }} / 2}
        end if
    end repeat
end tell

repeat while frontmost of active_app is false
    tell application (name of active_app) to activate
    delay 0.5
end repeat


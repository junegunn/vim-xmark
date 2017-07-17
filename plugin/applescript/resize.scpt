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

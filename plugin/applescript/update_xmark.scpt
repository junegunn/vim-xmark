on update_xmark()
    tell application "{{ app }}"
        if it is not running then
            activate
        end if
        set u to "file://{{ out }}"
        set win_index to 0
        repeat with w in every window
            set win_index to win_index + 1
            set tab_index to 0
            repeat with t in every tab of w
                set tab_index to tab_index + 1
                if URL of t = u then
                    tell t to reload
                    set index of window win_index to 1
                    set active tab index of w to tab_index
                    return
                end if
            end repeat
        end repeat
        make new window
        set URL of active tab of window 1 to u
    end tell
end update_xmark

update_xmark()

tell application "Finder"
    set {scr_left, scr_top, scr_width, scr_height} to bounds of window of desktop
end tell

tell application "System Events"
    repeat with p in (processes where background only is false)
        tell p
          repeat 2 times
              if "{{ resize }}" is ">" and it is frontmost or "{{ resize }}" is "<" and name is "{{ app }}" then
                  set size     of window 1 to {scr_width / 2, scr_height}
                  set position of window 1 to {0, 0}
              else if "{{ resize }}" is ">" and name is "{{ app }}" or "{{ resize }}" is "<" and it is frontmost then
                  set size     of window 1 to {scr_width / 2, scr_height}
                  set position of window 1 to {0 + scr_width / 2, 0}
              else if "{{ resize }}" is "+" and it is frontmost or "{{ resize }}" is "-" and name is "{{ app }}" then
                  set size     of window 1 to {scr_width, scr_height / 2}
                  set position of window 1 to {0, scr_height / 2}
              else if "{{ resize }}" is "+" and name is "{{ app }}" or "{{ resize }}" is "-" and it is frontmost then
                  set size     of window 1 to {scr_width, scr_height / 2}
                  set position of window 1 to {0, 0}
              end if
          end repeat
        end tell
    end repeat
end tell


on close_xmark()
    tell application "{{ app }}"
        if it is not running then
            return
        end if
        delete (every tab of every window where its URL is "file://{{ out }}")
    end tell
end close_xmark

close_xmark()


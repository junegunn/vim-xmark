tell application "{{ app }}"
    if it is running then
        delete (every tab of every window where its URL is "file://{{ out }}")
    end if
end tell


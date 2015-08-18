tell application "{{ app }}"
    if it is running then
        delete (every tab of every window where its URL is "file://{{ outurl }}")
    end if
end tell


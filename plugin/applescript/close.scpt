global app_path
set app_id to id of application "{{ app }}"
tell application "Finder"
    set app_path to POSIX path of (application file id app_id as alias)
end tell

using terms from application "{{ app }}"
    tell application app_path
        if it is running then
            delete (every tab of every window where its URL is "file://{{ outurl }}")
        end if
    end tell
end using terms from


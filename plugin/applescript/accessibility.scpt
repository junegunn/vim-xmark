-- http://stackoverflow.com/questions/18121451
tell application "System Preferences"
  set securityPane to pane id "com.apple.preference.security"
  tell securityPane to reveal anchor "Privacy_Accessibility"
  activate
end tell


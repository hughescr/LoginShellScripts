# Add note to Notes.app (OS X 10.8)
# Usage: `note 'title' 'body'` or `echo 'body' | note`
# Title is optional
function note() {
    local title
    local body
    if [ -t 0 ]; then
        title="$1"
        body="$2"
    else
        title=$(cat)
    fi
    local esc_title=${title//\\/\\\\}
    esc_title=${esc_title//\"/\\\"}
    local esc_body=${body//\\/\\\\}
    esc_body=${esc_body//\"/\\\"}
    osascript >/dev/null <<EOF
tell application "Notes"
    tell account "iCloud"
        tell folder "Notes"
            make new note with properties {name:"$esc_title", body:"$esc_title" & "<br><br>" & "$esc_body"}
        end tell
    end tell
end tell
EOF
}

# WildDuck API shell helpers
# ----------------------------------------------------------------------------
# Three functions for talking to a WildDuck mail API using httpie's
# `basic_session` session, which persists the X-Access-Token header between
# calls.
#
#   wdapi-login <username>   Authenticate (password pulled from 1Password via
#                            `op`), obtain a master-scope access token, and save
#                            it into the basic_session httpie session.
#   wdapi-logout             Invalidate the token server-side and surgically
#                            strip the saved X-Access-Token header from the
#                            session JSON.
#   wdapi-search [query] ... Search the authenticated user's mailboxes and
#                            render the results as a MUI-style colored preview.
#
# The API host is NOT hardcoded: it is read from the 1Password item (field
# "API base path") on first use and then cached/exported as $WDAPI_HOST for the
# rest of the shell (a brand-new shell re-reads it from op the first time).
# Set WDAPI_HOST in the environment to override / avoid the op read.
#
# Sourced by both bash (*.sh) and zsh (via the *.zsh symlink), so everything
# here is kept portable across the two shells.
# Depends on: https (httpie), jq, op (1Password CLI).
# ----------------------------------------------------------------------------

# Resolve the API host. Uses $WDAPI_HOST if already set; otherwise reads it from
# 1Password, normalizes (strips any scheme and path, keeps host[:port]), and
# exports it so later calls in this shell are cached.
_wdapi_host() {
    if [ -n "$WDAPI_HOST" ]; then printf '%s\n' "$WDAPI_HOST"; return 0; fi
    command -v op >/dev/null 2>&1 || { printf 'wdapi: `op` not found\n' >&2; return 1; }
    local raw host
    raw=$(op read "op://Private/elwb57dghfhl7k4kbvoygh6e7u/API base path" 2>/dev/null)
    if [ $? -ne 0 ] || [ -z "$raw" ]; then
        printf 'wdapi: failed to read API host from 1Password\n' >&2
        return 1
    fi
    host=${raw#*://}      # strip scheme if the field value includes https:// or http://
    host=${host%%/*}      # strip any path, keep host[:port]
    if [ -z "$host" ]; then printf 'wdapi: empty host from 1Password\n' >&2; return 1; fi
    export WDAPI_HOST="$host"
    printf '%s\n' "$WDAPI_HOST"
}

# Path to the httpie session file for the resolved host. httpie derives the
# session directory name from the request host, so this must match.
_wdapi_session_file() {
    local host
    host=$(_wdapi_host) || return 1
    printf '%s\n' "$HOME/.config/httpie/sessions/$host/basic_session.json"
}

# Atomically write jq stdout to a session file, preserving 0600 perms.
# $1 = destination session file. Reads the new content from stdin.
_wdapi_write_session() {
    local sf="$1" tmp
    mkdir -p "$(dirname "$sf")" 2>/dev/null
    tmp=$(mktemp "${sf}.XXXXXX") || return 1
    if cat >"$tmp"; then
        chmod 600 "$tmp" 2>/dev/null
        mv "$tmp" "$sf"
    else
        rm -f "$tmp"
        return 1
    fi
}

# Remove the X-Access-Token header (case-insensitive) from a session file,
# preserving every other header. $1 = session file. No-op if file is absent.
_wdapi_strip_token() {
    local sf="$1"
    [ -f "$sf" ] || return 0
    local stripped
    stripped=$(jq '.headers |= map(select((.name | ascii_downcase) != "x-access-token"))' "$sf" 2>/dev/null) || return 1
    printf '%s\n' "$stripped" | _wdapi_write_session "$sf"
}

# Set the X-Access-Token header in the session JSON. The TOKEN arrives on STDIN
# (a raw string) so it never appears on any argv. $1 = session file. Emits the
# updated session JSON on stdout (caller persists it). If the session file does
# not exist yet, a minimal valid httpie 3.x skeleton is used.
_wdapi_set_token() {
    local sf="$1" sessjson
    if [ -f "$sf" ]; then
        sessjson=$(cat "$sf")
    else
        sessjson='{"__meta__":{"about":"HTTPie session file","httpie":"3.2.4"},"auth":{"password":null,"type":null,"username":null},"cookies":[],"headers":[{"name":"Accept","value":"application/json, */*;q=0.5"}]}'
    fi
    jq -Rs --argjson s "$sessjson" '
        . as $tok
        | $s
        | .headers = (((.headers // []) | map(select((.name|ascii_downcase) != "x-access-token")))
                       + [{name:"X-Access-Token", value:$tok}])'
}

# wdapi-login <username>
# Authenticate and persist a master-scope access token into basic_session.
wdapi-login() {
    if [ -z "$1" ]; then
        printf 'usage: wdapi-login <username>\n' >&2
        return 1
    fi

    if ! command -v op >/dev/null 2>&1; then
        printf 'wdapi-login: `op` (1Password CLI) not found\n' >&2
        return 1
    fi
    if ! command -v jq >/dev/null 2>&1; then
        printf 'wdapi-login: `jq` not found\n' >&2
        return 1
    fi

    local host
    host=$(_wdapi_host) || return 1

    local username="$1"
    local pw
    pw=$(op read "op://Private/elwb57dghfhl7k4kbvoygh6e7u/password" 2>/dev/null)
    if [ $? -ne 0 ] || [ -z "$pw" ]; then
        printf 'wdapi-login: failed to read password from 1Password\n' >&2
        return 1
    fi

    # Authenticate WITHOUT the session so httpie cannot auto-inject a stale
    # X-Access-Token. The password must never appear on any argv (visible to
    # `ps`), so build the JSON body with jq reading the password from STDIN via
    # the `printf` shell BUILTIN (no separate process => no argv), then pipe the
    # body into httpie's stdin. httpie does NOT auto-set the JSON content-type
    # for a raw stdin body, so set it explicitly.
    local resp
    resp=$(printf '%s' "$pw" \
        | jq -Rs --arg u "$username" '{username:$u, password:., scope:"master", token:true}' \
        | https POST "$host/authenticate" Content-Type:application/json 2>/dev/null)
    pw=  # drop the password from the environment ASAP

    if [ -z "$resp" ]; then
        printf 'wdapi-login: no response from %s/authenticate\n' "$host" >&2
        return 1
    fi

    if [ "$(printf '%s' "$resp" | jq -r '.success // false')" != "true" ]; then
        printf 'wdapi-login: authentication failed: %s\n' \
            "$(printf '%s' "$resp" | jq -r '(.error // .code // "unknown error")')" >&2
        return 1
    fi

    local token
    token=$(printf '%s' "$resp" | jq -r '.token // empty')
    if [ -z "$token" ]; then
        printf 'wdapi-login: no token in authentication response\n' >&2
        return 1
    fi

    # Persist the token by writing it DIRECTLY into the session file. The token
    # reaches jq via STDIN (never argv); the (non-secret) existing session is
    # passed via --argjson inside _wdapi_set_token. Write atomically (0600).
    local sf
    sf=$(_wdapi_session_file)
    if ! printf '%s' "$token" | _wdapi_set_token "$sf" | _wdapi_write_session "$sf"; then
        token=
        printf 'wdapi-login: failed to write token into session file\n' >&2
        return 1
    fi
    token=  # don't keep the token in the environment

    # Verify the token works WITHOUT putting it on argv: it is now in the
    # session, so a plain session-backed request sends X-Access-Token for us.
    local me
    me=$(https --session=basic_session --print=b GET "$host/users/me" 2>/dev/null)

    if [ -z "$me" ] || [ "$(printf '%s' "$me" | jq -r '.success // false')" != "true" ]; then
        # Don't leave a bad token persisted.
        _wdapi_strip_token "$sf"
        printf 'wdapi-login: failed to verify token against /users/me (token removed from session)\n' >&2
        return 1
    fi

    local who
    who=$(printf '%s' "$me" | jq -r '
        (.username // "") as $u
        | (.address // "") as $a
        | if ($u != "" and $a != "") then ($u + " <" + $a + ">")
          elif ($u != "") then $u
          else $a end' 2>/dev/null)
    [ -z "$who" ] && who="$username"
    printf 'wdapi-login: authenticated as %s\n' "$who" >&2
}

# wdapi-logout
# Invalidate the saved token server-side, then strip it from the session file.
wdapi-logout() {
    if ! command -v jq >/dev/null 2>&1; then
        printf 'wdapi-logout: `jq` not found\n' >&2
        return 1
    fi

    local host
    host=$(_wdapi_host) || return 1

    # Ask the server to invalidate the token (session sends X-Access-Token).
    # Don't hard-fail if this errors -- the token may already be gone.
    if ! https --session=basic_session -j DELETE "$host/authenticate" >/dev/null 2>&1; then
        printf 'wdapi-logout: warning: server-side token invalidation failed (continuing with local cleanup)\n' >&2
    fi

    local sf
    sf=$(_wdapi_session_file)
    if [ ! -f "$sf" ]; then
        printf 'wdapi-logout: no session file at %s (nothing to clear)\n' "$sf" >&2
        return 0
    fi

    # Surgically remove ONLY the X-Access-Token header (case-insensitive),
    # preserving every other header (shared helper, atomic 0600 write).
    if _wdapi_strip_token "$sf"; then
        printf 'wdapi-logout: logged out and cleared saved token\n' >&2
    else
        printf 'wdapi-logout: failed to rewrite session file (left unchanged)\n' >&2
        return 1
    fi
}

# wdapi-search [query] [--from addr] [--to addr] [--subject s]
#              [--attachments] [--useAndSearch] [--raw|--json] [-h|--help]
# Search the authenticated user's mailboxes; pretty-prints by default.
wdapi-search() {
    if ! command -v jq >/dev/null 2>&1; then
        printf 'wdapi-search: `jq` not found\n' >&2
        return 1
    fi

    local query=""
    local raw=0
    local have_criterion=0
    local host
    local params
    params=()

    while [ $# -gt 0 ]; do
        case "$1" in
            -h|--help)
                cat >&2 <<'USAGE'
usage: wdapi-search [query] [options]
  query              free-text search over subject + body
  --from <addr>      match sender address
  --to <addr>        match recipient address
  --subject <s>      match subject
  --attachments      only messages with attachments
  --useAndSearch     require ALL criteria to match (AND instead of OR)
  --raw, --json      print the raw JSON response
  -h, --help         show this help
USAGE
                return 0
                ;;
            --from)
                if [ -z "$2" ]; then printf 'wdapi-search: --from needs a value\n' >&2; return 1; fi
                params+=("from==$2"); have_criterion=1; shift 2; continue
                ;;
            --to)
                if [ -z "$2" ]; then printf 'wdapi-search: --to needs a value\n' >&2; return 1; fi
                params+=("to==$2"); have_criterion=1; shift 2; continue
                ;;
            --subject)
                if [ -z "$2" ]; then printf 'wdapi-search: --subject needs a value\n' >&2; return 1; fi
                params+=("subject==$2"); have_criterion=1; shift 2; continue
                ;;
            --attachments)
                params+=("attachments==true"); have_criterion=1; shift; continue
                ;;
            --useAndSearch)
                params+=("useAndSearch==true"); shift; continue
                ;;
            --raw|--json)
                raw=1; shift; continue
                ;;
            --)
                shift
                if [ -n "$1" ] && [ -z "$query" ]; then query="$1"; have_criterion=1; shift; fi
                break
                ;;
            -*)
                printf 'wdapi-search: unknown option: %s\n' "$1" >&2
                return 1
                ;;
            *)
                if [ -z "$query" ]; then
                    query="$1"; have_criterion=1
                fi
                shift; continue
                ;;
        esac
    done

    if [ -n "$query" ]; then
        params+=("query==$query")
    fi

    if [ "$have_criterion" -ne 1 ]; then
        printf 'wdapi-search: provide a search query or at least one filter\n' >&2
        printf 'try: wdapi-search --help\n' >&2
        return 1
    fi

    host=$(_wdapi_host) || return 1

    if [ "$raw" -eq 1 ]; then
        https --session=basic_session GET "$host/users/me/search" "${params[@]}"
        return $?
    fi

    local body
    body=$(https --session=basic_session --print=b GET "$host/users/me/search" "${params[@]}" 2>/dev/null)
    if [ -z "$body" ]; then
        printf 'wdapi-search: no response from server\n' >&2
        return 1
    fi

    if [ "$(printf '%s' "$body" | jq -r '.success // false')" != "true" ]; then
        printf 'wdapi-search: search failed: %s\n' \
            "$(printf '%s' "$body" | jq -r '(.error // .code // "unknown error")')" >&2
        return 1
    fi

    printf '%s' "$body" | jq -r '
        # ANSI color helpers
        def esc: "\u001b[";
        def reset: esc + "0m";
        def dim: esc + "2m";
        def bold: esc + "1m";
        def blue: esc + "34m";
        def cyan: esc + "36m";
        def green: esc + "32m";
        def magenta: esc + "35m";
        def red: esc + "31m";
        def yellow: esc + "33m";
        def brightwhite: esc + "97m";

        def trunc(n): if (. | length) > n then (.[0:n] + "…") else . end;

        def fmtaddr(p):
            if p == null then ""
            elif (p.name != null and p.name != "") then
                (p.name + (if (p.address != null and p.address != "") then " <" + p.address + ">" else "" end))
            else (p.address // "")
            end;

        (.total // 0) as $total
        | (.page // 1) as $page
        | if $total == 0 or ((.results // []) | length) == 0 then
            dim + "No messages found" + reset
          else
            ( (.results // [])
              | map(
                  ( if (.seen == false) then (blue + "●" + reset + " ") else "  " end ) as $marker
                  | ( (.date // "") | (.[0:10] + " " + .[11:16]) ) as $date
                  | fmtaddr(.from) as $from
                  | (.subject // "(no subject)") as $subj
                  | ((.flagged // false) == true) as $flag
                  | ( if $flag then (red + bold + $subj + reset)
                      else (brightwhite + $subj + reset) end ) as $subjc
                  | ((.cc // []) | map(fmtaddr(.)) | map(select(. != "")) ) as $cclist
                  | ( (.intro // "") | gsub("\\s+"; " ") | trunc(100) ) as $intro
                  | ( $marker
                      + cyan + $date + reset + "  "
                      + green + bold + $from + reset + "  "
                      + $subjc
                      + ( if ($cclist | length) > 0 then "\n     " + magenta + dim + "cc: " + ($cclist | join(", ")) + reset else "" end )
                      + ( if ($intro | length) > 0 then "\n     " + dim + $intro + reset else "" end )
                    )
                )
              | join("\n\n")
            )
            + "\n\n" + dim + ($total | tostring) + " result" + (if $total == 1 then "" else "s" end) + " (page " + ($page | tostring) + ")" + reset
          end
    '
}

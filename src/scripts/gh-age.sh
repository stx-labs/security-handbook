#!/bin/sh
# gh-age: a drop-in `gh` wrapper that keeps gh's expiring OAuth refresh token
# encrypted with age to a YubiKey, and hands the real gh a short-lived access
# token through GH_TOKEN. Login uses GitHub's device flow without writing a
# plaintext refresh token to disk.
#
#   gh age-login [--scopes scope1,scope2]     log in and store the refresh token
#   gh age-logout                              delete the stored tokens
#   gh <anything else>                         run gh with a valid token
#
# Files:
#   $GH_AGE_DIR (default ~/.config/gh-age)
#     identity     age-plugin-fido2prf identity (requires the matching key)
#     refresh.age  the encrypted refresh token
#   $HOME/.gh-age-runtime/<configuration hash> (private, persists until logout)
#     cached access token, its expiry, and a lock
#
# Needs: the real gh (2.103.0+), age, age-plugin-fido2prf, curl, jq, flock.
# Set GH_REAL to the real gh binary, or it is looked up on PATH.
set -eu

CONF="${GH_AGE_DIR:-${XDG_CONFIG_HOME:-$HOME/.config}/gh-age}"
IDENTITY="$CONF/identity"
REFRESH="$CONF/refresh.age"

# gh's own OAuth app credentials. They are public, embedded in gh's source
# (internal/authflow/flow.go), and needed for the refresh grant.
CLIENT_ID=178c6fc778ccc68e1d6a
CLIENT_SECRET=34ddeff2b558a23d38fba8a6de74f086ede1cc0b

umask 077
die() { echo "gh-age: $*" >&2; exit 1; }

# Use a stable private directory under the user's home, never a shared /tmp
# name. Reject existing directories that another user could replace or access.
dir_info() {
  if [ "$(uname -s)" = Darwin ]; then
    stat -f '%u %Lp' "$1"
  else
    stat -c '%u %a' "$1"
  fi
}
uid=$(id -u)
[ -d "$HOME" ] && [ ! -L "$HOME" ] || die "HOME must be a real directory"
home_info=$(dir_info "$HOME") || die "cannot inspect HOME"
home_owner=${home_info%% *}
home_mode=${home_info#* }
[ "$home_owner" = "$uid" ] || die "HOME must be owned by the current user"
case "$home_mode" in *[!0-7]*|'') die "cannot inspect HOME permissions";; esac
[ $((0$home_mode & 022)) -eq 0 ] || die "HOME must not be writable by other users"
STATE="$HOME/.gh-age-runtime"
mkdir -p -m 700 "$STATE" || die "cannot create $STATE"
[ -d "$STATE" ] && [ ! -L "$STATE" ] || die "unsafe runtime directory: $STATE"
state_info=$(dir_info "$STATE") || die "cannot inspect $STATE"
state_owner=${state_info%% *}
state_mode=${state_info#* }
[ "$state_owner" = "$uid" ] && [ "$state_mode" = 700 ] || die "$STATE must be owned by you with mode 700"

# Resolve aliases of the same configuration to one cache and one lock. Never
# reuse a cached token from a different configuration or account.
mkdir -p "$CONF" || die "cannot create configuration directory: $CONF"
CONF=$(CDPATH= cd -P "$CONF" && pwd -P) || die "cannot resolve configuration directory"
IDENTITY="$CONF/identity"
REFRESH="$CONF/refresh.age"
if command -v sha256sum >/dev/null 2>&1; then
  conf_hash=$(printf '%s' "$CONF" | sha256sum)
else
  conf_hash=$(printf '%s' "$CONF" | shasum -a 256)
fi
conf_hash=${conf_hash%% *}
STATE="$STATE/$conf_hash"
mkdir -p -m 700 "$STATE" || die "cannot create runtime directory: $STATE"
[ -d "$STATE" ] && [ ! -L "$STATE" ] || die "unsafe runtime directory: $STATE"
state_info=$(dir_info "$STATE") || die "cannot inspect $STATE"
state_owner=${state_info%% *}
state_mode=${state_info#* }
[ "$state_owner" = "$uid" ] && [ "$state_mode" = 700 ] || die "$STATE must be owned by you with mode 700"

# Find the real gh: GH_REAL if set, else the first gh on PATH that isn't us.
: "${GH_REAL:=}"
if [ -z "$GH_REAL" ]; then
  old_ifs=$IFS; IFS=:
  for d in $PATH; do
    if [ -x "$d/gh" ] && ! [ "$d/gh" -ef "$0" ]; then
      GH_REAL="$d/gh"; break
    fi
  done
  IFS=$old_ifs
  [ -n "$GH_REAL" ] || die "cannot find the real gh on PATH; set GH_REAL"
fi

# Commands that need no token: don't make the YubiKey blink for tab completion.
case "${1:-}" in
  "" | -h | --help | help | --version | version | completion | __complete | __completeNoDesc)
    exec "$GH_REAL" "$@" ;;
esac

# Treat a help flag as such only when it cannot be an option's value. Unknown
# options are conservatively assumed to take a value; -- ends option parsing.
option_value=0
for arg in "$@"; do
  [ "$arg" != -- ] || break
  if [ "$option_value" -eq 1 ]; then
    option_value=0
    continue
  fi
  case "$arg" in
    -h|--help) exec "$GH_REAL" "$@" ;;
    --*=*) ;;
    -?*) option_value=1 ;;
  esac
done

# Serialise token work: GitHub rotates the refresh token on every use, so two
# concurrent refreshes would burn it.
exec 9>"$STATE/lock"
flock 9

save_refresh() { # token on stdin; FIDO2 verification is needed for encryption
  rm -f "$REFRESH.tmp"
  age -e -i "$IDENTITY" -o "$REFRESH.tmp" && mv "$REFRESH.tmp" "$REFRESH"
}

clear_cache() { rm -f "$STATE/access" "$STATE/access.tmp" "$STATE/expires_at" "$STATE/expires_at.tmp"; }

access_token() {
  now=$(date +%s)
  if [ -s "$STATE/access" ] && [ -s "$STATE/expires_at" ] &&
     [ "$(cat "$STATE/expires_at")" -gt $((now + 300)) ]; then
    cat "$STATE/access"
    return
  fi

  [ -f "$REFRESH" ] || die "no stored refresh token; run: gh age-login"
  echo "gh-age: refreshing GitHub token (YubiKey PIN/touch may be needed)" >&2

  # Do not contact GitHub if decryption fails. Keep the token off the command line.
  old_refresh=$(age -d -i "$IDENTITY" "$REFRESH") || die "could not decrypt refresh token"
  resp=$(printf '%s' "$old_refresh" | curl -fsS https://github.com/login/oauth/access_token \
      -H 'Accept: application/json' \
      -d grant_type=refresh_token \
      -d client_id="$CLIENT_ID" \
      -d client_secret="$CLIENT_SECRET" \
      --data-urlencode 'refresh_token@-')
  unset old_refresh

  # GitHub reports errors as HTTP 200 with an "error" field.
  if ! printf '%s' "$resp" | jq -e '.access_token' >/dev/null; then
    die "refresh failed: $(printf '%s' "$resp" | jq -r '.error_description // .error // .')
gh-age: if the refresh token was revoked or expired, run: gh age-login"
  fi

  # Save the rotated refresh token first: the old one is now dead.
  new_refresh=$(printf '%s' "$resp" | jq -r '.refresh_token // empty')
  if [ -z "$new_refresh" ]; then
    rm -f "$REFRESH" "$REFRESH.tmp"
    clear_cache
    die "refresh response did not contain a new refresh token; run: gh age-login"
  fi
  echo "gh-age: verify again to save the rotated refresh token" >&2
  if ! printf '%s\n' "$new_refresh" | save_refresh; then
    rm -f "$REFRESH" "$REFRESH.tmp"
    clear_cache
    die "could not save the rotated refresh token; run: gh age-login"
  fi
  unset new_refresh

  printf '%s' "$resp" | jq -r '.access_token' >"$STATE/access.tmp"
  expires_in=$(printf '%s' "$resp" | jq -r '.expires_in // 3600')
  echo $((now + expires_in)) >"$STATE/expires_at.tmp"
  mv "$STATE/access.tmp" "$STATE/access"
  mv "$STATE/expires_at.tmp" "$STATE/expires_at"
  cat "$STATE/access"
}

case "${1:-}" in
  age-login)
    shift
    [ -s "$IDENTITY" ] || die "missing $IDENTITY (age-plugin-fido2prf identity)"
    scopes='repo read:org gist offline_access'
    if [ "$#" -gt 0 ]; then
      [ "$#" -eq 2 ] && [ "$1" = --scopes ] || die "usage: gh age-login [--scopes scope1,scope2]"
      case "$2" in *[!a-zA-Z0-9_:,.-]*|'') die "invalid scopes";; esac
      scopes="$scopes $(printf '%s' "$2" | tr ',' ' ')"
    fi
    code_response=$(curl -fsS https://github.com/login/device/code \
      -H 'Accept: application/json' -d "client_id=$CLIENT_ID" \
      --data-urlencode "scope=$scopes") || die "could not start GitHub device authorization"
    device_code=$(printf '%s' "$code_response" | jq -er '.device_code | select(type == "string" and length > 0)') || die "invalid device authorization response"
    user_code=$(printf '%s' "$code_response" | jq -er '.user_code | select(type == "string" and length > 0)') || die "invalid device authorization response"
    interval=$(printf '%s' "$code_response" | jq -er '.interval | select(type == "number" and floor == . and . > 0)') || die "invalid device polling interval"
    lifetime=$(printf '%s' "$code_response" | jq -er '.expires_in | select(type == "number" and floor == . and . > 0)') || die "invalid device code expiry"
    deadline=$(($(date +%s) + lifetime))
    unset code_response
    echo "gh-age: open https://github.com/login/device and enter code $user_code" >&2
    echo "gh-age: waiting for authorization..." >&2
    while :; do
      [ "$(date +%s)" -lt "$deadline" ] || die "device authorization expired; run: gh age-login"
      sleep "$interval"
      resp=$(printf '%s' "$device_code" | curl -fsS https://github.com/login/oauth/access_token \
        -H 'Accept: application/json' -d "client_id=$CLIENT_ID" \
        -d 'grant_type=urn:ietf:params:oauth:grant-type:device_code' \
        --data-urlencode 'device_code@-') || die "device authorization request failed"
      error=$(printf '%s' "$resp" | jq -r '.error // empty') || die "invalid authorization response"
      case "$error" in
        authorization_pending) continue ;;
        slow_down) interval=$((interval + 5)); continue ;;
        '') break ;;
        *) die "device authorization failed: $error" ;;
      esac
    done
    unset device_code user_code
    tok=$(printf '%s' "$resp" | jq -er '.refresh_token | select(type == "string" and length > 0)') ||
      die "GitHub did not issue a refreshable token. Revoke GitHub CLI at https://github.com/settings/applications"
    access=$(printf '%s' "$resp" | jq -er '.access_token | select(type == "string" and length > 0)') || die "authorization response has no access token"
    expires_in=$(printf '%s' "$resp" | jq -er '.expires_in | select(type == "number" and floor == . and . > 0)') || die "authorization response has no valid expiry"
    # Anchor the cached expiry before the token was issued.
    issued_before=$((deadline - lifetime))
    printf '%s\n' "$tok" | save_refresh || die "could not encrypt refresh token; revoke GitHub CLI at https://github.com/settings/applications"
    unset tok resp
    clear_cache
    printf '%s' "$access" > "$STATE/access"
    echo $((issued_before + expires_in)) > "$STATE/expires_at"
    echo "gh-age: refresh token stored in $REFRESH; verifying..." >&2
    login=$(GH_TOKEN="$access" "$GH_REAL" api user --jq .login)
    unset access
    echo "gh-age: logged in as $login" >&2
    exit 0
    ;;
  age-logout)
    rm -f "$REFRESH" "$REFRESH.tmp"
    clear_cache
    echo "gh-age: local tokens deleted. To revoke them on GitHub, remove" >&2
    echo "gh-age: GitHub CLI at https://github.com/settings/applications" >&2
    exit 0
    ;;
  auth)
    case "${2:-}" in
      login) die "use 'gh age-login' instead of 'gh auth login'" ;;
      logout) die "use 'gh age-logout' instead of 'gh auth logout'" ;;
    esac
    ;;
esac

token=$(access_token)
exec 9>&- # release the lock so long-running gh commands don't block others
export GH_TOKEN="$token"
exec "$GH_REAL" "$@"

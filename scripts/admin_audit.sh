#!/usr/bin/env bash
# scripts/admin_audit.sh
# Audits the admin side of uzinduzi_mobile_app.
# Prints what exists, what's missing, and what's partially wired.

set -u
cd "$(dirname "$0")/.." || exit 1

BOLD=$'\033[1m'; DIM=$'\033[2m'; RED=$'\033[31m'; GRN=$'\033[32m'; YEL=$'\033[33m'; RST=$'\033[0m'

pass() { printf "  ${GRN}✔${RST} %s\n" "$1"; }
fail() { printf "  ${RED}✘${RST} %s\n" "$1"; }
warn() { printf "  ${YEL}●${RST} %s\n" "$1"; }
head() { printf "\n${BOLD}%s${RST}\n" "$1"; }

ADMIN=lib/features/admin

head "1. Infrastructure"
for f in admin_guard.dart admin_desktop_guard.dart admin_routes.dart admin_shell.dart; do
  [[ -f "$ADMIN/$f" ]] && pass "$f" || fail "$f (missing)"
done

head "2. Shared helpers (should exist)"
for f in shared/admin_confirm.dart shared/admin_danger_zone.dart shared/admin_preflight.dart shared/admin_media_upload.dart; do
  [[ -f "$ADMIN/$f" ]] && pass "$f" || fail "$f (missing)"
done

head "3. Albums admin"
for f in albums/admin_albums_screen.dart albums/admin_album_create_screen.dart \
         albums/admin_album_edit_screen.dart albums/admin_album_model.dart \
         albums/admin_albums_provider.dart; do
  [[ -f "$ADMIN/$f" ]] && pass "$f" || fail "$f (missing)"
done

head "4. Tracks admin"
for f in albums/admin_track_edit_screen.dart albums/admin_tracks_provider.dart; do
  [[ -f "$ADMIN/$f" ]] && pass "$f" || fail "$f (missing)"
done

head "5. Artists admin (management — not just picker)"
[[ -d "$ADMIN/artists" ]] && pass "artists/ dir exists" || fail "artists/ dir MISSING (only picker exists)"
for f in artists/admin_artists_screen.dart artists/admin_artist_edit_screen.dart \
         artists/admin_artists_provider.dart artists/admin_artist_model.dart; do
  [[ -f "$ADMIN/$f" ]] && pass "$f" || fail "$f (missing)"
done

head "6. Plaque Tiers admin"
[[ -d "$ADMIN/tiers" ]] && pass "tiers/ dir exists" || fail "tiers/ dir MISSING (public feature has no admin UI)"
for f in tiers/admin_tiers_screen.dart tiers/admin_tier_edit_screen.dart \
         tiers/admin_tiers_provider.dart tiers/admin_tier_model.dart; do
  [[ -f "$ADMIN/$f" ]] && pass "$f" || fail "$f (missing)"
done

head "7. Album Launch admin"
found_launch=0
for f in albums/admin_album_launch_screen.dart albums/admin_album_launch_provider.dart; do
  if [[ -f "$ADMIN/$f" ]]; then pass "$f"; found_launch=1; fi
done
[[ $found_launch -eq 0 ]] && fail "no launch admin screen (public LaunchCountdown is dead without it)"

head "8. Users admin"
for f in users/admin_users_screen.dart users/admin_users_provider.dart \
         users/admin_user_model.dart users/widgets/user_row_card.dart; do
  [[ -f "$ADMIN/$f" ]] && pass "$f" || fail "$f (missing)"
done

head "9. Feature checks in existing files"

check_grep() { # file  pattern  label
  local file="$ADMIN/$1" pat="$2" label="$3"
  if [[ ! -f "$file" ]]; then fail "$label — file missing"; return; fi
  if grep -qE "$pat" "$file"; then pass "$label"; else fail "$label"; fi
}

# Album edit gaps
check_grep albums/admin_album_edit_screen.dart 'genres'          'album edit: genres editable'
check_grep albums/admin_album_edit_screen.dart 'isDemo|is_demo'  'album edit: isDemo toggle'
check_grep albums/admin_album_edit_screen.dart 'showDialog'      'album edit: confirm dialog present'
check_grep albums/admin_album_edit_screen.dart 'delete-preflight|canHardDelete|hardDelete' \
                                                                 'album edit: hard-delete + preflight'
check_grep albums/admin_album_edit_screen.dart 'soft-delete'     'album edit: soft-delete toggle'
check_grep albums/admin_album_edit_screen.dart '_pickAndUploadCover' 'album edit: cover upload'

# Album create gaps
check_grep albums/admin_album_create_screen.dart 'ImagePicker|upload|presign' \
                                                                 'album create: cover upload'
check_grep albums/admin_album_create_screen.dart 'genres'        'album create: genres'

# Track edit gaps
check_grep albums/admin_track_edit_screen.dart 'isPublished'        'track edit: isPublished toggle'
check_grep albums/admin_track_edit_screen.dart 'releaseDate'        'track edit: releaseDate'
check_grep albums/admin_track_edit_screen.dart 'soft-delete|is_deleted' \
                                                                    'track edit: soft-delete'

# Users row actions
check_grep users/widgets/user_row_card.dart 'role|suspend|verify'  'user row: role/suspend/verify actions'

head "10. Backend endpoints referenced (grep)"
printf "${DIM}Referenced in admin Dart files — confirm these exist server-side.${RST}\n"
grep -rhoE "'/api/admin/[^']+'" "$ADMIN" 2>/dev/null | sort -u | sed 's/^/  /' || true

head "Summary"
total_missing=$(grep -c "missing" /dev/null 2>/dev/null || true)
printf "${BOLD}Priorities:${RST}\n"
printf "  1. ${RED}Safe delete${RST}    — albums + tracks confirm dialogs, preflight, hard-delete\n"
printf "  2. ${RED}Tiers admin${RST}   — full CRUD + image upload (public feature is live)\n"
printf "  3. ${RED}Launch admin${RST}  — create/edit windows, status, tierThresholds\n"
printf "  4. ${RED}Artists admin${RST} — CRUD + profile/cover upload\n"
printf "  5. ${YEL}Edit gaps${RST}     — genres[], isDemo, track isPublished/releaseDate\n"
printf "  6. ${YEL}Shared helpers${RST} — confirm, danger zone, preflight, media upload\n"
printf "\nRun again after each milestone to track progress.\n"
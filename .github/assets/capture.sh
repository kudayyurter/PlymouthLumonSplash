#!/usr/bin/env bash
# .github/assets/capture.sh: records demo.gif from the real theme, without root and
# without installing it or touching boot config.
#
# plymouthd runs the repo's contents/splash with its X11 renderer inside a bubblewrap
# sandbox (fake root in a user namespace, private /dev with no tty, DRM or input
# devices), drawing on a headless gamescope display that ffmpeg records.
#
# Needs: plymouth (with renderers/x11.so), bubblewrap, gamescope, ffmpeg, python-xlib,
# and the readme-writer skill's to-gif.sh.
# Usage (from the repo root): SKILL=~/.agents/skills/readme-writer bash .github/assets/capture.sh
set -euo pipefail

repo=$(cd "$(dirname "$0")/../.." && pwd)
out=$(mktemp -d)
W=1920 H=1080

# 1. Headless X display (nothing appears on your screen).
gamescope --backend headless -W $W -H $H -w $W -h $H -- sleep 120 >"$out/gamescope.log" 2>&1 &
gs=$!
trap 'kill $gs 2>/dev/null || true' EXIT
for _ in $(seq 50); do
  disp=$(grep -o 'Starting Xwayland on :[0-9]*' "$out/gamescope.log" | grep -o ':[0-9]*' || true)
  [ -n "$disp" ] && [ -S "/tmp/.X11-unix/X${disp#:}" ] && break
  sleep 0.2
done
export DISPLAY=$disp

# 2. plymouthd + the theme, sandboxed. It exits on its own after 20 s.
bwrap --ro-bind / / --dev /dev --proc /proc --tmpfs /run --tmpfs /run/udev \
  --tmpfs /sys/class/drm --tmpfs /sys/class/input --tmpfs /sys/class/tty \
  --bind "$out" "$out" --ro-bind "$repo/contents/splash" /usr/share/plymouth/themes/lumon \
  --unshare-user --uid 0 --gid 0 --unshare-pid --setenv DISPLAY "$DISPLAY" --die-with-parent \
  bash -c "plymouthd --no-daemon --no-boot-log --mode=boot --pid-file=$out/ply.pid \
             --kernel-command-line='quiet splash plymouth.theme=lumon' & sleep 1
           plymouth show-splash; sleep 20; plymouth quit" &
ply=$!

# 3. Find plymouth's window and record it.
win=""
for _ in $(seq 50); do
  win=$(python3 - <<'PY'
from Xlib import display
d = display.Display()
for w in d.screen().root.query_tree().children:
    a, g = w.get_attributes(), w.get_geometry()
    if a.map_state == 2 and g.width >= 640 and "plymouth" in str(w.get_wm_class() or "").lower():
        print(hex(w.id)); break
PY
)
  [ -n "$win" ] && break
  sleep 0.1
done
[ -n "$win" ] || { echo "plymouth window not found" >&2; exit 1; }
ffmpeg -loglevel error -y -f x11grab -draw_mouse 0 -framerate 50 -window_id "$win" -i "$DISPLAY" -t 16 \
  -c:v libx264 -crf 12 -preset veryfast -pix_fmt yuv420p "$out/splash.mp4"
wait $ply || true

# 4. One full loop of the animation (167 frames at 25 fps = 6.68 s), starting on the
#    finished logo so the first frame is not a black screen.
bash "$SKILL/scripts/to-gif.sh" "$out/splash.mp4" "$repo/.github/assets/demo" \
  --start "${START:-5.5}" --length 6.68 --fps 25 --width 800
rm -f "$repo/.github/assets/demo.mp4"   # keep the MP4 only for a github.com upload
echo "raw capture: $out/splash.mp4"

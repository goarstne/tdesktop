#!/bin/bash
# Renders the template for every Omarchy theme with Omarchy's own generator and checks the result.
S=$(dirname "$(readlink -f "$0")"); TPL=${1:-$S/telegram.tdesktop-theme.tpl}
export OMARCHY_PATH=${OMARCHY_PATH:-/usr/share/omarchy}
fail=0
for theme in "$OMARCHY_PATH"/themes/*/; do
  name=$(basename "$theme"); home=$(mktemp -d)
  mkdir -p "$home/.config/omarchy/themed" "$home/.local/state/omarchy/current/next-theme"
  cp "$TPL" "$home/.config/omarchy/themed/"
  cp "$theme/colors.toml" "$home/.local/state/omarchy/current/next-theme/" 2>/dev/null || { echo "$name: no colors.toml, skipped"; continue; }
  HOME=$home omarchy-theme-set-templates >/dev/null 2>&1
  python3 - "$home/.local/state/omarchy/current/next-theme/telegram.tdesktop-theme" "$name" <<'PY' || fail=1
import re, sys
vals, bad = {}, []
for n, line in enumerate(open(sys.argv[1]), 1):
    if line.startswith('//') or not line.strip(): continue
    m = re.fullmatch(r'(\w+): (#[0-9a-f]{6}(?:[0-9a-f]{2})?|\w+);\n?', line, re.I)
    if not m or (not m[2].startswith('#') and m[2] not in vals): bad.append(n); continue
    vals[m[1]] = m[2] if m[2].startswith('#') else vals[m[2]]
def L(c):
    ch = [int(c[i:i+2], 16)/255 for i in (1, 3, 5)]
    ch = [x/12.92 if x <= 0.03928 else ((x+0.055)/1.055)**2.4 for x in ch]
    return 0.2126*ch[0] + 0.7152*ch[1] + 0.0722*ch[2]
def cr(a, b):
    a, b = sorted((L(vals[a]), L(vals[b])), reverse=True); return (a+0.05)/(b+0.05)
pairs = [('windowFg','windowBg'),('windowFgActive','windowBgActive'),('activeButtonFg','activeButtonBg'),
         ('dialogsNameFgActive','dialogsBgActive'),('dialogsUnreadFg','dialogsUnreadBg'),
         ('historyTextOutFg','msgOutBg'),('historyTextInFg','msgInBg'),('historyTextOutFgSelected','msgOutBgSelected'),
         ('windowActiveTextFg','windowBg'),('lightButtonFg','lightButtonBg'),('windowSubTextFg','windowBg')]
worst = min(pairs, key=lambda p: cr(*p))
ok = not bad and cr(*worst) >= 2.5
print(f"{sys.argv[2]:16s} keys={len(vals)} badlines={bad[:5]} worst={worst[0]}/{worst[1]} {cr(*worst):.1f} {'ok' if ok else 'FAIL'}")
sys.exit(0 if ok else 1)
PY
  rm -rf "$home"
done
exit $fail

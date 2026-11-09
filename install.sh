#!/usr/bin/env bash
# Applies the omp kit: settings (through `omp config set`), global AGENTS.md rules, theme, plugins.
# Never touches models, providers or API keys. Safe to re-run: config.yml and AGENTS.md are backed up first.
#   ./install.sh                 settings, rules, theme and plugins
#   ./install.sh --no-plugins    skip the plugins
#   ./install.sh --yolo          also run tools without asking (risky commands still ask, see settings.json)
set -euo pipefail
cd "$(dirname "$0")"
KIT=$PWD
PLUGINS=1
YOLO=0
for a in "$@"; do case "$a" in
  --no-plugins) PLUGINS=0 ;;
  --yolo) YOLO=1 ;;
  *) echo "unknown option: $a" >&2; exit 2 ;;
esac; done

say() { printf '\033[1m%s\033[0m\n' "$*"; }
warn() { printf '\033[33m! %s\033[0m\n' "$*"; }
have() { command -v "$1" >/dev/null 2>&1; }

have omp || { echo "omp not found: install Oh My Pi first." >&2; exit 1; }
have python3 || { echo "python3 not found." >&2; exit 1; }
DIR=$(omp config path 2>/dev/null | tail -1)
DIR=${DIR:-$HOME/.omp/agent}
BACKUP="$DIR/backup-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$DIR" "$BACKUP"

say "1/4 Settings"
[ -f "$DIR/config.yml" ] && cp "$DIR/config.yml" "$BACKUP/"
# One `omp config set` per key: omp validates each value and keeps every other setting (models, keys...)
python3 -c 'import json,sys
for k, v in json.load(open(sys.argv[1])).items():
    print(k); print(json.dumps(v) if not isinstance(v, str) else v)' "$KIT/settings.json" |
while IFS= read -r key && IFS= read -r value; do
  omp config set "$key" "$value" >/dev/null || warn "could not set $key"
done
if have rtk; then
  # rtk already shortens command output: omp's own minimizer would do it twice
  omp config set shellMinimizer.enabled false >/dev/null
fi
[ "$YOLO" = 1 ] && omp config set tools.approvalMode yolo >/dev/null && warn "tools run without asking (yolo)"
echo "settings applied"

say "2/4 Global rules (AGENTS.md)"
if [ -f "$DIR/AGENTS.md" ] && ! cmp -s "$KIT/AGENTS.md" "$DIR/AGENTS.md"; then
  cp "$DIR/AGENTS.md" "$BACKUP/"
  warn "your previous AGENTS.md is in $BACKUP: merge back anything you want to keep"
fi
cp "$KIT/AGENTS.md" "$DIR/AGENTS.md"

say "3/4 Theme"
mkdir -p "$DIR/themes"
cp "$KIT"/themes/*.json "$DIR/themes/"

say "4/4 Plugins"
if [ "$PLUGINS" = 1 ]; then
  omp plugin install https://github.com/obra/superpowers >/dev/null && echo "superpowers installed" || warn "superpowers: install failed"
  omp plugin marketplace add DietrichGebert/ponytail >/dev/null 2>&1 || true
  omp plugin install ponytail@ponytail >/dev/null && echo "ponytail installed" || warn "ponytail: install failed"
else
  echo "skipped"
fi

rmdir "$BACKUP" 2>/dev/null || echo "previous files backed up in $BACKUP"
echo
say "Done. Pick your model: omp config set modelRoles.default <provider/model>"
have rtk || warn "rtk not found: optional, it shortens command output (see README)"

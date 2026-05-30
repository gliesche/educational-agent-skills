#!/usr/bin/env bash
#
# Packt einen Skill als .zip für den Upload in die Claude Desktop App / claude.ai.
# Die App erwartet die SKILL.md auf der obersten Ebene des Zips (nicht in einem Unterordner).
#
# Nutzung:
#   ./scripts/package-skill.sh spiele-erfinden
#   -> erzeugt dist/spiele-erfinden.zip
#
set -euo pipefail

SKILL_NAME="${1:-}"
if [[ -z "$SKILL_NAME" ]]; then
  echo "Bitte einen Skill-Namen angeben, z. B.: ./scripts/package-skill.sh spiele-erfinden"
  echo "Verfügbare Skills:"
  ls -1 skills/
  exit 1
fi

SKILL_DIR="skills/$SKILL_NAME"
if [[ ! -f "$SKILL_DIR/SKILL.md" ]]; then
  echo "Fehler: $SKILL_DIR/SKILL.md nicht gefunden."
  exit 1
fi

mkdir -p dist
OUT="dist/$SKILL_NAME.zip"
rm -f "$OUT"

# Aus dem Skill-Ordner heraus zippen, damit SKILL.md im Zip-Root liegt.
# .DS_Store wird ausgeschlossen.
( cd "$SKILL_DIR" && zip -r -X "../../$OUT" . -x "*.DS_Store" )

echo "Fertig: $OUT"
echo "Lade es in der Claude Desktop App hoch unter: Einstellungen → Customize → Skills → +"

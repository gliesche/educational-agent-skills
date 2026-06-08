# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

Öffentliche Sammlung von **Agent Skills für den Bildungsbereich** (Schule/Kinder). Doku und
Skill-Inhalte sind **auf Deutsch** (Zielgruppe: deutsche Kinder, Eltern, Lehrkräfte). Aktuell zwei
Skills: `spiele-erfinden` — begleitet Kinder altersgerecht dabei, ihr eigenes Browser-Spiel zu
erfinden (das Kind beschreibt, die KI baut); und `geografie-entdecken` — lässt Kinder Deutschland
auf einer klickbaren Karte entdecken und daraus ihr eigenes Quiz / ihre Steckbrief-Sammlung bauen
(das Kind erfindet das Werk, die KI baut; das Quiz stupst statt zu lösen).

## ⚠️ Wichtigste Regel: Dual-Location-Sync

Jeder Skill existiert **doppelt**:
- **Quelle (hier im Repo):** `skills/<name>/`
- **Live-Kopie für Claude Code:** `~/.claude/skills/<name>/`

Das Repo ist die **Quelle der Wahrheit**. Nach jeder Änderung an einem Skill die Live-Kopie
angleichen, sonst nutzt die laufende Claude-Code-Sitzung eine veraltete Version:

```bash
cp skills/spiele-erfinden/SKILL.md ~/.claude/skills/spiele-erfinden/SKILL.md
cp skills/spiele-erfinden/references/spiel-vorlagen.md ~/.claude/skills/spiele-erfinden/references/spiel-vorlagen.md
diff -r skills/spiele-erfinden ~/.claude/skills/spiele-erfinden   # muss leer sein
```

## Architektur-Prinzipien

- **Ein Skill = ein in sich geschlossener Ordner** mit `SKILL.md` (Frontmatter `name`,
  `description`, `user-invocable` + Anleitung) und optional `references/` (on-demand-Doku).
  Ein Skill kann **nicht** Dateien eines anderen Skills nutzen — relevant fürs Packaging.
- **Skills sind intern alters-adaptiv, NICHT pro Klasse gesplittet.** `spiele-erfinden` deckt
  ≈6–12 Jahre über eine Stufen-Kalibrierung in der `SKILL.md` ab. Grund: die geteilten Bausteine
  (Spiel-Vorlagen, Pädagogik) wären bei Klassen-Skills mehrfach dupliziert und würden auseinander
  driften. **Neue Skills entstehen nach Thema/Fach**, nicht nach Klassenstufe.
- **Auffindbarkeit nach Alter** läuft über die **Index-Tabelle in `README.md`** (Spalte
  „Altersstufe"), nicht über Ordnerstruktur.
- **Umgebungs-Bewusstsein:** Der Skill baut das Spiel als **HTML-Artifact** in der Claude
  Desktop-/Web-App (kein Datei-/`open`-Zugriff) und als **Datei + `open`** in Claude Code. Beim
  Bearbeiten der `SKILL.md` diese Doppelung erhalten.

## Spiel-Vorlagen (der inhaltliche Kern)

`skills/spiele-erfinden/references/spiel-vorlagen.md` enthält **10 fertige, in sich geschlossene
HTML-Spiele** als ` ```html `-Codeblöcke. Claude **kopiert** die passende Vorlage und passt nur die
mit `ANPASSEN` markierten Stellen an (Figur, Ziel, Farben, Texte, Schwierigkeit über `ZIEL`/`tempo`).

- **Vorlagen 1–9 laufen komplett offline** (kein Internet, kein Build, Doppelklick = los).
- **Vorlage 10 (3D)** lädt Three.js per CDN → braucht Internet. Bewusst **kein** SRI-Integrity-Hash,
  weil die Vorlage pro Kind neu angepasst wird (inkl. Version) und ein fixer Hash bräche.
- `innerHTML` wird nur zum **Leeren** genutzt; alle sichtbaren Texte über `textContent` (kein XSS).

## Verifikation (es gibt keine Test-Suite — so prüft man Vorlagen)

Nach Änderungen an den Vorlagen jede headless im Browser auf JS-Fehler prüfen. Vorgehen: die
` ```html `-Blöcke aus der Markdown extrahieren und mit dem vorhandenen Playwright-Build laden.

```bash
# 1) Blöcke extrahieren (Python-Regex auf die .md), z.B. nach /tmp/check/v1.html ...
# 2) Headless laden mit dem installierten Chromium-headless-shell:
EXE=$(ls ~/Library/Caches/ms-playwright/chromium_headless_shell-*/chrome-headless-shell-mac-*/chrome-headless-shell | head -1)
GROOT=$(npm root -g)   # @playwright/cli liegt global
NODE_PATH="$GROOT/@playwright/cli/node_modules" node -e '
const pw=require("playwright");(async()=>{const b=await pw.chromium.launch({executablePath:process.env.EXE});
const p=await b.newPage();const errs=[];p.on("pageerror",e=>errs.push(e.message));
await p.goto("file:///tmp/check/v1.html");await p.locator("button:visible").first().click();
await p.waitForTimeout(800);console.log(errs.length?errs:"ok");await b.close();})();'
```

Prüfen: keine `pageerror`/Console-Errors, Start-Knopf führt ins Spiel, Gewinn-/Verlier-Zustand
erreichbar. Bei `spiele-erfinden` zusätzlich darauf achten, dass deutsche Texte korrekt sind
(z.B. Anzahlen als Emoji-Zähler `'🍩 '+n` statt `n+' Donuts'`, um Ein-/Mehrzahl-Fehler zu vermeiden).

Bei `geografie-entdecken` (`references/karten-vorlage.md`) zusätzlich: Karte rendert 16
Bundesländer, Klick zeigt die **korrekte** Hauptstadt (Stichprobe Bayern→München, NRW→Düsseldorf),
der Üben-Modus ist **sichtbar** (nicht nur im DOM — `getComputedStyle(...).display` prüfen, nicht
nur `textContent`!) und antwortbar, der Fehler-Pfad sagt „noch nicht" + Hinweis statt „falsch".
Fakten in `REGIONS` nicht ändern — sie sind fakten-geprüft.

## Packaging für die Claude Desktop App / claude.ai

```bash
./scripts/package-skill.sh spiele-erfinden   # -> dist/<name>.zip
```

Die App erwartet die **`SKILL.md` im Zip-Root** (das Script zippt aus dem Skill-Ordner heraus).
`dist/` und `*.zip` sind in `.gitignore` und werden nicht versioniert.

## Konventionen

- **Sprache:** Doku, README, Skill-Texte und Spiel-Texte auf **Deutsch**. Code-Identifier (auch im
  generierten Spiel-Code) auf Englisch.
- **Kein „Claude" im Skill-/Repo-Namen** — Markenschutz; offizielle Zugehörigkeit vermeiden. Der
  generische Begriff ist „Agent Skills".
- **Commits:** Conventional Commits (`feat`, `fix`, `docs`, `chore`…), ein Anliegen pro Commit,
  atomar, **keine** `Co-Authored-By`-Zeile.
- **Lizenz:** MIT.

## Pädagogische Grundlage

Die Gestaltung folgt belegten Prinzipien (Konstruktionismus, Selbstbestimmungstheorie, Flow,
Growth Mindset, „low floor / wide walls"), dokumentiert mit Quellen in
[`docs/paedagogik.md`](docs/paedagogik.md). Leitprinzip für alle Skills: **Das Kind erfindet, die
KI baut** — die kreative/beschreibende Arbeit (das eigentliche Lernziel) nie für das Kind
übernehmen, beim Feststecken nur anstupsen.

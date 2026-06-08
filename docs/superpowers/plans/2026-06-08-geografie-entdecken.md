# geografie-entdecken Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Einen neuen Fach-Skill `geografie-entdecken` bauen, der ein Kind (≈6–12, kalibriert 3. Klasse) Deutschland entdecken lässt und es daraus ein eigenes Werk (Quiz/Steckbriefe) bauen lässt — als eine offline, sofort spielbare HTML-Vorlage plus `SKILL.md`.

**Architecture:** Zwei Dateien wie `spiele-erfinden` (`SKILL.md` + `references/karten-vorlage.md`). Die HTML-Vorlage ist **datengetrieben**: eine generische Engine liest ein `REGIONS`-Objekt + Inline-SVG-Karte; ein Paket-Wechsel (später Europa) tauscht nur Daten + SVG. Verifikation über headless Chromium (kein Test-Framework im Repo).

**Tech Stack:** Reines HTML/CSS/JS (kein Build, kein CDN — Inline-SVG). Verifikation: Playwright (`chrome-headless-shell`) via global installiertem `@playwright/cli`. Build-Zeit-Helfer: Node (GeoJSON→SVG-Konverter, dessen Output eingebettet wird).

---

## Quelle der Wahrheit für Inhalte

Der **fakten-geprüfte Datensatz** (16 Bundesländer + Hauptstädte + Flüsse + kindgerechte Anker, 9 Nachbarländer, 2 Meere, Gebirge) steht in **Anhang A** des Specs `docs/superpowers/specs/2026-06-08-geografie-entdecken-design.md`. Alle `REGIONS`-Einträge werden daraus befüllt — nicht neu erfinden.

## Wiederverwendbarer Headless-Check (in jeder HTML-Task genutzt)

Die HTML-Vorlage liegt als ` ```html `-Block in `references/karten-vorlage.md`. Zum Prüfen wird der Block extrahiert und headless geladen. Diese zwei Helfer einmalig anlegen:

**Extractor** `/tmp/geo-check/extract.py` (zieht den ersten html-Codeblock aus der .md):
```python
import re, sys, pathlib
md = pathlib.Path(sys.argv[1]).read_text(encoding="utf-8")
m = re.search(r"```html\n(.*?)\n```", md, re.S)
assert m, "kein ```html Block gefunden"
out = pathlib.Path("/tmp/geo-check/index.html")
out.parent.mkdir(parents=True, exist_ok=True)
out.write_text(m.group(1), encoding="utf-8")
print("extrahiert ->", out)
```

**Runner** `/tmp/geo-check/run.sh` (lädt index.html headless, führt das übergebene JS-Assert-Snippet aus):
```bash
#!/usr/bin/env bash
set -euo pipefail
EXE=$(ls ~/Library/Caches/ms-playwright/chromium_headless_shell-*/chrome-headless-shell-mac-*/chrome-headless-shell | head -1)
GROOT=$(npm root -g)
ASSERT_FILE="${1:?assert-js datei fehlt}"
NODE_PATH="$GROOT/@playwright/cli/node_modules" EXE="$EXE" ASSERT_FILE="$ASSERT_FILE" node -e '
const pw=require("playwright"); const fs=require("fs");
(async()=>{
  const b=await pw.chromium.launch({executablePath:process.env.EXE});
  const p=await b.newPage();
  const errs=[]; p.on("pageerror",e=>errs.push(String(e.message))); p.on("console",m=>{if(m.type()==="error")errs.push("console: "+m.text());});
  await p.goto("file:///tmp/geo-check/index.html");
  const assertFn=fs.readFileSync(process.env.ASSERT_FILE,"utf-8");
  let res;
  try { res = await p.evaluate(`(async()=>{ ${assertFn} })()`); }
  catch(e){ console.log("ASSERT-FEHLER:", e.message); await b.close(); process.exit(1); }
  if(errs.length){ console.log("PAGE-ERRORS:", errs); await b.close(); process.exit(1); }
  console.log("OK", res??"");
  await b.close();
})();'
```
Anlegen + ausführbar machen: `mkdir -p /tmp/geo-check && chmod +x /tmp/geo-check/run.sh`

Konvention der Assert-Dateien: reines JS, das im Seitenkontext läuft, `throw` bei Fehlschlag, optional `return`-Wert. Vor Implementierung ausführen (muss FAIL geben = „rot"), nach Implementierung (muss OK geben = „grün").

---

## Engine-Verträge (Namen über alle Tasks konsistent)

Diese Identifier werden in mehreren Tasks referenziert — exakt so verwenden:

```js
// Konfiguration ganz oben (ANPASSEN-Block für Personalisierung)
const CONFIG = {
  childName: "",                 // ANPASSEN: für Titel ("Linus' Deutschland-Reise")
  mascot: "🦉",                  // ANPASSEN: Begleit-Emoji
  colors: { land:"#a7d8a0", landActive:"#f4b942", sea:"#9ec9e8", bg:"#fef9ef" }, // ANPASSEN
  includedKeys: null,            // ANPASSEN: null = alle 16, sonst z.B. ["by","sn","th"]
  level: "mitte",                // ANPASSEN: "klein" | "mitte" | "aelter"
  topics: { capitals:true, rivers:true, neighbors:true, directions:true } // ANPASSEN
};

// Daten (aus Spec Anhang A)
const REGIONS = [ { key, name, capital, isCityState, rivers:[], anchor, svgId } /* ...16 */ ];
const NEIGHBORS = [/* 9 */]; const SEAS = ["Nordsee","Ostsee"]; const MOUNTAINS = [/* ... */];

// Laufzeit-Zustand
const state = { mode:"entdecken", discovered:new Set(), queue:[], current:null, hintLevel:0, score:0 };

// Engine-Funktionen (Signaturen fix)
function startGame() {}            // Startbildschirm -> Spiel
function setMode(mode) {}          // "entdecken" | "ueben"
function regionByKey(key) {}       // -> REGION | undefined
function onRegionClick(key) {}     // Dispatch je nach state.mode
function showInfo(key) {}          // Entdecken: Infokarte AM Land (Name, Hauptstadt-Punkt, Anker)
function buildQuizQueue() {}       // Üben: Fragenliste aus includedKeys, interleaved
function nextQuestion() {}         // nächste Abruf-Frage (stumme Karte)
function checkAnswer(key) {}       // richtig -> celebrate+markDiscovered; falsch -> nochNicht()
function nochNicht(correctKey) {}  // zeigt richtige Lage + startet Hinweis-Stufen (kein "falsch")
function giveHint() {}             // gestufte Hinweise: Region -> Anfangsbuchstabe -> Umriss
function markDiscovered(key) {}    // Fortschritt positiv (Land einfärben/sammeln)
function renderCompass() {}        // Kompass-Rose (N/O/S/W)
function renderLegend() {}         // Legende: Punkt=Hauptstadt, blau=Meer, Linie=Fluss
function celebrate() {}            // positives Feedback, immer ein Ergebnis
```

Alle sichtbaren Texte **Deutsch** via `textContent` (kein `innerHTML` außer zum Leeren). Steuerung Maus/Touch **und** Tastatur.

---

## Task 1: Skill-Gerüst + SVG-Karte + Daten + Spiel-Shell

**Files:**
- Create: `skills/geografie-entdecken/references/karten-vorlage.md`
- Build-time helper: `/tmp/geo-check/geojson-to-svg.mjs` (Output wird eingebettet, Helfer selbst nicht versioniert)
- Test: `/tmp/geo-check/assert-shell.js`

- [ ] **Step 1: Verifikations-Helfer anlegen**

`/tmp/geo-check/extract.py` und `/tmp/geo-check/run.sh` aus dem Abschnitt oben anlegen, `chmod +x /tmp/geo-check/run.sh`.

- [ ] **Step 2: SVG-Pfade der 16 Bundesländer erzeugen (GeoJSON→SVG-Konverter)**

Öffentlich, gemeinfrei nutzbar (dl-de/by-2-0, Attribution nötig): `isellsoap/deutschlandGeoJSON`, niedrige Auflösung. Konverter `/tmp/geo-check/geojson-to-svg.mjs`:

```js
import https from "node:https";
const URL="https://raw.githubusercontent.com/isellsoap/deutschlandGeoJSON/main/2_bundeslaender/4_niedrig.geo.json";
const NAME2KEY={ "Baden-Württemberg":"bw","Bayern":"by","Berlin":"be","Brandenburg":"bb","Bremen":"hb","Hamburg":"hh","Hessen":"he","Mecklenburg-Vorpommern":"mv","Niedersachsen":"ni","Nordrhein-Westfalen":"nw","Rheinland-Pfalz":"rp","Saarland":"sl","Sachsen":"sn","Sachsen-Anhalt":"st","Schleswig-Holstein":"sh","Thüringen":"th" };
const get=u=>new Promise((res,rej)=>{https.get(u,r=>{let d="";r.on("data",c=>d+=c);r.on("end",()=>res(JSON.parse(d)));}).on("error",rej);});
const gj=await get(URL);
// Bounding box
let minLon=1e9,maxLon=-1e9,minLat=1e9,maxLat=-1e9;
const eachRing=(geom,cb)=>{ const polys=geom.type==="Polygon"?[geom.coordinates]:geom.coordinates; for(const poly of polys) for(const ring of poly) cb(ring); };
for(const f of gj.features) eachRing(f.geometry,ring=>{for(const[lon,lat]of ring){minLon=Math.min(minLon,lon);maxLon=Math.max(maxLon,lon);minLat=Math.min(minLat,lat);maxLat=Math.max(maxLat,lat);}});
const W=760, midLat=(minLat+maxLat)/2, kx=Math.cos(midLat*Math.PI/180);
const sx=W/((maxLon-minLon)*kx); const H=Math.round((maxLat-minLat)*sx);
const px=lon=>((lon-minLon)*kx*sx).toFixed(1);
const py=lat=>((maxLat-lat)*sx).toFixed(1);
const ringToPath=ring=>"M"+ring.map(([lon,lat])=>`${px(lon)},${py(lat)}`).join("L")+"Z";
let paths=[];
for(const f of gj.features){
  const nm=f.properties.name||f.properties.NAME_1||f.properties.GEN; const key=NAME2KEY[nm];
  if(!key){console.error("UNGEMAPPT:",nm);continue;}
  let d=""; eachRing(f.geometry,ring=>{ if(ring.length>2) d+=ringToPath(ring); });
  paths.push(`<path id="r-${key}" data-key="${key}" data-name="${nm}" d="${d}"/>`);
}
console.log(`<svg id="map" viewBox="0 0 ${Math.ceil((maxLon-minLon)*kx*sx)} ${H}" xmlns="http://www.w3.org/2000/svg">`);
console.log(paths.join("\n"));
console.log("</svg>");
console.error("paths:",paths.length); // muss 16 sein
```

Ausführen: `node /tmp/geo-check/geojson-to-svg.mjs > /tmp/geo-check/map.svg 2>/tmp/geo-check/map.log`. In der Log-Ausgabe muss `paths: 16` stehen. Falls die Quelle nicht erreichbar/anders strukturiert ist: alternativ Pfade aus einer gemeinfreien Wikimedia-SVG („Deutschland Bundesländer"-Karte) extrahieren und mit `id="r-<key>"` versehen — Ziel ist identisch: 16 Inline-`<path>` mit `data-key`.

- [ ] **Step 3: Assert-Datei schreiben (rot)**

`/tmp/geo-check/assert-shell.js`:
```js
// Startbildschirm da, Start-Knopf führt ins Spiel, Karte rendert 16 Länder, Klick wählt ein Land
const startBtn = document.querySelector("#start-btn"); if(!startBtn) throw "kein #start-btn";
startBtn.click();
const paths = document.querySelectorAll("#map [data-key]");
if(paths.length !== 16) throw "erwarte 16 Länder, fand "+paths.length;
const by = document.querySelector('#map [data-key="by"]'); if(!by) throw "Bayern (by) fehlt";
by.dispatchEvent(new MouseEvent("click",{bubbles:true}));
return "shell ok, "+paths.length+" Länder";
```

- [ ] **Step 4: Run rot** — `python3 /tmp/geo-check/extract.py skills/geografie-entdecken/references/karten-vorlage.md` (schlägt fehl: Datei existiert noch nicht). Erwartet: FAIL.

- [ ] **Step 5: Vorlage anlegen — Shell + SVG + Daten**

`skills/geografie-entdecken/references/karten-vorlage.md` mit kurzer Anleitungs-Einleitung (analog `spiel-vorlagen.md`: „Claude kopiert diese Vorlage und passt nur die `ANPASSEN`-Stellen an") + einem ` ```html `-Block. Der HTML-Block enthält:
- `<head>`: Meta, Titel (`ANPASSEN`), Inline-CSS (große Klickflächen, kräftige Farben aus `CONFIG.colors`, responsive).
- Attribution-Kommentar zur Kartenquelle (dl-de/by-2-0).
- Startbildschirm `#start` mit Spielnamen + großem `#start-btn ▶ Start` + einer Steuerungszeile.
- Spielbereich `#game` (versteckt bis Start) mit dem Inline-`<svg id="map">` aus Step 2 und einem Info-Panel `#panel`.
- `<script>`: `CONFIG`, `REGIONS` (alle 16 aus Spec Anhang A: `key,name,capital,isCityState,rivers,anchor` — `anchor` = der kindgerechte Mini-Fakt; `svgId` = `r-<key>`), `NEIGHBORS/SEAS/MOUNTAINS`, `state`, und die Funktions-Rümpfe aus „Engine-Verträge".
- Minimal verdrahtet für diese Task: `startGame()` blendet `#start` aus, `#game` ein; jeder `[data-key]`-Pfad bekommt Klick- + Keyboard-Handler → `onRegionClick(key)`; `onRegionClick` ruft vorerst `markActive(key)` (Land einfärben). `regionByKey` implementiert.

Schlüssel→Name-Mapping konsistent zu Step 2 (`bw,by,be,bb,hb,hh,he,mv,ni,nw,rp,sl,sn,st,sh,th`).

- [ ] **Step 6: Run grün** — `python3 /tmp/geo-check/extract.py skills/geografie-entdecken/references/karten-vorlage.md && /tmp/geo-check/run.sh /tmp/geo-check/assert-shell.js`. Erwartet: `OK shell ok, 16 Länder`.

- [ ] **Step 7: Commit**
```bash
git add skills/geografie-entdecken/references/karten-vorlage.md
git commit -m "feat(geografie): add Deutschland map shell with 16 clickable Bundesländer"
```

---

## Task 2: Entdecken-Modus (Dual Coding, Kompass, Legende, Segmentierung, „Mein Bundesland")

**Files:**
- Modify: `skills/geografie-entdecken/references/karten-vorlage.md` (Script + CSS)
- Test: `/tmp/geo-check/assert-entdecken.js`

- [ ] **Step 1: Assert-Datei schreiben (rot)**

`/tmp/geo-check/assert-entdecken.js`:
```js
document.querySelector("#start-btn").click();
setMode("entdecken");
const by = document.querySelector('#map [data-key="by"]');
by.dispatchEvent(new MouseEvent("click",{bubbles:true}));
const panel = document.querySelector("#panel").textContent;
if(!/Bayern/.test(panel)) throw "Panel zeigt nicht 'Bayern'";
if(!/München/.test(panel)) throw "Panel zeigt nicht Hauptstadt 'München'";   // Daten-Korrektheit
if(!document.querySelector("#capital-dot")) throw "kein Hauptstadt-Punkt auf Karte";
if(!document.querySelector("#compass")) throw "keine Kompass-Rose";
if(!document.querySelector("#legend")) throw "keine Legende";
if(!by.classList.contains("discovered")) throw "Land nicht als entdeckt markiert";
return "entdecken ok";
```

- [ ] **Step 2: Run rot** — `python3 .../extract.py ... && /tmp/geo-check/run.sh /tmp/geo-check/assert-entdecken.js`. Erwartet: FAIL (z.B. „Panel zeigt nicht 'Bayern'").

- [ ] **Step 3: Implementieren**

Im Script:
- `showInfo(key)`: Region holen, `#panel` per `textContent` mit Name + „Hauptstadt: {capital}" + Anker-Satz füllen; `mascot` voranstellen. Bei `isCityState` Hinweis „Stadtstaat". Themen aus `CONFIG.topics` (Flüsse nur wenn `rivers` an).
- Hauptstadt-Punkt `#capital-dot` als `<circle>` im SVG an der Landfläche positionieren (Schwerpunkt der Bounding-Box des Pfads via `getBBox()` — Dual-Coding/Contiguity: Info am Ort).
- `renderCompass()`: kleines `#compass`-Overlay mit N/O/S/W; bei Start einmalig rendern.
- `renderLegend()`: `#legend` mit Punkt=Hauptstadt, blaue Fläche=Meer, Linie=Fluss.
- `onRegionClick(key)`: wenn `state.mode==="entdecken"` → `showInfo(key)` + `markDiscovered(key)` (fügt Klasse `discovered`, zählt Fortschritt). 
- Segmentierung: optionaler „weiter"-Hinweis nach 3–5 neuen Ländern (Zähler in `state`), nicht zwingend interaktiv blockierend.
- „Mein Bundesland": `CONFIG.homeKey` (ANPASSEN, optional) → beim Start kurz hervorheben/zuerst zeigen.
- Meere als blasse blaue Flächen + Nachbarländer als blasse Randflächen ins SVG (statische `<path>`/`<rect>` mit `CONFIG.colors.sea`), Beschriftung nur wenn `topics.neighbors`/Meere aktiv.

- [ ] **Step 4: Run grün** — Erwartet: `OK entdecken ok`.

- [ ] **Step 5: Commit**
```bash
git add skills/geografie-entdecken/references/karten-vorlage.md
git commit -m "feat(geografie): add Entdecken mode with map-anchored info, compass and legend"
```

---

## Task 3: Üben-Modus (echter Abruf, Stupser statt Lösung, niedrige Stakes, „noch nicht")

**Files:**
- Modify: `skills/geografie-entdecken/references/karten-vorlage.md`
- Test: `/tmp/geo-check/assert-ueben.js`

- [ ] **Step 1: Assert-Datei schreiben (rot)**

`/tmp/geo-check/assert-ueben.js`:
```js
document.querySelector("#start-btn").click();
setMode("ueben");
nextQuestion();
const q = document.querySelector("#question").textContent;
if(!q || q.length<3) throw "keine Frage angezeigt";
// stumme Karte: aktuelle Frage kennt die Lösung
const correct = state.current.key;
// 1) FALSCH antworten -> kein "falsch", Hinweis erscheint, kein Game-Over
const wrongKey = REGIONS.find(r=>r.key!==correct).key;
checkAnswer(wrongKey);
const fb = document.querySelector("#feedback").textContent;
if(/falsch/i.test(fb)) throw "sagt 'falsch' (verboten)";
if(!/noch nicht|fast|schau/i.test(fb)) throw "kein 'noch nicht'-Feedback";
if(!document.querySelector("#hint").textContent) throw "kein gestufter Hinweis nach Fehler";
if(document.querySelector("#game-over")) throw "Game-Over existiert (verboten)";
// 2) RICHTIG antworten -> positives Ergebnis, Fortschritt
checkAnswer(correct);
if(!/super|toll|geschafft|⭐/i.test(document.querySelector("#feedback").textContent)) throw "kein positives Feedback bei richtig";
return "ueben ok";
```

- [ ] **Step 2: Run rot** — Erwartet: FAIL („keine Frage angezeigt" o.ä.).

- [ ] **Step 3: Implementieren**

- `setMode("ueben")`: `#panel` aus, Quiz-UI (`#question`, `#feedback`, `#hint`) an; Karte „stumm" (keine Labels, `discovered`-Färbung der gelernten Länder bleibt als Fortschritt).
- `buildQuizQueue()`: aus `CONFIG.includedKeys ?? alle`, gemischte Fragetypen (Interleaving) je nach `CONFIG.topics`: (a) „Klick {Land} auf der Karte" (Lage-Abruf), (b) „Welche Hauptstadt gehört zu {Land}?" (Knöpfe), (c) „Klick das Land im {Himmelsrichtung}". Neue Länder erst geblockt, dann mischen. Spacing-lite: richtig beantwortete Länder hinten wieder einreihen statt entfernen.
- `nextQuestion()`: nimmt nächstes Element, setzt `state.current`, `state.hintLevel=0`, rendert Frage.
- `checkAnswer(key|value)`: richtig → `celebrate()` (positiver Text + ⭐), `markDiscovered`, kurzer Fakt als Belohnung, dann `nextQuestion()`. Falsch → `nochNicht(correct)`.
- `nochNicht(correctKey)`: `#feedback` = „Noch nicht — fast! Schau nochmal" (nie „falsch"); ruft `giveHint()`; **zeigt nicht sofort die Lösung** — erst nach 2–3 Hinweisstufen das richtige Land sanft hervorheben.
- `giveHint()`: Stufen über `state.hintLevel`: 0→Region/Himmelsrichtung („liegt im Süden"), 1→Anfangsbuchstabe, 2→Umriss/Highlight des richtigen Landes. Prozessbezogenes Lob, konkrete Hilfe (kein leeres Trostpflaster).
- Niedrige Stakes: kein Leben, kein Timer (höchstens optionaler, nicht-default „Schnell-Modus"), kein Game-Over. Fortschritt positiv (gesammelte Länder).
- Immer ein Ergebnis: nach Queue-Durchlauf `celebrate()`-Abschluss „Geschafft! 🎉 / Nochmal? 🔄" mit Neustart.

- [ ] **Step 4: Run grün** — Erwartet: `OK ueben ok`.

- [ ] **Step 5: Commit**
```bash
git add skills/geografie-entdecken/references/karten-vorlage.md
git commit -m "feat(geografie): add Üben mode with real retrieval, staged hints and low-stakes feedback"
```

---

## Task 4: Personalisierung & Alters-Kalibrierung (ANPASSEN-Parameter)

**Files:**
- Modify: `skills/geografie-entdecken/references/karten-vorlage.md`
- Test: `/tmp/geo-check/assert-config.js`

- [ ] **Step 1: Assert-Datei schreiben (rot)**

`/tmp/geo-check/assert-config.js`:
```js
// Untermenge + Maskottchen + Level wirken sich aus
if(typeof CONFIG !== "object") throw "kein CONFIG";
// includedKeys schränkt das Quiz ein
CONFIG.includedKeys = ["by","sn","th"];
document.querySelector("#start-btn").click();
setMode("ueben"); buildQuizQueue();
const keys = new Set(state.queue.map(q=>q.key));
for(const k of keys){ if(!["by","sn","th"].includes(k)) throw "Quiz nutzt nicht-erlaubtes Land "+k; }
// level "klein" reduziert Frage-Schwierigkeit (Wiedererkennen statt stumme Karte)
CONFIG.level="klein";
if(typeof difficultyForLevel !== "function") throw "keine Alters-Kalibrierung";
if(difficultyForLevel("klein").blindMap !== false) throw "klein sollte keine stumme Karte erzwingen";
if(difficultyForLevel("aelter").blindMap !== true) throw "aelter sollte stumme Karte nutzen";
return "config ok";
```

- [ ] **Step 2: Run rot** — Erwartet: FAIL.

- [ ] **Step 3: Implementieren**

- `CONFIG`-Block (siehe Engine-Verträge) ganz oben, jede Zeile mit Kommentar `// ANPASSEN: …`.
- `buildQuizQueue()` respektiert `CONFIG.includedKeys` und `CONFIG.topics`.
- `difficultyForLevel(level)` → `{ blindMap, choices, readingAloud, perRound }`: 
  - `klein`: `blindMap:false` (beschriftet, Wiedererkennen), `choices:2`, viele Emojis, `perRound:3`.
  - `mitte`: `blindMap:true` ab Stufe 2, `choices:3`, `perRound:4`.
  - `aelter`: `blindMap:true`, `choices:4`/Freitext, `perRound:5`.
- Farben/Maskottchen/Name aus `CONFIG` in UI ziehen.

- [ ] **Step 4: Run grün** — Erwartet: `OK config ok`.

- [ ] **Step 5: Commit**
```bash
git add skills/geografie-entdecken/references/karten-vorlage.md
git commit -m "feat(geografie): add personalization config and age-level calibration"
```

---

## Task 5: SKILL.md (Begleit-Verhalten, Ablauf, Bauen-im-Gespräch, Sicherheit)

**Files:**
- Create: `skills/geografie-entdecken/SKILL.md`
- Test: `/tmp/geo-check/assert-skillmd.sh`

- [ ] **Step 1: Check schreiben (rot)**

`/tmp/geo-check/assert-skillmd.sh`:
```bash
#!/usr/bin/env bash
set -euo pipefail
F=skills/geografie-entdecken/SKILL.md
test -f "$F" || { echo "FAIL: SKILL.md fehlt"; exit 1; }
head -1 "$F" | grep -q '^---$' || { echo "FAIL: kein Frontmatter"; exit 1; }
grep -q '^name: geografie-entdecken$' "$F" || { echo "FAIL: name falsch/fehlt"; exit 1; }
grep -q '^user-invocable: true$' "$F" || { echo "FAIL: user-invocable fehlt"; exit 1; }
for kw in "Artifact" "open" "Stadtstaat\|Bundesland" "noch nicht" "Maskottchen\|Maskottchen" "karten-vorlage.md" "Klasse\|Alter"; do
  grep -qi "$kw" "$F" || { echo "FAIL: Stichwort '$kw' fehlt"; exit 1; }
done
echo "OK skillmd"
```
`chmod +x /tmp/geo-check/assert-skillmd.sh`

- [ ] **Step 2: Run rot** — `/tmp/geo-check/assert-skillmd.sh`. Erwartet: `FAIL: SKILL.md fehlt`.

- [ ] **Step 3: SKILL.md schreiben**

Frontmatter (`name: geografie-entdecken`, ausführliche `description` mit Triggern wie „Deutschland lernen", „Bundesländer üben", „Geografie", „/geografie-entdecken"; `user-invocable: true`). Inhalt, regionsneutral formuliert wo möglich, Deutschland als geladenes Paket:
- **Leitidee:** Kind entdeckt + baut ein eigenes Werk über Deutschland; „Kind erfindet, KI baut".
- **Alters-Kalibrierung** (🐣/🦊/🦉-Tabelle aus Spec §4) + Zeile für Erwachsene (Alter/Klasse fragen).
- **Ablauf:** (0) Erwachsenen-Zeile → (1) Begrüßung → (2) „Mein Bundesland zuerst" → (3) **Entdecken** (kurz, häppchenweise) → (4) **Bauen im Gespräch**: Kind wählt Projektart (eigenes Quiz / Steckbrief-Sammlung), wählt Länder/Fakten/Maskottchen, beschreibt → Claude setzt `CONFIG`/Inhalte und baut die Vorlage → (5) **Üben** → (6) **Verbessern** (neue Runde) → (7) **Herzeigen**.
- **Bau-Anleitung:** „Lies `references/karten-vorlage.md`, kopiere den HTML-Block, passe **nur** die `ANPASSEN`-Stellen an (Name, Maskottchen, Farben, `includedKeys`, `level`, `topics`, `homeKey`). Fakten nicht ändern."
- **Doppel-Umgebung** (wörtlich wie `spiele-erfinden`): Desktop/Web → HTML-Artifact (dasselbe aktualisieren); Claude Code → `~/lab/kinder-spiele/<name>/index.html` + `open`.
- **Pädagogik-Regeln knapp:** Quiz stupst statt löst; „noch nicht" + konkrete Hilfe; niedrige Stakes; prozessbezogenes Lob; Autonomie (Kind wählt Inhalt, nicht nur Farbe).
- **Sicherheit:** kindgerecht, keine echten Mitschüler-Namen in dauerhaften Inhalten.

- [ ] **Step 4: Run grün** — `/tmp/geo-check/assert-skillmd.sh`. Erwartet: `OK skillmd`.

- [ ] **Step 5: Commit**
```bash
git add skills/geografie-entdecken/SKILL.md
git commit -m "feat(geografie): add SKILL.md companion flow with build-in-conversation loop"
```

---

## Task 6: Repo-Integration (README + CLAUDE.md)

**Files:**
- Modify: `README.md` (Skills-Tabelle)
- Modify: `CLAUDE.md` (Zeile „einziger Skill" + Verifikations-Notiz)

- [ ] **Step 1: Check schreiben (rot)**

`/tmp/geo-check/assert-docs.sh`:
```bash
#!/usr/bin/env bash
set -euo pipefail
grep -q "geografie-entdecken" README.md || { echo "FAIL: README ohne Skill-Zeile"; exit 1; }
grep -q "skills/geografie-entdecken" README.md || { echo "FAIL: README ohne Link"; exit 1; }
grep -qi "einziger Skill" CLAUDE.md && { echo "FAIL: CLAUDE.md sagt noch 'einziger Skill'"; exit 1; }
grep -q "geografie-entdecken" CLAUDE.md || { echo "FAIL: CLAUDE.md erwähnt Skill nicht"; exit 1; }
echo "OK docs"
```
`chmod +x /tmp/geo-check/assert-docs.sh`

- [ ] **Step 2: Run rot** — Erwartet: `FAIL: README ohne Skill-Zeile`.

- [ ] **Step 3: README-Zeile ergänzen**

Neue Tabellenzeile unter `spiele-erfinden` (Spalten: Skill | Altersstufe | Was es tut):
```markdown
| [`geografie-entdecken`](skills/geografie-entdecken/) | **≈6–12** (adaptiv, kalibriert 3. Kl.) | Lässt Kinder **Deutschland entdecken** (Bundesländer, Hauptstädte, Flüsse, Nachbarländer, Meere) auf einer klickbaren Karte — und daraus ihr **eigenes Werk** bauen (eigenes Quiz, Steckbrief-Sammlung). Übt mit echtem Abruf, das Quiz **stupst statt zu lösen**. Lehrplan-Säule **Karten-Lesen** (Himmelsrichtungen) inklusive. |
```

- [ ] **Step 4: CLAUDE.md anpassen**

In der Einleitung „Erster und bislang einziger Skill: `spiele-erfinden`" ersetzen durch eine Formulierung mit zwei Skills (`spiele-erfinden`, `geografie-entdecken`). Im Verifikations-Abschnitt eine kurze Notiz ergänzen: die `karten-vorlage.md` ebenso headless prüfen (Karte rendert 16 Länder, Hauptstadt-Stichprobe Bayern→München, Üben-Modus erreichbar, „noch nicht"-Pfad statt „falsch").

- [ ] **Step 5: Run grün** — `/tmp/geo-check/assert-docs.sh`. Erwartet: `OK docs`.

- [ ] **Step 6: Commit**
```bash
git add README.md CLAUDE.md
git commit -m "docs: list geografie-entdecken in README and CLAUDE.md"
```

---

## Task 7: Dual-Location-Sync + Packaging-Probe

**Files:**
- Sync target: `~/.claude/skills/geografie-entdecken/`

- [ ] **Step 1: Live-Kopie angleichen**
```bash
mkdir -p ~/.claude/skills/geografie-entdecken/references
cp skills/geografie-entdecken/SKILL.md ~/.claude/skills/geografie-entdecken/SKILL.md
cp skills/geografie-entdecken/references/karten-vorlage.md ~/.claude/skills/geografie-entdecken/references/karten-vorlage.md
```

- [ ] **Step 2: Sync verifizieren**
Run: `diff -r skills/geografie-entdecken ~/.claude/skills/geografie-entdecken`
Expected: keine Ausgabe (identisch).

- [ ] **Step 3: Packaging-Probe**
Run: `./scripts/package-skill.sh geografie-entdecken && unzip -l dist/geografie-entdecken.zip`
Expected: Zip entsteht, `SKILL.md` liegt im Zip-Root, `references/karten-vorlage.md` enthalten. (`dist/` ist gitignored — nicht committen.)

- [ ] **Step 4: kein Commit nötig** (Sync-Ziel + dist liegen außerhalb des Repos bzw. in .gitignore).

---

## Task 8: Gesamt-Verifikation + Fakten-Stichproben + Abschluss

**Files:**
- Test: `/tmp/geo-check/assert-final.js`

- [ ] **Step 1: Gesamt-Assert schreiben**

`/tmp/geo-check/assert-final.js`:
```js
document.querySelector("#start-btn").click();
// Daten-Korrektheit: 4 Stichproben (Verwechslungs-Klassiker)
const expect={ by:"München", nw:"Düsseldorf", he:"Wiesbaden", bb:"Potsdam" };
for(const[k,cap] of Object.entries(expect)){
  const r=regionByKey(k); if(!r) throw "Region fehlt: "+k;
  if(r.capital!==cap) throw `Hauptstadt falsch: ${k} -> ${r.capital}, erwartet ${cap}`;
}
if(REGIONS.length!==16) throw "nicht 16 Regionen";
if(NEIGHBORS.length!==9) throw "nicht 9 Nachbarländer";
// Modi durchschalten ohne Fehler
setMode("entdecken"); document.querySelector('#map [data-key="sn"]').dispatchEvent(new MouseEvent("click",{bubbles:true}));
if(!/Dresden/.test(document.querySelector("#panel").textContent)) throw "Sachsen->Dresden nicht angezeigt";
setMode("ueben"); nextQuestion();
return "final ok";
```

- [ ] **Step 2: Run grün** — `python3 .../extract.py ... && /tmp/geo-check/run.sh /tmp/geo-check/assert-final.js`. Erwartet: `OK final ok`. Zusätzlich alle vorherigen Assert-Dateien (`shell, entdecken, ueben, config`) erneut laufen lassen — alle OK.

- [ ] **Step 3: Deutsche Texte sichten**
Manuell den `#panel`/Feedback-Text auf Ein-/Mehrzahl & Umlaute prüfen (z.B. Flüsse-Liste, „noch nicht"-Sätze). Bei Befund fixen + Headless erneut.

- [ ] **Step 4: Live-Kopie final angleichen** (falls Task 5/8 noch Änderungen brachten) — `cp …` + `diff -r` leer.

- [ ] **Step 5: Branch pushen / PR vorbereiten** (nur wenn der Nutzer es wünscht)
```bash
git log --oneline main..HEAD   # Überblick der Commits auf feat/geografie-entdecken
```

---

## Self-Review (gegen das Spec)

**Spec-Abdeckung:** §2 Pädagogik → Tasks 2/3 (Dual Coding, Stupser, „noch nicht", niedrige Stakes) + Task 5 (Regeln). §3 Lehrplan/Karten-Lesen → Task 2 (Kompass/Legende), Meere/Berlin → Task 2, „Mein Bundesland" → Tasks 2/5. §4 Schleife → Task 5 (Ablauf inkl. Bauen/Herzeigen). §4 Alters-Kalibrierung → Task 4. §5 generische Architektur/Daten → Task 1 (`REGIONS`, datengetrieben). §6 Bau-Regeln/offline/Steuerung → Tasks 1–3. §7 Repo-Integration → Tasks 6/7. §8 Verifikation → Tasks 1–4,8. §9 Scope (2 Projektarten, nur DE) → Task 5 Bauen-Schritt. Anhang A Daten → Task 1.

**Bauen-Modus-Hinweis:** Die zwei Start-Projektarten (eigenes Quiz, Steckbrief-Sammlung) werden **im Gespräch** umgesetzt (Claude wählt `CONFIG.includedKeys`/`topics` + baut die Vorlage) — kein In-App-Editor (YAGNI, siehe Spec §6). Steckbrief-Sammlung = Entdecken-Panel auf die gewählten Länder fokussiert; eigenes Quiz = `includedKeys` + Fragetyp-Auswahl. Falls sich beim Bauen zeigt, dass „Steckbrief-Sammlung" eine eigene Render-Ansicht braucht, in Task 2 ein einfaches `renderSteckbrief(keys)` ergänzen (gleiche Daten, andere Darstellung).

**Platzhalter-Scan:** keine TBD/TODO; alle Assert-Snippets + Engine-Signaturen konkret.

**Typ-Konsistenz:** Funktionsnamen/Felder (`regionByKey`, `setMode`, `nextQuestion`, `checkAnswer`, `nochNicht`, `giveHint`, `CONFIG.includedKeys`, `state.current.key`, `difficultyForLevel`) über alle Tasks identisch verwendet.

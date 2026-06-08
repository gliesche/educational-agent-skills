# Skill-Design: `geografie-entdecken`

> Status: **Entwurf, validiert** · Datum: 2026-06-08 · Zielgruppe: Grundschulkinder ≈6–12,
> kalibriert auf ~3. Klasse. Erstes Inhalts-Paket: **Deutschland**.

Ein neuer Fach-Skill für die Sammlung neben `spiele-erfinden`. Begleitet ein Kind dabei,
**Deutschland geografisch zu entdecken** (Bundesländer, Hauptstädte, Flüsse, Nachbarländer,
Meere, Himmelsrichtungen) — und daraus ein **eigenes Werk** zu bauen (eigenes Quiz,
Steckbrief-Sammlung), das es üben und herzeigen kann.

Dieses Dokument wurde gegen drei Dinge validiert (Multi-Agent-Recherche + adversariale
Faktenprüfung): die Pädagogik-Prinzipien des Repos (`docs/paedagogik.md`), den Sachunterricht-
Lehrplan Klasse 3 mehrerer Bundesländer, und die Lernforschung zum Geografie-Lernen 8–9-Jähriger.

---

## 1. Ziel & Leitidee

- **Lernziel (für das Kind):** Deutschland räumlich begreifen — *wo* liegt was, nicht nur Namen
  pauken. Karten-Lesen als Kompetenz (Himmelsrichtungen, Legende).
- **Eigentliches Lernziel (Repo-DNA):** Das Kind **erfindet ein Werk über Deutschland**, die KI
  baut es. Das Beschreiben/Auswählen/Anordnen IST das Lernen — wie bei `spiele-erfinden` das
  Prompten. Deutschland selbst ist unveränderlich; **erfunden wird das Artefakt darüber.**
- **Leitstern:** „Das Kind erfindet, die KI baut" bleibt erhalten — über die Konstruktion eines
  eigenen Quiz / einer Steckbrief-Sammlung / Reiseroute, nicht über das Abfragen von Fakten.

## 2. Pädagogische Grundlage (validiert gegen `docs/paedagogik.md`)

Tragfähig **mit** den folgenden Korrekturen gegenüber einem reinen Entdecken+Quiz-Tool. Die drei
ursprünglich soliden Bausteine bleiben: „noch nicht"-Feedback (Growth Mindset/Productive Failure),
adaptive Schwierigkeit (Flow/ZPD), Personalisierung (Autonomie/Verbundenheit).

| Prinzip (`paedagogik.md`) | Umsetzung im Skill |
|---|---|
| Konstruktionismus — Bauen schlägt Spielen (§1) | **Bau-Modus**: Kind baut eigenes Quiz / Steckbrief-Sammlung / Reiseroute. Fakten = Rohmaterial, Erfinden = Auswählen/Anordnen/Beschreiben/Gestalten. |
| Selbstbestimmung: Autonomie/Kompetenz/Verbundenheit (§2) | Kind wählt **inhaltlich** (welche Länder, eigene Fragen), nicht nur kosmetisch. Maskottchen + warmer Ton = Verbundenheit. Adaptive Schwierigkeit = Kompetenz. |
| Flow / ZPD + Scaffolding mit Fading (§3) | Frage-Stützen stufenweise abbauen: beschriftete Karte → Multiple-Choice mit Hinweis → stumme Karte (reiner Abruf). Bei Fehler Stütze kurz zurückholen. |
| Productive Failure & „Noch nicht" (§4) | Erst raten/probieren lassen, **dann selbst** im Entdecken-Modus finden. „noch nicht" **+ konkrete Hilfe** (nie leeres Lob). |
| Kognitive Last gering (§5) | **Segmentierung**: nie 16 auf einmal; 3–5 Länder pro Runde, nach Region. Alters-Kalibrierung (s.u.). |
| Low floor / high ceiling / **wide walls** (§6) | Mehrere Projektarten über dieselbe Karte (eigenes Quiz, Steckbriefe, Reiseroute, später Wappen-Galerie). |
| KI fragt statt löst — kein Cognitive Offloading (§7) | **Quiz stupst, löst nicht.** Gestufte Hinweise (Region → Anfangsbuchstabe → Umriss). Kreativteil (Fragen formulieren, beschreiben) bleibt beim Kind. |
| Kreativ-Schleife & Herzeigen (§1) | Vollständige Schleife: Entdecken → **Bauen** → Üben → Verbessern → **Herzeigen** („Quiz damit deine Eltern!"). |

### Lernmethoden-Präzisierungen (Evidenz)

- **Echter Abruf, nicht Wiedererkennen:** mind. eine Quiz-Stufe verlangt *Lage erzeugen* (Land auf
  stummer Karte anklicken). Testing-Effekt bei Grundschulkindern d≈0.48–0.64.
- **Entdecken kurz halten & verzahnen:** nicht „lange lernen, dann lange testen" — häppchenweise
  entdecken, sofort Mini-Abruf desselben Landes.
- **Dual Coding:** Faktenwissen **immer an der Karte** verankern; Info erscheint *auf/an* dem
  Bundesland (Contiguity), Hauptstadt als Punkt an echter Position. Nie reine Textliste.
- **Konkretheit:** jedes Land mit konkretem Anker (Wahrzeichen/Tier/Symbol, merkbare Form).
- **Sofortiges korrektives Feedback:** bei Fehler sofort die *richtige Lage zeigen* + Mini-Hinweis.
- **Niedrige Stakes:** keine Noten, kein Game-Over, kein stressender Countdown. Fortschritt positiv
  (gelernte Länder einfärben/sammeln) statt Fehler zählen.
- **Spacing & Interleaving:** gelernte Länder kehren später wieder; Fragetypen/Regionen mischen
  (dosiert — neue Länder erst geblockt, dann mischen).
- **Lob prozessbezogen** („den Norden hast du gut drauf"), nicht personbezogen („du bist schlau").

### Vermeiden (Pitfalls)
Fehler-Bestrafung, Stress-Timer als Standard, reines Auswendiglernen ohne Karte, zu viel auf
einmal, Wiedererkennen-statt-Abrufen, uninformatives Feedback, Reiz-/Badge-Überladung, starrer
Zwangspfad ohne Wahl, Wettbewerb/Vergleich im Vordergrund.

## 3. Lehrplan-Abdeckung (Sachunterricht Klasse 3)

Kern-Set (Bundesländer, Hauptstädte, Flüsse, Nachbarländer, Gebirge) trifft den Schulbuch-Standard.
**Verpflichtend ergänzt**, weil in jedem Bundesland-Plan:

- **Karten-Lesen als zweite Säule (Pflicht-Kompetenz!):** Himmelsrichtungen N/O/S/W (Kompass-Rose),
  Legende/Kartenzeichen lesen, Karte = Draufsicht, Nordung. *Das* ist der Schwerpunkt der Lehrpläne,
  den ein reines Fakten-Quiz verfehlt.
- **Nord- & Ostsee** (als blaue Flächen auf der Karte), **Berlin als Bundeshauptstadt** markiert.
- **„Mein Bundesland"-Einstieg** (Heimatbezug = didaktischer Startpunkt überall).

**Bewusst weglassen** (Klasse 4+ / Überfrachtung): detaillierte Maßstab-/Entfernungsrechnung,
lückenlose Flussverläufe, Einwohner-/Wirtschaftsdaten. Faustregel: **Fakten zurückhaltend,
Karten-Lese-Kompetenz gleichwertig.**

## 4. Was das Kind erlebt — die Creative-Learning-Schleife

Alles auf **einer** klickbaren SVG-Deutschlandkarte; ein einziges, mitwachsendes Artefakt.

1. **Entdecken (kurz, verzahnt, segmentiert).** Kind klickt Länder; Name + Hauptstadt (Punkt an
   echter Lage) + konkreter Anker erscheinen *am Land*. Start mit „Mein Bundesland". Kompass-Rose
   lehrt Himmelsrichtungen nebenbei. 3–5 Länder pro Runde, „weiter"-Knopf.
2. **Bauen (der konstruktionistische Kern).** Kind sagt, was es will → KI baut es ins Artefakt:
   - **Eigenes Quiz** (Kind wählt Länder, formuliert eigene Frage) — *erste Projektart*
   - **Steckbrief-Sammlung** der Lieblingsländer (Kind wählt Fakten, Maskottchen) — *erste Projektart*
   - *(extensibel: Reiseroute/Schatzkarte N→S, Wappen-Galerie)*
3. **Üben & Herzeigen.** Echter Abruf (stumme Karte anklicken), Stupser statt Lösung, niedrige
   Stakes, „noch nicht" + Hilfe, gemischte Fragetypen, Spacing. Dann **Herzeigen**: „Das hast DU
   gemacht — quiz damit deine Eltern!"

### Alters-Kalibrierung (analog `spiele-erfinden`)

| | 🐣 ≈6–7 | 🦊 ≈8–10 (Kalibrier-Mitte) | 🦉 ≈10–12 |
|---|---|---|---|
| Kartenumfang | wenige/große Regionen, evtl. nur eine Landeshälfte | volle 16er-Karte mit Knöpfen | volle Karte + Freitext |
| Lesen/Tippen | fast nur Knöpfe, Vorlesen, viele Emojis | Knöpfe + etwas Freitext | mehr Freitext, eigene Fragen |
| Abruf-Stufe | beschriftete Karte, Wiedererkennen | Multiple-Choice → stumme Karte | stumme Karte, eigene Quiz-Regeln |
| Bau-Modus | wählt aus Vorlagen | wählt + beschreibt | erfindet eigene Fragen/Route |

Eine starre 16er-Karte für alle überlastet 🐣 — Schwierigkeit über `ANPASSEN`-Parameter steuern.

## 5. Architektur (generisch & schlank)

Wie `spiele-erfinden`: **zwei Dateien**, datengetrieben.

```
skills/geografie-entdecken/
├── SKILL.md                      # regionsneutrales Begleit-Verhalten, Ablauf,
│                                 #   Alters-Kalibrierung, Doppel-Umgebung, Sicherheit
└── references/
    └── karten-vorlage.md         # eine self-contained HTML-Vorlage:
                                  #   SVG-Karte + REGIONS-Daten + generische Engine
```

- **Datengetrieben:** Quiz-/Steckbrief-Engine generiert alles aus einem `REGIONS`-Objekt.
  Land hinzufügen = ein Objekt + ein `<path id>`. Neues Paket (Europa) = `<svg>` + `REGIONS`
  tauschen, **Engine unberührt**. → „so generisch wie möglich".
- **Datenschema** (englische Identifier, Repo-Konvention):
  ```js
  REGIONS = [{ key, name, capital, isCityState, rivers:[], anchor, svgId }]
  // + NEIGHBORS:[], SEAS:[], MOUNTAINS:[]
  ```
- **Doppel-Umgebung** (wie `spiele-erfinden`): Claude Desktop/Web → interaktives **HTML-Artifact**;
  Claude Code → Datei `~/lab/kinder-spiele/<name>/index.html` + `open`.
- **Sprache:** sichtbare Texte Deutsch, Code-Identifier Englisch.

## 6. HTML-Lernspiel — Bau-Regeln

- **Eine HTML-Datei**, offline (kein CDN — anders als 3D-Vorlage von `spiele-erfinden`; die Karte
  ist Inline-SVG). Steuerung Maus/Touch **und** Tastatur. Große Klickflächen.
- **Lagetreue Inline-SVG** der 16 Bundesländer (gemeinfrei, vereinfacht-aber-wiedererkennbar),
  jedes Land `<path id>` = `REGIONS[].svgId`. Meere als blaue Flächen, Nachbarländer als blasse
  Randflächen (für „Deutschland in Europa"), **Kompass-Rose** + **Legende**.
- **In-App-Modi:** Entdecken / Üben — frei umschaltbar (Autonomie). **Das „Bauen" passiert im
  Gespräch** (Kind beschreibt → Claude baut die Auswahl ins Artefakt, wie bei `spiele-erfinden`),
  nicht über einen In-App-Editor — so bleibt der Prompting-als-Lernen-Kern erhalten. Das gebaute
  eigene Quiz / die Steckbriefe füllen dann den Üben- bzw. Entdecken-Modus.
- **Üben:** echter Abruf (stumme Karte), gestufte Hinweise statt Lösung, „noch nicht" + Hilfe,
  niedrige Stakes (immer ein Ergebnis, nie Sackgasse), Fortschritt positiv.
- **Sicherheit/Inhalt:** kindgerecht, freundlich, `textContent` für alle sichtbaren Texte
  (`innerHTML` nur zum Leeren), keine echten Mitschüler-Namen in dauerhaften Inhalten.

## 7. Repo-Integration

- **README:** neue Zeile in der Skills-Tabelle (Altersstufe „≈6–12, kalibriert 3. Kl.").
- **`CLAUDE.md`:** Zeile „Erster und bislang einziger Skill" aktualisieren (jetzt zwei Skills);
  kurze Verifikations-Notiz für die Karten-Vorlage analog zu den Spiel-Vorlagen ergänzen.
- **Dual-Location-Sync:** nach `~/.claude/skills/geografie-entdecken/` kopieren (Repo = Quelle der
  Wahrheit), `diff -r` muss leer sein.
- **Packaging:** bestehendes `./scripts/package-skill.sh geografie-entdecken`.

## 8. Verifikation (kein Test-Framework im Repo)

Wie bei den Spiel-Vorlagen: ` ```html `-Block extrahieren, headless Chromium laden. Prüfen:
- keine `pageerror`/Console-Errors,
- Start funktioniert, Modus-Wechsel funktioniert,
- Entdecken: Klick auf ein Bundesland zeigt **korrekte** Hauptstadt (Stichprobe Bayern→München),
- Üben: eine Abruf-Frage beantwortbar, „noch nicht"-Pfad mit Hinweis erreichbar, Ergebnis-Zustand,
- deutsche Texte korrekt (Ein-/Mehrzahl, Umlaute).

## 9. Scope / YAGNI

- **MVP baut:** Entdecken + Üben (volle Engine, Karten-Lese-Säule) + Bau-Modus mit **zwei**
  Projektarten (eigenes Quiz, Steckbrief-Sammlung). Nur **Deutschland**.
- **Extensibel, jetzt NICHT gebaut:** Europa/Welt-Pakete, Reiseroute/Wappen-Galerie,
  Sehenswürdigkeiten, Naturraum-Höhenbänder. Struktur lässt sie zu; kein spekulativer Inhalt.

## 10. Getroffene Entscheidungen

- Name `geografie-entdecken` (Fach, nicht Klasse). Deutschland = erstes Paket.
- Echte SVG-Karte (vom Nutzer gewählt). Voll & repo-treu (vom Nutzer gewählt).
- Zwei-Datei-Struktur wie `spiele-erfinden`. Offline (Inline-SVG, kein CDN).

---

## Anhang A: Geprüfter Datensatz Deutschland (autoritativ)

Alle Hauptstädte, 9 Nachbarländer, 2 Meere von drei skeptischen Prüfern + Websuche bestätigt.
Flüsse/Gebirge ohne grobe Fehler. (Grenzfall, akzeptiert: Mosel berührt das Saarland nur kurz.)

### Bundesländer (16)

| Bundesland | Hauptstadt | Stadtstaat | Flüsse | Anker (Mini-Fakt, kindgerecht) |
|---|---|---|---|---|
| Baden-Württemberg | Stuttgart | nein | Rhein, Neckar, Donau | Hier beginnt die Donau. |
| Bayern | München | nein | Donau, Main, Isar | Größtes Bundesland; Alpen + Zugspitze (höchster Berg). |
| Berlin | Berlin | ja | Spree, Havel | Hauptstadt Deutschlands und eigenes Bundesland. |
| Brandenburg | Potsdam | nein | Havel, Spree, Oder | Liegt wie ein Ring um Berlin. |
| Bremen | Bremen | ja | Weser | Kleinstes Bundesland, zwei Städte (Bremen + Bremerhaven). |
| Hamburg | Hamburg | ja | Elbe, Alster | Riesiger Hafen, mehr Brücken als Venedig. |
| Hessen | Wiesbaden | nein | Rhein, Main, Fulda | Frankfurts Hochhäuser = „Mainhattan". |
| Mecklenburg-Vorpommern | Schwerin | nein | Warnow, Peene, Elde | Viele Seen, u.a. die Müritz (größter See in DE). |
| Niedersachsen | Hannover | nein | Weser, Ems, Elbe | Flaches Land, Wattenmeer-Inseln in der Nordsee. |
| Nordrhein-Westfalen | Düsseldorf | nein | Rhein, Ruhr, Weser | Meiste Einwohner aller Bundesländer. |
| Rheinland-Pfalz | Mainz | nein | Rhein, Mosel, Lahn | Weintrauben an steilen Hängen an Mosel & Rhein. |
| Saarland | Saarbrücken | nein | Saar, Mosel, Blies | Kleinstes Flächen-Bundesland, an der Grenze zu Frankreich. |
| Sachsen | Dresden | nein | Elbe, Mulde, Weiße Elster | Erzgebirge: Holz-Nussknacker & Räuchermännchen. |
| Sachsen-Anhalt | Magdeburg | nein | Elbe, Saale, Havel | Der Brocken (höchster Berg im Harz), oft im Nebel. |
| Schleswig-Holstein | Kiel | nein | Eider, Trave, Stör | Liegt zwischen zwei Meeren: Nordsee und Ostsee. |
| Thüringen | Erfurt | nein | Saale, Werra, Unstrut | Der Rennsteig, ein berühmter Wanderweg über die Berge. |

### Nachbarländer (9, im Uhrzeigersinn ab Norden)
Dänemark, Polen, Tschechien, Österreich, Schweiz, Frankreich, Luxemburg, Belgien, Niederlande.

### Meere
Nordsee, Ostsee.

### Wichtige Flüsse (gesamt)
Rhein, Elbe, Donau, Main, Weser, Mosel, Oder, Neckar, Saale, Spree, Havel, Ems.

### Wichtige Gebirge
Alpen, Schwarzwald, Harz, Erzgebirge, Bayerischer Wald, Thüringer Wald, Rhön, Eifel,
Fichtelgebirge, Schwäbische Alb.

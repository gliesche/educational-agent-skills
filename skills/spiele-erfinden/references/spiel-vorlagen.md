# Spiel-Vorlagen

Fertige, erprobte HTML-Spiel-Gerüste für die häufigsten Spiel-Typen von Kindern. Jede Vorlage
ist **eine einzige, in sich geschlossene `.html`-Datei**: läuft per Doppelklick, keine Installation.
Such die passende Vorlage zur Idee des Kindes, **kopiere sie** und **passe nur die markierten
Stellen an** (`/* ANPASSEN: ... */`): Figur, Ziel, Hindernis, Ort, Farben, Texte.

> **Internet?** Die Vorlagen 1–9 laufen **komplett offline** (kein Internet nötig — ideal für die
> Schule). Nur die 3D-Vorlage (10) lädt eine 3D-Bibliothek aus dem Netz.

So ordnest du die Idee zu:

| Kind sagt … | Vorlage |
|---|---|
| Sachen fangen, sammeln, auffangen | **1. Fangspiel** |
| Hüpfen, springen, ausweichen | **2. Hüpfspiel** |
| schnell tippen/klicken, Maulwurf-Klopfen | **3. Klick-Spiel** |
| Weg finden, Labyrinth, Ausgang suchen | **4. Labyrinth** |
| Fragen, raten, Quiz, was weiß ich | **5. Quiz** |
| Karten umdrehen, Paare finden, merken | **6. Memory** |
| Rennen, Auto, Hindernissen ausweichen, Spuren | **7. Renn-Spiel** |
| Schlange, wachsen, nicht selbst beißen | **8. Snake** |
| Tier füttern, pflegen, kümmern, glücklich machen | **9. Tier-Pflege** |
| **echtes 3D**, herumlaufen, 3D-Welt, Sterne/Würfel sammeln | **10. 3D-Sammelspiel** |

Wenn die Idee mehrere Typen mischt, nimm die Vorlage, die dem **Hauptziel** am nächsten kommt,
und füge Details aus der Idee hinzu (Ort, Farben, Figuren). Behalte immer: Startbildschirm,
Punkte, Gewinnen/Verlieren, großer Neustart-Knopf, alles auf Deutsch.

Allgemeine Anpass-Punkte in jeder Vorlage:
- **Spielfiguren = Emojis** (leicht austauschbar): Held, Sammel-Ding, Hindernis.
- **Farben** über die CSS-Variablen oben (`--bg`, `--akzent`).
- **Texte** (Titel, Steuerungs-Hinweis, Gewonnen-Text) in Kinder-Deutsch.
- **Schwierigkeit** über die Geschwindigkeits-/Zeit-Werte (Kommentar `// ANPASSEN`).

---

## 1. Fangspiel (Sachen auffangen)

Held unten bewegt sich links/rechts (Pfeiltasten **oder** Maus/Finger) und fängt gute Dinge,
weicht schlechten aus. Punkte sammeln, bei genug Punkten gewonnen.

```html
<!DOCTYPE html>
<html lang="de">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1, user-scalable=no">
<title>🐱 Sterne fangen</title> <!-- ANPASSEN: Titel -->
<style>
  :root{ --bg:#0b1e4a; --akzent:#ffd23f; } /* ANPASSEN: Farben (Ort/Stimmung) */
  *{box-sizing:border-box;margin:0;padding:0;-webkit-user-select:none;user-select:none;}
  html,body{height:100%;font-family:system-ui,Arial,sans-serif;}
  body{background:var(--bg);overflow:hidden;}
  #spiel{position:relative;width:100vw;height:100vh;overflow:hidden;}
  .ding{position:absolute;font-size:42px;will-change:transform;}
  #held{position:absolute;bottom:10px;font-size:56px;transition:none;}
  #punkte{position:absolute;top:12px;left:16px;color:#fff;font-size:28px;font-weight:bold;
          text-shadow:0 2px 6px rgba(0,0,0,.5);}
  .schicht{position:absolute;inset:0;display:flex;flex-direction:column;align-items:center;
           justify-content:center;text-align:center;color:#fff;background:rgba(0,0,0,.55);
           gap:18px;padding:24px;}
  h1{font-size:40px;} p{font-size:22px;max-width:600px;line-height:1.4;}
  button{font-size:26px;padding:16px 34px;border:none;border-radius:18px;cursor:pointer;
         background:var(--akzent);color:#222;font-weight:bold;box-shadow:0 6px 0 rgba(0,0,0,.25);}
  button:active{transform:translateY(4px);box-shadow:0 2px 0 rgba(0,0,0,.25);}
  .gross{font-size:72px;}
</style>
</head>
<body>
<div id="spiel">
  <div id="punkte">⭐ 0</div>
  <div id="held">🐱</div> <!-- ANPASSEN: Held-Figur -->

  <div class="schicht" id="start">
    <div class="gross">🐱</div>
    <h1>Sterne fangen</h1> <!-- ANPASSEN -->
    <p>Fang die Sterne ⭐ mit der Katze 🐱.<br>Pass auf die Bomben 💣 auf!<br>
       Bewege dich mit den Pfeiltasten ← → oder mit der Maus.</p> <!-- ANPASSEN -->
    <button onclick="los()">▶ Start</button>
  </div>

  <div class="schicht" id="ende" style="display:none">
    <div class="gross" id="endeEmoji">🎉</div>
    <h1 id="endeTitel">Geschafft!</h1>
    <p id="endeText"></p>
    <button onclick="los()">🔄 Nochmal</button>
  </div>
</div>

<script>
const spiel=document.getElementById('spiel');
const held=document.getElementById('held');
const punkteEl=document.getElementById('punkte');
// ANPASSEN: gute Dinge (Punkte), schlechte Dinge (Spielende):
const GUT='⭐', SCHLECHT='💣';
const ZIEL=15;            // ANPASSEN: so viele Punkte = gewonnen
let tempo=2.2;            // ANPASSEN: Fall-Tempo (größer = schwerer)
let heldX, punkte, dinge, laeuft=false, timer;

function los(){
  document.getElementById('start').style.display='none';
  document.getElementById('ende').style.display='none';
  punkte=0; dinge=[]; tempo=2.2; laeuft=true;
  punkteEl.textContent='⭐ 0';
  heldX=window.innerWidth/2; setzeHeld();
  document.querySelectorAll('.ding').forEach(d=>d.remove());
  clearInterval(timer); timer=setInterval(spawn,900); // ANPASSEN: Abstand neuer Dinge
  loop();
}
function setzeHeld(){ held.style.left=(heldX-28)+'px'; }
function spawn(){
  if(!laeuft) return;
  const d=document.createElement('div'); d.className='ding';
  const schlecht=Math.random()<0.3;            // ANPASSEN: Anteil böser Dinge
  d.textContent=schlecht?SCHLECHT:GUT;
  d.dataset.bad=schlecht?'1':'0';
  d.style.left=Math.random()*(window.innerWidth-42)+'px';
  d.style.top='-50px'; spiel.appendChild(d); dinge.push(d);
}
function loop(){
  if(!laeuft) return;
  for(const d of dinge){
    let y=parseFloat(d.style.top)+tempo; d.style.top=y+'px';
    const dx=Math.abs((parseFloat(d.style.left)+21)-heldX);
    if(y>window.innerHeight-90 && dx<50){       // gefangen
      if(d.dataset.bad==='1'){ ende(false); return; }
      punkte++; punkteEl.textContent='⭐ '+punkte; d.remove(); dinge=dinge.filter(x=>x!==d);
      if(punkte>=ZIEL){ ende(true); return; }
    } else if(y>window.innerHeight){ d.remove(); dinge=dinge.filter(x=>x!==d); }
  }
  requestAnimationFrame(loop);
}
function ende(gewonnen){
  laeuft=false; clearInterval(timer);
  document.getElementById('endeEmoji').textContent=gewonnen?'🎉':'💥';
  document.getElementById('endeTitel').textContent=gewonnen?'Geschafft!':'Aua!';
  document.getElementById('endeText').textContent=
    gewonnen?('Du hast ⭐ '+punkte+' gefangen! Super!'):('Eine Bombe! Du hattest ⭐ '+punkte+'.'); // Zahl als Emoji-Zähler -> kein Ein-/Mehrzahl-Problem bei 1
  document.getElementById('ende').style.display='flex';
}
// Steuerung: Tastatur
document.addEventListener('keydown',e=>{
  if(!laeuft) return;
  if(e.key==='ArrowLeft')  heldX=Math.max(28,heldX-40);
  if(e.key==='ArrowRight') heldX=Math.min(window.innerWidth-28,heldX+40);
  setzeHeld();
});
// Steuerung: Maus/Finger
function folge(x){ if(laeuft){ heldX=Math.max(28,Math.min(window.innerWidth-28,x)); setzeHeld(); } }
spiel.addEventListener('mousemove',e=>folge(e.clientX));
spiel.addEventListener('touchmove',e=>{folge(e.touches[0].clientX);e.preventDefault();},{passive:false});
</script>
</body>
</html>
```

---

## 2. Hüpfspiel (springen & ausweichen)

Held rennt automatisch, Hindernisse kommen von rechts. Mit Leertaste / Klick / Tipp springen.
Lange genug überleben = gewonnen.

```html
<!DOCTYPE html>
<html lang="de">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1, user-scalable=no">
<title>🦘 Hüpf-Held</title> <!-- ANPASSEN -->
<style>
  :root{ --bg:#7ec8e3; --boden:#5a9e3a; --akzent:#ff7b3f; } /* ANPASSEN: Farben */
  *{box-sizing:border-box;margin:0;padding:0;-webkit-user-select:none;user-select:none;}
  html,body{height:100%;font-family:system-ui,Arial,sans-serif;}
  body{background:var(--bg);overflow:hidden;}
  #spiel{position:relative;width:100vw;height:100vh;overflow:hidden;}
  #boden{position:absolute;bottom:0;width:100%;height:80px;background:var(--boden);}
  #held{position:absolute;left:80px;bottom:80px;font-size:54px;}
  .hindernis{position:absolute;bottom:80px;font-size:46px;}
  #punkte{position:absolute;top:12px;left:16px;color:#063;font-size:28px;font-weight:bold;}
  .schicht{position:absolute;inset:0;display:flex;flex-direction:column;align-items:center;
           justify-content:center;text-align:center;color:#fff;background:rgba(0,0,0,.55);gap:18px;padding:24px;}
  h1{font-size:40px;} p{font-size:22px;max-width:600px;line-height:1.4;}
  button{font-size:26px;padding:16px 34px;border:none;border-radius:18px;cursor:pointer;
         background:var(--akzent);color:#fff;font-weight:bold;box-shadow:0 6px 0 rgba(0,0,0,.25);}
  button:active{transform:translateY(4px);box-shadow:0 2px 0 rgba(0,0,0,.25);}
  .gross{font-size:72px;}
</style>
</head>
<body>
<div id="spiel">
  <div id="punkte">🏅 0</div>
  <div id="boden"></div>
  <div id="held">🦘</div> <!-- ANPASSEN: Held -->
  <div class="schicht" id="start">
    <div class="gross">🦘</div>
    <h1>Hüpf-Held</h1> <!-- ANPASSEN -->
    <p>Spring über die Kakteen 🌵!<br>Drück die Leertaste oder klick/tippe zum Springen.</p> <!-- ANPASSEN -->
    <button onclick="los()">▶ Start</button>
  </div>
  <div class="schicht" id="ende" style="display:none">
    <div class="gross" id="endeEmoji">🎉</div>
    <h1 id="endeTitel"></h1>
    <p id="endeText"></p>
    <button onclick="los()">🔄 Nochmal</button>
  </div>
</div>
<script>
const held=document.getElementById('held'), spiel=document.getElementById('spiel');
const punkteEl=document.getElementById('punkte');
const HINDERNIS='🌵';     // ANPASSEN: was im Weg steht
const ZIEL=20;            // ANPASSEN: so viele Punkte = gewonnen
let yv=0, y=0, springt=false, hindernisse=[], punkte=0, laeuft=false, tempo=6, timer;
const G=1.1, SPRUNG=20;   // ANPASSEN: Schwerkraft & Sprungkraft

function los(){
  document.getElementById('start').style.display='none';
  document.getElementById('ende').style.display='none';
  document.querySelectorAll('.hindernis').forEach(h=>h.remove());
  y=0;yv=0;springt=false;hindernisse=[];punkte=0;tempo=6;laeuft=true;
  punkteEl.textContent='🏅 0';
  clearInterval(timer); timer=setInterval(()=>{ if(laeuft){punkte++;punkteEl.textContent='🏅 '+punkte;
    if(punkte>=ZIEL){ende(true);}} },500); // ANPASSEN: Punkte-Tempo
  spawn(); loop();
}
function spawn(){
  if(!laeuft) return;
  const h=document.createElement('div'); h.className='hindernis'; h.textContent=HINDERNIS;
  h.style.left=window.innerWidth+'px'; spiel.appendChild(h); hindernisse.push(h);
  setTimeout(spawn, 1100+Math.random()*900); // ANPASSEN: Abstand der Hindernisse
}
function springen(){ if(laeuft && !springt){ springt=true; yv=SPRUNG; } }
function loop(){
  if(!laeuft) return;
  if(springt){ y+=yv; yv-=G; if(y<=0){y=0;springt=false;} }
  held.style.bottom=(80+y)+'px';
  for(const h of hindernisse){
    let hx=parseFloat(h.style.left)-tempo; h.style.left=hx+'px';
    if(hx<130 && hx>40 && y<40){ ende(false); return; }   // Zusammenstoß
    if(hx<-60){ h.remove(); hindernisse=hindernisse.filter(x=>x!==h); }
  }
  requestAnimationFrame(loop);
}
function ende(gewonnen){
  laeuft=false; clearInterval(timer);
  document.getElementById('endeEmoji').textContent=gewonnen?'🎉':'💥';
  document.getElementById('endeTitel').textContent=gewonnen?'Geschafft!':'Autsch!';
  document.getElementById('endeText').textContent=
    gewonnen?'Du hast es geschafft! Toll gesprungen!':('Reingelaufen! Punkte: '+punkte);
  document.getElementById('ende').style.display='flex';
}
document.addEventListener('keydown',e=>{ if(e.code==='Space'){e.preventDefault();springen();} });
spiel.addEventListener('mousedown',springen);
spiel.addEventListener('touchstart',e=>{springen();e.preventDefault();},{passive:false});
</script>
</body>
</html>
```

---

## 3. Klick-Spiel (schnell tippen, Maulwurf-Klopfen)

Dinge ploppen an zufälligen Stellen auf. Schnell anklicken/antippen für Punkte. Zeit läuft.

```html
<!DOCTYPE html>
<html lang="de">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1, user-scalable=no">
<title>👆 Schnapp den Frosch</title> <!-- ANPASSEN -->
<style>
  :root{ --bg:#2e7d32; --akzent:#ffd23f; } /* ANPASSEN */
  *{box-sizing:border-box;margin:0;padding:0;-webkit-user-select:none;user-select:none;}
  html,body{height:100%;font-family:system-ui,Arial,sans-serif;}
  body{background:var(--bg);overflow:hidden;}
  #spiel{position:relative;width:100vw;height:100vh;overflow:hidden;}
  .ziel{position:absolute;font-size:60px;cursor:pointer;transition:transform .08s;}
  .ziel:active{transform:scale(1.3);}
  #hud{position:absolute;top:12px;left:16px;right:16px;display:flex;justify-content:space-between;
       color:#fff;font-size:26px;font-weight:bold;text-shadow:0 2px 6px rgba(0,0,0,.5);}
  .schicht{position:absolute;inset:0;display:flex;flex-direction:column;align-items:center;
           justify-content:center;text-align:center;color:#fff;background:rgba(0,0,0,.55);gap:18px;padding:24px;}
  h1{font-size:40px;} p{font-size:22px;max-width:600px;line-height:1.4;}
  button{font-size:26px;padding:16px 34px;border:none;border-radius:18px;cursor:pointer;
         background:var(--akzent);color:#222;font-weight:bold;box-shadow:0 6px 0 rgba(0,0,0,.25);}
  button:active{transform:translateY(4px);box-shadow:0 2px 0 rgba(0,0,0,.25);}
  .gross{font-size:72px;}
</style>
</head>
<body>
<div id="spiel">
  <div id="hud"><span id="punkte">🐸 0</span><span id="uhr">⏰ 30</span></div>
  <div class="schicht" id="start">
    <div class="gross">🐸</div>
    <h1>Schnapp den Frosch</h1> <!-- ANPASSEN -->
    <p>Tippe die Frösche 🐸 so schnell du kannst!<br>Du hast 30 Sekunden.</p> <!-- ANPASSEN -->
    <button onclick="los()">▶ Start</button>
  </div>
  <div class="schicht" id="ende" style="display:none">
    <div class="gross">🏆</div>
    <h1>Zeit um!</h1>
    <p id="endeText"></p>
    <button onclick="los()">🔄 Nochmal</button>
  </div>
</div>
<script>
const spiel=document.getElementById('spiel');
const punkteEl=document.getElementById('punkte'), uhrEl=document.getElementById('uhr');
const ZIEL_EMOJI='🐸';    // ANPASSEN: was angetippt wird
const START_ZEIT=30;      // ANPASSEN: Sekunden
let punkte, zeit, laeuft=false, spawnT, uhrT;

function los(){
  document.getElementById('start').style.display='none';
  document.getElementById('ende').style.display='none';
  document.querySelectorAll('.ziel').forEach(z=>z.remove());
  punkte=0; zeit=START_ZEIT; laeuft=true;
  punkteEl.textContent='🐸 0'; uhrEl.textContent='⏰ '+zeit;
  clearInterval(uhrT); uhrT=setInterval(()=>{ zeit--; uhrEl.textContent='⏰ '+zeit;
    if(zeit<=0) ende(); },1000);
  clearInterval(spawnT); spawnT=setInterval(spawn,800); // ANPASSEN: wie oft ein Ziel kommt
  spawn();
}
function spawn(){
  if(!laeuft) return;
  const z=document.createElement('div'); z.className='ziel'; z.textContent=ZIEL_EMOJI;
  z.style.left=Math.random()*(window.innerWidth-70)+'px';
  z.style.top=(60+Math.random()*(window.innerHeight-140))+'px';
  const weg=setTimeout(()=>z.remove(),1100);          // ANPASSEN: wie lange sichtbar
  z.addEventListener('pointerdown',()=>{ if(!laeuft)return; punkte++;
    punkteEl.textContent='🐸 '+punkte; clearTimeout(weg); z.remove(); });
  spiel.appendChild(z);
}
function ende(){
  laeuft=false; clearInterval(spawnT); clearInterval(uhrT);
  document.querySelectorAll('.ziel').forEach(z=>z.remove());
  document.getElementById('endeText').textContent='Du hast '+punkte+' geschnappt! Klasse!';
  document.getElementById('ende').style.display='flex';
}
</script>
</body>
</html>
```

---

## 4. Labyrinth (den Weg finden)

Held mit Pfeiltasten (oder Wisch-Knöpfen auf dem Tablet) durch ein Gitter zum Ziel führen.

```html
<!DOCTYPE html>
<html lang="de">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1, user-scalable=no">
<title>🐭 Finde den Käse</title> <!-- ANPASSEN -->
<style>
  :root{ --bg:#1a1333; --wand:#5b3fa0; --weg:#efe9ff; --akzent:#ffd23f; } /* ANPASSEN */
  *{box-sizing:border-box;margin:0;padding:0;-webkit-user-select:none;user-select:none;}
  html,body{height:100%;font-family:system-ui,Arial,sans-serif;}
  body{background:var(--bg);display:flex;flex-direction:column;align-items:center;justify-content:center;
       height:100vh;gap:14px;color:#fff;}
  #titel{font-size:26px;font-weight:bold;}
  #gitter{display:grid;gap:2px;background:#000;padding:4px;border-radius:10px;}
  .zelle{width:38px;height:38px;display:flex;align-items:center;justify-content:center;font-size:26px;}
  .wand{background:var(--wand);} .weg{background:var(--weg);}
  #knoepfe{display:grid;grid-template-columns:repeat(3,64px);gap:8px;justify-content:center;}
  #knoepfe button{font-size:28px;padding:10px;border:none;border-radius:14px;background:var(--akzent);
                  cursor:pointer;box-shadow:0 5px 0 rgba(0,0,0,.3);} 
  #knoepfe button:active{transform:translateY(3px);box-shadow:0 2px 0 rgba(0,0,0,.3);}
  .leer{visibility:hidden;}
  .schicht{position:fixed;inset:0;display:flex;flex-direction:column;align-items:center;
           justify-content:center;text-align:center;background:rgba(0,0,0,.6);gap:18px;padding:24px;}
  h1{font-size:40px;} p{font-size:22px;}
  .start-btn{font-size:26px;padding:16px 34px;border:none;border-radius:18px;cursor:pointer;
             background:var(--akzent);color:#222;font-weight:bold;box-shadow:0 6px 0 rgba(0,0,0,.25);}
  .gross{font-size:72px;}
</style>
</head>
<body>
<div id="titel">🐭 Finde den Käse 🧀</div> <!-- ANPASSEN -->
<div id="gitter"></div>
<div id="knoepfe">
  <button class="leer"></button><button onclick="zug(0,-1)">⬆️</button><button class="leer"></button>
  <button onclick="zug(-1,0)">⬅️</button><button class="leer"></button><button onclick="zug(1,0)">➡️</button>
  <button class="leer"></button><button onclick="zug(0,1)">⬇️</button><button class="leer"></button>
</div>

<div class="schicht" id="start">
  <div class="gross">🐭</div>
  <h1>Finde den Käse</h1> <!-- ANPASSEN -->
  <p>Bring die Maus 🐭 zum Käse 🧀.<br>Nimm die Pfeiltasten oder die Knöpfe.</p> <!-- ANPASSEN -->
  <button class="start-btn" onclick="los()">▶ Start</button>
</div>
<div class="schicht" id="ende" style="display:none">
  <div class="gross">🎉</div>
  <h1>Gefunden!</h1>
  <p>Super gemacht! Du hast den Weg gefunden! 🧀</p>
  <button class="start-btn" onclick="los()">🔄 Nochmal</button>
</div>

<script>
// 1=Wand, 0=Weg. ANPASSEN: Labyrinth gern umbauen (rechteckig, S=Start, Z=Ziel-Position).
const KARTE=[
  [1,1,1,1,1,1,1,1,1],
  [1,0,0,0,1,0,0,0,1],
  [1,0,1,0,1,0,1,0,1],
  [1,0,1,0,0,0,1,0,1],
  [1,0,1,1,1,0,1,0,1],
  [1,0,0,0,0,0,0,0,1],
  [1,1,1,0,1,1,1,0,1],
  [1,0,0,0,1,0,0,0,1],
  [1,1,1,1,1,1,1,1,1],
];
const HELD='🐭', ZIEL_EMOJI='🧀';   // ANPASSEN: Figur & Ziel
const START={x:1,y:1}, ZIEL={x:7,y:7}; // ANPASSEN: Start- und Ziel-Feld
let px,py,laeuft=false;
const gitter=document.getElementById('gitter');
gitter.style.gridTemplateColumns='repeat('+KARTE[0].length+',38px)';

function zeichne(){
  gitter.innerHTML='';
  for(let y=0;y<KARTE.length;y++) for(let x=0;x<KARTE[0].length;x++){
    const z=document.createElement('div');
    z.className='zelle '+(KARTE[y][x]?'wand':'weg');
    if(x===px&&y===py) z.textContent=HELD;
    else if(x===ZIEL.x&&y===ZIEL.y) z.textContent=ZIEL_EMOJI;
    gitter.appendChild(z);
  }
}
function los(){
  document.getElementById('start').style.display='none';
  document.getElementById('ende').style.display='none';
  px=START.x; py=START.y; laeuft=true; zeichne();
}
function zug(dx,dy){
  if(!laeuft) return;
  const nx=px+dx, ny=py+dy;
  if(KARTE[ny]&&KARTE[ny][nx]===0){ px=nx; py=ny; zeichne();
    if(px===ZIEL.x&&py===ZIEL.y){ laeuft=false; document.getElementById('ende').style.display='flex'; } }
}
document.addEventListener('keydown',e=>{
  if(e.key==='ArrowUp')zug(0,-1); if(e.key==='ArrowDown')zug(0,1);
  if(e.key==='ArrowLeft')zug(-1,0); if(e.key==='ArrowRight')zug(1,0);
});
</script>
</body>
</html>
```

---

## 5. Quiz (Fragen raten)

Fragen mit großen Antwort-Knöpfen. Richtig = grün, falsch = rot. Punkte am Ende.

```html
<!DOCTYPE html>
<html lang="de">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1, user-scalable=no">
<title>❓ Tier-Quiz</title> <!-- ANPASSEN -->
<style>
  :root{ --bg:#13315c; --akzent:#ffd23f; --richtig:#34c759; --falsch:#ff453a; } /* ANPASSEN */
  *{box-sizing:border-box;margin:0;padding:0;-webkit-user-select:none;user-select:none;}
  html,body{height:100%;font-family:system-ui,Arial,sans-serif;}
  body{background:var(--bg);color:#fff;display:flex;align-items:center;justify-content:center;
       min-height:100vh;padding:20px;}
  #box{width:100%;max-width:620px;text-align:center;display:flex;flex-direction:column;gap:18px;}
  #frage{font-size:30px;font-weight:bold;line-height:1.3;min-height:80px;}
  #antworten{display:grid;gap:12px;}
  #antworten button{font-size:24px;padding:18px;border:none;border-radius:16px;cursor:pointer;
                    background:#fff;color:#222;font-weight:bold;box-shadow:0 5px 0 rgba(0,0,0,.3);}
  #antworten button:active{transform:translateY(3px);box-shadow:0 2px 0 rgba(0,0,0,.3);}
  #antworten button.r{background:var(--richtig);color:#fff;} 
  #antworten button.f{background:var(--falsch);color:#fff;}
  #punkte{font-size:22px;font-weight:bold;}
  .gross{font-size:72px;}
  .start-btn{font-size:26px;padding:16px 34px;border:none;border-radius:18px;cursor:pointer;
             background:var(--akzent);color:#222;font-weight:bold;box-shadow:0 6px 0 rgba(0,0,0,.25);}
</style>
</head>
<body>
<div id="box">
  <div id="anfang">
    <div class="gross">❓</div>
    <h1 style="font-size:38px">Tier-Quiz</h1> <!-- ANPASSEN -->
    <p style="font-size:22px">Errätst du alle Fragen? 🦁</p>
    <br><button class="start-btn" onclick="los()">▶ Start</button>
  </div>
  <div id="spiel" style="display:none">
    <div id="punkte">⭐ 0</div>
    <div id="frage"></div>
    <div id="antworten"></div>
  </div>
  <div id="ende" style="display:none">
    <div class="gross">🏆</div>
    <h1 id="endeText" style="font-size:32px"></h1>
    <br><button class="start-btn" onclick="los()">🔄 Nochmal</button>
  </div>
</div>
<script>
// ANPASSEN: Fragen. richtig = Nummer der richtigen Antwort (0 = erste).
const FRAGEN=[
  {f:"Welches Tier sagt Muh? 🐮", a:["Kuh","Hund","Fisch"], richtig:0},
  {f:"Wie viele Beine hat eine Spinne? 🕷️", a:["6","8","4"], richtig:1},
  {f:"Welches Tier kann fliegen? ", a:["Elefant","Schildkröte","Vogel 🐦"], richtig:2},
];
const frageEl=document.getElementById('frage'), antwortenEl=document.getElementById('antworten');
const punkteEl=document.getElementById('punkte');
let i, punkte, gesperrt;

function los(){
  document.getElementById('anfang').style.display='none';
  document.getElementById('ende').style.display='none';
  document.getElementById('spiel').style.display='block';
  i=0; punkte=0; punkteEl.textContent='⭐ 0'; zeige();
}
function zeige(){
  gesperrt=false;
  const q=FRAGEN[i]; frageEl.textContent=q.f; antwortenEl.innerHTML='';
  q.a.forEach((text,n)=>{
    const b=document.createElement('button'); b.textContent=text;
    b.onclick=()=>antwort(b,n,q.richtig); antwortenEl.appendChild(b);
  });
}
function antwort(btn,gewaehlt,richtig){
  if(gesperrt) return; gesperrt=true;
  const btns=antwortenEl.children;
  if(gewaehlt===richtig){ btn.classList.add('r'); punkte++; punkteEl.textContent='⭐ '+punkte; }
  else { btn.classList.add('f'); btns[richtig].classList.add('r'); }
  setTimeout(()=>{ i++; if(i<FRAGEN.length) zeige(); else fertig(); },1100);
}
function fertig(){
  document.getElementById('spiel').style.display='none';
  document.getElementById('endeText').textContent='Du hattest '+punkte+' von '+FRAGEN.length+' richtig! 🎉';
  document.getElementById('ende').style.display='block';
}
</script>
</body>
</html>
```

---

## 6. Memory (Kartenpaare finden)

Karten umdrehen und gleiche Paare finden. Ruhig, gut fürs Gedächtnis. Reines Klick-/Tipp-Spiel.

```html
<!DOCTYPE html>
<html lang="de">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1, user-scalable=no">
<title>🧠 Tier-Memory</title> <!-- ANPASSEN -->
<style>
  :root{ --bg:#243b6b; --akzent:#ffd23f; --karte:#ffffff; --rueck:#7aa2ff; } /* ANPASSEN: Farben */
  *{box-sizing:border-box;margin:0;padding:0;-webkit-user-select:none;user-select:none;}
  html,body{height:100%;font-family:system-ui,Arial,sans-serif;}
  body{background:var(--bg);color:#fff;display:flex;flex-direction:column;align-items:center;
       justify-content:center;min-height:100vh;gap:16px;padding:16px;}
  #titel{font-size:26px;font-weight:bold;} #info{font-size:20px;}
  #brett{display:grid;gap:10px;}
  .karte{width:80px;height:80px;border-radius:14px;font-size:44px;cursor:pointer;display:flex;
         align-items:center;justify-content:center;background:var(--rueck);box-shadow:0 5px 0 rgba(0,0,0,.25);transition:transform .12s;}
  .karte.auf{background:var(--karte);} .karte.fertig{visibility:hidden;} .karte:active{transform:scale(.95);}
  .schicht{position:fixed;inset:0;display:flex;flex-direction:column;align-items:center;
           justify-content:center;text-align:center;background:rgba(0,0,0,.6);gap:18px;padding:24px;}
  h1{font-size:40px;} p{font-size:22px;}
  .btn{font-size:26px;padding:16px 34px;border:none;border-radius:18px;cursor:pointer;
       background:var(--akzent);color:#222;font-weight:bold;box-shadow:0 6px 0 rgba(0,0,0,.25);}
  .gross{font-size:72px;}
</style>
</head>
<body>
<div id="titel">🧠 Tier-Memory</div> <!-- ANPASSEN -->
<div id="info">Paare: 0</div>
<div id="brett"></div>
<div class="schicht" id="start">
  <div class="gross">🧠</div><h1>Memory</h1>
  <p>Dreh die Karten um und finde die Paare! 🐶🐶</p>
  <button class="btn" onclick="los()">▶ Start</button>
</div>
<div class="schicht" id="ende" style="display:none">
  <div class="gross">🎉</div><h1>Alle gefunden!</h1>
  <p id="endeText"></p>
  <button class="btn" onclick="los()">🔄 Nochmal</button>
</div>
<script>
const MOTIVE=['🐶','🐱','🦊','🐰','🐼','🐸']; // ANPASSEN: 6 Paare = 6 Emojis
const SPALTEN=4;                              // ANPASSEN: Karten pro Reihe
const brett=document.getElementById('brett'), info=document.getElementById('info');
let auf, gefunden, sperre;
function misch(a){ for(let i=a.length-1;i>0;i--){const j=Math.floor(Math.random()*(i+1));[a[i],a[j]]=[a[j],a[i]];} return a; }
function los(){
  document.getElementById('start').style.display='none';
  document.getElementById('ende').style.display='none';
  brett.style.gridTemplateColumns='repeat('+SPALTEN+',80px)';
  const karten=misch([...MOTIVE,...MOTIVE]); auf=[]; gefunden=0; sperre=false;
  info.textContent='Paare: 0'; brett.innerHTML='';
  karten.forEach(m=>{ const k=document.createElement('div'); k.className='karte'; k.dataset.motiv=m;
    k.addEventListener('click',()=>dreh(k)); brett.appendChild(k); });
}
function dreh(k){
  if(sperre||k.classList.contains('auf')||k.classList.contains('fertig')) return;
  k.textContent=k.dataset.motiv; k.classList.add('auf'); auf.push(k);
  if(auf.length===2){ sperre=true;
    if(auf[0].dataset.motiv===auf[1].dataset.motiv){
      gefunden++; info.textContent='Paare: '+gefunden;
      setTimeout(()=>{ auf.forEach(x=>x.classList.add('fertig')); auf=[]; sperre=false;
        if(gefunden===MOTIVE.length) gewonnen(); },500);
    } else {
      setTimeout(()=>{ auf.forEach(x=>{x.textContent='';x.classList.remove('auf');}); auf=[]; sperre=false; },800);
    }
  }
}
function gewonnen(){
  document.getElementById('endeText').textContent='Du hast alle '+MOTIVE.length+' Paare gefunden! Super Gedächtnis!';
  document.getElementById('ende').style.display='flex';
}
</script>
</body>
</html>
```

---

## 7. Renn-Spiel (Hindernissen ausweichen)

Auto/Figur auf 3 Spuren, von oben kommen Hindernisse. Mit ← → (oder Tippen links/rechts) ausweichen.
Wird immer schneller. Lange genug durchhalten = gewonnen.

```html
<!DOCTYPE html>
<html lang="de">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1, user-scalable=no">
<title>🏎️ Renn-Spiel</title> <!-- ANPASSEN -->
<style>
  :root{ --bg:#33363d; --strasse:#4a4e57; --akzent:#ffd23f; } /* ANPASSEN */
  *{box-sizing:border-box;margin:0;padding:0;-webkit-user-select:none;user-select:none;}
  html,body{height:100%;font-family:system-ui,Arial,sans-serif;}
  body{background:var(--bg);overflow:hidden;}
  #spiel{position:relative;width:100vw;height:100vh;overflow:hidden;}
  #strasse{position:absolute;top:0;bottom:0;left:50%;transform:translateX(-50%);width:300px;background:var(--strasse);}
  .auto,.hindernis{position:absolute;font-size:50px;}
  #punkte{position:absolute;top:12px;left:16px;color:#fff;font-size:28px;font-weight:bold;text-shadow:0 2px 6px rgba(0,0,0,.5);}
  .schicht{position:absolute;inset:0;display:flex;flex-direction:column;align-items:center;
           justify-content:center;text-align:center;color:#fff;background:rgba(0,0,0,.6);gap:18px;padding:24px;}
  h1{font-size:40px;} p{font-size:22px;max-width:560px;line-height:1.4;}
  button{font-size:26px;padding:16px 34px;border:none;border-radius:18px;cursor:pointer;
         background:var(--akzent);color:#222;font-weight:bold;box-shadow:0 6px 0 rgba(0,0,0,.25);}
  .gross{font-size:72px;}
</style>
</head>
<body>
<div id="spiel">
  <div id="strasse"></div>
  <div id="punkte">🏁 0</div>
  <div class="auto" id="auto">🏎️</div> <!-- ANPASSEN: Figur -->
  <div class="schicht" id="start">
    <div class="gross">🏎️</div><h1>Renn-Spiel</h1>
    <p>Weich den Hindernissen aus! 🚧<br>Fahr mit ← → oder tippe links/rechts.</p>
    <button onclick="los()">▶ Start</button>
  </div>
  <div class="schicht" id="ende" style="display:none">
    <div class="gross" id="endeEmoji">🎉</div><h1 id="endeTitel"></h1>
    <p id="endeText"></p>
    <button onclick="los()">🔄 Nochmal</button>
  </div>
</div>
<script>
const spiel=document.getElementById('spiel'), auto=document.getElementById('auto');
const punkteEl=document.getElementById('punkte');
const HINDERNIS='🚧'; // ANPASSEN
const ZIEL=25;        // ANPASSEN: so viele Punkte = gewonnen
const SPUREN=3;
let spur, hindernisse, punkte, laeuft=false, tempo, spawnT, punktT;
function spurX(s){ const mitte=window.innerWidth/2, breite=300, b=breite/SPUREN; return mitte-breite/2 + b*s + b/2; }
function setzeAuto(){ auto.style.left=(spurX(spur)-25)+'px'; auto.style.bottom='20px'; }
function los(){
  document.getElementById('start').style.display='none';
  document.getElementById('ende').style.display='none';
  document.querySelectorAll('.hindernis').forEach(h=>h.remove());
  spur=1; hindernisse=[]; punkte=0; tempo=4; laeuft=true;
  punkteEl.textContent='🏁 0'; setzeAuto();
  clearInterval(spawnT); spawnT=setInterval(spawn,1000); // ANPASSEN: Abstand der Hindernisse
  clearInterval(punktT); punktT=setInterval(()=>{ if(laeuft){ punkte++; punkteEl.textContent='🏁 '+punkte;
    tempo+=0.15; if(punkte>=ZIEL) ende(true); } },400);
  loop();
}
function spawn(){
  if(!laeuft) return;
  const s=Math.floor(Math.random()*SPUREN);
  const h=document.createElement('div'); h.className='hindernis'; h.textContent=HINDERNIS;
  h.dataset.spur=s; h.style.left=(spurX(s)-25)+'px'; h.style.top='-60px';
  spiel.appendChild(h); hindernisse.push(h);
}
function loop(){
  if(!laeuft) return;
  for(const h of hindernisse){
    let y=parseFloat(h.style.top)+tempo; h.style.top=y+'px';
    if(parseInt(h.dataset.spur)===spur && y>window.innerHeight-120 && y<window.innerHeight-20){ ende(false); return; }
    if(y>window.innerHeight){ h.remove(); hindernisse=hindernisse.filter(x=>x!==h); }
  }
  requestAnimationFrame(loop);
}
function ende(gewonnen){
  laeuft=false; clearInterval(spawnT); clearInterval(punktT);
  document.getElementById('endeEmoji').textContent=gewonnen?'🏆':'💥';
  document.getElementById('endeTitel').textContent=gewonnen?'Ziel erreicht!':'Bumm!';
  document.getElementById('endeText').textContent=gewonnen?'Du bist super gefahren!':('Crash! Punkte: '+punkte);
  document.getElementById('ende').style.display='flex';
}
function links(){ if(laeuft&&spur>0){spur--;setzeAuto();} }
function rechts(){ if(laeuft&&spur<SPUREN-1){spur++;setzeAuto();} }
document.addEventListener('keydown',e=>{ if(e.key==='ArrowLeft')links(); if(e.key==='ArrowRight')rechts(); });
spiel.addEventListener('pointerdown',e=>{ if(!laeuft)return; if(e.clientX<window.innerWidth/2)links(); else rechts(); });
</script>
</body>
</html>
```

---

## 8. Snake (Schlange)

Die Schlange wächst beim Fressen. Nicht in die Wand oder sich selbst beißen. Pfeiltasten oder Knöpfe.

```html
<!DOCTYPE html>
<html lang="de">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1, user-scalable=no">
<title>🐍 Snake</title> <!-- ANPASSEN -->
<style>
  :root{ --bg:#10241a; --akzent:#ffd23f; } /* ANPASSEN */
  *{box-sizing:border-box;margin:0;padding:0;-webkit-user-select:none;user-select:none;}
  html,body{height:100%;font-family:system-ui,Arial,sans-serif;}
  body{background:var(--bg);color:#fff;display:flex;flex-direction:column;align-items:center;
       justify-content:center;min-height:100vh;gap:12px;}
  #punkte{font-size:26px;font-weight:bold;}
  canvas{background:#16341f;border-radius:10px;touch-action:none;}
  #pad{display:grid;grid-template-columns:repeat(3,60px);gap:6px;margin-top:6px;}
  #pad button{font-size:24px;padding:8px;border:none;border-radius:12px;background:var(--akzent);cursor:pointer;box-shadow:0 4px 0 rgba(0,0,0,.3);}
  #pad .leer{visibility:hidden;}
  .schicht{position:fixed;inset:0;display:flex;flex-direction:column;align-items:center;
           justify-content:center;text-align:center;background:rgba(0,0,0,.6);gap:18px;padding:24px;}
  h1{font-size:40px;} p{font-size:22px;}
  .btn{font-size:26px;padding:16px 34px;border:none;border-radius:18px;cursor:pointer;
       background:var(--akzent);color:#222;font-weight:bold;box-shadow:0 6px 0 rgba(0,0,0,.25);}
  .gross{font-size:72px;}
</style>
</head>
<body>
<div id="punkte">🍎 0</div>
<canvas id="c" width="360" height="360"></canvas>
<div id="pad">
  <button class="leer"></button><button onclick="lenk(0,-1)">⬆️</button><button class="leer"></button>
  <button onclick="lenk(-1,0)">⬅️</button><button class="leer"></button><button onclick="lenk(1,0)">➡️</button>
  <button class="leer"></button><button onclick="lenk(0,1)">⬇️</button><button class="leer"></button>
</div>
<div class="schicht" id="start">
  <div class="gross">🐍</div><h1>Snake</h1>
  <p>Friss die Äpfel 🍎 und werde lang!<br>Steuere mit Pfeiltasten oder Knöpfen.<br>Beiß dich nicht selbst!</p>
  <button class="btn" onclick="los()">▶ Start</button>
</div>
<div class="schicht" id="ende" style="display:none">
  <div class="gross" id="endeEmoji">🎉</div><h1 id="endeTitel"></h1>
  <p id="endeText"></p>
  <button class="btn" onclick="los()">🔄 Nochmal</button>
</div>
<script>
const c=document.getElementById('c'), ctx=c.getContext('2d');
const N=18, ZELLE=c.width/N;   // ANPASSEN: Gittergröße
const ZIEL=10;                 // ANPASSEN: so viele Äpfel = gewonnen
let schlange, dir, next, apfel, punkte, laeuft=false, tick;
function los(){
  document.getElementById('start').style.display='none';
  document.getElementById('ende').style.display='none';
  schlange=[{x:9,y:9},{x:8,y:9},{x:7,y:9}]; dir={x:1,y:0}; next=dir;
  punkte=0; document.getElementById('punkte').textContent='🍎 0';
  setzeApfel(); laeuft=true;
  clearInterval(tick); tick=setInterval(schritt,160); // ANPASSEN: Tempo (kleiner = schneller)
  zeichne();
}
function setzeApfel(){ do{ apfel={x:Math.floor(Math.random()*N),y:Math.floor(Math.random()*N)}; }
  while(schlange.some(s=>s.x===apfel.x&&s.y===apfel.y)); }
function lenk(x,y){ if(!laeuft) return; if(x===-dir.x&&y===-dir.y) return; next={x,y}; } // nicht umkehren
function schritt(){
  dir=next;
  const kopf={x:schlange[0].x+dir.x, y:schlange[0].y+dir.y};
  if(kopf.x<0||kopf.x>=N||kopf.y<0||kopf.y>=N||schlange.some(s=>s.x===kopf.x&&s.y===kopf.y)){ ende(false); return; }
  schlange.unshift(kopf);
  if(kopf.x===apfel.x&&kopf.y===apfel.y){ punkte++; document.getElementById('punkte').textContent='🍎 '+punkte;
    if(punkte>=ZIEL){ ende(true); return; } setzeApfel(); }
  else schlange.pop();
  zeichne();
}
function zeichne(){
  ctx.clearRect(0,0,c.width,c.height);
  ctx.font=ZELLE+'px serif'; ctx.textAlign='center'; ctx.textBaseline='middle';
  ctx.fillText('🍎', apfel.x*ZELLE+ZELLE/2, apfel.y*ZELLE+ZELLE/2);
  schlange.forEach((s,i)=>{ ctx.fillStyle=i===0?'#9be870':'#5fd36a'; ctx.fillRect(s.x*ZELLE+1,s.y*ZELLE+1,ZELLE-2,ZELLE-2); });
}
function ende(gewonnen){
  laeuft=false; clearInterval(tick);
  document.getElementById('endeEmoji').textContent=gewonnen?'🏆':'🐍';
  document.getElementById('endeTitel').textContent=gewonnen?'Geschafft!':'Aua!';
  document.getElementById('endeText').textContent=gewonnen?'Du hast es geschafft! Lange Schlange!':('Du hattest 🍎 '+punkte+'.');
  document.getElementById('ende').style.display='flex';
}
document.addEventListener('keydown',e=>{
  if(e.key==='ArrowUp')lenk(0,-1); if(e.key==='ArrowDown')lenk(0,1);
  if(e.key==='ArrowLeft')lenk(-1,0); if(e.key==='ArrowRight')lenk(1,0);
});
</script>
</body>
</html>
```

---

## 9. Tier-Pflege (füttern & glücklich halten)

Drei Balken (Hunger, Spaß, Energie) sinken langsam. Mit Knöpfen auffüllen. Bleibt alles im grünen
Bereich, steigt die Glücks-Punktzahl. Ein leerer Balken macht das Tier traurig.

```html
<!DOCTYPE html>
<html lang="de">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1, user-scalable=no">
<title>🐶 Tier-Pflege</title> <!-- ANPASSEN -->
<style>
  :root{ --bg:#ffe9c7; --akzent:#ff7eb6; } /* ANPASSEN */
  *{box-sizing:border-box;margin:0;padding:0;-webkit-user-select:none;user-select:none;}
  html,body{height:100%;font-family:system-ui,Arial,sans-serif;}
  body{background:var(--bg);color:#5a3d2b;display:flex;flex-direction:column;align-items:center;
       justify-content:center;min-height:100vh;gap:14px;padding:16px;}
  #punkte{font-size:20px;font-weight:bold;}
  #tier{font-size:120px;} #tier.happy{animation:hop .6s infinite;}
  @keyframes hop{0%,100%{transform:translateY(0)}50%{transform:translateY(-14px)}}
  #balken{width:280px;display:flex;flex-direction:column;gap:10px;}
  .reihe{display:flex;align-items:center;gap:8px;font-size:22px;}
  .bar{flex:1;height:18px;background:#fff;border-radius:10px;overflow:hidden;box-shadow:inset 0 2px 4px rgba(0,0,0,.15);}
  .fill{height:100%;width:100%;transition:width .3s;}
  #knoepfe{display:flex;gap:12px;}
  #knoepfe button{font-size:30px;padding:14px 20px;border:none;border-radius:16px;cursor:pointer;background:#fff;box-shadow:0 5px 0 rgba(0,0,0,.15);}
  #knoepfe button:active{transform:translateY(3px);box-shadow:0 2px 0 rgba(0,0,0,.15);}
  .schicht{position:fixed;inset:0;display:flex;flex-direction:column;align-items:center;
           justify-content:center;text-align:center;background:rgba(0,0,0,.55);color:#fff;gap:18px;padding:24px;}
  h1{font-size:40px;} p{font-size:22px;max-width:520px;line-height:1.4;}
  .btn{font-size:26px;padding:16px 34px;border:none;border-radius:18px;cursor:pointer;
       background:var(--akzent);color:#fff;font-weight:bold;box-shadow:0 6px 0 rgba(0,0,0,.25);}
  .gross{font-size:72px;}
</style>
</head>
<body>
<div id="punkte">⭐ Glück: 0</div>
<div id="tier">🐶</div> <!-- ANPASSEN: Tier -->
<div id="balken">
  <div class="reihe">🍖 <div class="bar"><div class="fill" id="hunger" style="background:#ff8a5c"></div></div></div>
  <div class="reihe">🎾 <div class="bar"><div class="fill" id="spass" style="background:#5cc8ff"></div></div></div>
  <div class="reihe">⚡ <div class="bar"><div class="fill" id="energie" style="background:#a0e85b"></div></div></div>
</div>
<div id="knoepfe">
  <button onclick="fuettern()">🍖</button>
  <button onclick="spielen()">🎾</button>
  <button onclick="schlafen()">😴</button>
</div>
<div class="schicht" id="start">
  <div class="gross">🐶</div><h1>Tier-Pflege</h1>
  <p>Halte dein Tier glücklich! 🍖🎾😴<br>Füttern, spielen, schlafen — lass keinen Balken leer werden.</p>
  <button class="btn" onclick="los()">▶ Start</button>
</div>
<div class="schicht" id="ende" style="display:none">
  <div class="gross" id="endeEmoji">🎉</div><h1 id="endeTitel"></h1>
  <p id="endeText"></p>
  <button class="btn" onclick="los()">🔄 Nochmal</button>
</div>
<script>
const tier=document.getElementById('tier');
const ZIEL=20; // ANPASSEN: so viele Glücks-Punkte = gewonnen
let hunger,spass,energie,glueck,laeuft=false,timer;
function setze(){
  document.getElementById('hunger').style.width=hunger+'%';
  document.getElementById('spass').style.width=spass+'%';
  document.getElementById('energie').style.width=energie+'%';
  const schnitt=(hunger+spass+energie)/3;
  tier.textContent = schnitt>66?'🐶':schnitt>33?'🙂':'😢'; // ANPASSEN: Tier-Emojis
  tier.className = schnitt>66?'happy':'';
}
function los(){
  document.getElementById('start').style.display='none';
  document.getElementById('ende').style.display='none';
  hunger=spass=energie=70; glueck=0; laeuft=true;
  document.getElementById('punkte').textContent='⭐ Glück: 0'; setze();
  clearInterval(timer); timer=setInterval(tick,1000);
}
function tick(){
  if(!laeuft) return;
  hunger=Math.max(0,hunger-6); spass=Math.max(0,spass-5); energie=Math.max(0,energie-4); // ANPASSEN: Abnahme
  if(hunger>40&&spass>40&&energie>40){ glueck++; document.getElementById('punkte').textContent='⭐ Glück: '+glueck;
    if(glueck>=ZIEL){ ende(true); return; } }
  if(hunger===0||spass===0||energie===0){ ende(false); return; }
  setze();
}
function fuettern(){ if(laeuft){ hunger=Math.min(100,hunger+25); setze(); } }
function spielen(){ if(laeuft){ spass=Math.min(100,spass+25); energie=Math.max(0,energie-5); setze(); } }
function schlafen(){ if(laeuft){ energie=Math.min(100,energie+30); setze(); } }
function ende(gewonnen){
  laeuft=false; clearInterval(timer);
  document.getElementById('endeEmoji').textContent=gewonnen?'🏆':'😢';
  document.getElementById('endeTitel').textContent=gewonnen?'Superglücklich!':'Oh nein!';
  document.getElementById('endeText').textContent=gewonnen?'Dein Tier ist megaglücklich! Toll gepflegt!':'Dein Tier braucht mehr Pflege. Versuch es nochmal!';
  document.getElementById('ende').style.display='flex';
}
</script>
</body>
</html>
```

---

## 10. 3D-Sammelspiel (echtes 3D mit Three.js)

Eine echte 3D-Welt: Die Figur läuft mit den Pfeiltasten herum und sammelt alle Sterne ein.
**Braucht Internet** (lädt die 3D-Bibliothek). Tastatur-gesteuert — am besten am Computer.

```html
<!DOCTYPE html>
<html lang="de">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1, user-scalable=no">
<title>🌟 3D-Sammeln</title> <!-- ANPASSEN -->
<style>
  *{box-sizing:border-box;margin:0;padding:0;-webkit-user-select:none;user-select:none;}
  html,body{height:100%;overflow:hidden;font-family:system-ui,Arial,sans-serif;}
  #punkte{position:fixed;top:12px;left:16px;color:#fff;font-size:28px;font-weight:bold;text-shadow:0 2px 6px rgba(0,0,0,.6);z-index:5;}
  .schicht{position:fixed;inset:0;display:flex;flex-direction:column;align-items:center;
           justify-content:center;text-align:center;color:#fff;background:rgba(20,30,60,.7);gap:18px;padding:24px;z-index:10;}
  h1{font-size:40px;} p{font-size:22px;max-width:560px;line-height:1.45;}
  button{font-size:26px;padding:16px 34px;border:none;border-radius:18px;cursor:pointer;
         background:#ffd23f;color:#222;font-weight:bold;box-shadow:0 6px 0 rgba(0,0,0,.25);}
  .gross{font-size:72px;} canvas{display:block;}
</style>
</head>
<body>
<div id="punkte">🌟 0</div>
<div class="schicht" id="start">
  <div class="gross">🌟</div><h1>3D-Sammeln</h1>
  <p>Lauf durch die 3D-Welt und sammle alle Sterne ein! 🌟<br>Bewege dich mit ← ↑ → ↓ (oder W A S D).</p>
  <button onclick="los()">▶ Start</button>
</div>
<div class="schicht" id="ende" style="display:none">
  <div class="gross">🏆</div><h1>Geschafft!</h1>
  <p id="endeText"></p>
  <button onclick="los()">🔄 Nochmal</button>
</div>
<!-- ANPASSEN: 3D-Bibliothek (braucht Internet). Stabile UMD-Version mit globalem THREE. -->
<script src="https://cdnjs.cloudflare.com/ajax/libs/three.js/r128/three.min.js"></script>
<script>
let scene,camera,renderer,spieler,sterne=[],punkte,laeuft=false;
const tasten={};
const ANZAHL=8; // ANPASSEN: so viele Sterne zum Sammeln
function init(){
  scene=new THREE.Scene();
  scene.background=new THREE.Color(0x87ceeb);        // ANPASSEN: Himmelfarbe
  scene.fog=new THREE.Fog(0x87ceeb,20,60);
  camera=new THREE.PerspectiveCamera(60, innerWidth/innerHeight, 0.1, 200);
  renderer=new THREE.WebGLRenderer({antialias:true});
  renderer.setSize(innerWidth,innerHeight); document.body.appendChild(renderer.domElement);
  scene.add(new THREE.AmbientLight(0xffffff,0.7));
  const sonne=new THREE.DirectionalLight(0xffffff,0.7); sonne.position.set(10,20,10); scene.add(sonne);
  const boden=new THREE.Mesh(new THREE.PlaneGeometry(80,80), new THREE.MeshStandardMaterial({color:0x6fcf5f})); // ANPASSEN: Boden
  boden.rotation.x=-Math.PI/2; scene.add(boden);
  spieler=new THREE.Mesh(new THREE.SphereGeometry(1,24,24), new THREE.MeshStandardMaterial({color:0xff5fa2})); // ANPASSEN: Figur
  spieler.position.set(0,1,0); scene.add(spieler);
  for(let i=0;i<14;i++){ const x=(Math.random()-0.5)*70, z=(Math.random()-0.5)*70; if(Math.abs(x)<6&&Math.abs(z)<6) continue;
    const stamm=new THREE.Mesh(new THREE.CylinderGeometry(0.4,0.4,2), new THREE.MeshStandardMaterial({color:0x8b5a2b})); stamm.position.set(x,1,z); scene.add(stamm);
    const krone=new THREE.Mesh(new THREE.ConeGeometry(1.6,3,8), new THREE.MeshStandardMaterial({color:0x2e8b57})); krone.position.set(x,3.2,z); scene.add(krone); }
  addEventListener('resize',()=>{ camera.aspect=innerWidth/innerHeight; camera.updateProjectionMatrix(); renderer.setSize(innerWidth,innerHeight); });
  animate();
}
function setzeSterne(){
  sterne.forEach(s=>scene.remove(s)); sterne=[];
  for(let i=0;i<ANZAHL;i++){
    const s=new THREE.Mesh(new THREE.OctahedronGeometry(0.8), new THREE.MeshStandardMaterial({color:0xffd23f,emissive:0x665500}));
    s.position.set((Math.random()-0.5)*60,1.2,(Math.random()-0.5)*60); scene.add(s); sterne.push(s);
  }
}
function los(){
  document.getElementById('start').style.display='none';
  document.getElementById('ende').style.display='none';
  spieler.position.set(0,1,0); punkte=0; document.getElementById('punkte').textContent='🌟 0';
  setzeSterne(); laeuft=true;
}
function animate(){
  requestAnimationFrame(animate);
  if(laeuft){
    const v=0.35;
    if(tasten['ArrowUp']||tasten['w']) spieler.position.z-=v;
    if(tasten['ArrowDown']||tasten['s']) spieler.position.z+=v;
    if(tasten['ArrowLeft']||tasten['a']) spieler.position.x-=v;
    if(tasten['ArrowRight']||tasten['d']) spieler.position.x+=v;
    spieler.position.x=Math.max(-39,Math.min(39,spieler.position.x));
    spieler.position.z=Math.max(-39,Math.min(39,spieler.position.z));
    for(const s of sterne){ s.rotation.y+=0.05; s.rotation.x+=0.03;
      if(s.position.distanceTo(spieler.position)<1.6){ scene.remove(s); sterne=sterne.filter(x=>x!==s);
        punkte++; document.getElementById('punkte').textContent='🌟 '+punkte; if(sterne.length===0) gewonnen(); } }
    camera.position.set(spieler.position.x, spieler.position.y+8, spieler.position.z+12);
    camera.lookAt(spieler.position);
  }
  renderer.render(scene,camera);
}
function gewonnen(){ laeuft=false;
  document.getElementById('endeText').textContent='Du hast alle Sterne gesammelt! Super!';
  document.getElementById('ende').style.display='flex';
}
addEventListener('keydown',e=>{ tasten[e.key]=true; if(e.key.startsWith('Arrow'))e.preventDefault(); });
addEventListener('keyup',e=>{ tasten[e.key]=false; });
init();
</script>
</body>
</html>
```

---

## Tipps fürs Anpassen

- **Figuren tauschen:** Such ein passendes Emoji für Held, Sammel-Ding und Hindernis aus der Idee
  des Kindes (z. B. Rakete 🚀, Stern ⭐, Meteor ☄️). Ersetze die `ANPASSEN`-Emojis.
- **Ort = Hintergrundfarbe:** Weltraum → dunkelblau, Wald → grün, Unterwasser → türkis, Schule → hell.
- **Schwierigkeit:** Die `// ANPASSEN`-Zahlen (Tempo, Zeit, Ziel-Punkte) anpassen. Lieber etwas
  zu leicht als zu schwer — ein 9-jähriges Kind soll gewinnen können.
- **Texte kindgerecht:** Titel, Steuerungs-Hinweis und „Gewonnen"-Text in einfacher, fröhlicher Sprache.
- **Ein-/Mehrzahl vermeiden:** Schreib Anzahlen als Emoji-Zähler (z. B. `'🍩 '+punkte` statt `punkte+' Donuts'`).
  Sonst steht bei genau 1 falsches Deutsch da („1 Donuts"). Grundschulkinder merken das sofort.
- **Mehrere Wünsche:** Wenn das Kind später etwas ändern will, nimm dieselbe Datei und passe nur
  die betroffene Stelle an. So bleibt das Spiel stabil.

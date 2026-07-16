# Freitags Bash · Abend 2 — Drehbuch & Verbesserungs-Review
*Stand: 16.07.2026, Abend vor dem Event. Teil 1 = operativer Ablauf für morgen, Teil 2 = was man verbessern kann (Operativ / Technik / Ansicht), priorisiert.*

---

## Teil 1 · Drehbuch für morgen

### Heute Abend / morgen Vormittag (Pflicht)

1. **SQL Abschnitt 12** in Supabase ausführen (SQL-Editor im *richtigen* Konto — Projekt-Ref `bvaxeqkfozegeejdimdp` in der URL):
   `alter table events add column if not exists champion_ban jsonb;`
   Ohne die Spalte schlägt „Bann aktivieren" fehl (der Toast sagt es dir dann auch).
2. **Deployen** (`deploy.bat`) — bringt alles auf einmal live: Spielpool + Line-up-Editor, Chameleon Infectious, Haxball-DE-Bracket, Dino Runner, Champions-Bann, Pool-Slide, Keepalive-Workflow.
3. Nach dem Push: **GitHub → Actions → „Supabase Keepalive" → Run workflow** — einmal manuell testen, ob er grün durchläuft. (Er wird erst durch diesen Deploy überhaupt aktiv!)
4. **Abend anlegen** im Admin (Datum 17.07.). Line-up prüfen: Haxball → GeoGuessr → Brawlhalla → **Chameleon** → Fall Guys ist der Default. Chess liegt im Pool (Chip „+ ♟️" erscheint nur solange der Abend im Entwurf ist).
5. **Stech-Spiel** im Setup wählen (Dropdown zeigt die Spiele des Abends).
6. Einmal **bash.endocraft.app öffnen** und prüfen, dass Daten laden (nicht dass Supabase wieder schläft) + Countdown zeigt morgen.

### Crew-Ansagen (heute!)

- **Meccha Chameleon kaufen & installieren** (~6 €, Steam, nur Windows) — nicht erst morgen um 20:00.
- Host mit gutem Netz bestimmen; **einmal zu zweit eine private Lobby testen** — und mir sagen, wie der Join genau läuft, falls die „So joinst du"-Schritte auf der Seite angepasst werden müssen.
- Erinnerung: **Vetos setzen** geht bis zum Live-Schalten (Spielabend-Seite → Veto). Der Champions-Bann bleibt geheim. 😈
- Bei ~11 Leuten: Chameleon empfiehlt 2–10 Spieler — Plan B, falls die Lobby bei 11 zickt (z. B. einer castet im Voice mit).

### Der Abend selbst (Admin-Handgriffe in Reihenfolge)

1. **Teilnehmer anklicken!** Der Default ist bewusst LEER — vergisst du das, sind alle Auslosungen und „Heute am Start" leer. (Häufigste Stolperfalle.)
2. **Live schalten** → Intro startet automatisch bei „Teilnehmer".
3. **Intro durchsteppen:** 👥 Teilnehmer → 🎮 **Spielpool** (neu: alle 6 fliegen rein, das Line-up leuchtet auf) → Spiele 1–5 einzeln → 🃏 Vetos (mit King-of-the-Hill-Regel + Dino-Runner-Vorstellung).
4. **Champions-Bann:** im Admin King + Spiel wählen → „💥 Bann aktivieren" (Confirm zeigt die Opfer) → neuer „💥"-Button in der Zeigen-Leiste → Enthüllung läuft (Stempel → Zerstörung → Zwangsrekrutierung).
5. **Joker aktivieren** (copter_active-Toggle), sobald es Vetos gibt — sonst sehen die Veto-Spieler das Dino-Widget nicht.
6. Pro Spiel: **Status durchschalten** (offen → läuft → fertig) — das steuert die komplette Live-Dramaturgie (Bumper, Uhr, Ranking-Reveal). *Der wichtigste wiederkehrende Handgriff des Abends.*
7. Pro Spiel Links/Codes eintragen: GeoGuessr-Challenge-Link, Haxball-Raum-Link, Brawlhalla-Lobby-Codes, Fall-Guys-Code. Chameleon: Lobby-Daten im Voice ansagen.
8. **Haxball DE:** Turnierbaum auslosen → Sieger-Teams anklicken → nach jeder Runde „nächste Runde auslosen" → GF-Sieger klicken. Nur die aktuelle Runde ist änderbar („letzte Runde verwerfen" als Notausgang).
9. **Chameleon Infectious:** pro Runde Jäger auslosen (Rotation automatisch, ⚖-Zeile zeigt Fairness) → Funde antippen (geht auch live durch die Spieler) → **„🏁 Runde beenden" nicht vergessen** — sonst kriegen die Überlebenden ihre Punkte nicht!
10. ☕ **Pause-Button** nutzen (Banner auf der Live-Seite).
11. Nach Spiel 5: **Endstand-Show** (Veto-Endstand → Gesamttabelle → Tagessieger) → **Finalisieren** (schreibt Saisonpunkte inkl. Krone-Bürde ×0,8 auf den King und Streicher-Logik).
12. Danach mir Bescheid geben → ich trage den Champions-Bann als **§15** auf der Regelseite nach.

---

## Teil 2 · Verbesserungs-Review

### Operativ (größter Hebel)

| Prio | Idee | Warum |
|---|---|---|
| ⭐⭐⭐ | **Admin-Checkliste im Admin** — kleine Box oben im Abend mit Auto-Häkchen (Teilnehmer > 0? Stech-Spiel gesetzt? Join-Link je Spiel? Joker aktiv? alle Disziplinen „fertig"?) | Die zwei realen Fehlerquellen sind Vergessenes (Teilnehmer, Runde-beenden, Status). Eine Live-Checkliste fängt alle ab. |
| ⭐⭐⭐ | **Status-Automatik**: Disziplin automatisch auf „läuft" bei erster Auslosung/Eingabe, automatisch „fertig", wenn alle Platzierungen stehen | Halbiert deine Klicks und die Live-Seite hängt nie hinterher. |
| ⭐⭐ | **Zeitplan-Widget**: DURATION_HINTs als Soll-Zeitplan + Ist-Zeiten (live_since) → „+12 min über Plan" im Admin | Ihr wollt um 22:45 fertig sein; aktuell fliegt ihr blind. |
| ⭐⭐ | **Chameleon-Rundentimer** auf der Live-Seite (z. B. 5 min Countdown groß) | „Nicht gefunden" braucht ein sauberes Rundenende — aktuell entscheidet der Host nach Gefühl. |
| ⭐ | Discord/WhatsApp-Ansage-Vorlage generieren (Ablauf + Kaufliste) aus dem Line-up | Ein Klick statt Abtippen. |

### Technik

| Prio | Punkt | Details |
|---|---|---|
| ⭐⭐⭐ | **Backups!** Supabase Free macht KEINE automatischen Backups. | Nach jedem Abend Tabellen-Export (CSV im Dashboard oder kleines Skript). Die ganze Saison hängt an einer DB ohne Sicherung — der Pause-Schreck war die Warnung. Ich kann dir ein Backup-Skript/Workflow bauen (analog Keepalive, legt JSON-Dumps ins Repo). |
| ⭐⭐ | **Code-Duplikate zusammenziehen**: DE-Logik (deShape/dePlan/deReplay) und `CHAM_SURVIVE_BONUS` existieren in admin.html UND abend.html | Drift-Gefahr: Wer eine Kopie ändert, verwertet falsch. Nach der Saison in eine gemeinsame `shared.js`. |
| ⭐⭐ | **Recompute-Performance**: Punkte-Neuberechnung macht pro Spieler einzelne DB-Roundtrips (11 Spieler = 11+ Requests) | Am Abend spürbar (1–3 s pro Klick). Später: ein einziges Batch-Upsert. |
| ⭐ | Fehler landen nur in console.error | Kleiner globaler „Speichern fehlgeschlagen"-Banner auf abend.html, damit Self-Entry-Fehler auffallen. |
| ⭐ | abend.html ist ein ~190-KB-Monolith | Funktioniert, aber jede Änderung wird riskanter. Post-Season: in Module schneiden. |
| ⭐ | Demo (?demo=1) hinkt hinterher (zeigt alten Haxball-Trichter, kein Pool-Intro) | Als Vorschau-Tool fürs nächste Feature-Testen aktualisieren. |
| – | Admin-Passwort + Anon-Key im Klartext, RLS erlaubt anon-Writes | Bewusster Trade-off für den Freundeskreis — nur wissen: Wer die Admin-URL kennt, kann alles. Nicht dringend. |

### Ansicht / UX

| Prio | Punkt | Details |
|---|---|---|
| ⭐⭐ | **Handy-Test der Live-Seite** | Viele gucken am Handy/Zweitgerät. DE-Baum & Chameleon-Karten sind scrollbar gebaut, aber ein echter Test auf 2–3 Handys vor 20:00 lohnt (10 min). |
| ⭐⭐ | „Als Nächstes"-Match (Haxball-DE) zusätzlich in der Klartext-Statuszeile | Wer nur die Tabelle sieht, verpasst, dass er dran ist — ggf. sogar Namens-Ping („🔔 Ryze & Pixie: ihr seid dran!"). |
| ⭐ | Endstand-Veto-Stufe zeigt zerstörte Vetos nicht | „💥 zerstört durch Champions-Bann" als Karte im Veto-Endstand — rundet die Story ab. |
| ⭐ | Saison-Rangliste auf index zeigt nach Abend 2 endlich Bewegung | Formkurve/Statistik-Seite verlinken, Head-to-Head nach Abend 2 bauen. |
| – | Grain-Overlay + Glow-Effekte auf schwachen Laptops | Falls die Live-Seite auf dem Beamer-Rechner ruckelt: `body::before` (Grain) testweise ausschalten. |

### Mein Vorschlag

**Vor morgen nichts Riskantes mehr anfassen.** Wenn du EINE Sache willst, bau ich dir noch die ⭐⭐⭐-**Admin-Checkliste** (reine Anzeige, kein Eingriff in Logik — risikoarm). Alles andere (Status-Automatik, Backups, Zeitplan, shared.js) machen wir entspannt nach dem Event — Backups als Erstes.

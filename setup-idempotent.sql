-- Freitags Bash — komplettes, idempotentes Setup
-- Kann beliebig oft im Supabase SQL-Editor ausgeführt werden, ohne Fehler.
-- Deckt ab: vetoes-Tabelle (+ Policies + Realtime) und die neue phase-Spalte für Haxball.

-- ============================================================
-- 1) VETOES-Tabelle (Veto-Picker auf abend.html)
-- ============================================================
create table if not exists vetoes (
  id uuid primary key default gen_random_uuid(),
  event_id uuid references events(id) on delete cascade,
  player_id uuid references players(id) on delete cascade,
  discipline_kind text,
  created_at timestamptz default now(),
  unique (event_id, player_id)
);

alter table vetoes enable row level security;

-- Policies erst entfernen, dann neu anlegen -> kein "already exists"-Fehler mehr
drop policy if exists vetoes_select on vetoes;
drop policy if exists vetoes_insert on vetoes;
drop policy if exists vetoes_update on vetoes;
drop policy if exists vetoes_delete on vetoes;

create policy vetoes_select on vetoes for select using (true);
create policy vetoes_insert on vetoes for insert with check (true);
create policy vetoes_update on vetoes for update using (true) with check (true);
create policy vetoes_delete on vetoes for delete using (true);

-- Realtime aktivieren (Fehler ignorieren, falls schon publiziert)
do $$
begin
  alter publication supabase_realtime add table vetoes;
exception
  when duplicate_object then null;
end $$;

-- ============================================================
-- 2) PHASE-Spalte (Haxball-Trichter-Phasen für die Live-Anzeige)
-- ============================================================
alter table disciplines add column if not exists phase text;

-- ============================================================
-- 3) TIEBREAKER-Spalte (Stech-Spiel pro Abend bei Gleichstand)
-- ============================================================
-- Speichert den discipline_kind des Stech-Spiels (z.B. 'haxball'),
-- wird im Admin pro Abend festgelegt und auf abend.html live angezeigt.
alter table events add column if not exists tiebreaker text;

-- ============================================================
-- 4) JOIN-LINK + TEAM-AUSLOSUNG (Live-Features auf abend.html)
-- ============================================================
-- join_link: echter Raum-Link bzw. Code pro Spiel (Admin trägt ihn ein),
--            wird auf der Spielabend-Seite groß angezeigt.
-- teams_drawn_at: Zeitstempel der letzten Team-Auslosung — triggert
--            die einmalige Reveal-Animation auf der Live-Seite.
alter table disciplines add column if not exists join_link text;
alter table disciplines add column if not exists teams_drawn_at timestamptz;

-- ============================================================
-- 5) FALL-GUYS MINI-TURNIER (mehrere Modi pro Abend, je solo/Team)
-- ============================================================
-- disciplines.modes: Definition der Modi, z.B. [{"n":1,"type":"solo"},{"n":2,"type":"team"}]
-- results.modes:     pro Spieler die Ergebnisse je Modus, z.B. {"1":{"placement":2},"2":{"team":1,"placement":1}}
-- Die Fall-Guys-Gesamtplatzierung (results.placement/points) wird aus der Summe aller Modus-Punkte berechnet.
alter table disciplines add column if not exists modes jsonb;
alter table results     add column if not exists modes jsonb;

-- ============================================================
-- 6) HAXBALL-PARTIEN (Round-Robin / Turnierbaum)
-- ============================================================
-- disciplines.bracket: { "gpp": <Spiele je Paarung>, "games": { "1-2":[Sieger-Team je Spiel], ... } }
-- Rein informativ/Anzeige — die gewertete Endplatzierung wird weiterhin per Klick-Reihenfolge erfasst.
alter table disciplines add column if not exists bracket jsonb;

-- ============================================================
-- 7) LIVE-PAUSE (Admin schaltet eine Pause, Banner auf der Spielabend-Seite)
-- ============================================================
-- events.pause_msg: null = keine Pause; Text = Pausen-Banner (z.B. "weiter um 21:10").
alter table events add column if not exists pause_msg text;

-- ============================================================
-- 8) VORSTELLUNG (admin-gesteuert) + JOKER-AKTIVIERUNG
-- ============================================================
-- intro_step: null/aus = keine Vorstellung; 0 = Teilnehmer des Tages; 1..N = Disziplin N vorstellen.
-- copter_active: Joker-Minispiel (Fly the Copter) wird erst angezeigt, wenn true.
alter table events add column if not exists intro_step int;
alter table events add column if not exists copter_active boolean;

-- ============================================================
-- 9) ROSTER „Heute am Start" (Teilnehmer-Auswahl des Abends)
-- ============================================================
-- events.roster: JSON-Array der player_ids, die heute spielen. Wird im Admin bei
-- jeder Teilnehmer-Auswahl + beim Live-Schalten gesetzt; die Spielabend-Seite zeigt
-- genau diese Liste als „Heute am Start" an. events ist bereits in der Realtime-
-- Publication, daher übernimmt die Live-Seite Änderungen ohne Reload.
alter table events add column if not exists roster jsonb;

-- ============================================================
-- 10) GEOGUESSR-RUNDENZAHL (pro Abend einstellbar)
-- ============================================================
-- disciplines.rounds: Anzahl GeoGuessr-Runden im Challenge-Link (Standard 5).
-- Rein informativ — wird live im Regeltext angezeigt; die Wertung bleibt nach Platzierung.
alter table disciplines add column if not exists rounds int;

-- ============================================================
-- 11) SYNCHRONE UHREN (Broadcast-Look: Sendezeit + Spiel-Uhr)
-- ============================================================
-- events.live_since: Zeitpunkt des Live-Schaltens → „Sendezeit"-Uhr auf der Spielabend-Seite.
-- disciplines.live_since: Zeitpunkt, ab dem eine Disziplin auf „läuft" steht → „Spiel"-Uhr.
-- Beide werden im Admin gesetzt; die Live-Seite zählt clientseitig sekündlich hoch (synchron für alle).
alter table events      add column if not exists live_since timestamptz;
alter table disciplines add column if not exists live_since timestamptz;

-- ============================================================
-- 12) ENDSTAND-REVEAL-STUFE (admin-gesteuert für die Abschluss-Bühne)
-- ============================================================
-- events.endstand_stage: vom Admin schrittweise hochgeschaltet, sobald alle Disziplinen durch sind.
-- 0 = Veto-Endstand alleine, 1 = Gesamttabelle baut sich auf, 2 = Tagessieger zentral.
-- null = noch nicht im Endstand; die Spielabend-Seite startet automatisch bei 0/1 wenn null,
-- aber sobald der Admin einen Wert setzt, übernimmt der die Steuerung (Realtime-Sync).
alter table events add column if not exists endstand_stage int;

-- ============================================================
-- 13) WATCH2GETHER-LINK (gemeinsamer Mitschau-Raum)
-- ============================================================
-- events.w2g_link: URL zum Watch2Gether-Raum des Abends. Wenn gesetzt, erscheint auf der
-- Spielabend-Seite ein prominenter Button „📺 Mitschauen", der den Raum in einem neuen Tab öffnet.
-- Realtime-Sync: Admin trägt ein, alle Zuschauer sehen den Button sofort.
alter table events add column if not exists w2g_link text;

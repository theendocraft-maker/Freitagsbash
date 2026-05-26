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

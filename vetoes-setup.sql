-- Freitags Bash · Veto-Tabelle
-- Einmalig im Supabase SQL-Editor ausführen (Dashboard → SQL Editor → New query → einfügen → Run)

create table if not exists public.vetoes (
  id uuid primary key default gen_random_uuid(),
  event_id uuid not null references public.events(id) on delete cascade,
  player_id uuid not null references public.players(id) on delete cascade,
  discipline_kind text not null,
  created_at timestamptz not null default now(),
  unique (event_id, player_id)   -- ein Veto pro Spieler pro Abend
);

alter table public.vetoes enable row level security;

-- Gleiche Vertrauens-Policys wie der Rest der Seite (kein Login):
create policy "vetoes_select" on public.vetoes for select using (true);
create policy "vetoes_insert" on public.vetoes for insert with check (true);
create policy "vetoes_update" on public.vetoes for update using (true) with check (true);
create policy "vetoes_delete" on public.vetoes for delete using (true);

-- Live-Updates aktivieren (damit Vetos sofort bei allen erscheinen):
alter publication supabase_realtime add table public.vetoes;

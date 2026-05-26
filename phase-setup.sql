-- Freitags Bash — Phase-Spalte für Haxball (Live-Anzeige der Trichter-Phasen)
-- Einmalig im Supabase SQL-Editor ausführen.
-- Speichert die aktuelle Phase einer Disziplin (z.B. Haxball: 'Teams' → '2v2' → '1v1-Finale').
-- Wird vom Admin gesetzt und auf abend.html live angezeigt.

alter table disciplines add column if not exists phase text;

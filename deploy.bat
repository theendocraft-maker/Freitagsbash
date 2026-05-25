@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

REM ===========================================================
REM  Projektordner FEST verdrahtet - egal von wo die .bat
REM  gestartet wird, es wird immer dieser Ordner deployed.
REM ===========================================================
set "PROJ=C:\Users\cxrat\Desktop\Freitags Bash"
cd /d "%PROJ%" 2>nul
if errorlevel 1 (
  echo [FEHLER] Ordner nicht gefunden:
  echo   %PROJ%
  echo Bitte PROJ-Pfad oben in der Datei anpassen.
  pause
  exit /b 1
)

echo ============================================
echo   Freitags Bash  -  Deploy zu GitHub Pages
echo   Ordner: %CD%
echo ============================================
echo.

where git >nul 2>nul
if errorlevel 1 (
  echo [FEHLER] Git ist nicht installiert: https://git-scm.com/download/win
  pause
  exit /b 1
)

REM --- Welche Dateien liegen hier wirklich? (Datum + Groesse zum Abgleich) ---
echo --- Dateien in diesem Ordner ---
for %%F in (index.html regeln.html admin.html CNAME) do (
  if exist "%%F" (
    for %%A in ("%%F") do echo   %%~tA   %%~zA Bytes   %%F
  ) else (
    echo   [FEHLT] %%F
  )
)
echo.

REM --- Repo initialisieren falls noetig ---
if not exist ".git" (
  echo Initialisiere lokales Git-Repo...
  git init >nul
  git branch -M main
)

REM --- Identitaet setzen falls leer ---
for /f "delims=" %%i in ('git config user.name 2^>nul') do set "GU=%%i"
if "!GU!"=="" git config user.name "theendocraft-maker"
for /f "delims=" %%i in ('git config user.email 2^>nul') do set "GE=%%i"
if "!GE!"=="" git config user.email "cx.ratti@gmx.de"

REM --- Remote sicherstellen ---
git remote remove origin >nul 2>nul
git remote add origin https://github.com/theendocraft-maker/Freitagsbash.git

REM --- Dateien aufnehmen ---
echo Fuege Dateien hinzu...
git add -A

echo.
echo --- Das sieht Git als Aenderung (leer = nichts Neues) ---
git status --short
echo.

set "MSG="
set /p MSG="Commit-Nachricht (Enter = 'update site'): "
if "!MSG!"=="" set "MSG=update site"

git commit -m "!MSG!"
if errorlevel 1 echo (Kein neuer Commit noetig - pushe vorhandenen Stand.)

REM --- Remote-Stand integrieren, dann pushen ---
echo.
echo Pushe zu GitHub... (beim ersten Mal oeffnet sich ein Login-Fenster)
git fetch origin main >nul 2>nul
git merge origin/main --no-edit >nul 2>nul
git push -u origin main
if errorlevel 1 (
  echo.
  echo [HINWEIS] Push fehlgeschlagen.
  echo Bei "rejected/non-fast-forward" einmal ausfuehren:
  echo     git pull origin main --allow-unrelated-histories --no-edit
  echo und danach deploy.bat erneut starten.
  pause
  exit /b 1
)

echo.
echo ============================================
echo   FERTIG! Push erfolgreich.
echo   Pruefen: github.com/theendocraft-maker/Freitagsbash
echo   (Commit-Zahl sollte hochgegangen sein)
echo   Live in 1-2 Min: bash.endocraft.app  (Strg+Shift+R)
echo ============================================
echo.
pause

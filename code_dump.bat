@ECHO OFF
SETLOCAL ENABLEDELAYEDEXPANSION

:: --- CONFIGURATION ---
SET "outputFile=resultats_recherche.txt"
SET "scriptName=%~nx0"

:: --- 1. CHOIX DU DOSSIER ---
:AskDir
ECHO.
SET "targetDir=%CD%"
SET /P "inputDir=Chemin du dossier a scanner : "

IF NOT "%inputDir%"=="" (
    IF EXIST "%inputDir%" (
        SET "targetDir=%inputDir%"
    ) ELSE (
        ECHO [ERREUR] Dossier introuvable.
        GOTO AskDir
    )
)

:: --- 2. CHOIX DU STYLE ---
:AskMode
ECHO.
ECHO [1] MARKDOWN (Balises code)
ECHO [2] COMPACT  (Brut sans lignes vides)
SET /P "modeChoice=Choix : "

IF "%modeChoice%" NEQ "1" IF "%modeChoice%" NEQ "2" GOTO AskMode

:: --- NETTOYAGE ---
IF EXIST "%outputFile%" DEL "%outputFile%"

ECHO.
ECHO Analyse en cours... (Ne fermez pas la fenetre)

:: En-tête
(
    ECHO SCAN : %targetDir%
    ECHO Date : %DATE% %TIME%
    ECHO ----------------------------------------
) > "%outputFile%"

SET "fileCount=0"

:: --- TRAITEMENT ---
CALL :ProcessDirectory "%targetDir%"

:: --- FIN ---
ECHO. >> "%outputFile%"
ECHO [FIN] Fichiers traites : !fileCount! >> "%outputFile%"

ECHO.
ECHO ----------------------------------------
ECHO Termine ! 
ECHO Fichiers analyses : !fileCount!
ECHO Resultats enregistres dans : %outputFile%
ECHO ----------------------------------------
PAUSE
GOTO :EOF

:: ---------------------------------------------------------
:: FONCTION DE TRAITEMENT
:: ---------------------------------------------------------
:ProcessDirectory
SET "currentDir=%~1"

REM On parcourt les fichiers. 
FOR %%F IN ("%currentDir%\*.*") DO (
    SET "filePath=%%F"
    SET "fileName=%%~nxF"
    SET "fileExt=%%~xF"
    
    SET "skip=0"
    
    REM --- FILTRES DE SECURITE ---
    
    REM 1. Le script et le résultat
    IF /I "!fileName!" == "%scriptName%" SET "skip=1"
    IF /I "!fileName!" == "%outputFile%" SET "skip=1"
    
    REM 2. Dossiers techniques/caches
    IF /I "!fileName!" == ".gitignore" SET "skip=1"
    IF /I "!fileName!" == "package-lock.json" SET "skip=1"
    IF /I "!fileName!" == "yarn.lock" SET "skip=1"
    
    REM 3. Images et Medias
    IF /I "!fileExt!" == ".jpg" SET "skip=1"
    IF /I "!fileExt!" == ".jpeg" SET "skip=1"
    IF /I "!fileExt!" == ".png" SET "skip=1"
    IF /I "!fileExt!" == ".gif" SET "skip=1"
    IF /I "!fileExt!" == ".ico" SET "skip=1"
    IF /I "!fileExt!" == ".svg" SET "skip=1"
    IF /I "!fileExt!" == ".webp" SET "skip=1"
    IF /I "!fileExt!" == ".mp4" SET "skip=1"
    IF /I "!fileExt!" == ".mp3" SET "skip=1"
    
    REM 4. Binaires et Executables
    IF /I "!fileExt!" == ".exe" SET "skip=1"
    IF /I "!fileExt!" == ".dll" SET "skip=1"
    IF /I "!fileExt!" == ".obj" SET "skip=1"
    IF /I "!fileExt!" == ".o" SET "skip=1"
    IF /I "!fileExt!" == ".bin" SET "skip=1"
    IF /I "!fileExt!" == ".dat" SET "skip=1"
    IF /I "!fileExt!" == ".iso" SET "skip=1"
    IF /I "!fileExt!" == ".pdf" SET "skip=1"
    IF /I "!fileExt!" == ".zip" SET "skip=1"
    IF /I "!fileExt!" == ".rar" SET "skip=1"
    IF /I "!fileExt!" == ".7z" SET "skip=1"
    IF /I "!fileExt!" == ".tar" SET "skip=1"
    IF /I "!fileExt!" == ".gz" SET "skip=1"
    IF /I "!fileExt!" == ".class" SET "skip=1"
    IF /I "!fileExt!" == ".jar" SET "skip=1"
    IF /I "!fileExt!" == ".pyc" SET "skip=1"

    REM Si le fichier est safe, on traite
    IF "!skip!" == "0" (
        SET /A fileCount+=1
        ECHO [!fileCount!] Ajout : !fileName!
        
        IF "%modeChoice%"=="1" (
            REM === MODE 1 : MARKDOWN ===
            (
                ECHO.
                ECHO ---
                ECHO ### FICHIER : !fileName!
                ECHO **Chemin :** !filePath!
                ECHO.
                ECHO ```
                TYPE "!filePath!" 2>nul
                ECHO.
                ECHO ```
            ) >> "%outputFile%"
        ) ELSE (
            REM === MODE 2 : COMPACT (Anti-vide) ===
            (
                ECHO.
                ECHO ^>^>^> !filePath!
                REM LE SECRET EST ICI : [^ ] cherche tout ce qui n'est PAS un espace
                TYPE "!filePath!" 2>nul | findstr /R /C:"[^ ]" 2>nul
            ) >> "%outputFile%"
        )
    )
)

REM Gestion des sous-dossiers
FOR /D %%D IN ("%currentDir%\*") DO (
    SET "dirName=%%~nxD"
    SET "skipDir=0"
    
    REM Exclusions de dossiers
    IF /I "!dirName!" == "node_modules" SET "skipDir=1"
    IF /I "!dirName!" == ".git" SET "skipDir=1"
    IF /I "!dirName!" == ".svn" SET "skipDir=1"
    IF /I "!dirName!" == "dist" SET "skipDir=1"
    IF /I "!dirName!" == "build" SET "skipDir=1"
    IF /I "!dirName!" == "bin" SET "skipDir=1"
    IF /I "!dirName!" == "obj" SET "skipDir=1"
    IF /I "!dirName!" == "vendor" SET "skipDir=1"
    IF /I "!dirName!" == ".idea" SET "skipDir=1"
    IF /I "!dirName!" == ".vscode" SET "skipDir=1"
    IF /I "!dirName!" == "__pycache__" SET "skipDir=1"
    IF /I "!dirName!" == "venv" SET "skipDir=1"
    IF /I "!dirName!" == "env" SET "skipDir=1"
    
    IF "!skipDir!" == "0" (
        CALL :ProcessDirectory "%%D"
    )
)
GOTO :EOF
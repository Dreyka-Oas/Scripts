@ECHO OFF
SETLOCAL ENABLEDELAYEDEXPANSION
CHCP 65001 >NUL

:: --- CONFIGURATION ---
SET "outputFile=architecture_filtree.txt"

:: --- CHOIX DU DOSSIER ---
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

:: --- INITIALISATION ---
IF EXIST "%outputFile%" DEL "%outputFile%"

ECHO.
ECHO Generation de l'arbre filtre... (Cela peut prendre quelques secondes)

(
    ECHO ARCHITECTURE FILTREE
    ECHO Dossier : %targetDir%
    ECHO Date : %DATE% %TIME%
    ECHO ----------------------------------------
    ECHO.
    ECHO %targetDir%
) > "%outputFile%"

:: --- LANCEMENT DU TRAITEMENT ---
CALL :ProcessFolder "%targetDir%" ""

:: --- FIN ---
ECHO.
ECHO ----------------------------------------
ECHO Arbre genere dans : %outputFile%
ECHO ----------------------------------------
PAUSE
GOTO :EOF

:: ---------------------------------------------------------
:: FONCTION RECURSIVE (Le cœur du script)
:: ---------------------------------------------------------
:ProcessFolder
SET "currentPath=%~1"
SET "indent=%~2"

:: 1. TRAITEMENT DES FICHIERS
FOR %%F IN ("%currentPath%\*.*") DO (
    SET "fileName=%%~nxF"
    SET "fileExt=%%~xF"
    SET "fileSize=%%~zF"
    SET "skip=0"

    REM --- A. FILTRE FICHIERS VIDES ---
    IF !fileSize! EQU 0 SET "skip=1"

    REM --- B. FILTRE EXTENSIONS INTERDITES (Binaires & Archives) ---
    REM Note : On ne filtre PAS les images (.jpg, .png...) car tu veux les garder.
    IF /I "!fileExt!" == ".exe" SET "skip=1"
    IF /I "!fileExt!" == ".dll" SET "skip=1"
    IF /I "!fileExt!" == ".bin" SET "skip=1"
    IF /I "!fileExt!" == ".obj" SET "skip=1"
    IF /I "!fileExt!" == ".o" SET "skip=1"
    IF /I "!fileExt!" == ".iso" SET "skip=1"
    IF /I "!fileExt!" == ".dat" SET "skip=1"
    
    REM Archives
    IF /I "!fileExt!" == ".zip" SET "skip=1"
    IF /I "!fileExt!" == ".rar" SET "skip=1"
    IF /I "!fileExt!" == ".7z" SET "skip=1"
    IF /I "!fileExt!" == ".tar" SET "skip=1"
    IF /I "!fileExt!" == ".gz" SET "skip=1"
    
    REM Fichiers système/cache
    IF /I "!fileName!" == "thumbs.db" SET "skip=1"
    IF /I "!fileName!" == ".DS_Store" SET "skip=1"
    IF /I "!fileName!" == "%outputFile%" SET "skip=1"
    IF /I "!fileName!" == "%~nx0" SET "skip=1"

    REM --- C. AFFICHAGE ---
    IF "!skip!" == "0" (
        ECHO %indent%├── !fileName! >> "%outputFile%"
    )
)

:: 2. TRAITEMENT DES DOSSIERS (Récursion)
FOR /D %%D IN ("%currentPath%\*") DO (
    SET "dirName=%%~nxD"
    SET "skipDir=0"

    REM --- D. FILTRE DOSSIERS ---
    IF /I "!dirName!" == ".git" SET "skipDir=1"
    IF /I "!dirName!" == ".svn" SET "skipDir=1"
    IF /I "!dirName!" == ".vscode" SET "skipDir=1"
    IF /I "!dirName!" == ".idea" SET "skipDir=1"
    IF /I "!dirName!" == "node_modules" SET "skipDir=1"
    IF /I "!dirName!" == "vendor" SET "skipDir=1"
    IF /I "!dirName!" == "dist" SET "skipDir=1"
    IF /I "!dirName!" == "build" SET "skipDir=1"
    IF /I "!dirName!" == "__pycache__" SET "skipDir=1"
    
    REM Vérifier si le dossier est vide (technique rapide)
    REM On regarde s'il y a au moins un fichier ou dossier dedans
    DIR "%%D" /A /B >NUL 2>&1
    IF ERRORLEVEL 1 SET "skipDir=1"

    IF "!skipDir!" == "0" (
        ECHO %indent%├── [!dirName!] >> "%outputFile%"
        
        REM Appel récursif avec indentation augmentée
        REM On ajoute "│   " pour décaler visuellement
        CALL :ProcessFolder "%%D" "%indent%│   "
    )
)

GOTO :EOF
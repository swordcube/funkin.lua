@echo off
cls
cd helpers

@REM Delete old export folder and make new one
echo Making export folder

mkdir "../../export" > nul

rd /S /Q "../../export/%1" > nul
mkdir "../../export/%1" > nul

@REM Copy assets folder to export folder
echo Copying assets to export

Xcopy ..\..\assets ..\..\export\%1\assets /E /H /C /I /Y > nul
Xcopy ..\..\mods ..\..\export\%1\mods /E /H /C /I /Y > nul
copy ..\..\alsoft.ini ..\..\export\%1\alsoft.ini

@REM Create new Flora.love file
echo Packaging game (this might take a while!)

7za.exe a Flora.zip ../../ -x!.vscode -x!.git -x!assets -x!commands -x!export > nul
ren Flora.zip Flora.love

@REM Modify to your needs
set LOVE_PATH=C:\Program Files\LOVE

@REM Copy all important Love2D dlls to output dir
echo Copying Love2D DLLs to export

copy "%LOVE_PATH%\love.dll" "../../export/%1/love.dll" > nul
copy "%LOVE_PATH%\lua51.dll" "../../export/%1/lua51.dll" > nul
copy "%LOVE_PATH%\SDL3.dll" "../../export/%1/SDL3.dll" > nul
copy "%LOVE_PATH%\OpenAL32.dll" "../../export/%1/OpenAL32.dll" > nul
copy "%LOVE_PATH%\mpg123.dll" "../../export/%1/mpg123.dll" > nul
copy "%LOVE_PATH%\msvcp120.dll" "../../export/%1/msvcp120.dll" > nul
copy "%LOVE_PATH%\msvcp140.dll" "../../export/%1/msvcp140.dll" > nul
copy "%LOVE_PATH%\msvcr120.dll" "../../export/%1/msvcr120.dll" > nul
copy "%LOVE_PATH%\msvcr140.dll" "../../export/%1/msvcr140.dll" > nul

@REM Create final executable
echo Creating final executable

copy /b "%LOVE_PATH%\%2.exe" temp.exe > nul

@REM Copy icon.ico to export folder
copy ..\..\icon.ico ..\..\export\%1\icon.ico > nul

@REM Apply icon.ico to executable

@REM NOTE: Have to make a temp.exe, apply the icon to it, and then
@REM add the game contents to it otherwise rcedit will strip the game
@REM contents out of the executable, forcing Love2D to open it's sample project

rcedit.exe temp.exe --set-icon ..\..\export\%1\icon.ico

rcedit.exe temp.exe --set-file-version 1.0.0
rcedit.exe temp.exe --set-product-version 1.0.0

rcedit.exe temp.exe --set-version-string "ProductName" "funkin.lua"
rcedit.exe temp.exe --set-version-string "CompanyName" "swordcube"
rcedit.exe temp.exe --set-version-string "LegalCopyright" "2024-2024 swordcube"
rcedit.exe temp.exe --set-version-string "FileDescription" "funkin.lua"

copy /b temp.exe + Flora.love "../../export/%1/Funkin.exe" > nul

del Flora.love
del temp.exe

echo Published a %1 build successfully! Check export/%1
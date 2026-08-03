@echo off
setlocal
cd /d "%~dp0"

echo ============================================
echo  MetalSync - Build onefile
echo ============================================
echo.

python -m pip show pyinstaller >nul 2>&1
if errorlevel 1 (
    echo PyInstaller no esta instalado.
    echo Instalando...
    python -m pip install pyinstaller
    if errorlevel 1 goto :error
)

echo.
echo Generando MetalSync.exe...
python -m PyInstaller ^
    --noconfirm ^
    --clean ^
    --onefile ^
    --console ^
    --name MetalSync ^
    metalsync.py

if errorlevel 1 goto :error

copy /Y metalsync.json dist\metalsync.json >nul
copy /Y README.md dist\README.md >nul

echo.
echo ============================================
echo Build completada.
echo.
echo Archivos:
echo   dist\MetalSync.exe
echo   dist\metalsync.json
echo   dist\README.md
echo ============================================
echo.
pause
exit /b 0

:error
echo.
echo ERROR: no se pudo generar el ejecutable.
echo.
pause
exit /b 1

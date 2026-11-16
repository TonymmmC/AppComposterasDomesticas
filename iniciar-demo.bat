@echo off
chcp 65001 > nul
title Compostera Inteligente - Lanzador de Demostración
color 0A

echo ===============================================================================
echo        🌱 SISTEMA DE MONITOREO DE COMPOSTERAS DOMÉSTICAS INTELIGENTES
echo                PROTOTIPADO, SIMULACIÓN 3D Y BACKEND REST
echo ===============================================================================
echo.

echo [1/3] Iniciando Servidor Backend REST (Express + TypeScript) en puerto 3000...
start "Backend REST - Compostera" cmd /k "cd backend && npm start"

timeout /t 2 /nobreak > nul

echo [2/3] Iniciando Simulador de Hardware ESP32 (Transmisión HTTP JSON)...
start "Simulador Hardware ESP32" cmd /k "cd simulador && node src/simulador.js"

timeout /t 2 /nobreak > nul

echo [3/3] Abriendo Simulación 3D Interactiva del Hardware en el Navegador...
start http://localhost:3000/3d

echo.
echo ===============================================================================
echo  ✔ DEMOSTRACIÓN EN MARCHA
echo  • Simulación 3D disponible en: http://localhost:3000/3d
echo  • Backend Express en:          http://localhost:3000
echo  • App Flutter (pestaña 4):     Ver pestaña 'Hardware 3D' en la app
echo ===============================================================================
echo.
pause

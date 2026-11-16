# Lanzador de Demostración Completa del Sistema de Composteras Domésticas
Write-Host "===============================================================================" -ForegroundColor Green
Write-Host "       🌱 SISTEMA DE MONITOREO DE COMPOSTERAS DOMÉSTICAS INTELIGENTES" -ForegroundColor Green
Write-Host "               PROTOTIPADO, SIMULACIÓN 3D Y BACKEND REST" -ForegroundColor Green
Write-Host "===============================================================================" -ForegroundColor Green
Write-Host ""

$baseDir = $PSScriptRoot

Write-Host "[1/3] Iniciando Servidor Backend REST (Express + TypeScript) en puerto 3000..." -ForegroundColor Cyan
Start-Process cmd -ArgumentList "/k cd /d `"$baseDir\backend`" && npm start"

Start-Sleep -Seconds 2

Write-Host "[2/3] Iniciando Simulador de Hardware ESP32..." -ForegroundColor Cyan
Start-Process cmd -ArgumentList "/k cd /d `"$baseDir\simulador`" && node src/simulador.js"

Start-Sleep -Seconds 2

Write-Host "[3/3] Abriendo Simulación 3D Interactiva en el Navegador..." -ForegroundColor Yellow
Start-Process "http://localhost:3000/3d"

Write-Host ""
Write-Host "✔ Demostración iniciada con éxito." -ForegroundColor Green
Write-Host "• Simulación 3D: http://localhost:3000/3d" -ForegroundColor White
Write-Host "• Backend: http://localhost:3000/salud" -ForegroundColor White
Write-Host "• App Flutter: pestaña 'Hardware 3D' disponible en la barra inferior" -ForegroundColor Yellow

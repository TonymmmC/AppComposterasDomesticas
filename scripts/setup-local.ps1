# Configuracion local del clon. Correr una sola vez despues de clonar.
#
#   powershell -ExecutionPolicy Bypass -File scripts/setup-local.ps1
#
# Marca como ignoradas las carpetas de trabajo personal, para que no aparezcan
# en git status ni se suban por error. Usa .git/info/exclude, que es local de
# cada clon y no viaja en el repositorio.

$ErrorActionPreference = 'Stop'

$raiz = Split-Path -Parent $PSScriptRoot

if (-not (Test-Path (Join-Path $raiz '.git'))) {
    Write-Error 'No hay repositorio git en esta carpeta.'
}

$excludePath = Join-Path $raiz '.git/info/exclude'

# Carpetas de trabajo personal de cada integrante.
$patrones = @('/Docs/', '/.notas/')

$actual = @()
if (Test-Path $excludePath) {
    $actual = Get-Content $excludePath
}

$agregados = 0
foreach ($patron in $patrones) {
    if ($actual -notcontains $patron) {
        Add-Content -Path $excludePath -Value $patron -Encoding utf8
        $agregados++
    }
}

if ($agregados -gt 0) {
    Write-Host "Exclusiones locales agregadas: $agregados"
} else {
    Write-Host 'Las exclusiones locales ya estaban configuradas.'
}

Write-Host 'Verificar con: git status --short'

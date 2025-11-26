# 🚀 Quick Start Script
# Este script automatiza el setup inicial de la app

Write-Host "🪞 Responsibility Mirror - Setup Script" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host ""

# Verificar Flutter
Write-Host "✓ Verificando Flutter..." -ForegroundColor Yellow
$flutterVersion = flutter --version 2>&1
if ($LASTEXITCODE -eq 0) {
    Write-Host "✓ Flutter instalado correctamente" -ForegroundColor Green
} else {
    Write-Host "✗ Flutter no encontrado. Por favor instala Flutter primero." -ForegroundColor Red
    exit 1
}

# Instalar dependencias
Write-Host ""
Write-Host "✓ Instalando dependencias..." -ForegroundColor Yellow
flutter pub get

if ($LASTEXITCODE -eq 0) {
    Write-Host "✓ Dependencias instaladas" -ForegroundColor Green
} else {
    Write-Host "✗ Error instalando dependencias" -ForegroundColor Red
    exit 1
}

# Generar código Hive
Write-Host ""
Write-Host "✓ Generando código de Hive..." -ForegroundColor Yellow
flutter pub run build_runner build --delete-conflicting-outputs

if ($LASTEXITCODE -eq 0) {
    Write-Host "✓ Código generado correctamente" -ForegroundColor Green
} else {
    Write-Host "✗ Error generando código" -ForegroundColor Red
    exit 1
}

# Verificar dispositivos
Write-Host ""
Write-Host "✓ Verificando dispositivos conectados..." -ForegroundColor Yellow
flutter devices

# Preguntar si desea ejecutar
Write-Host ""
$run = Read-Host "¿Deseas ejecutar la app ahora? (S/N)"
if ($run -eq "S" -or $run -eq "s") {
    Write-Host ""
    Write-Host "🚀 Ejecutando app..." -ForegroundColor Cyan
    flutter run
} else {
    Write-Host ""
    Write-Host "✓ Setup completado. Ejecuta 'flutter run' cuando estés listo." -ForegroundColor Green
}

Write-Host ""
Write-Host "💪 ¡Listo para crear disciplina!" -ForegroundColor Cyan

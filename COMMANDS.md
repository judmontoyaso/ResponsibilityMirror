# 🛠️ Comandos Útiles de Desarrollo

## Setup Inicial

```powershell
# Instalar dependencias
flutter pub get

# Generar código Hive
flutter pub run build_runner build --delete-conflicting-outputs

# Verificar todo está OK
flutter doctor -v
```

## Desarrollo

```powershell
# Ejecutar en modo debug (con hot reload)
flutter run

# Ejecutar en modo release (optimizado)
flutter run --release

# Ejecutar en modo profile (para análisis)
flutter run --profile

# Ver dispositivos conectados
flutter devices

# Limpiar build cache
flutter clean
```

## Hot Reload durante desarrollo

Cuando `flutter run` está activo:
- Presiona `r` → Hot reload (recarga cambios)
- Presiona `R` → Hot restart (reinicio completo)
- Presiona `q` → Salir
- Presiona `h` → Ver ayuda

## Análisis de Código

```powershell
# Analizar problemas en el código
flutter analyze

# Formatear código
dart format .

# Formatear archivo específico
dart format lib/screens/home_screen.dart
```

## Build y Release

```powershell
# Generar APK debug
flutter build apk --debug

# Generar APK release
flutter build apk --release

# Generar APK dividido por arquitectura (más pequeño)
flutter build apk --split-per-abi

# Generar App Bundle (para Play Store)
flutter build appbundle --release

# Analizar tamaño del APK
flutter build apk --analyze-size
```

## Testing

```powershell
# Ejecutar todos los tests
flutter test

# Ejecutar test específico
flutter test test/models/goal_test.dart

# Cobertura de tests
flutter test --coverage

# Ver cobertura en HTML
genhtml coverage/lcov.info -o coverage/html
```

## Debugging

```powershell
# Ver logs en tiempo real
flutter logs

# Inspeccionar app (DevTools)
flutter pub global activate devtools
flutter pub global run devtools

# Ejecutar en modo verbose
flutter run -v
```

## Hive (Base de datos)

```powershell
# Regenerar adaptadores Hive
flutter pub run build_runner build --delete-conflicting-outputs

# Modo watch (regenera automáticamente)
flutter pub run build_runner watch
```

## Instalación en Dispositivo

```powershell
# Instalar en dispositivo conectado
flutter install

# Instalar APK manualmente con ADB
adb install build\app\outputs\flutter-apk\app-release.apk

# Ver dispositivos ADB
adb devices

# Ver logs de Android
adb logcat
```

## Gestión de Dependencias

```powershell
# Actualizar dependencias
flutter pub upgrade

# Actualizar dependencias outdated
flutter pub outdated

# Agregar nueva dependencia
flutter pub add nombre_paquete

# Agregar dev dependency
flutter pub add --dev nombre_paquete
```

## Assets e Iconos

```powershell
# Generar iconos de launcher
flutter pub run flutter_launcher_icons

# Generar splash screen
flutter pub run flutter_native_splash:create
```

## Troubleshooting

```powershell
# Limpiar todo y reinstalar
flutter clean
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs

# Limpiar cache de Gradle (Android)
cd android
.\gradlew clean
cd ..

# Reiniciar ADB
adb kill-server
adb start-server
```

## Git

```powershell
# Preparar commit
git add .
git commit -m "tipo: mensaje descriptivo"

# Ver estado
git status

# Ver cambios
git diff

# Push a GitHub
git push origin main
```

## Rendimiento

```powershell
# Ejecutar performance overlay
flutter run --profile

# Analizar tiempo de compilación
flutter run --trace-startup
```

## Estructura de Proyecto

```powershell
# Ver árbol de archivos
tree /F lib

# Contar líneas de código
git ls-files | findstr "\.dart$" | ForEach-Object { Get-Content $_ } | Measure-Object -Line
```

## Shortcuts en VS Code

- `Ctrl + Shift + P` → Command Palette
- `Ctrl + .` → Quick Fix
- `F5` → Start Debugging
- `Shift + F5` → Stop Debugging
- `Ctrl + F5` → Run Without Debugging

## Scripts Personalizados

```powershell
# Setup completo
.\setup.ps1

# Build release
.\build-release.ps1

# Deploy
.\deploy.ps1
```

---

## 📚 Recursos Útiles

- [Flutter Docs](https://docs.flutter.dev/)
- [Dart Docs](https://dart.dev/guides)
- [Pub.dev](https://pub.dev/) - Paquetes
- [Flutter Awesome](https://flutterawesome.com/) - Recursos

## 🆘 Comandos de Emergencia

```powershell
# Si nada funciona:
flutter clean
flutter pub cache clean
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
flutter doctor
flutter run
```

---

💡 **Tip**: Añade estos comandos a tu PATH o crea aliases para mayor velocidad.

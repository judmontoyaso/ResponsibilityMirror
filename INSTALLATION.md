

# 🚀 Guía de Instalación y Ejecución

## Prerrequisitos

1. **Flutter SDK** instalado (3.0 o superior)
   ```bash
   flutter --version
   ```

2. **Android Studio** con:
   - Android SDK
   - Android SDK Platform-Tools
   - Android SDK Build-Tools
   - Android Emulator (opcional)

3. **Dispositivo Android** (físico o emulador)
   - API Level 21+ (Android 5.0+)

## 📦 Instalación

### Paso 1: Verificar instalación de Flutter

```powershell
flutter doctor
```

Asegúrate de que todos los checks estén en verde o con advertencias menores.

### Paso 2: Instalar dependencias

```powershell
cd c:\Users\Acer\Documents\Projects\ResponsibilityMirror
flutter pub get
```

### Paso 3: Generar código de Hive

```powershell
flutter pub run build_runner build --delete-conflicting-outputs
```

Este comando genera los archivos `.g.dart` necesarios para Hive (almacenamiento local).

### Paso 4: Conectar dispositivo o iniciar emulador

**Opción A: Dispositivo físico**
- Habilita "Depuración USB" en tu Android
- Conecta por USB
- Verifica conexión: `flutter devices`

**Opción B: Emulador**
```powershell
flutter emulators
flutter emulators --launch <emulator_id>
```

### Paso 5: Ejecutar la app

```powershell
flutter run
```

Para ejecutar en modo release (más rápido):
```powershell
flutter run --release
```

## 🏗️ Compilar APK

Para generar un APK instalable:

```powershell
# APK de depuración
flutter build apk --debug

# APK de producción (optimizado)
flutter build apk --release

# APK dividido por arquitectura (más pequeño)
flutter build apk --split-per-abi
```

El APK estará en: `build\app\outputs\flutter-apk\`

## 📱 Instalar APK en dispositivo

```powershell
# Instalar directamente
flutter install

# O manualmente con adb
adb install build\app\outputs\flutter-apk\app-release.apk
```

## 🔧 Solución de problemas comunes

### Error: "Gradle sync failed"
```powershell
cd android
.\gradlew clean
cd ..
flutter clean
flutter pub get
```

### Error: "MissingPluginException"
```powershell
flutter clean
flutter pub get
flutter run
```

### Error de permisos en Android
- Ve a Ajustes > Apps > Responsibility Mirror
- Habilita permisos de Notificaciones y Cámara

### Error: "Execution failed for task ':app:lintVitalRelease'"
Edita `android/build.gradle` y agrega en `android`:
```gradle
lintOptions {
    checkReleaseBuilds false
}
```

## 🎯 Características principales

Una vez instalada la app:

1. **Pantalla Inicio**: Ver resumen de metas del día
2. **Pantalla Espejo**: Vista estilo espejo con tus compromisos
3. **Check-in Diario**: Revisar cumplimiento nocturno
4. **Ajustes**: Configurar notificaciones y personalización

## 📝 Configuración inicial recomendada

1. Ir a **Ajustes**
2. Configurar tu nombre
3. Elegir modo de notificaciones (Brutal/Equilibrado/Suave)
4. Agregar tus primeras metas en **Espejo**
5. Configurar notificaciones personalizadas

## 🔔 Permisos requeridos

La app solicitará:
- ✅ **Notificaciones**: Para recordatorios motivacionales
- 📸 **Cámara** (opcional): Para modo espejo con cámara frontal

## 🆘 Soporte

Si tienes problemas:
1. Ejecuta `flutter doctor -v` y revisa errores
2. Verifica que el dispositivo esté en modo desarrollador
3. Intenta `flutter clean` y vuelve a compilar

## 📊 Comandos útiles

```powershell
# Ver logs en tiempo real
flutter logs

# Hot reload (recarga en caliente durante desarrollo)
# Presiona 'r' en la terminal donde corre flutter run

# Hot restart (reinicio completo)
# Presiona 'R' en la terminal

# Ver dispositivos conectados
flutter devices

# Analizar tamaño del APK
flutter build apk --analyze-size

# Ejecutar en modo profile (para análisis de rendimiento)
flutter run --profile
```

---

**¡Listo! Ya puedes empezar a usar tu Responsibility Mirror App 💪**

# 🎯 Inicio Rápido - Responsibility Mirror

## ⚡ Setup en 3 pasos

### 1️⃣ Instalar dependencias y generar código

```powershell
cd c:\Users\Acer\Documents\Projects\ResponsibilityMirror
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
```

### 2️⃣ Conectar dispositivo

**Opción A: Dispositivo físico Android**
- Habilita "Opciones de desarrollador" y "Depuración USB"
- Conecta por USB
- Verifica: `flutter devices`

**Opción B: Emulador**
```powershell
flutter emulators
flutter emulators --launch Pixel_5_API_34  # o tu emulador
```

### 3️⃣ Ejecutar

```powershell
flutter run
```

---

## 🛠️ Troubleshooting rápido

### Si da error de Gradle:
```powershell
cd android
.\gradlew clean
cd ..
flutter clean
flutter pub get
```

### Si no encuentra el SDK de Flutter:

Edita `android/local.properties` y cambia la ruta:
```properties
flutter.sdk=C:\\tu\\ruta\\a\\flutter
```

### Si falla build_runner:
```powershell
flutter clean
flutter pub cache repair
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
```

---

## 📱 Características principales

Una vez ejecutada la app:

1. **Inicio** - Ver resumen de metas y progreso del día
2. **Espejo** - Pantalla principal con efecto espejo y tus compromisos
3. **Check-in** - Revisión nocturna de cumplimiento
4. **Ajustes** - Configurar notificaciones y personalización

---

## 🔔 Configuración recomendada (primera vez)

1. Ve a **Ajustes** (⚙️)
2. Ingresa tu nombre
3. Elige modo de notificación:
   - **Brutal** = Estilo Goggins sin excusas
   - **Equilibrado** = Balance entre firmeza y compasión
   - **Suave** = Motivación compasiva
4. Configura horarios de notificaciones
5. Ve a **Espejo** (🪞) y agrega tu primera meta

---

## 📚 Documentación completa

- [INSTALLATION.md](./INSTALLATION.md) - Guía detallada de instalación
- [NEXT_STEPS.md](./NEXT_STEPS.md) - Próximos pasos y mejoras
- [COMMANDS.md](./COMMANDS.md) - Todos los comandos útiles
- [ROADMAP.md](./ROADMAP.md) - Planes futuros
- [IDEAS.md](./IDEAS.md) - Ideas de características

---

## 🚀 Script automático (Windows)

```powershell
.\setup.ps1
```

Este script hace todo automáticamente.

---

## 💪 ¡Listo para crear disciplina!

**"No esperes motivación, crea disciplina."** - David Goggins


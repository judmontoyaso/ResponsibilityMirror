# 📁 Estructura del Proyecto - Responsibility Mirror

## 🏗️ Estructura completa

```
ResponsibilityMirror/
│
├── 📄 pubspec.yaml                 # Dependencias y configuración Flutter
├── 📄 README.md                    # Documentación principal
├── 📄 LICENSE                      # Licencia MIT
├── 📄 .gitignore                   # Archivos a ignorar en Git
├── 📄 QUICKSTART.md               # Guía de inicio rápido
├── 📄 INSTALLATION.md             # Guía detallada de instalación
├── 📄 NEXT_STEPS.md               # Próximos pasos
├── 📄 COMMANDS.md                 # Comandos útiles
├── 📄 CONTRIBUTING.md             # Guía para contribuidores
├── 📄 ROADMAP.md                  # Planes futuros
├── 📄 IDEAS.md                    # Ideas de características
├── 📄 setup.ps1                   # Script de setup automático
│
├── 📂 lib/                        # Código fuente Flutter
│   ├── 📄 main.dart              # Punto de entrada
│   │
│   ├── 📂 config/
│   │   └── 📄 theme.dart         # Tema y colores
│   │
│   ├── 📂 models/                # Modelos de datos
│   │   ├── 📄 goal.dart          # Modelo de meta
│   │   ├── 📄 note.dart          # Sticky notes
│   │   ├── 📄 checkin.dart       # Check-in diario
│   │   └── 📄 notification_config.dart
│   │
│   ├── 📂 providers/             # Gestión de estado (Provider)
│   │   ├── 📄 goals_provider.dart
│   │   ├── 📄 notifications_provider.dart
│   │   └── 📄 settings_provider.dart
│   │
│   ├── 📂 screens/               # Pantallas de la app
│   │   ├── 📄 home_screen.dart   # Pantalla de inicio
│   │   ├── 📄 mirror_screen.dart # Espejo principal
│   │   ├── 📄 checkin_screen.dart # Check-in nocturno
│   │   └── 📄 settings_screen.dart # Ajustes
│   │
│   ├── 📂 widgets/               # Componentes reutilizables
│   │   ├── 📄 goal_card.dart
│   │   ├── 📄 mirror_goal_item.dart
│   │   └── 📄 add_goal_dialog.dart
│   │
│   ├── 📂 services/              # Servicios
│   │   └── 📄 notification_service.dart
│   │
│   └── 📂 utils/                 # Utilidades
│       └── 📄 quotes.dart        # 80+ frases motivacionales
│
├── 📂 android/                    # Configuración Android
│   ├── 📄 build.gradle           # Build principal
│   ├── 📄 settings.gradle        # Settings de Gradle
│   ├── 📄 local.properties       # Propiedades locales
│   ├── 📄 gradle.properties      # Propiedades de Gradle
│   │
│   └── 📂 app/
│       ├── 📄 build.gradle       # Build de la app
│       │
│       └── 📂 src/main/
│           ├── 📄 AndroidManifest.xml  # Manifest con permisos
│           │
│           └── 📂 kotlin/com/responsibilitymirror/app/
│               └── 📄 MainActivity.kt
│
└── 📂 assets/                     # Recursos estáticos
    ├── 📂 images/                # Imágenes
    ├── 📂 icon/                  # Iconos de la app
    └── 📂 quotes/                # Archivos de frases (futuro)
```

---

## 📊 Estadísticas del Proyecto

### Archivos creados
- **Dart**: 20+ archivos
- **Android**: 6 archivos de configuración
- **Documentación**: 8 archivos MD
- **Total**: 35+ archivos

### Líneas de código (estimado)
- **Dart**: ~2,500 líneas
- **Configuración**: ~300 líneas
- **Documentación**: ~1,500 líneas

### Características implementadas
- ✅ 4 pantallas completas
- ✅ Sistema de notificaciones
- ✅ Persistencia con Hive
- ✅ 3 modos motivacionales
- ✅ 80+ frases de Goggins
- ✅ Check-in diario
- ✅ Gestión de metas

---

## 🎯 Archivos clave

### Para empezar a desarrollar:
1. `lib/main.dart` - Entry point
2. `lib/screens/mirror_screen.dart` - Pantalla principal
3. `lib/utils/quotes.dart` - Frases motivacionales

### Para configurar:
1. `android/app/build.gradle` - Configuración Android
2. `pubspec.yaml` - Dependencias
3. `lib/config/theme.dart` - Colores y tema

### Para personalizar:
1. `lib/utils/quotes.dart` - Agrega tus frases
2. `lib/config/theme.dart` - Cambia colores
3. `android/app/src/main/AndroidManifest.xml` - Permisos

---

## 🔄 Archivos generados (no en Git)

Estos se generan automáticamente:

```
.dart_tool/
.packages
build/
*.g.dart          # Generados por build_runner
*.hive            # Base de datos local
.flutter-plugins
```

---

## 📦 Dependencias principales

### Producción:
- `flutter` - Framework
- `provider` - Estado
- `hive` - Base de datos
- `flutter_local_notifications` - Notificaciones
- `workmanager` - Tareas en segundo plano
- `google_fonts` - Tipografías
- `uuid` - IDs únicos

### Desarrollo:
- `build_runner` - Generación de código
- `hive_generator` - Generador Hive
- `flutter_launcher_icons` - Iconos

---

## 🚀 Próximos archivos a crear

### Versión 1.1:
- [ ] `lib/screens/camera_mirror_screen.dart` - Modo cámara
- [ ] `lib/widgets/stats_chart.dart` - Gráficos
- [ ] `lib/screens/history_screen.dart` - Historial detallado
- [ ] `test/` - Tests unitarios

### Versión 2.0:
- [ ] `lib/services/cloud_sync_service.dart` - Sincronización
- [ ] `lib/screens/community_screen.dart` - Social
- [ ] `lib/services/ai_service.dart` - IA

---

## 📝 Convenciones de nomenclatura

- **Archivos**: `snake_case.dart`
- **Clases**: `PascalCase`
- **Variables**: `camelCase`
- **Constantes**: `camelCase` con `const`
- **Privados**: prefijo `_`

---

## 🔗 Relaciones entre archivos

```
main.dart
  ├─→ providers/ (ChangeNotifier)
  │    ├─→ models/ (Data)
  │    └─→ services/ (Business Logic)
  │
  └─→ screens/ (UI)
       ├─→ widgets/ (Components)
       ├─→ config/theme.dart
       └─→ utils/quotes.dart
```

---

## 💡 Tips para navegar el código

1. **Buscar una característica**: Empieza en `screens/`
2. **Modificar datos**: Ve a `models/`
3. **Cambiar lógica**: Revisa `providers/`
4. **Ajustar UI**: Mira `widgets/`
5. **Agregar frases**: Edita `utils/quotes.dart`

---

**Proyecto creado con ❤️ y disciplina**

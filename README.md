# 🪞 Responsibility Mirror App

> **Inspirada en David Goggins** - Una app Android para mantener tus compromisos diarios mediante un "espejo digital de responsabilidad".

[![Flutter](https://img.shields.io/badge/Flutter-3.0+-02569B?logo=flutter)](https://flutter.dev)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](./LICENSE)
[![Platform](https://img.shields.io/badge/Platform-Android-brightgreen)](https://www.android.com)

---

## 📖 Tabla de Contenidos

- [Descripción](#-descripción)
- [Características](#-características)
- [Screenshots](#-screenshots)
- [Instalación](#-instalación)
- [Uso](#-uso)
- [Arquitectura](#-arquitectura)
- [Contribuir](#-contribuir)
- [Roadmap](#-roadmap)
- [Licencia](#-licencia)

---

## 🎯 Descripción

**Responsibility Mirror** digitaliza el famoso método de David Goggins de escribir metas en un espejo real. La app te ayuda a:

- ✅ Visualizar tus metas diarias en un "espejo digital"
- 🔔 Recibir notificaciones motivacionales personalizadas
- 💪 Mantener disciplina con recordatorios estilo Goggins
- 📊 Realizar check-ins diarios de responsabilidad
- 🎯 Establecer reglas personales permanentes

> "El único enemigo que no puede derrotarte es el que vive dentro de ti." — David Goggins

---

## ✨ Características

### 🪞 Pantalla Espejo
- Fondo estilo espejo con efecto de cristal
- Visualización clara de metas y reglas personales
- Sistema de prioridades (baja, media, alta)
- Metas diarias vs reglas permanentes

### 🔔 Notificaciones Inteligentes
**3 Modos disponibles:**

1. **Brutal (Goggins)**: Sin excusas, directo al punto
   - "El espejo no escucha excusas"
   - "Haz lo que dijiste, no lo que sientes"
   - "40% es cuando tu mente dice que terminaste"

2. **Equilibrado**: Balance entre firmeza y compasión
   - "Tus metas te esperan. Empieza ahora"
   - "El éxito es la suma de pequeños esfuerzos"

3. **Suave**: Motivación compasiva
   - "Avanza aunque sea un paso"
   - "El tú de mañana te agradecerá"

### ✅ Check-in Diario
- Revisión nocturna de cumplimiento
- Registro de estado de ánimo
- Notas de reflexión
- Historial completo con estadísticas
- Porcentaje de cumplimiento

### ⚙️ Personalización
- Configurar nombre personalizado
- Horarios de notificaciones customizables
- Mensajes personalizados
- Modo cámara experimental

---

## 📸 Screenshots

*(Aquí irían capturas de pantalla de la app)*

---

## 🚀 Instalación

### Prerrequisitos
- Flutter 3.0+
- Android Studio
- Dispositivo Android 5.0+ (API 21+)

### Setup Rápido

```powershell
# Clonar repositorio
git clone https://github.com/tu-usuario/responsibility-mirror.git
cd responsibility-mirror

# Ejecutar script de setup (Windows)
.\setup.ps1

# O manualmente:
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
flutter run
```

Ver [INSTALLATION.md](./INSTALLATION.md) para instrucciones detalladas.

---

## 📱 Uso

### Primera vez

1. **Configura tu perfil** en Ajustes
2. **Elige tu modo** de notificaciones (Brutal/Equilibrado/Suave)
3. **Agrega tu primera meta** en la pantalla Espejo
4. **Programa notificaciones** según tus horarios

### Flujo diario

**Mañana:**
1. Revisa tus metas en el Espejo
2. Marca las que completes durante el día

**Tarde:**
1. Recibe recordatorios motivacionales
2. Mantén el foco en tus compromisos

**Noche:**
1. Realiza tu check-in diario (21:00)
2. Reflexiona sobre el día
3. Prepárate para mañana

---

## 🏗️ Arquitectura

### Stack Tecnológico
- **Framework**: Flutter 3.0+
- **Estado**: Provider
- **Almacenamiento**: Hive (NoSQL local)
- **Notificaciones**: flutter_local_notifications + WorkManager
- **UI**: Material Design 3

### Estructura del proyecto

```
lib/
├── main.dart                 # Entry point
├── config/
│   └── theme.dart           # Tema y colores
├── models/
│   ├── goal.dart            # Modelo de meta
│   ├── note.dart            # Sticky notes
│   ├── checkin.dart         # Check-in diario
│   └── notification_config.dart
├── providers/
│   ├── goals_provider.dart
│   ├── notifications_provider.dart
│   └── settings_provider.dart
├── screens/
│   ├── home_screen.dart     # Pantalla inicio
│   ├── mirror_screen.dart   # Espejo principal
│   ├── checkin_screen.dart  # Check-in nocturno
│   └── settings_screen.dart
├── widgets/
│   ├── goal_card.dart
│   ├── mirror_goal_item.dart
│   └── add_goal_dialog.dart
├── services/
│   └── notification_service.dart
└── utils/
    └── quotes.dart          # Frases motivacionales
```

### Patrones de diseño
- **Provider**: Gestión de estado
- **Repository**: Abstracción de datos
- **Service**: Lógica de negocio
- **Widget composition**: UI modular

---

## 🤝 Contribuir

¡Contribuciones son bienvenidas! Ver [CONTRIBUTING.md](./CONTRIBUTING.md)

### Quick Start para contribuidores

1. Fork el repo
2. Crea tu rama: `git checkout -b feature/nueva-feature`
3. Commit: `git commit -m 'feat: agregar nueva feature'`
4. Push: `git push origin feature/nueva-feature`
5. Abre un Pull Request

---

## 🗺️ Roadmap

Ver [ROADMAP.md](./ROADMAP.md) para planes futuros.

### Próximas features (v1.1)
- [ ] Modo cámara frontal funcional
- [ ] Selfie diaria de responsabilidad
- [ ] Estadísticas avanzadas
- [ ] Widgets de Android
- [ ] Racha de días cumplidos

### Ideas futuras
Ver [IDEAS.md](./IDEAS.md) para todas las ideas propuestas.

---

## 📄 Licencia

Este proyecto está bajo la licencia MIT. Ver [LICENSE](./LICENSE) para más detalles.

---

## 🙏 Agradecimientos

- **David Goggins** por la inspiración y filosofía
- **Comunidad Flutter** por las herramientas
- **Todos los contribuidores** que mejoran esta app

---

## 📞 Contacto

- **Issues**: [GitHub Issues](../../issues)
- **Discussions**: [GitHub Discussions](../../discussions)

---

## ⭐ Star History

Si este proyecto te ayuda, ¡considera darle una estrella! ⭐

---

<div align="center">

**"No esperes motivación, crea disciplina."**

💪 Hecho con disciplina y Flutter

</div>

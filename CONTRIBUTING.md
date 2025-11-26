# Contributing to Responsibility Mirror

¡Gracias por considerar contribuir a este proyecto! 🎉

## 🤝 Cómo contribuir

### Reportar bugs

1. Verifica que el bug no esté ya reportado en [Issues](../../issues)
2. Crea un nuevo issue con:
   - Descripción clara del problema
   - Pasos para reproducirlo
   - Comportamiento esperado vs actual
   - Screenshots si es posible
   - Versión de la app y dispositivo

### Sugerir características

1. Revisa [IDEAS.md](./IDEAS.md) y [ROADMAP.md](./ROADMAP.md)
2. Abre un issue con etiqueta `enhancement`
3. Describe claramente la característica y su valor

### Enviar código

1. Fork el repositorio
2. Crea una rama para tu feature: `git checkout -b feature/mi-feature`
3. Realiza tus cambios
4. Commit con mensajes descriptivos
5. Push a tu fork
6. Abre un Pull Request

## 📝 Guías de código

### Flutter/Dart

- Sigue las [Dart style guidelines](https://dart.dev/guides/language/effective-dart/style)
- Usa `flutter analyze` antes de commit
- Formatea con `dart format .`
- Nomenclatura:
  - Clases: `PascalCase`
  - Variables/funciones: `camelCase`
  - Constantes: `camelCase` con `const`
  - Privados: prefijo `_`

### Estructura de archivos

```
lib/
├── models/          # Modelos de datos
├── providers/       # Estado (Provider)
├── screens/         # Pantallas completas
├── widgets/         # Componentes reutilizables
├── services/        # Servicios (notificaciones, etc)
├── utils/           # Utilidades y helpers
└── config/          # Configuración y temas
```

### Commits

Formato: `tipo: descripción`

Tipos:
- `feat`: Nueva característica
- `fix`: Corrección de bug
- `docs`: Documentación
- `style`: Formato (no afecta código)
- `refactor`: Refactorización
- `test`: Tests
- `chore`: Tareas de mantenimiento

Ejemplos:
- `feat: agregar modo cámara al espejo`
- `fix: corregir crash en notificaciones nocturnas`
- `docs: actualizar README con instrucciones iOS`

## 🧪 Tests

- Escribe tests para nuevas características
- Mantén cobertura > 70%
- Ejecuta `flutter test` antes de PR

## 📄 Documentación

- Documenta funciones públicas
- Actualiza README si es necesario
- Comenta código complejo

## 🎨 UI/UX

- Mantén consistencia con el diseño actual
- Considera modo oscuro
- Prueba en diferentes tamaños de pantalla
- Accesibilidad es importante

## ⚡ Rendimiento

- Evita rebuilds innecesarios
- Usa `const` donde sea posible
- Optimiza imágenes y assets
- Profile antes de optimizar

## 🔒 Seguridad

- No commits de secrets o API keys
- Valida inputs del usuario
- Sanitiza datos antes de guardar

## 📱 Plataformas

Actualmente soportamos:
- ✅ Android
- 🚧 iOS (en roadmap)
- 🚧 Web (en roadmap)

## 💬 Comunicación

- Issues: Para bugs y features
- Discussions: Para ideas y preguntas
- Pull Requests: Para contribuciones de código

## 📜 Licencia

Al contribuir, aceptas que tu código se licencie bajo MIT License.

---

**¡Gracias por ayudar a mejorar Responsibility Mirror! 💪**

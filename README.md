# Racha Diaria 📱

Una aplicación Flutter para rastrear hábitos diarios y mantener rachas de consistencia.

## 🚀 Características

- **Seguimiento de Racha**: Mantén un registro de tu racha actual y la más larga
- **Hábitos Personalizables**: Rastrea diferentes hábitos como ejercicio, lectura, meditación, etc.
- **Interfaz Moderna**: Diseño atractivo con Material Design 3
- **Notificaciones Visuales**: Feedback inmediato al completar hábitos
- **Estadísticas**: Visualiza tu progreso diario

## 🛠️ Instalación

### Prerrequisitos

- Flutter SDK (versión 3.0 o superior)
- Dart SDK
- Un dispositivo o emulador para ejecutar la aplicación

### Pasos de Instalación

1. **Clona el repositorio**:
   ```bash
   git clone <tu-repositorio>
   cd racha_diaria_app
   ```

2. **Instala las dependencias**:
   ```bash
   flutter pub get
   ```

3. **Ejecuta la aplicación**:
   ```bash
   flutter run
   ```

## 📱 Uso de la Aplicación

1. **Pantalla Principal**: Ve tu racha actual y estadísticas
2. **Completar Hábitos**: Toca cualquier hábito para marcarlo como completado
3. **Reiniciar Racha**: Usa el botón "Reiniciar Racha" para empezar de nuevo
4. **Seguimiento**: La aplicación mantiene automáticamente el registro de tu progreso

## 🎨 Personalización

La aplicación incluye 4 hábitos predefinidos:
- 🏋️ Ejercicio
- 📚 Leer
- 🧘 Meditar
- ✍️ Escribir

Puedes modificar estos hábitos editando el archivo `lib/main.dart` en la sección `_habits`.

## 🏗️ Estructura del Proyecto

```
lib/
├── main.dart          # Archivo principal con toda la lógica de la aplicación
test/
├── widget_test.dart   # Pruebas unitarias
```

## 🧪 Pruebas

Ejecuta las pruebas con:
```bash
flutter test
```

## 📦 Dependencias

Esta aplicación utiliza solo las dependencias básicas de Flutter:
- `flutter/material.dart` - Para la interfaz de usuario
- `flutter_test` - Para las pruebas (solo en desarrollo)

## 🚀 Próximas Mejoras

- [ ] Persistencia de datos con SharedPreferences
- [ ] Notificaciones push para recordatorios
- [ ] Gráficos de progreso
- [ ] Personalización de hábitos
- [ ] Temas oscuros
- [ ] Exportar datos

## 📄 Licencia

Este proyecto está bajo la Licencia MIT. Ver el archivo `LICENSE` para más detalles.

## 🤝 Contribuciones

Las contribuciones son bienvenidas. Por favor:
1. Fork el proyecto
2. Crea una rama para tu feature (`git checkout -b feature/AmazingFeature`)
3. Commit tus cambios (`git commit -m 'Add some AmazingFeature'`)
4. Push a la rama (`git push origin feature/AmazingFeature`)
5. Abre un Pull Request

## 📞 Contacto

Si tienes preguntas o sugerencias, no dudes en contactarme.

---

¡Mantén tu racha y construye mejores hábitos! 💪
# 🏥 MediAsis

<div align="center">
  <img src="assets/images/logo.png" alt="MediAsis Logo" width="200">
  
  **Tu Asistencia Médica Integral**
  
  [![Flutter](https://img.shields.io/badge/Flutter-3.19.0-02569B?style=flat&logo=flutter)](https://flutter.dev)
  [![Dart](https://img.shields.io/badge/Dart-3.4.0-0175C2?style=flat&logo=dart)](https://dart.dev)
  [![Platform](https://img.shields.io/badge/Platform-Android-green?style=flat&logo=android)](https://www.android.com)
  [![License](https://img.shields.io/badge/License-MIT-blue?style=flat)](LICENSE)
</div>

---

## 📱 Descripción

**MediAsis** es una aplicación médica profesional para dispositivos Android, diseñada para la gestión integral de historias clínicas y consultas médicas. La aplicación ofrece una interfaz moderna e intuitiva que facilita el trabajo diario de profesionales de la salud.

### ✨ Características Principales

- 🏠 **Dashboard Informativo**: Vista rápida de estadísticas y consultas pendientes del día
- 📋 **Gestión de Consultas**: Registro completo de consultas médicas con diagnóstico CIE-10
- 📁 **Historias Clínicas**: Expedientes electrónicos completos con todos los antecedentes
- 🔄 **Evoluciones Médicas**: Seguimiento detallado del progreso del paciente
- 💬 **Comentarios Médicos**: Notas y observaciones clínicas
- 🔍 **Búsqueda Avanzada**: Localización rápida de pacientes y expedientes
- 📱 **Diseño Profesional**: Interfaz Material Design 3 con tema médico coherente

---

## 🚀 Instalación

### Requisitos Previos

- Flutter SDK 3.19.0 o superior
- Dart SDK 3.4.0 o superior
- Android SDK (API 21+)
- Un dispositivo Android o emulador

### Desde el Código Fuente

```bash
# Clonar el repositorio
git clone https://github.com/tu-usuario/mediasis.git
cd mediasis

# Instalar dependencias
flutter pub get

# Ejecutar la aplicación
flutter run

# Construir APK de producción
flutter build apk --release
```

### Descarga Directa

Descarga la última versión desde la sección de [Releases](https://github.com/tu-usuario/mediasis/releases).

---

## 📖 Guía de Uso

### Estructura de la Aplicación

La aplicación está organizada en tres secciones principales:

#### 1. Inicio (Dashboard)
- Vista rápida de estadísticas
- Consultas programadas para hoy
- Notificaciones de consultas pendientes

#### 2. Consultas
- Lista completa de consultas médicas
- Filtros por estado (Pendiente, Completada, etc.)
- Formulario completo para nuevas consultas:
  - Datos del paciente
  - Motivo de consulta
  - Síntomas y antecedentes
  - Exploración física
  - Diagnóstico con código CIE-10
  - Tratamiento y medicamentos
  - Indicaciones y pronóstico

#### 3. Historias Clínicas
- Expedientes electrónicos completos
- Antecedentes heredofamiliares y personales
- Antecedentes quirúrgicos, alérgicos y traumáticos
- Inmunizaciones y medicamentos actuales
- Evoluciones médicas
- Comentarios y notas médicas

### Flujo de Trabajo

1. **Nueva Consulta**: Al crear una consulta, si el paciente no tiene historia clínica, se crea automáticamente.
2. **Evoluciones**: Desde la historia clínica, puede agregar evoluciones, comentarios o procedimientos.
3. **Estados**: Las consultas pueden cambiar de estado: Pendiente → En curso → Completada.

---

## 🛠️ Arquitectura

```
mediasis/
├── lib/
│   ├── main.dart              # Punto de entrada
│   ├── models/                # Modelos de datos
│   │   ├── paciente.dart
│   │   ├── consulta.dart
│   │   ├── historia_clinica.dart
│   │   └── evolucion.dart
│   ├── providers/             # Estado de la app (Provider)
│   │   ├── pacientes_provider.dart
│   │   ├── consultas_provider.dart
│   │   └── historias_provider.dart
│   ├── screens/               # Pantallas
│   │   ├── home_screen.dart
│   │   ├── consultas_screen.dart
│   │   ├── historias_screen.dart
│   │   └── ...
│   ├── widgets/               # Widgets reutilizables
│   ├── database/              # SQLite helper
│   ├── theme/                 # Tema y colores
│   └── utils/                 # Utilidades
├── assets/
│   └── images/                # Logo e imágenes
├── android/                   # Configuración Android
└── .github/workflows/         # CI/CD con GitHub Actions
```

### Tecnologías Utilizadas

| Tecnología | Uso |
|------------|-----|
| **Flutter** | Framework de UI |
| **Provider** | Gestión de estado |
| **SQLite** | Base de datos local |
| **Material Design 3** | Sistema de diseño |

---

## 🎨 Tema y Diseño

La aplicación utiliza una paleta de colores profesional basada en el logo:

- **Primary Blue**: `#0066A8` - Color principal de la marca
- **Primary Teal**: `#4BA3A8` - Color secundario para acentos
- **Success Green**: `#4CAF50` - Estados exitosos
- **Error Red**: `#E53935` - Errores y alertas

---

## 🧪 Testing

```bash
# Ejecutar todos los tests
flutter test

# Ejecutar tests con cobertura
flutter test --coverage

# Generar reporte de cobertura
genhtml coverage/lcov.info -o coverage/html
```

---

## 📦 Build y Distribución

### Build Local

```bash
# APK Debug
flutter build apk --debug

# APK Release
flutter build apk --release

# APK por arquitectura (recomendado)
flutter build apk --release --split-per-abi

# App Bundle para Google Play
flutter build appbundle --release
```

### CI/CD con GitHub Actions

El proyecto incluye configuración automática de CI/CD:

1. **Análisis**: Se ejecuta en cada push/PR
2. **Build**: Genera APKs automáticamente
3. **Release**: Crea releases automáticamente con tags

```bash
# Crear un nuevo release
git tag v1.0.0
git push origin v1.0.0
```

---

## 🤝 Contribuir

1. Fork el repositorio
2. Crea una rama para tu feature (`git checkout -b feature/nueva-funcionalidad`)
3. Commit tus cambios (`git commit -m 'Agrega nueva funcionalidad'`)
4. Push a la rama (`git push origin feature/nueva-funcionalidad`)
5. Abre un Pull Request

### Guías de Contribución

- Sigue las convenciones de código de Dart/Flutter
- Asegúrate de que todos los tests pasen
- Documenta las nuevas funcionalidades
- Actualiza el CHANGELOG.md

---

## 📄 Licencia

Este proyecto está bajo la Licencia MIT. Ver el archivo [LICENSE](LICENSE) para más detalles.

---

## 👨‍💻 Autor

Desarrollado con ❤️ para profesionales de la salud.

---

## 🙏 Agradecimientos

- Flutter Team por el excelente framework
- Material Design por el sistema de diseño
- Todos los contribuidores

---

<div align="center">
  <sub>MediAsis - Tu Asistencia Médica Integral</sub>
</div>

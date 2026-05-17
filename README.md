# MyMsg 🚀

Una aplicación de mensajería multiplataforma (Web y Móvil) desarrollada con **Flutter** y **Go**, diseñada con Clean Architecture y enfocada en una interfaz moderna y rápida (estilo Neon Cyan Cyberpunk).

## 🌟 Características Principales

*   **Sincronización en Tiempo Real**: Comunicación mediante WebSockets.
*   **Diseño Neon Premium**: Interfaz oscura con alto contraste, bordes neón y estética futurista.
*   **Transferencia de Archivos**: Envío de imágenes, documentos, audios y más.
*   **Vistas Previas Integradas**: Las imágenes se cargan directamente en el chat.
*   **Gestión de Documentos**: Archivos (PDF, TXT, MD, código, etc.) con tarjetas de alto contraste y opciones de "Ver" y "Bajar".
*   **Almacenamiento Local Directo**: Descarga de archivos directamente a tu dispositivo (soporte completo para Android 11+).
*   **Soporte Multidispositivo**: Desarrollado con Flutter para Móvil (Android/iOS) y Cliente Web.

## 🏗️ Arquitectura y Tecnologías

### Frontend (Flutter)
*   **Clean Architecture**: Separación estricta entre `Domain`, `Data` y `Presentation`.
*   **Atomic Design**: Organización de widgets en `atoms`, `molecules` y `organisms`.
*   **State Management**: `flutter_bloc` para el manejo reactivo del estado del chat.
*   **Almacenamiento Local**: `shared_preferences` para auto-reconexión y guardado de sesión.

### Backend (Go)
*   **Servidor WebSocket**: Manejo eficiente de múltiples conexiones simultáneas.
*   **Proxy MinIO**: Almacenamiento seguro de objetos y previsualización de imágenes directamente desde los buckets de S3.

## ⚙️ Requisitos Previos

*   [Flutter SDK](https://flutter.dev/docs/get-started/install) (versión 3.0 o superior)
*   [Go](https://golang.org/doc/install) (1.20 o superior)
*   Tailscale (opcional, para conexiones LAN globales)
*   Contenedor MinIO (para almacenamiento de archivos)

## 🚀 Instalación y Ejecución

### 1. Backend (Go)
Asegúrate de que MinIO esté ejecutándose y luego inicia el servidor:
```bash
cd backend/cmd/api
go run main.go
```
*El servidor correrá en el puerto `:8081`.*

### 2. Frontend (Flutter)
Instala las dependencias y corre el proyecto:
```bash
flutter pub get
flutter run
```
*Puedes probarlo en un dispositivo Android, iOS o en Google Chrome para la versión Web.*

## 🔒 Estructura del Repositorio

Aclaración sobre los archivos de Flutter: Aunque parezca que solo importa `lib/` y `pubspec.yaml`, las carpetas `android/`, `ios/` y `web/` son **fundamentales** porque contienen las configuraciones nativas de permisos (como el acceso de escritura `MANAGE_EXTERNAL_STORAGE` en Android 11+) y los iconos de la aplicación.

---
**Desarrollado como proyecto académico de Ingeniería de Software - ESPE.**

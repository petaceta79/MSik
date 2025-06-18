# MSik

Un reproductor de música local, el cual permite crear playlists y descargar audios de YouTube.

## 🧭 Contenidos

- [Descripción](#descripción)  
- [Características](#características)  
- [Instalación](#instalación)  
- [Tecnologías](#tecnologías) 
- [Créditos](#créditos)

## Descripción

Es un reproductor de música que guarda todos los audios de forma local. Los archivos descargados desde YouTube se almacenan en formato MP3, ocupando poco espacio. Estos se guardan en carpetas privadas, por lo que no son accesibles desde fuera de la aplicación.

Permite reproducir los audios de forma individual o agruparlos en listas de reproducción (playlists).

Durante la reproducción, ofrece las funciones básicas de cualquier reproductor de música, como saltar canciones, repetir en bucle, entre otras.

## Instalación

El proyecto se puede abrir desde el IDE preferido tal como vscode o android studio. En caso de querer isntalar la app, la apk esta dentro del proyecto en la carpeta release

## Tecnologías

El proyecto está desarrollado usando las siguientes tecnologías y herramientas:

- **🔧 Lenguaje**: Dart
- **📱 Framework**: Flutter
- **📦 Gestión de dependencias**: Pub

### Dependencias principales

#### Reproducción de Audio
- `just_audio` (^0.10.4) - Reproductor de audio flexible
- `audio_video_progress_bar` (^2.0.3) - Barra de progreso para medios

#### Almacenamiento
- `shared_preferences` (^2.5.3) - Almacenamiento persistente clave-valor
- `path_provider` (^2.1.5) - Acceso a rutas del sistema

#### Multimedia
- `file_picker` (^10.2.0) - Selección de archivos multimedia
- `ffmpeg_kit_flutter_new` (^2.0.0) - Procesamiento avanzado de audio/video

#### Integraciones
- `youtube_explode_dart` (^2.4.2) - Extracción de datos de YouTube

#### UI
- `cupertino_icons` (^1.0.8) - Iconos estilo iOS

### Notas
- Todas las dependencias usan la última versión estable al momento de desarrollo
- Algunas dependencias como `ffmpeg_kit_flutter_new` requieren configuración adicional para iOS/Android

## Créditos

- 👤 **[Norman](https://github.com/petaceta79)**

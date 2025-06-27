# MSik

Un reproductor de música local, el cual permite crear playlists y descargar audios de YouTube.

## 🧭 Contenidos

- [Objetivos](#Objetivos) 
- [Descripción](#descripción)  
- [Características](#características)  
- [Instalación](#instalación)  
- [Tecnologías](#tecnologías) 
- [Créditos](#créditos)

## Objetivos

El objetivo es actualizar mucho más esta app y llegar a publicarla en alguna plataforma.

## Descripción

Es un reproductor de música que guarda todos los audios de forma local. Los archivos descargados desde YouTube se almacenan en formato MP3, ocupando poco espacio. Estos se guardan en carpetas privadas, por lo que no son accesibles desde fuera de la aplicación.

Permite reproducir los audios de forma individual o agruparlos en listas de reproducción (playlists).

Durante la reproducción, ofrece las funciones básicas de cualquier reproductor de música, como saltar canciones, repetir en bucle, entre otras.

## Instalación

El proyecto puede abrirse desde el IDE preferido, como VSCode o Android Studio. En caso de querer instalar la app, está planeado poner el archivo APK disponible en alguna plataforma de distribución una vez esté finalizada.

## Tecnologías

El proyecto está desarrollado usando las siguientes tecnologías y herramientas:

- ** Lenguaje**: Dart
- ** Framework**: Flutter
- ** Gestión de dependencias**: Pub

### Dependencias principales

#### Reproducción de Audio
- [`just_audio`](https://pub.dev/packages/just_audio) ^0.10.4 - Reproductor de audio flexible
- [`audio_video_progress_bar`](https://pub.dev/packages/audio_video_progress_bar) ^2.0.3 - Barra de progreso interactiva

#### Almacenamiento
- [`shared_preferences`](https://pub.dev/packages/shared_preferences) ^2.5.3 - Almacenamiento clave-valor
- [`path_provider`](https://pub.dev/packages/path_provider) ^2.1.5 - Acceso a rutas del sistema

#### Multimedia
- [`file_picker`](https://pub.dev/packages/file_picker) ^10.2.0 - Selección de archivos
- [`ffmpeg_kit_flutter_new`](https://pub.dev/packages/ffmpeg_kit_flutter_new) ^2.0.0 - Procesamiento de audio/video

#### Integraciones
- [`youtube_explode_dart`](https://pub.dev/packages/youtube_explode_dart) ^2.4.2 - Extracción de datos de YouTube

#### UI
- [`font_awesome_flutter`](https://pub.dev/packages/font_awesome_flutter) ^10.8.0 - Iconos profesionales
- [`flutter_screenutil`](https://pub.dev/packages/flutter_screenutil) ^5.9.3 - Responsividad

## Créditos

- 👤 **[Norman](https://github.com/petaceta79)**

import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'utilsSongPlaylist.dart';
import 'package:file_picker/file_picker.dart';

// Devuelve una lista con el path de todos los archivos de la carpeta songs
Future<List<String>> obtenerPathsCanciones() async {
  // Obtener directorio privado de la app
  final baseDir = await getApplicationDocumentsDirectory();

  // Ruta de la carpeta "songs"
  final songsDir = Directory('${baseDir.path}/songs');

  // Crear carpeta si no existe
  if (!await songsDir.exists()) {
    await songsDir.create(recursive: true);
    print('Carpeta creada');
  }

  // Obtener archivos de la carpeta (solo archivos regulares, no subdirectorios)
  final archivos = await songsDir.list().toList();

  // Obtenemos path de cada archivo
  final paths = archivos
      .map((file) => file.path)
      .toList();

  return paths;
}

// Abre un seleccionador de archivos, lo copia en songs y lo annade al diccionario
Future<void> pickAndCopyFileToSongs() async {
  // Abre el selector de archivos
  FilePickerResult? result = await FilePicker.platform.pickFiles();

  if (result != null && result.files.single.path != null) {
    // Obtén el archivo seleccionado
    String selectedFilePath = result.files.single.path!; // path seleccionado
    File selectedFile = File(selectedFilePath);

    // Obtén el directorio interno donde guardar la carpeta 'songs'
    final baseDir = await getApplicationDocumentsDirectory();
    Directory songsDir = Directory('${baseDir.path}/songs');

    // Crea la carpeta songs si no existe
    if (!await songsDir.exists()) {
      await songsDir.create(recursive: true);
    }

    // Define la ruta destino dentro de la carpeta songs
    String fileName = selectedFile.uri.pathSegments.last;
    String destPath = '${songsDir.path}/$fileName';

    // Guardar en dic
    if (!await isSongSaved(fileName)) {
      await selectedFile.copy(destPath);
      await saveSongNameValue(fileName, destPath);
    }
    else {
      print("ya existe");
    }
  } else {
    print('No se seleccionó ningún archivo');
  }
}

// Elimina el archivo de la cancion y su entrada en el diccionario
Future<void> deleteSongFile(String songName) async {
  // Obtiene el directorio interno donde está la carpeta 'songs'
  final filePath = await getSongUrlfile(songName);

  if (filePath != "-1") {
    // Obtener le archivo
    File fileToDelete = File(filePath);

    // Verifica si el archivo existe antes de eliminarlo
    if (await fileToDelete.exists()) {
      await fileToDelete.delete();
    }
    await deleteSong(songName); // borrar la entrada igualmente
  }
}

// Borra todos los archvios y entradas del diccionario
Future<void> borrarTodasLasCancionesYArchivos() async {
  // Corregir primero
  corregirCanciones();

  // Paso 1: Borrar todos los archivos dentro de /songs
  final paths = await obtenerPathsCanciones();
  for (final path in paths) {
    final file = File(path);
    if (await file.exists()) {
      await file.delete();
    }
  }

  // Paso 2: Obtener canciones que aún están en SharedPreferences
  final cancionesGuardadas = await allSavedSongs();

  // Paso 3: Borrar todas las entradas del diccionario
  for (final nombre in cancionesGuardadas) {
    await deleteSong(nombre);
  }
}

// Corrige incoerencias en la app
// Agrega al diccionario los archivos sin entradas
// elimina del diccionario las canciones sin url asignada
Future<void> corregirCanciones() async {
  final pathsFisicos = await obtenerPathsCanciones();
  final urlsGuardadas = await getAllSavedSongUrls();

  // Paso 1: Eliminar URLs guardadas que no existen físicamente
  for (final url in urlsGuardadas) {
    if (!pathsFisicos.contains(url)) {
      final songName = await getSongNameFromUrl(url);
      if (songName != null) {
        await deleteSong(songName);
        print('🗑️ Eliminada entrada inválida: $songName -> $url');
      }
    }
  }

  // Paso 2: Agregar archivos que existen pero no están registrados
  for (final path in pathsFisicos) {
    if (!urlsGuardadas.contains(path)) {
      final fileName = path.split('/').last;
      final songName = fileName; // Usa el nombre del archivo como identificador
      await saveSongNameValue(songName, path);
      print('✅ Registrada nueva canción: $songName -> $path');
    }
  }
}

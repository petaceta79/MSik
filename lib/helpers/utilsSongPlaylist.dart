import 'package:shared_preferences/shared_preferences.dart';



// Sistema de prefijos para coexistir:
// Canciones song_...
// Playlist playlist_...
// Info playlists recurrentes ultPlaylist_
// Info canciones recurrentes ultCanciones_



// Generales
// Devuelve una lista todas las keys del diccionario
Future<List<String>> allKeys() async {
  final prefs = await SharedPreferences.getInstance();

  return prefs.getKeys().toList();
}

// Borra todas las claves del SharedPreferences
Future<void> deleteAllKeys() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.clear();
}



// Canciones
// Devuelve una lista con el nombre de todas las cancinoes del diccionario
Future<List<String>> allSavedSongs() async {
  final prefs = await SharedPreferences.getInstance();
  final keys = prefs.getKeys();
  final songNames = <String>[];

  for (var key in keys) {
    if (key.startsWith('song_')) {
      final name = key.substring(5); // Quita el prefijo "song_"
      songNames.add(name);
    }
  }

  return songNames;
}

// Dado el nombre de la canción, obtiene la URL del archivo de audio
Future<String> getSongUrlfile(String songName) async {
  final prefs = await SharedPreferences.getInstance();
  final key = 'song_$songName';

  if (prefs.containsKey(key)) {
    return prefs.getString(key)!;
  } else {
    return "-1";
  }
}

// Dado una url devuelve la primera cancion con esta
Future<String?> getSongNameFromUrl(String url) async {
  final prefs = await SharedPreferences.getInstance();
  final keys = prefs.getKeys();

  for (final key in keys) {
    if (key.startsWith('song_') && prefs.getString(key) == url) {
      return key.substring(5); // Devuelve solo el nombre sin el prefijo
    }
  }

  return null;
}

// Obtiene todas las urls
Future<List<String>> getAllSavedSongUrls() async {
  final songNames = await allSavedSongs();
  final urls = <String>[];

  for (final name in songNames) {
    final url = await getSongUrlfile(name);
    if (url != "-1") {
      urls.add(url);
    }
  }

  return urls;
}


// Dado el nombre de la canción y la URL, la guarda si no existe aún
// Lanza una excepción si ya existe
Future<void> saveSongNameValue(String songName, String urlFile) async {
  final prefs = await SharedPreferences.getInstance();
  final key = 'song_$songName';

  if (prefs.containsKey(key)) {
    throw Exception('La canción "$songName" ya existe');
  } else {
    await prefs.setString(key, urlFile);
  }
}

// Dado el nombre de una canción, la borra del diccionario
Future<void> deleteSong(String songName) async {
  final prefs = await SharedPreferences.getInstance();
  final key = 'song_$songName';

  await prefs.remove(key);

  // borrar de las playlists
  removeSongFromAllPlaylists(songName);
}

// Cambia el nombre de una canción, conservando su URL
Future<void> renameSong(String newNameSong, String oldNameSong) async {
  final prefs = await SharedPreferences.getInstance();
  final oldKey = 'song_$oldNameSong';
  final newKey = 'song_$newNameSong';

  if (!prefs.containsKey(oldKey)) {
    throw Exception('No existe canción con el nombre "$oldNameSong"');
  }
  if (prefs.containsKey(newKey)) {
    throw Exception('Ya existe una canción con el nombre "$newNameSong"');
  }

  final url = prefs.getString(oldKey);

  // Guarda la canción con el nuevo nombre y elimina la vieja
  await prefs.setString(newKey, url!);
  await prefs.remove(oldKey);

  // Actualizar con los nuevos nombres las playlists
  renameSongInAllPlaylists(oldNameSong, newNameSong);
}

// Devuelve true si la canción "songName" está guardada
Future<bool> isSongSaved(String songName) async {
  final prefs = await SharedPreferences.getInstance();
  final key = 'song_$songName';

  return prefs.containsKey(key);
}

// Dado el nombre de la canción, asocia una nueva URL
Future<void> changeUrl(String songName, String newUrl) async {
  final prefs = await SharedPreferences.getInstance();
  final key = 'song_$songName';

  if (prefs.containsKey(key)) {
    await prefs.setString(key, newUrl);
  } else {
    throw Exception('No existe canción con el nombre "$songName"');
  }
}



// Playlist
// Devuelve una lista con el nombre de todas las playlist del diccionario
Future<List<String>> allSavedPlaylist() async {
  final prefs = await SharedPreferences.getInstance();
  final keys = prefs.getKeys();
  final listaNames = <String>[];

  for (var key in keys) {
    if (key.startsWith('playlist_')) {
      final name = key.substring(9);
      listaNames.add(name);
    }
  }

  return listaNames;
}

// Crea una playlist vacia de nombre 'playlistName'
Future<void> createEmptyPlaylist(String playlistName) async {
  final prefs = await SharedPreferences.getInstance();
  final key = 'playlist_$playlistName';

  if (prefs.containsKey(key)) {
    throw Exception('La playlist "$playlistName" ya existe');
  } else {
    await prefs.setStringList(key, []);
  }
}

// Devuelve si una playlist esta en el diccionario
Future<bool> isPlaylistSaved(String playlistName) async {
  final prefs = await SharedPreferences.getInstance();
  final key = 'playlist_$playlistName';
  return prefs.containsKey(key);
}

// Dado el nombre de una canción, la borra del diccionario
Future<void> deletePlaylist(String playlistName) async {
  final prefs = await SharedPreferences.getInstance();
  final key = 'playlist_$playlistName';

  await prefs.remove(key);
}

// Dado una playlist la vacia
Future<void> vaciarPlaylist(String playlistName) async {
  final prefs = await SharedPreferences.getInstance();
  final key = 'playlist_$playlistName';

  if (!prefs.containsKey(key)) {
    throw Exception('La playlist "$playlistName" no existe');
  }

  // Asigna una lista vacía a la playlist
  await prefs.setStringList(key, []);
}

// Dado el nombre de la canción, obtiene la URL del archivo de audio
Future<List<String>> getPlaylistSongs(String playlistName) async {
  final prefs = await SharedPreferences.getInstance();
  final key = 'playlist_$playlistName';

  if (prefs.containsKey(key)) {
    return prefs.getStringList(key)!;
  } else {
    return [];
  }
}

// Agrega una canción a la playlist dada (si no está ya en la lista)
Future<void> addSongToPlaylist(String playlistName, String songName) async {
  final prefs = await SharedPreferences.getInstance();
  final key = 'playlist_$playlistName';

  if (!prefs.containsKey(key)) {
    throw Exception('La playlist "$playlistName" no existe');
  }

  if (await isSongInPlaylist(playlistName, songName)) {
    throw Exception('La cancion ya esta');
  }

  List<String> songs = prefs.getStringList(key)!;

  songs.add(songName);
  await prefs.setStringList(key, songs);
}

// Elimina una canción de la playlist dada (si existe)
Future<void> removeSongFromPlaylist(String playlistName, String songName) async {
  final prefs = await SharedPreferences.getInstance();
  final key = 'playlist_$playlistName';

  if (!prefs.containsKey(key)) {
    throw Exception('La playlist "$playlistName" no existe');
  }

  List<String> songs = prefs.getStringList(key)!;

  songs.remove(songName);
  await prefs.setStringList(key, songs);
}

// Intercambia las canciones en las posiciones index1 e index2 de la playlist dada
Future<void> swapSongsInPlaylist(String playlistName, int index1, int index2) async {
  final prefs = await SharedPreferences.getInstance();
  final key = 'playlist_$playlistName';

  if (!prefs.containsKey(key)) {
    throw Exception('La playlist "$playlistName" no existe');
  }

  List<String> songs = prefs.getStringList(key)!;

  // Verificar que los índices estén dentro del rango válido
  if (index1 < 0 || index1 >= songs.length || index2 < 0 || index2 >= songs.length) {
    throw Exception('Índices fuera de rango');
  }

  // Intercambiar las canciones
  String temp = songs[index1];
  songs[index1] = songs[index2];
  songs[index2] = temp;

  // Guardar la lista modificada
  await prefs.setStringList(key, songs);
}

// Devuelve cuantas canciones hay en una playlist
Future<int> getPlaylistLength(String playlistName) async {
  final songs = await getPlaylistSongs(playlistName);
  return songs.length;
}

// Dado una cancion de una lista, devuelve su posicion en esta
Future<int> getSongIndexInPlaylist(String playlistName, String songName) async {
  final songs = await getPlaylistSongs(playlistName);
  return songs.indexOf(songName);  // devuelve -1 si no está
}

// En una playlist, mueve la cancion del indice fromIndex al indice toIndex
Future<void> moveSongInPlaylist(String playlistName, int fromIndex, int toIndex) async {
  final prefs = await SharedPreferences.getInstance();
  final key = 'playlist_$playlistName';

  if (!prefs.containsKey(key)) {
    throw Exception('La playlist "$playlistName" no existe');
  }

  List<String> songs = prefs.getStringList(key)!;

  if (fromIndex < 0 || fromIndex >= songs.length || toIndex < 0 || toIndex >= songs.length) {
    throw Exception('Índices fuera de rango');
  }

  final song = songs.removeAt(fromIndex);
  songs.insert(toIndex, song);

  await prefs.setStringList(key, songs);
}

// Renomba una playlist, manteniendo las canciones
Future<void> renamePlaylist(String newName, String oldName) async {
  final prefs = await SharedPreferences.getInstance();
  final oldKey = 'playlist_$oldName';
  final newKey = 'playlist_$newName';

  if (!prefs.containsKey(oldKey)) {
    throw Exception('No existe playlist con el nombre "$oldName"');
  }

  if (prefs.containsKey(newKey)) {
    throw Exception('Ya existe una playlist con el nombre "$newName"');
  }

  List<String> songs = prefs.getStringList(oldKey)!;
  await prefs.setStringList(newKey, songs);
  await prefs.remove(oldKey);
}

// Elimina todas las playlists
Future<void> deleteAllPlaylists() async {
  final prefs = await SharedPreferences.getInstance();
  final keys = prefs.getKeys();

  for (final key in keys) {
    if (key.startsWith('playlist_')) {
      await prefs.remove(key);
    }
  }
}

// Devuelve true si la canción 'songName' está dentro de la playlist 'playlistName'
Future<bool> isSongInPlaylist(String playlistName, String songName) async {
  final prefs = await SharedPreferences.getInstance();
  final key = 'playlist_$playlistName';

  if (!prefs.containsKey(key)) {
    throw Exception('La playlist "$playlistName" no existe');
  }

  final List<String> songs = prefs.getStringList(key) ?? [];

  return songs.contains(songName);
}

// Cambia el nombre de la canción oldName por newName en todas las playlists donde aparezca
Future<void> renameSongInAllPlaylists(String oldName, String newName) async {
  final prefs = await SharedPreferences.getInstance();
  final keys = prefs.getKeys();

  for (final key in keys) {
    if (key.startsWith('playlist_')) {
      final List<String> songs = prefs.getStringList(key) ?? [];

      // Verifica si la canción está en la playlist
      if (songs.contains(oldName)) {
        // Reemplaza todas las ocurrencias
        final updatedSongs = songs.map((song) => song == oldName ? newName : song).toList();

        // Guarda la nueva lista actualizada
        await prefs.setStringList(key, updatedSongs);
      }
    }
  }
}

// Dado una canciones la borra de todas las playlists
Future<void> removeSongFromAllPlaylists(String songName) async {
  final prefs = await SharedPreferences.getInstance();
  final keys = prefs.getKeys();

  for (final key in keys) {
    if (key.startsWith('playlist_')) {
      final List<String> songs = prefs.getStringList(key) ?? [];

      if (songs.contains(songName)) {
        songs.remove(songName);
        await prefs.setStringList(key, songs);
      }
    }
  }
}



// Info playlists recurrentes
// Devuelve una lista con las ultimas playlists escuchadas, sino ''
Future<List<String>> utlimasplaylistEscuchadas() async {
  final prefs = await SharedPreferences.getInstance();

  if (!prefs.containsKey("ultPlaylist_")) {
    return ['', ''];
  }

  List<String> list = prefs.getStringList("ultPlaylist_")!;

  while (list.length < 2) {
    list.add('');
  }

  return list;
}

// Añade cancion a la lista de ultimas escuchadas
void anyadirUltimaPlaylistsEscuchada(String name) async {
  final prefs = await SharedPreferences.getInstance();

  if (!prefs.containsKey("ultPlaylist_")) {
    prefs.setStringList("ultPlaylist_", [name]);
    return;
  }

  List<String> list = prefs.getStringList("ultPlaylist_")!;

  if (list.contains(name)) return;

  if (list.length == 2) {
    list[0] = list[1];
    list[1] = name;
  }
  else if (list.length > 2) {
    while (list.length > 2) {
      list.removeLast();
    }
  }
  else {
    list.add(name);
  }

  prefs.setStringList("ultPlaylist_", list);
}

void reiniciarUltimaPlaylists() async {
  final prefs = await SharedPreferences.getInstance();

  prefs.remove("ultPlaylist_");
}



// Info canciones mas escuchadas
// Devuelve todas las canciones que se han escuchado minimo una vez
Future<List<String>> cancionesEscuchadasMinimo1() async {
  final prefs = await SharedPreferences.getInstance();
  final keys = prefs.getKeys();
  final songNames = <String>[];

  for (var key in keys) {
    if (key.startsWith('ultCanciones_')) {
      final name = key.substring(13); // Quita el prefijo "song_"
      songNames.add(name);
    }
  }

  return songNames;
}

Future<List<String>> DosCancionesMasEscuchadas() async {
  final prefs = await SharedPreferences.getInstance();
  List<String> songs = await cancionesEscuchadasMinimo1();

  String song1 = '';
  String song2 = '';
  int song1Lis = 0;
  int song2Lis = 0;

  for (var song in songs) {
    final key = 'ultCanciones_$song';
    int value = prefs.getInt(key)!;

    if (song1Lis < value) {
      if (song1Lis != 0) {
        song2 = song1;
        song2Lis = song1Lis;
      }
      song1 = song;
      song1Lis = value;
    } else if (song2Lis < value) {
      song2 = song;
      song2Lis = value;
    }
  }

  return [song1, song1Lis.toString(), song2, song2Lis.toString()];
}

// Suma una reproduccion a la cancion
void sumarReproduccionCancion(String songName) async {
  final prefs = await SharedPreferences.getInstance();
  final key = 'ultCanciones_$songName';

  if (!prefs.containsKey(key)) {
    prefs.setInt(key, 1);
    return;
  }

  int value = prefs.getInt(key)!;
  value++;

  prefs.setInt(key, value);
}

void reiniciarCancionesMasEscuchadas() async {
  final prefs = await SharedPreferences.getInstance();
  final keys = prefs.getKeys();

  for (final key in keys) {
    if (key.startsWith('ultCanciones_')) {
      await prefs.remove(key);
    }
  }
}

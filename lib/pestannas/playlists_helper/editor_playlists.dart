import 'package:flutter/material.dart';
import '../../helpers/utilsGestionArchivos.dart';
import '../../helpers/utilsSongPlaylist.dart';
import '../../reproductorDeMusica/reproductor_de_musica.dart';

class EditorPlaylist extends StatefulWidget {
  final String playlistName;

  // Constructor con parámetro requerido 'texto'
  const EditorPlaylist({Key? key, required this.playlistName}) : super(key: key);


  @override
  _EditorPlaylistState createState() => _EditorPlaylistState();
}

class _EditorPlaylistState extends State<EditorPlaylist> {

  List<String> canciones = [];

  @override
  void initState() {
    super.initState();
    cargarCancionesDePlaylist();
  }

  Future<void> cargarCancionesDePlaylist() async {
    String nombrePlaylist = widget.playlistName;
    
    List<String> lista = await getPlaylistSongs(nombrePlaylist);
    setState(() {
      canciones = lista;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: Text('Editor de playlists'),
      ),
      body: Column(
        children: [
          SizedBox(
            height: screenHeight * 0.75,
            child: SingleChildScrollView(
              child: Column(
                children: canciones.map((cancion) => buildSongRow(cancion)).toList(),
              ),
            ),
          ),
          botonesDown(),
        ],
      ),
    );
  }

  Padding botonesDown() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ElevatedButton(
            onPressed: () async {
              String? song = await pedirCancion(context ,await allSavedSongs());
              if (song != null) {
                addSongToPlaylist(widget.playlistName, song);
                await cargarCancionesDePlaylist(); // asegúrate de que esto hace setState internamente
                await cargarCancionesDePlaylist();
              }
            },
            child: Text('Añadir canción'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              await vaciarPlaylist(widget.playlistName);
              await cargarCancionesDePlaylist(); // vuelve a cargar canciones después de borrar
            },
            child: Text('Borrar todo'),
          ),
        ],
      ),
    );
  }

  // Row de la cancion
  Widget buildSongRow(String songName) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                songName,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  SizedBox(width: 8),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    onPressed: () async {
                      await removeSongFromPlaylist(widget.playlistName, songName);
                      await cargarCancionesDePlaylist();
                    },
                    child: Icon(Icons.delete),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<String?> pedirCancion(BuildContext context, List<String> songs) async {
    return showDialog<String>(
      context: context,
      barrierDismissible: false, // no se cierra tocando fuera
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Selecciona una canción'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: songs.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(songs[index]),
                  onTap: () {
                    Navigator.of(context).pop(songs[index]);
                  },
                );
              },
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop(null); // devuelve null si cancela
              },
            ),
          ],
        );
      },
    );
  }
}
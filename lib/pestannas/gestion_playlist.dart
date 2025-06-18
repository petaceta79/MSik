import 'package:flutter/material.dart';
import '../helpers/utilsSongPlaylist.dart';
import '../reproductorDeMusica/reproductor_de_musica.dart';
import 'playlists_helper/editor_playlists.dart';

class GestionPlaylist extends StatefulWidget {
  @override
  _GestionPlaylistState createState() => _GestionPlaylistState();
}

class _GestionPlaylistState extends State<GestionPlaylist> {

  List<String> playlists = [];

  @override
  void initState() {
    super.initState();
    cargarPlaylists();
  }

  Future<void> cargarPlaylists() async {
    List<String> Allplaylists = await allSavedPlaylist();
    setState(() {
      playlists = Allplaylists;
    });
  }

  void irAReproductor(String playlistName) async {
    final canciones = await getPlaylistSongs(playlistName);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReproductorDeMusica(canciones: canciones),
      ),
    );
  }

  void irAEditorPLaylist(String playlistName) async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditorPlaylist(playlistName: playlistName),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: Text('Gestión de Playlists'),
      ),
      body: Column(
        children: [
          SizedBox(
            height: screenHeight * 0.75,
            child: SingleChildScrollView(
              child: Column(
                children: playlists.map((playlist) => buildPlaylistRow(playlist)).toList(),
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
              String? name = await pedirNombre(context);
              if (name != null) {
                await createEmptyPlaylist(name);
                await cargarPlaylists(); // asegúrate de que esto hace setState internamente
              }
            },
            child: Text('Crear playlist'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              await deleteAllPlaylists();
              await cargarPlaylists(); // vuelve a cargar canciones después de borrar
            },
            child: Text('Borrar todo'),
          ),
        ],
      ),
    );
  }

  // Row de la cancion
  Widget buildPlaylistRow(String playlistName) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                playlistName,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  ElevatedButton(
                    onPressed: () {
                      print('Reproducir $playlistName');
                      irAReproductor(playlistName);
                    },
                    child: Text('Play'),
                  ),
                  SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () async {
                      // await renameSong();
                      String? name = await pedirNombre(context);
                      if (name != null) {
                        await renamePlaylist(name, playlistName);
                        await cargarPlaylists();
                      }
                    },
                    child: Text('Rename'),
                  ),
                  SizedBox(width: 8),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    onPressed: () async {
                      await deletePlaylist(playlistName);
                      await cargarPlaylists();
                    },
                    child: Icon(Icons.delete),
                  ),
                  SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () async {
                      irAEditorPLaylist(playlistName);
                    },
                    child: Text('Editar'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Pedir nombre
  Future<String?> pedirNombre(BuildContext context) async {
    TextEditingController controller = TextEditingController();

    return showDialog<String>(
      context: context,
      barrierDismissible: false, // para que no se cierre tocando fuera
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Introduce un nombre'),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: InputDecoration(hintText: 'Escribe el nombre aquí'),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop(null); // devuelve null si cancela
              },
            ),
            ElevatedButton(
              child: Text('Aceptar'),
              onPressed: () {
                Navigator.of(context).pop(controller.text); // devuelve texto
              },
            ),
          ],
        );
      },
    );
  }

}
import 'package:flutter/material.dart';
import '/helpers/utilsGestionArchivos.dart';
import '../helpers/utilsSongPlaylist.dart';
import '../reproductorDeMusica/reproductor_de_musica.dart';
import 'downloader/descargar_youtube.dart';

class GestionCanciones extends StatefulWidget {
  @override
  _GestionCancionesState createState() => _GestionCancionesState();
}

class _GestionCancionesState extends State<GestionCanciones> {

  List<String> canciones = [];

  @override
  void initState() {
    super.initState();
    cargarCanciones();
    print("Paso por initState");
  }

  Future<void> cargarCanciones() async {
    List<String> lista = await allSavedSongs();
    setState(() {
      canciones = lista;
    });
  }

  void irAReproductor(String songName) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReproductorDeMusica(canciones: [songName]),
      ),
    );
  }

  void irADescargar() async{
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DescargaAudioYoutube(),
      ),
    );

    await cargarCanciones();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: Text('Gestión de Canciones'),
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
                  await pickAndCopyFileToSongs();
                  await cargarCanciones(); // asegúrate de que esto hace setState internamente
                },
                child: Text('Añadir canción'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () async {
                  await borrarTodasLasCancionesYArchivos();
                  await cargarCanciones(); // vuelve a cargar canciones después de borrar
                },
                child: Text('Borrar todo'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.yellow),
                onPressed: () async {
                  irADescargar();
                  await cargarCanciones(); // vuelve a cargar canciones después de borrar
                },
                child: Text('Descargar'),
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
                  ElevatedButton(
                    onPressed: () {
                      print('Reproducir $songName');
                      irAReproductor(songName);
                    },
                    child: Text('Play'),
                  ),
                  SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () async {
                      // await renameSong();
                      String? name = await pedirNombre(context);
                      if (name != null) {
                        await renameSong(name, songName);
                        await cargarCanciones();
                      }
                    },
                    child: Text('Rename'),
                  ),
                  SizedBox(width: 8),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    onPressed: () async {
                      await deleteSongFile(songName);
                      await cargarCanciones();
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
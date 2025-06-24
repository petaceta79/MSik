import 'dart:ffi';

import 'package:flutter/material.dart';
import '../helpers/utilsSongPlaylist.dart';
import '../reproductorDeMusica/reproductor_de_musica.dart';
import 'playlists_helper/editor_playlists.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';


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
    return Scaffold(
      backgroundColor: Color(0xFF4A4A4A), // Gris oscuro
      appBar: AppBar(
        backgroundColor: Color(0xFF4A4A4A), // Gris oscuro
        centerTitle: true, // Centra el texto manteniendo la flecha de regreso
        title: Text(
          'Playlists',
          style: TextStyle(
            fontSize: 24.sp, // Tamaño adaptado con sp
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: listaPlaylists(),
          ),
          botonesDown(context),
        ],
      ),
    );
  }

  SizedBox listaPlaylists() {
    return SizedBox(
      child: SingleChildScrollView(
        child: Column(
          children: playlists
              .map((playlist) => buildPlaylistRow(playlist))
              .toList(),
        ),
      ),
    );
  }

  Padding botonesDown(BuildContext context) {
    final double buttonWidth = 120.w;

    return Padding(
      padding: EdgeInsets.all(24.w),
      child: Center(
        child: Wrap(
          spacing: 8.w,
          runSpacing: 8.h,
          alignment: WrapAlignment.center,
          children: [
            SizedBox(
              width: buttonWidth,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFC64820),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
                onPressed: () async {
                  String? name = await pedirNombre(context);
                  if (name != null) {
                    await createEmptyPlaylist(name);
                    await cargarPlaylists(); // recuerda que debe llamar a setState internamente
                  }
                },
                child: Icon(Icons.library_add, size: 24.sp),
              ),
            ),
            SizedBox(width: 20.h),
            SizedBox(
              width: buttonWidth,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFC64820),
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
                onPressed: () async {
                  bool confirmado = await advertenciaBorrar(context);
                  if (confirmado) {
                    await deleteAllPlaylists();
                    await cargarPlaylists();
                  }
                },
                child: Icon(Icons.delete_forever, color: Colors.red, size: 24.sp),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Row de la cancion
  Widget buildPlaylistRow(String playlistName) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 6.h, horizontal: 12.w),
      padding: EdgeInsets.all(10.w),
      decoration: BoxDecoration(
        color: Colors.orange,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.deepOrangeAccent, width: 2.w),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withAlpha((0.5 * 255).round()),
            blurRadius: 5.r,
            offset: Offset(0, 3.h),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text(
                    playlistName,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 16.sp),
                  ),
                ),
                SizedBox(height: 8.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFC64820),
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                      ),
                      onPressed: () {
                        anyadirUltimaPlaylistsEscuchada(playlistName);
                        irAReproductor(playlistName);
                      },
                      child: Icon(Icons.play_arrow, size: 22.sp),
                    ),
                    SizedBox(width: 10.w),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFC64820),
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                      ),
                      onPressed: () async {
                        String? name = await pedirNombre(context);
                        if (name != null) {
                          await renamePlaylist(name, playlistName);
                          await cargarPlaylists();
                        }
                      },
                      child: Icon(Icons.drive_file_rename_outline, size: 22.sp),
                    ),
                    SizedBox(width: 10.w),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFC64820),
                        foregroundColor: Colors.red,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                      ),
                      onPressed: () async {
                        await deletePlaylist(playlistName);
                        await cargarPlaylists();
                      },
                      child: Icon(Icons.delete, size: 22.sp),
                    ),
                    SizedBox(width: 10.w),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFC64820),
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                      ),
                      onPressed: () async {
                        irAEditorPLaylist(playlistName);
                      },
                      child: Icon(Icons.edit, size: 22.sp),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<bool> advertenciaBorrar(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          barrierDismissible: false, // No se puede cerrar tocando fuera
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('¿Estás seguro?'),
              actions: [
                TextButton(
                  child: Text('No'),
                  onPressed: () {
                    Navigator.of(context).pop(false); // Cancelar
                  },
                ),
                TextButton(
                  child: Text('Sí'),
                  onPressed: () {
                    Navigator.of(context).pop(true); // Confirmar
                  },
                ),
              ],
            );
          },
        ) ??
        false; // Si se cierra el diálogo sin seleccionar nada, devuelve false
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

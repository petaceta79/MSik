import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '/helpers/utilsGestionArchivos.dart';
import '../helpers/utilsSongPlaylist.dart';
import '../reproductorDeMusica/reproductor_de_musica.dart';
import 'downloader/descargar_youtube.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class GestionCanciones extends StatefulWidget {
  @override
  _GestionCancionesState createState() => _GestionCancionesState();
}

class _GestionCancionesState extends State<GestionCanciones> {
  List<String> canciones = [];

  // Buscador de canciones
  String searchText = "";
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    cargarCanciones();
    print("Paso por initState");
  }

  Future<void> cargarCanciones() async {
    List<String> lista = await allSavedSongs();
    setState(() {
      canciones = lista
          .where((c) => c.toLowerCase().contains(searchText.toLowerCase()))
          .toList();
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

  void irADescargar() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => DescargaAudioYoutube()),
    );

    await cargarCanciones();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF4A4A4A),
      appBar: AppBar(
        backgroundColor: Color(0xFF4A4A4A),
        centerTitle: true,
        title: Text(
          'Canciones',
          style: TextStyle(
            fontSize: 24.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 2.w),
        child: Column(
          children: [
            buildSearchBox(),
            SizedBox(height: 10.h),  // espacio vertical adaptado
            Expanded(child: Viewer_canciones()),  // usar Expanded si quieres que crezca
            botonesDown(context),
          ],
        ),
      ),
    );
  }

  Expanded Viewer_canciones() {
    return Expanded(
      child: SingleChildScrollView(
        child: Column(
          children: canciones.map((cancion) => buildSongRow(cancion)).toList(),
        ),
      ),
    );
  }

  Padding botonesDown(BuildContext context) {
    final buttonWidth = 105.w; // calculamos el ancho adaptado

    return Padding(
      padding: EdgeInsets.all(24.w),  // padding adaptado
      child: Center(
        child: Wrap(
          spacing: 8.w,        // espacio horizontal adaptado
          runSpacing: 8.h,     // espacio vertical adaptado
          alignment: WrapAlignment.center,
          children: [
            SizedBox(
              width: buttonWidth,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                ),
                onPressed: () async {
                  await pickAndCopyFileToSongs();
                  await cargarCanciones();
                },
                child: Icon(Icons.file_copy, size: 24.sp),  // icono adaptado
              ),
            ),
            SizedBox(width: 1.w,),
            SizedBox(
              width: buttonWidth,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                ),
                onPressed: () async {
                  bool confirmado = await advertenciaBorrar(context);
                  if (confirmado) {
                    await borrarTodasLasCancionesYArchivos();
                    await cargarCanciones();
                  }
                },
                child: Icon(Icons.delete, color: Colors.red, size: 24.sp),
              ),
            ),
            SizedBox(width: 1.w,),
            SizedBox(
              width: buttonWidth,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                ),
                onPressed: () async {
                  irADescargar();
                  await cargarCanciones();
                },
                child: Icon(FontAwesomeIcons.youtube, color: Colors.red, size: 24.sp),
              ),
            ),
          ],
        ),
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

  // Row de la cancion
  Widget buildSongRow(String songName) {
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
                    songName,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
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
                        irAReproductor(songName);
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
                          await renameSong(name, songName);
                          await cargarCanciones();
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
                        await deleteSongFile(songName);
                        await cargarCanciones();
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
                        String? playlist = await pedirPlaylist(context);
                        if (playlist != null) {
                          await addSongToPlaylist(playlist, songName);
                        }
                      },
                      child: Icon(Icons.playlist_add, size: 22.sp),
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

  Widget buildSearchBox() {
    return Padding(
      padding: EdgeInsets.all(8.w), // padding adaptado
      child: TextField(
        controller: searchController,
        style: TextStyle(
          color: Colors.black,
          fontSize: 16.sp, // tamaño del texto adaptado
        ),
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.orange,
          hintText: 'Buscar canción',
          hintStyle: TextStyle(fontSize: 16.sp), // hint adaptado
          prefixIcon: Icon(Icons.search, size: 24.sp), // ícono adaptado
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r), // radio adaptado
          ),
        ),
        onChanged: (text) {
          setState(() async {
            searchText = text.toLowerCase();
            await cargarCanciones();
          });
        },
      ),
    );
  }

  Future<String?> pedirPlaylist(BuildContext context) async {
    List<String> playlists = await allSavedPlaylist();

    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Selecciona una playlist'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: playlists.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(playlists[index]),
                  onTap: () {
                    Navigator.of(context).pop(playlists[index]);
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              child: Text('Cancelar'),
              onPressed: () => Navigator.of(context).pop(null),
            ),
          ],
        );
      },
    );
  }
}

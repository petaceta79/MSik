import 'package:flutter/material.dart';
import '../../helpers/utilsGestionArchivos.dart';
import '../../helpers/utilsSongPlaylist.dart';
import '../../reproductorDeMusica/reproductor_de_musica.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';


class EditorPlaylist extends StatefulWidget {
  final String playlistName;

  // Constructor con parámetro requerido 'texto'
  const EditorPlaylist({Key? key, required this.playlistName})
    : super(key: key);

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
    return Scaffold(
      backgroundColor: Color(0xFF4A4A4A), // Gris oscuro
      appBar: AppBar(
        backgroundColor: Color(0xFF4A4A4A), // Gris oscuro
        centerTitle: true,
        title: Text(
          'Editor Playlists',
          style: TextStyle(
            fontSize: 24.sp, // Tamaño adaptado con screenutil
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(child: SongsViwer()),
          botonesDown()
        ],
      ),
    );
  }

  Expanded SongsViwer() {
    return Expanded(
      child: SingleChildScrollView(
        child: Column(
          children: canciones.map((cancion) => buildSongRow(cancion)).toList(),
        ),
      ),
    );
  }

  Padding botonesDown() {
    return Padding(
      padding: EdgeInsets.all(26.w), // Padding adaptable
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFC64820),
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r), // radio adaptado
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: 20.w, // padding horizontal adaptable
                  vertical: 12.h,    // padding vertical adaptable
                ),
              ),
              onPressed: () async {
                List<String>? songs = await pedirCanciones(
                  context,
                  await allSavedSongs(),
                  canciones,
                );

                if (songs != null && songs.isNotEmpty) {
                  for (String song in songs) {
                    await addSongToPlaylist(widget.playlistName, song);
                  }
                  await cargarCancionesDePlaylist();
                }
              },
              child: Icon(Icons.add_box, size: 24.sp),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding: EdgeInsets.symmetric(
                  horizontal: 20.w,
                  vertical: 12.h,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
              onPressed: () async {
                bool confirmado = await advertenciaBorrar(context);
                if (confirmado) {
                  await vaciarPlaylist(widget.playlistName);
                  await cargarCancionesDePlaylist();
                }
              },
              child: Icon(Icons.delete_forever, size: 24.sp),
            ),
          ],
        ),
      ),
    );
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
                Text(
                  songName,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 16.sp),
                ),
                SizedBox(height: 8.h),
                Row(
                  children: [
                    SizedBox(width: 8.w),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFC64820),
                        foregroundColor: Colors.red,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 8.h,
                        ),
                      ),
                      onPressed: () async {
                        await removeSongFromPlaylist(
                          widget.playlistName,
                          songName,
                        );
                        await cargarCancionesDePlaylist();
                      },
                      child: Icon(Icons.delete, size: 20.sp),
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

  Future<List<String>?> pedirCanciones(
    BuildContext context,
    List<String> songs,
    List<String> cancionesUsadas,
  ) async {
    List<String> selectedSongs = [];

    // Canciones que se pueden mostrar inicialmente (sin las usadas)
    List<String> cancionesDisponibles = songs
        .where((song) => !cancionesUsadas.contains(song))
        .toList();

    TextEditingController searchController = TextEditingController();
    String searchText = "";

    return showDialog<List<String>>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            // Filtrar las canciones mientras se escribe
            List<String> cancionesFiltradas = cancionesDisponibles
                .where(
                  (song) =>
                      song.toLowerCase().contains(searchText.toLowerCase()),
                )
                .toList();

            return AlertDialog(
              title: const Text('Selecciona una o varias canciones'),
              content: SizedBox(
                width: double.maxFinite,
                child: Column(
                  children: [
                    TextField(
                      controller: searchController,
                      decoration: const InputDecoration(
                        hintText: 'Buscar canción...',
                        prefixIcon: Icon(Icons.search),
                      ),
                      onChanged: (value) {
                        setState(() {
                          searchText = value;
                        });
                      },
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: cancionesFiltradas.length,
                        itemBuilder: (context, index) {
                          final song = cancionesFiltradas[index];
                          final isSelected = selectedSongs.contains(song);
                          return ListTile(
                            title: Text(song),
                            trailing: isSelected
                                ? const Icon(Icons.check_box)
                                : const Icon(Icons.check_box_outline_blank),
                            onTap: () {
                              setState(() {
                                if (isSelected) {
                                  selectedSongs.remove(song);
                                } else {
                                  selectedSongs.add(song);
                                }
                              });
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('Cancelar'),
                  onPressed: () {
                    Navigator.of(context).pop(null);
                  },
                ),
                TextButton(
                  child: const Text('Aceptar'),
                  onPressed: () {
                    Navigator.of(context).pop(selectedSongs);
                  },
                ),
              ],
            );
          },
        );
      },
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
}

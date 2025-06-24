import 'package:flutter/material.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../../helpers/utilsSongPlaylist.dart';
import 'package:ffmpeg_kit_flutter_new/ffmpeg_kit.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class DescargaAudioYoutube extends StatefulWidget {
  @override
  _DescargaAudioYoutubeState createState() => _DescargaAudioYoutubeState();
}

class _DescargaAudioYoutubeState extends State<DescargaAudioYoutube> {
  final TextEditingController _controller = TextEditingController(); // para URL/ID
  final TextEditingController _searchController = TextEditingController(); // para búsquedas
  final YoutubeExplode _yt = YoutubeExplode();
  bool _descargando = false;
  String _mensaje = '';

  Future<void> _descargarAudio(String input) async {
    setState(() {
      _descargando = true;
      _mensaje = '';
    });

    try {
      final videoId = VideoId.parseVideoId(input);
      if (videoId == null) throw Exception("ID o URL inválido");

      final manifest = await _yt.videos.streamsClient.getManifest(videoId);
      final audio = manifest.audioOnly.withHighestBitrate();
      final stream = _yt.videos.streamsClient.get(audio);

      final info = await _yt.videos.get(videoId);
      final rawTitle = info.title;
      final safeTitle = rawTitle.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_');

      if (await isSongSaved(safeTitle)) {
        throw Exception("Ya existe");
      }

      final baseDir = await getApplicationDocumentsDirectory();
      final songsDir = Directory('${baseDir.path}/songs');
      if (!await songsDir.exists()) {
        await songsDir.create(recursive: true);
      }

      final filePath = '${songsDir.path}/$safeTitle.mp4';
      final file = File(filePath);

      await stream.pipe(file.openWrite());

      final mp3FilePath = await convertirAMp3(filePath);

      await saveSongNameValue(safeTitle, mp3FilePath);

      setState(() {
        _mensaje = '✅ Descargado y registrado: $safeTitle';
      });
    } catch (e) {
      setState(() {
        _mensaje = '❌ Error: ${e.toString()}';
      });
    }

    setState(() {
      _descargando = false;
    });
  }

  // Cambia el archivo por mp3 (borra el origial), devuelve le nuevo path
  Future<String> convertirAMp3(String inputFilePath) async {
    // Cambia la extensión de mp4 a mp3 para la salida
    final outputFilePath = inputFilePath.replaceAll('.mp4', '.mp3');

    // Ejecuta el comando FFmpeg para convertir
    await FFmpegKit.execute('-i "$inputFilePath" -vn -ar 44100 -ac 2 -b:a 192k "$outputFilePath"');

    // Opcional: eliminar el archivo original para ahorrar espacio
    final originalFile = File(inputFilePath);
    if (await originalFile.exists()) {
      await originalFile.delete();
    }

    return outputFilePath;
  }

  Future<void> _buscarYMostrarResultados() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;

    try {
      final resultados = await _yt.search.search(query);
      final primerosCinco = resultados
          .whereType<Video>()
          .take(5)
          .toList();

      if (primerosCinco.isEmpty) {
        setState(() {
          _mensaje = 'No se encontraron resultados.';
        });
        return;
      }

      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Resultados'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: primerosCinco.map((video) {
                return ListTile(
                  title: Text(video.title, maxLines: 2, overflow: TextOverflow.ellipsis),
                  subtitle: Text(video.author),
                  onTap: () {
                    Navigator.of(context).pop();
                    _descargarAudio(video.id.value);
                  },
                );
              }).toList(),
            ),
          );
        },
      );
    } catch (e) {
      setState(() {
        _mensaje = '❌ Error al buscar: ${e.toString()}';
      });
    }
  }

  @override
  void dispose() {
    _yt.close();
    _controller.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF4A4A4A),
      appBar: AppBar(
        backgroundColor: Color(0xFF4A4A4A),
        centerTitle: true,
        title: Text(
          'Descargar de youtube',
          style: TextStyle(
            fontSize: 24.sp, // ← adaptado
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.w), // ← adaptado
        child: Column(
          children: [
            Divider(color: Colors.orange, thickness: 2.h), // ← adaptado
            SizedBox(height: 20.h),
            UrlSearcher(),
            SizedBox(height: 12.h),
            UrlBotton(),
            SizedBox(height: 12.h),
            TitleSearcher(),
            SizedBox(height: 12.h),
            TitleBotton(),
            SizedBox(height: 20.h),
            Divider(color: Colors.orange, thickness: 2.h),
            SizedBox(height: 20.h),
            TextoResult(),
          ],
        ),
      ),
    );
  }

  Container TextoResult() {
    if (_mensaje == null || _mensaje.isEmpty) {
      return Container(); // No ocupa espacio ni se ve
    }

    return Container(
      padding: EdgeInsets.all(8.w), // ← adaptado
      decoration: BoxDecoration(
        color: Colors.grey,
        borderRadius: BorderRadius.circular(8.r), // ← adaptado
      ),
      child: Text(
        _mensaje,
        style: TextStyle(
          color: Colors.black,
          fontSize: 18.sp, // ← adaptado
        ),
      ),
    );
  }

  ElevatedButton TitleBotton() {
    return ElevatedButton(
      onPressed: !_descargando ? _buscarYMostrarResultados : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: Color(0xFFC64820),
        foregroundColor: Colors.black,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.r), // ← adaptado
        ),
      ),
      child: _descargando
          ? CircularProgressIndicator(color: Colors.white)
          : Icon(Icons.cloud_download, size: 25.sp), // ← adaptado
    );
  }

  TextField TitleSearcher() {
    return TextField(
      controller: _searchController,
      style: TextStyle(fontSize: 16.sp), // ← adaptado
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.orange,
        hintText: 'Buscar por título o artista',
        hintStyle: TextStyle(fontSize: 16.sp), // ← adaptado
        prefixIcon: Icon(Icons.search, size: 24.sp), // ← adaptado
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r), // ← adaptado
        ),
      ),
    );
  }

  ElevatedButton UrlBotton() {
    return ElevatedButton(
      onPressed: !_descargando ? () => _descargarAudio(_controller.text) : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: Color(0xFFC64820),
        foregroundColor: Colors.black,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.r), // ← adaptado
        ),
      ),
      child: _descargando
          ? SizedBox(
        height: 20.sp,
        width: 20.sp,
        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.sp),
      )
          : Icon(Icons.cloud_download, size: 25.sp), // ← adaptado
    );
  }

  TextField UrlSearcher() {
    return TextField(
      controller: _controller,
      style: TextStyle(fontSize: 16.sp), // ← texto adaptado
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.orange,
        hintText: 'Pega la URL del video',
        hintStyle: TextStyle(fontSize: 16.sp), // ← hint adaptado
        prefixIcon: Icon(Icons.search, size: 24.sp), // ← ícono adaptado
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r), // ← borde adaptado
        ),
      ),
    );
  }
}

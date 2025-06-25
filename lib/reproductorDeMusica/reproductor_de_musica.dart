import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/material.dart';
import 'reproductorMusicaNotificadores/play_button_notifier.dart';
import 'reproductorMusicaNotificadores/progress_notifier.dart';
import 'reproductorMusicaNotificadores/repeat_button_notifier.dart';
import 'page_manager.dart';
import '../helpers/utilsSongPlaylist.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';


class ReproductorDeMusica extends StatefulWidget {
  final List<String> canciones;

  const ReproductorDeMusica({Key? key, required this.canciones})
    : super(key: key);

  @override
  State<ReproductorDeMusica> createState() {
    return _ReproductorDeMusicaState();
  }
}

class _ReproductorDeMusicaState extends State<ReproductorDeMusica> {
  late final PageManager _pageManager;

  @override
  void initState() {
    super.initState();
    _pageManager = PageManager(songNames: widget.canciones);

    _pageManager.currentSongTitleNotifier.addListener(() {
      final titulo = _pageManager.currentSongTitleNotifier.value;
      if (titulo.trim().isNotEmpty) {
        sumarReproduccionCancion(titulo);
      }
    });
  }

  @override
  void dispose() {
    _pageManager.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF4A4A4A), // Gris oscuro
      appBar: AppBar(
        backgroundColor: Color(0xFF4A4A4A), // Gris oscuro
        centerTitle: true, // Centra el texto manteniendo la flecha de regreso
        title: Text(
          'Reproductor',
          style: TextStyle(
            fontSize: 24.sp, // Tamaño más grande adaptativo
            fontWeight: FontWeight.bold, // Opcional: texto más destacado
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(20.w), // Padding adaptativo horizontal
        child: Column(
          children: [
            CurrentSongTitle(pageManager: _pageManager),

            Divider(
              thickness: 1,
              color: Colors.black,
              height: 16.h, // altura adaptativa
            ),

            Playlist(pageManager: _pageManager),
            ReproductorBotones(),
          ],
        ),
      ),
    );
  }

  Container ReproductorBotones() {
    return Container(
      margin: EdgeInsets.all(4.w), // Espacio externo adaptado
      padding: EdgeInsets.all(12.w), // Espacio interno adaptado
      decoration: BoxDecoration(
        color: Colors.orange[200], // Fondo gris claro
        borderRadius: BorderRadius.circular(16.r), // Bordes redondeados adaptados
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8.r,
            offset: Offset(0, 4.h), // Sombra sutil adaptada
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AudioProgressBar(pageManager: _pageManager),
          AudioControlButtons(pageManager: _pageManager),
        ],
      ),
    );
  }
}

class CurrentSongTitle extends StatelessWidget {
  final PageManager pageManager;

  const CurrentSongTitle({Key? key, required this.pageManager})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: pageManager.currentSongTitleNotifier,
      builder: (BuildContext context, String title, Widget? child) {
        return Padding(
          padding: EdgeInsets.only(top: 8.h), // padding adaptado
          child: Text(
            title,
            style: TextStyle(
              fontSize: 30.sp, // tamaño adaptado
              color: Colors.orange[500],
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            softWrap: false,
          ),
        );
      },
    );
  }
}

class Playlist extends StatelessWidget {
  final PageManager pageManager;

  const Playlist({Key? key, required this.pageManager}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ValueListenableBuilder<List<String>>(
        valueListenable: pageManager.playlistNotifier,
        builder: (context, playlistTitles, _) {
          return ListView.builder(
            itemCount: playlistTitles.length,
            itemBuilder: (context, index) {
              return ListTile(title: cancionDeLaLista(playlistTitles, index));
            },
          );
        },
      ),
    );
  }

  Container cancionDeLaLista(List<String> playlistTitles, int index) {
    return Container(
      padding: EdgeInsets.all(7.w), // padding adaptado
      decoration: BoxDecoration(
        color: Colors.orange,
        borderRadius: BorderRadius.circular(12.r), // radio adaptado
        border: Border.all(color: Colors.deepOrangeAccent, width: 1.w),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withAlpha((0.5 * 255).round()),
            blurRadius: 5.r,
            offset: Offset(0, 3.h),
          ),
        ],
      ),
      child: Center(
        child: Text(
          '${playlistTitles[index]}',
          style: TextStyle(fontSize: 16.sp), // texto adaptado
        ),
      ),
    );
  }
}

class AudioProgressBar extends StatelessWidget {
  final PageManager pageManager;

  const AudioProgressBar({Key? key, required this.pageManager})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ProgressBarState>(
      valueListenable: pageManager.progressNotifier,
      builder: (_, value, __) {
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 10.w), // ejemplo padding adaptado
          child: ProgressBar(
            progress: value.current,
            buffered: value.buffered,
            total: value.total,
            onSeek: pageManager.seek,
            progressBarColor: Colors.black,         // Color de la barra de progreso
            bufferedBarColor: Colors.grey.shade200, // Color de la barra buffer
            baseBarColor: Colors.grey.shade300,      // Color de la barra base (fondo)
            thumbColor: Colors.black,                // Color del thumb (círculo que se mueve)
            // si ProgressBar tuviera texto, aquí podrías usar fontSize: 16.sp por ejemplo
          ),
        );
      },
    );
  }
}

class AudioControlButtons extends StatelessWidget {
  final PageManager pageManager;

  const AudioControlButtons({Key? key, required this.pageManager})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          height: 60.h, // adaptado en altura
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              RepeatButton(pageManager: pageManager),
              PreviousSongButton(pageManager: pageManager),
              PlayButton(pageManager: pageManager),
              NextSongButton(pageManager: pageManager),
              ShuffleButton(pageManager: pageManager),
            ],
          ),
        ),
        SizedBox(height: 8.h), // espacio adaptado
        ControlVolumen(pageManager: pageManager),
      ],
    );
  }
}

class RepeatButton extends StatelessWidget {
  final PageManager pageManager;

  const RepeatButton({Key? key, required this.pageManager}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<RepeatState>(
      valueListenable: pageManager.repeatButtonNotifier,
      builder: (context, value, child) {
        Icon icon;
        switch (value) {
          case RepeatState.off:
            icon = Icon(Icons.repeat, color: Colors.grey, size: 24.sp);
            break;
          case RepeatState.repeatSong:
            icon = Icon(Icons.repeat_one, size: 24.sp);
            break;
          case RepeatState.repeatPlaylist:
            icon = Icon(Icons.repeat, size: 24.sp);
            break;
        }
        return IconButton(
          icon: icon,
          onPressed: pageManager.onRepeatButtonPressed,
          iconSize: 32.sp, // También puedes ajustar el tamaño del botón
        );
      },
    );
  }
}

class PreviousSongButton extends StatelessWidget {
  final PageManager pageManager;

  const PreviousSongButton({Key? key, required this.pageManager})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: pageManager.isFirstSongNotifier,
      builder: (_, isFirst, __) {
        return IconButton(
          icon: Icon(
            Icons.skip_previous,
            size: 28.sp, // Tamaño adaptable
          ),
          onPressed: (isFirst) ? null : pageManager.onPreviousSongButtonPressed,
        );
      },
    );
  }
}

class PlayButton extends StatelessWidget {
  final PageManager pageManager;

  const PlayButton({Key? key, required this.pageManager}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ButtonState>(
      valueListenable: pageManager.playButtonNotifier,
      builder: (_, value, __) {
        switch (value) {
          case ButtonState.loading:
            return Container(
              margin: EdgeInsets.all(8.0.w),
              width: 32.0.w,
              height: 32.0.w,
              child: CircularProgressIndicator(),
            );
          case ButtonState.paused:
            return IconButton(
              icon: Icon(Icons.play_arrow),
              iconSize: 32.0.sp,
              onPressed: pageManager.play,
            );
          case ButtonState.playing:
            return IconButton(
              icon: Icon(Icons.pause),
              iconSize: 32.0.sp,
              onPressed: pageManager.pause,
            );
        }
      },
    );
  }
}

class NextSongButton extends StatelessWidget {
  final PageManager pageManager;

  const NextSongButton({Key? key, required this.pageManager}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: pageManager.isLastSongNotifier,
      builder: (_, isLast, __) {
        return IconButton(
          iconSize: 32.sp, // tamaño adaptable
          icon: Icon(Icons.skip_next),
          onPressed: isLast ? null : pageManager.onNextSongButtonPressed,
        );
      },
    );
  }
}

class ShuffleButton extends StatelessWidget {
  final PageManager pageManager;

  const ShuffleButton({Key? key, required this.pageManager}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: pageManager.isShuffleModeEnabledNotifier,
      builder: (context, isEnabled, child) {
        return IconButton(
          iconSize: 28.sp, // tamaño adaptable del ícono
          icon: Icon(
            Icons.shuffle,
            color: isEnabled ? Colors.black : Colors.grey,
          ),
          onPressed: pageManager.onShuffleButtonPressed,
        );
      },
    );
  }
}

class ControlVolumen extends StatelessWidget {
  final PageManager pageManager;

  const ControlVolumen({Key? key, required this.pageManager}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          iconSize: 24.sp,
          icon: Icon(Icons.volume_down),
          onPressed: () {
            pageManager.disminuirVolumen();
          },
          tooltip: 'Bajar volumen',
        ),
        ValueListenableBuilder<double>(
          valueListenable: pageManager.volumeNotifier,
          builder: (context, volumen, _) {
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.w),
              child: Text(
                '${(volumen * 100).toInt()}%',
                style: TextStyle(fontSize: 16.sp),
              ),
            );
          },
        ),
        IconButton(
          iconSize: 24.sp,
          icon: Icon(Icons.volume_up),
          onPressed: () {
            pageManager.aumentarVolumen();
          },
          tooltip: 'Subir volumen',
        ),
      ],
    );
  }
}

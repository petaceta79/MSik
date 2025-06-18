import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/material.dart';
import 'reproductorMusicaNotificadores/play_button_notifier.dart';
import 'reproductorMusicaNotificadores/progress_notifier.dart';
import 'reproductorMusicaNotificadores/repeat_button_notifier.dart';
import 'page_manager.dart';


class ReproductorDeMusica extends StatefulWidget {
  final List<String> canciones;
  const ReproductorDeMusica({Key? key, required this.canciones}) : super(key: key);

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
  }

  @override
  void dispose() {
    _pageManager.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // Vuelve a la pantalla anterior
          },
        ),
        title: Text('Reproductor de Música'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            CurrentSongTitle(pageManager: _pageManager),
            Playlist(pageManager: _pageManager),
            AudioProgressBar(pageManager: _pageManager),
            AudioControlButtons(pageManager: _pageManager),
          ],
        ),
      ),
    );
  }
}



class CurrentSongTitle extends StatelessWidget {
  final PageManager pageManager;
  const CurrentSongTitle({Key? key, required this.pageManager}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: pageManager.currentSongTitleNotifier,
      builder: (_, title, __) {
        return Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Text(title, style: TextStyle(fontSize: 40)),
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
              return ListTile(
                title: Text('${playlistTitles[index]}'),
              );
            },
          );
        },
      ),
    );
  }
}


class AudioProgressBar extends StatelessWidget {
  final PageManager pageManager;
  const AudioProgressBar({Key? key, required this.pageManager}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ProgressBarState>(
      valueListenable: pageManager.progressNotifier,
      builder: (_, value, __) {
        return ProgressBar(
          progress: value.current,
          buffered: value.buffered,
          total: value.total,
          onSeek: pageManager.seek,
        );
      },
    );
  }
}


class AudioControlButtons extends StatelessWidget {
  final PageManager pageManager;
  const AudioControlButtons({Key? key, required this.pageManager}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          height: 60,
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
        const SizedBox(height: 8),
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
            icon = Icon(Icons.repeat, color: Colors.grey);
            break;
          case RepeatState.repeatSong:
            icon = Icon(Icons.repeat_one);
            break;
          case RepeatState.repeatPlaylist:
            icon = Icon(Icons.repeat);
            break;
        }
        return IconButton(
          icon: icon,
          onPressed: pageManager.onRepeatButtonPressed,
        );
      },
    );
  }
}

class PreviousSongButton extends StatelessWidget {
  final PageManager pageManager;
  const PreviousSongButton({Key? key, required this.pageManager}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: pageManager.isFirstSongNotifier,
      builder: (_, isFirst, __) {
        return IconButton(
          icon: Icon(Icons.skip_previous),
          onPressed:
          (isFirst) ? null : pageManager.onPreviousSongButtonPressed,
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
              margin: EdgeInsets.all(8.0),
              width: 32.0,
              height: 32.0,
              child: CircularProgressIndicator(),
            );
          case ButtonState.paused:
            return IconButton(
              icon: Icon(Icons.play_arrow),
              iconSize: 32.0,
              onPressed: pageManager.play,
            );
          case ButtonState.playing:
            return IconButton(
              icon: Icon(Icons.pause),
              iconSize: 32.0,
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
          icon: Icon(Icons.skip_next),
          onPressed: (isLast) ? null : pageManager.onNextSongButtonPressed,
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
          icon: (isEnabled)
              ? Icon(Icons.shuffle)
              : Icon(Icons.shuffle, color: Colors.grey),
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
          icon: Icon(Icons.volume_down),
          onPressed: () {
            pageManager.disminuirVolumen();
          },
          tooltip: 'Bajar volumen',
        ),
        ValueListenableBuilder<double>(
          valueListenable: pageManager.volumeNotifier,
          builder: (context, volumen, _) {
            return Text('${(volumen * 100).toInt()}%');
          },
        ),
        IconButton(
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
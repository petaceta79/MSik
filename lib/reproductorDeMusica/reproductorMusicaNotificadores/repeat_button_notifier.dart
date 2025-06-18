import 'package:flutter/foundation.dart';

// Notificador del estado del boton de bucle
class RepeatButtonNotifier extends ValueNotifier<RepeatState> {
  RepeatButtonNotifier() : super(_initialValue);
  static const _initialValue = RepeatState.off;

  void nextState() {
    final next = (value.index + 1) % RepeatState.values.length;
    value = RepeatState.values[next];
  }
}

// Estados posibles del boton de bucle
enum RepeatState {
  off,
  repeatSong,
  repeatPlaylist,
}

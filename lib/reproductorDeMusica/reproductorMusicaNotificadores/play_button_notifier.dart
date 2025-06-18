import 'package:flutter/material.dart';

// notificador del estado de la cancion
class PlayButtonNotifier extends ValueNotifier<ButtonState> {
  PlayButtonNotifier() : super(_initialValue);
  static const _initialValue = ButtonState.paused;
}

// valores posibles del boton
enum ButtonState { paused, playing, loading, }
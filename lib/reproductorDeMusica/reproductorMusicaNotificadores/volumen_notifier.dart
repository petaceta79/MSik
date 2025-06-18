import 'package:flutter/material.dart';

/// Notificador del estado del volumen
class VolumeNotifier extends ValueNotifier<double> {
  VolumeNotifier() : super(_initialValue);

  static const double _initialValue = 1.0;
}

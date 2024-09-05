import 'package:flutter/material.dart' show AppLifecycleState;
import 'package:flutter_riverpod/flutter_riverpod.dart';

final appStateProvider = StateProvider<AppLifecycleState>((ref) {
  // resumed => App activa
  return AppLifecycleState.resumed;
});


/*
      resumed
      inactive
      paused
      detached
*/
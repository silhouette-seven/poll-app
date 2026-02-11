import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum WaveMode { idle, success, error }

class WaveState extends ChangeNotifier {
  bool _isOnline = true;
  WaveMode _mode = WaveMode.idle;
  Timer? _revertTimer;

  bool get isOnline => _isOnline;
  WaveMode get mode => _mode;

  /// Current color palette based on state
  List<Color> get colors {
    switch (_mode) {
      case WaveMode.success:
        return const [Color(0xFF00E676), Color(0xFF69F0AE), Color(0xFF00C853)];
      case WaveMode.error:
        return const [Color(0xFFFF5252), Color(0xFFFF8A80), Color(0xFFD50000)];
      case WaveMode.idle:
        if (_isOnline) {
          return const [
            Color(0xFF6B4EFF),
            Color(0xFF448AFF),
            Color(0xFF536DFE),
          ];
        } else {
          return const [
            Color(0xFFFFB300),
            Color(0xFFFFCA28),
            Color(0xFFFFA000),
          ];
        }
    }
  }

  void setOnline(bool online) {
    if (_isOnline != online) {
      _isOnline = online;
      notifyListeners();
    }
  }

  void triggerSuccess() {
    _revertTimer?.cancel();
    _mode = WaveMode.success;
    notifyListeners();
    _revertTimer = Timer(const Duration(milliseconds: 1500), () {
      _mode = WaveMode.idle;
      notifyListeners();
    });
  }

  void triggerError() {
    _revertTimer?.cancel();
    _mode = WaveMode.error;
    notifyListeners();
    _revertTimer = Timer(const Duration(milliseconds: 1500), () {
      _mode = WaveMode.idle;
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _revertTimer?.cancel();
    super.dispose();
  }
}

final waveStateProvider = ChangeNotifierProvider<WaveState>((ref) {
  return WaveState();
});

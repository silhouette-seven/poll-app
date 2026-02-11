import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:poll_app/features/common/wave_state.dart';
import 'package:poll_app/features/polls/providers/poll_providers.dart';

class AnimatedWaveBackground extends ConsumerStatefulWidget {
  final Widget child;
  const AnimatedWaveBackground({super.key, required this.child});

  @override
  ConsumerState<AnimatedWaveBackground> createState() =>
      _AnimatedWaveBackgroundState();
}

class _AnimatedWaveBackgroundState extends ConsumerState<AnimatedWaveBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;

  List<Color> _displayColors = const [
    Color(0xFF6B4EFF),
    Color(0xFF448AFF),
    Color(0xFF536DFE),
  ];
  List<Color> _previousColors = const [
    Color(0xFF6B4EFF),
    Color(0xFF448AFF),
    Color(0xFF536DFE),
  ];
  List<Color>? _lastTargetColors;
  double _colorT = 1.0;

  @override
  void initState() {
    super.initState();
    // Very long duration so movement is imperceptibly slow
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(hours: 1),
    )..repeat(); // Linear 0→1 over an hour — no perceptible loop
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _updateColors(List<Color> newColors) {
    if (_lastTargetColors == null ||
        !_colorsEqual(_lastTargetColors!, newColors)) {
      _previousColors = _displayColors;
      _lastTargetColors = newColors;
      _colorT = 0.0;
    }
    if (_colorT < 1.0) {
      _colorT = (_colorT + 0.012).clamp(0.0, 1.0);
      _displayColors = _lerpColors(_previousColors, newColors, _colorT);
    }
  }

  @override
  Widget build(BuildContext context) {
    final waveState = ref.watch(waveStateProvider);
    _updateColors(waveState.colors);

    // Watch connectivity
    final connectivityAsync = ref.watch(connectivityStreamProvider);
    connectivityAsync.whenData((isOnline) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(waveStateProvider).setOnline(isOnline);
      });
    });

    final bgColor = Theme.of(context).scaffoldBackgroundColor;

    return Stack(
      children: [
        // Gradient — repaints via the animation's repaint parameter
        // No setState, no AnimatedBuilder, no widget rebuilds at all
        Positioned.fill(
          child: RepaintBoundary(
            child: CustomPaint(
              painter: _GradientPainter(
                animation: _animController,
                colors: _displayColors,
              ),
            ),
          ),
        ),
        // Frosted glass
        Positioned.fill(
          child: ClipRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
              child: Container(color: bgColor.withOpacity(0.7)),
            ),
          ),
        ),
        // Content — never touched by animation
        widget.child,
      ],
    );
  }

  bool _colorsEqual(List<Color> a, List<Color> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  List<Color> _lerpColors(List<Color> from, List<Color> to, double t) {
    return List.generate(min(from.length, to.length), (i) {
      return Color.lerp(from[i], to[i], t) ?? to[i];
    });
  }
}

/// Uses CustomPainter's `repaint` parameter to drive repainting
/// directly from the animation — zero widget rebuilds.
class _GradientPainter extends CustomPainter {
  final Animation<double> animation;
  final List<Color> colors;

  _GradientPainter({required this.animation, required this.colors})
    : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final t = animation.value;
    for (int i = 0; i < colors.length; i++) {
      // Slow sinusoidal drift using tiny fractions of t
      // With 1-hour duration, t changes ~0.00028 per second
      // sin wraps smoothly, so no boundary at all
      final phase = t * 2 * pi * 3; // 3 full slow cycles over the hour
      final offset = i * 2.094; // 120° apart
      final cx = size.width * (0.5 + 0.25 * sin(phase + offset));
      final cy = size.height * (0.4 + 0.2 * cos(phase * 0.7 + offset));
      final radius =
          size.width * (0.55 + 0.15 * sin(phase * 0.4 + offset + 1.0));

      final paint =
          Paint()
            ..shader = RadialGradient(
              colors: [colors[i].withOpacity(0.30), colors[i].withOpacity(0.0)],
            ).createShader(
              Rect.fromCircle(center: Offset(cx, cy), radius: radius),
            );

      canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
    }
  }

  @override
  bool shouldRepaint(_GradientPainter oldDelegate) => true;
}

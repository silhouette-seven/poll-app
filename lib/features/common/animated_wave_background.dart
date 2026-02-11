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
    with TickerProviderStateMixin {
  late AnimationController _waveController;
  late AnimationController _colorController;

  late List<Color> _currentColors;
  late List<Color> _targetColors;
  late List<Color> _previousColors;

  @override
  void initState() {
    super.initState();
    // Continuous wave animation (30s loop)
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 30),
    )..repeat();

    // Color transition animation
    _colorController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    const initialColors = [
      Color(0xFF6B4EFF),
      Color(0xFF448AFF),
      Color(0xFF536DFE),
    ];
    _currentColors = initialColors;
    _previousColors = initialColors;
    _targetColors = initialColors;
  }

  @override
  void dispose() {
    _waveController.dispose();
    _colorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final waveState = ref.watch(waveStateProvider);
    final newColors = waveState.colors;

    // Watch connectivity
    final connectivityAsync = ref.watch(connectivityStreamProvider);
    connectivityAsync.whenData((isOnline) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(waveStateProvider).setOnline(isOnline);
      });
    });

    // Trigger color transition if target changes
    if (!_colorsEqual(_targetColors, newColors)) {
      _previousColors = List.of(_currentColors);
      _targetColors = newColors;

      // Logic:
      // If it's an event (Success/Error), we want a "pulse" effect:
      // 1. Go to new color (forward)
      // 2. Return to idle (reverse) - handled by WaveNotifier logic usually,
      //    but here we ensure the transition itself is smooth.
      // If the waveState resets automatically, this will just animate to new target.

      _colorController.forward(from: 0.0);
    }

    // Update current colors during transition
    if (_colorController.isAnimating || _colorController.isCompleted) {
      // Use curves for smoother visual transition
      final t = Curves.easeInOutCubic.transform(_colorController.value);
      _currentColors = _lerpColors(_previousColors, _targetColors, t);
    }

    final bgColor = Theme.of(context).scaffoldBackgroundColor;

    return Stack(
      children: [
        Positioned.fill(
          child: RepaintBoundary(
            child: AnimatedBuilder(
              animation: Listenable.merge([_waveController, _colorController]),
              builder: (context, child) {
                // Interpolate colors based on controller value
                final t = Curves.easeInOutCubic.transform(
                  _colorController.value,
                );
                final displayColors = _lerpColors(
                  _previousColors,
                  _targetColors,
                  t,
                );

                return CustomPaint(
                  painter: _GradientPainter(
                    animation: _waveController,
                    colors: displayColors,
                  ),
                );
              },
            ),
          ),
        ),
        // Frosted glass overlay
        Positioned.fill(
          child: ClipRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
              child: Container(color: bgColor.withOpacity(0.7)),
            ),
          ),
        ),
        // Content
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

class _GradientPainter extends CustomPainter {
  final Animation<double> animation;
  final List<Color> colors;

  _GradientPainter({required this.animation, required this.colors});

  @override
  void paint(Canvas canvas, Size size) {
    final t = animation.value;
    for (int i = 0; i < colors.length; i++) {
      final phase = t * 2 * pi;
      final offset = i * 2.094;

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
  bool shouldRepaint(_GradientPainter oldDelegate) =>
      oldDelegate.animation.value != animation.value ||
      oldDelegate.colors != colors;
}

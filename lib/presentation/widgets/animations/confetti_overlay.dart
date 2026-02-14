import 'dart:math' as math;

import 'package:flutter/material.dart';

class ConfettiOverlay extends StatefulWidget {
  const ConfettiOverlay({super.key});

  @override
  State<ConfettiOverlay> createState() => _ConfettiOverlayState();
}

class _ConfettiOverlayState extends State<ConfettiOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<_ConfettiPiece> _pieces;

  static const _colors = [
    Color(0xFFFF6B6B),
    Color(0xFF4ECDC4),
    Color(0xFFFFE66D),
    Color(0xFFA8E6CF),
    Color(0xFF95E1D3),
    Color(0xFFF38181),
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..forward();

    final random = math.Random();
    _pieces = List.generate(30, (_) {
      return _ConfettiPiece(
        x: random.nextDouble(),
        speed: 0.3 + random.nextDouble() * 0.7,
        size: 6.0 + random.nextDouble() * 8,
        color: _colors[random.nextInt(_colors.length)],
        rotationSpeed: random.nextDouble() * 4 - 2,
        drift: random.nextDouble() * 0.4 - 0.2,
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final progress = _controller.value;
        if (progress >= 1.0) return const SizedBox.shrink();

        return IgnorePointer(
          child: CustomPaint(
            size: MediaQuery.of(context).size,
            painter: _ConfettiPainter(pieces: _pieces, progress: progress),
          ),
        );
      },
    );
  }
}

class _ConfettiPiece {
  _ConfettiPiece({
    required this.x,
    required this.speed,
    required this.size,
    required this.color,
    required this.rotationSpeed,
    required this.drift,
  });

  final double x;
  final double speed;
  final double size;
  final Color color;
  final double rotationSpeed;
  final double drift;
}

class _ConfettiPainter extends CustomPainter {
  _ConfettiPainter({required this.pieces, required this.progress});

  final List<_ConfettiPiece> pieces;
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    for (final piece in pieces) {
      final t = progress * piece.speed;
      final x =
          piece.x * size.width +
          math.sin(t * math.pi * 2) * piece.drift * size.width;
      final y = t * size.height * 1.2;
      final opacity = (1.0 - progress).clamp(0.0, 1.0);

      final paint = Paint()..color = piece.color.withValues(alpha: opacity);

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(t * piece.rotationSpeed * math.pi);
      canvas.drawRect(
        Rect.fromCenter(
          center: Offset.zero,
          width: piece.size,
          height: piece.size * 0.6,
        ),
        paint,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter oldDelegate) =>
      progress != oldDelegate.progress;
}

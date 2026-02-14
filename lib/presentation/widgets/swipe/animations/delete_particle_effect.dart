import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:pickture/core/constants/app_constants.dart';
import 'package:pickture/core/theme/app_colors.dart';

class DeleteParticleEffect extends StatefulWidget {
  const DeleteParticleEffect({super.key});

  @override
  State<DeleteParticleEffect> createState() => _DeleteParticleEffectState();
}

class _DeleteParticleEffectState extends State<DeleteParticleEffect>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<_Particle> _particles;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppConstants.durationSlow,
    )..forward();

    final random = math.Random();
    _particles = List.generate(12, (_) {
      final angle = random.nextDouble() * 2 * math.pi;
      final speed = 50.0 + random.nextDouble() * 100;
      return _Particle(
        dx: math.cos(angle) * speed,
        dy: math.sin(angle) * speed,
        size: 4.0 + random.nextDouble() * 8,
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
        return CustomPaint(
          size: const Size(200, 200),
          painter: _ParticlePainter(
            particles: _particles,
            progress: _controller.value,
          ),
        );
      },
    );
  }
}

class _Particle {
  _Particle({required this.dx, required this.dy, required this.size});

  final double dx;
  final double dy;
  final double size;
}

class _ParticlePainter extends CustomPainter {
  _ParticlePainter({required this.particles, required this.progress});

  final List<_Particle> particles;
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()
      ..color = AppColors.delete.withValues(alpha: 1.0 - progress);

    for (final p in particles) {
      final offset = center + Offset(p.dx * progress, p.dy * progress);
      canvas.drawCircle(offset, p.size * (1.0 - progress * 0.5), paint);
    }
  }

  @override
  bool shouldRepaint(_ParticlePainter oldDelegate) =>
      progress != oldDelegate.progress;
}

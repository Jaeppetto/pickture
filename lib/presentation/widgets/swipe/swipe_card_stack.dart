import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:pickture/core/constants/app_constants.dart';
import 'package:pickture/core/utils/haptic_service.dart';
import 'package:pickture/domain/entities/photo.dart';
import 'package:pickture/presentation/widgets/swipe/animations/delete_particle_effect.dart';
import 'package:pickture/presentation/widgets/swipe/animations/keep_checkmark.dart';
import 'package:pickture/presentation/widgets/swipe/photo_detail_overlay.dart';
import 'package:pickture/presentation/widgets/swipe/swipe_card.dart';
import 'package:pickture/presentation/widgets/swipe/swipe_direction.dart';
import 'package:pickture/presentation/widgets/swipe/swipe_overlay.dart';

class SwipeCardStack extends StatefulWidget {
  const SwipeCardStack({
    super.key,
    required this.photos,
    required this.currentIndex,
    required this.onSwiped,
    this.hapticService,
  });

  final List<Photo> photos;
  final int currentIndex;
  final void Function(SwipeDirection direction) onSwiped;
  final HapticService? hapticService;

  @override
  State<SwipeCardStack> createState() => SwipeCardStackState();
}

class SwipeCardStackState extends State<SwipeCardStack>
    with SingleTickerProviderStateMixin {
  Offset _offset = Offset.zero;
  bool _isDragging = false;
  bool _showDetail = false;
  late AnimationController _animationController;
  Animation<Offset>? _animation;

  SwipeDirection? _currentDirection;
  double _currentOpacity = 0;

  // Swipe effect overlay
  SwipeDirection? _effectDirection;
  Timer? _effectTimer;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: AppConstants.durationSwipe,
    );
  }

  @override
  void dispose() {
    _effectTimer?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(SwipeCardStack oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentIndex != oldWidget.currentIndex) {
      _resetCard();
    }
  }

  void _showSwipeEffect(SwipeDirection direction) {
    if (direction == SwipeDirection.up) return;
    _effectTimer?.cancel();
    setState(() => _effectDirection = direction);
    _effectTimer = Timer(AppConstants.durationSlow, () {
      if (mounted) {
        setState(() => _effectDirection = null);
      }
    });
  }

  void _resetCard() {
    setState(() {
      _offset = Offset.zero;
      _currentDirection = null;
      _currentOpacity = 0;
      _showDetail = false;
    });
  }

  void animateSwipe(SwipeDirection direction) {
    final size = MediaQuery.of(context).size;
    late Offset target;
    switch (direction) {
      case SwipeDirection.left:
        target = Offset(-size.width * 1.5, 0);
      case SwipeDirection.right:
        target = Offset(size.width * 1.5, 0);
      case SwipeDirection.up:
        target = Offset(0, -size.height * 1.5);
    }

    _animation = Tween<Offset>(begin: _offset, end: target).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _animationController.forward(from: 0).then((_) {
      widget.onSwiped(direction);
      _showSwipeEffect(direction);
      _resetCard();
      _animationController.reset();
    });

    widget.hapticService?.mediumImpact();
  }

  void _onPanStart(DragStartDetails details) {
    _isDragging = true;
    _animationController.stop();
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (!_isDragging) return;
    setState(() {
      _offset += details.delta;
      _updateDirection();
    });
  }

  void _onPanEnd(DragEndDetails details) {
    _isDragging = false;
    final velocity = details.velocity.pixelsPerSecond;
    final distance = _offset.distance;

    SwipeDirection? direction;

    if (_offset.dx.abs() > _offset.dy.abs()) {
      // Horizontal
      if (distance > AppConstants.swipeThreshold ||
          velocity.distance > AppConstants.swipeVelocityThreshold) {
        direction = _offset.dx > 0 ? SwipeDirection.right : SwipeDirection.left;
      }
    } else if (_offset.dy < 0) {
      // Up
      if (_offset.dy.abs() > AppConstants.swipeUpThreshold ||
          velocity.distance > AppConstants.swipeVelocityThreshold) {
        direction = SwipeDirection.up;
      }
    }

    if (direction != null) {
      animateSwipe(direction);
    } else {
      _springBack();
    }
  }

  void _springBack() {
    _animation = Tween<Offset>(begin: _offset, end: Offset.zero).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );

    _animationController.addListener(_onSpringUpdate);
    _animationController.forward(from: 0).then((_) {
      _animationController.removeListener(_onSpringUpdate);
      setState(() {
        _offset = Offset.zero;
        _currentDirection = null;
        _currentOpacity = 0;
      });
    });
  }

  void _onSpringUpdate() {
    if (_animation != null) {
      setState(() {
        _offset = _animation!.value;
        _updateDirection();
      });
    }
  }

  void _updateDirection() {
    final absX = _offset.dx.abs();
    final absY = _offset.dy.abs();

    if (absX > absY && absX > 20) {
      _currentDirection = _offset.dx > 0
          ? SwipeDirection.right
          : SwipeDirection.left;
      _currentOpacity = (absX / AppConstants.swipeThreshold).clamp(0.0, 1.0);
    } else if (_offset.dy < -20) {
      _currentDirection = SwipeDirection.up;
      _currentOpacity = (absY / AppConstants.swipeUpThreshold).clamp(0.0, 1.0);
    } else {
      _currentDirection = null;
      _currentOpacity = 0;
    }

    // Haptic at threshold
    if (_currentOpacity >= 1.0 && _currentOpacity < 1.05) {
      widget.hapticService?.lightImpact();
    }
  }

  @override
  Widget build(BuildContext context) {
    final remaining = widget.photos.length - widget.currentIndex;
    final stackCount = math.min(AppConstants.cardStackSize, remaining);

    if (stackCount <= 0) return const SizedBox.shrink();

    return Stack(
      alignment: Alignment.center,
      children: [
        // Background cards
        for (int i = stackCount - 1; i > 0; i--) _buildBackCard(i),
        // Front card with gestures
        _buildFrontCard(),
        // Swipe effect overlay
        if (_effectDirection == SwipeDirection.left)
          const DeleteParticleEffect(),
        if (_effectDirection == SwipeDirection.right) const KeepCheckmark(),
      ],
    );
  }

  Widget _buildBackCard(int stackIndex) {
    final scale = 1.0 - (stackIndex * AppConstants.cardStackScale);
    final yOffset = stackIndex * AppConstants.cardStackOffset;
    final photoIndex = widget.currentIndex + stackIndex;

    if (photoIndex >= widget.photos.length) {
      return const SizedBox.shrink();
    }

    return Transform.translate(
      offset: Offset(0, yOffset),
      child: Transform.scale(
        scale: scale,
        child: Opacity(
          opacity: (1.0 - stackIndex * 0.2).clamp(0.0, 1.0),
          child: SizedBox(
            width: double.infinity,
            height: double.infinity,
            child: SwipeCard(photo: widget.photos[photoIndex]),
          ),
        ),
      ),
    );
  }

  Widget _buildFrontCard() {
    final photo = widget.photos[widget.currentIndex];
    final angle = _offset.dx / 1000;

    return GestureDetector(
      onPanStart: _onPanStart,
      onPanUpdate: _onPanUpdate,
      onPanEnd: _onPanEnd,
      onTap: () => setState(() => _showDetail = !_showDetail),
      child: Transform.translate(
        offset: _offset,
        child: Transform.rotate(
          angle: angle,
          child: SizedBox(
            width: double.infinity,
            height: double.infinity,
            child: Stack(
              fit: StackFit.expand,
              children: [
                SwipeCard(photo: photo),
                SwipeOverlay(
                  direction: _currentDirection,
                  opacity: _currentOpacity,
                ),
                if (_showDetail)
                  PhotoDetailOverlay(
                    photo: photo,
                    onClose: () => setState(() => _showDetail = false),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

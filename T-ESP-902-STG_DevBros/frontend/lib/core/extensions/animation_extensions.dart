import 'package:flutter/material.dart';

extension AnimationExtensions on Widget {
  /// Wraps widget in FadeTransition
  Widget fadeTransition(Animation<double> animation) {
    return FadeTransition(
      opacity: animation,
      child: this,
    );
  }

  /// Wraps widget in ScaleTransition
  Widget scaleTransition(Animation<double> animation) {
    return ScaleTransition(
      scale: animation,
      child: this,
    );
  }

  /// Wraps widget in SlideTransition
  Widget slideTransition(Animation<Offset> animation) {
    return SlideTransition(
      position: animation,
      child: this,
    );
  }

  /// Wraps widget in both FadeTransition and ScaleTransition
  Widget fadeScaleTransition({
    required Animation<double> fadeAnimation,
    required Animation<double> scaleAnimation,
  }) {
    return FadeTransition(
      opacity: fadeAnimation,
      child: ScaleTransition(
        scale: scaleAnimation,
        child: this,
      ),
    );
  }

  /// Wraps widget in both FadeTransition and SlideTransition
  Widget fadeSlideTransition({
    required Animation<double> fadeAnimation,
    required Animation<Offset> slideAnimation,
  }) {
    return FadeTransition(
      opacity: fadeAnimation,
      child: SlideTransition(
        position: slideAnimation,
        child: this,
      ),
    );
  }
}

/// Helper class for creating staggered animations
class StaggeredAnimationHelper {
  static Animation<double> createStaggeredFade(
    AnimationController controller, {
    required double beginInterval,
    required double endInterval,
    Curve curve = Curves.easeOut,
  }) {
    return Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: controller,
        curve: Interval(beginInterval, endInterval, curve: curve),
      ),
    );
  }

  static Animation<Offset> createStaggeredSlide(
    AnimationController controller, {
    required double beginInterval,
    required double endInterval,
    Offset beginOffset = const Offset(0, 0.2),
    Curve curve = Curves.easeOut,
  }) {
    return Tween<Offset>(begin: beginOffset, end: Offset.zero).animate(
      CurvedAnimation(
        parent: controller,
        curve: Interval(beginInterval, endInterval, curve: curve),
      ),
    );
  }

  static Animation<double> createStaggeredScale(
    AnimationController controller, {
    required double beginInterval,
    required double endInterval,
    double beginScale = 0.8,
    Curve curve = Curves.easeOut,
  }) {
    return Tween<double>(begin: beginScale, end: 1.0).animate(
      CurvedAnimation(
        parent: controller,
        curve: Interval(beginInterval, endInterval, curve: curve),
      ),
    );
  }
}

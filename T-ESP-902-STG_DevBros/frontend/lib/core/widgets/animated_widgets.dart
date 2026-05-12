import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shimmer/shimmer.dart';

/// Widget avec Staggered Animation
class StaggeredAnimationCard extends StatelessWidget {
  const StaggeredAnimationCard({
    super.key,
    required this.child,
    required this.index,
    this.delay = const Duration(milliseconds: 100),
  });

  final Widget child;
  final int index;
  final Duration delay;

  @override
  Widget build(BuildContext context) {
    return child
        .animate()
        .fadeIn(
          duration: 500.ms,
          delay: (delay * index),
        )
        .slideY(
          begin: 0.3,
          end: 0,
          duration: 500.ms,
          delay: (delay * index),
          curve: Curves.easeOutCubic,
        );
  }
}

/// Parallax Container pour destinations
class ParallaxContainer extends StatefulWidget {
  const ParallaxContainer({
    super.key,
    required this.child,
    this.parallaxStrength = 0.1,
  });

  final Widget child;
  final double parallaxStrength;

  @override
  State<ParallaxContainer> createState() => _ParallaxContainerState();
}

class _ParallaxContainerState extends State<ParallaxContainer> {
  late ScrollController _scrollController;
  double _offset = 0;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    setState(() {
      _offset = _scrollController.offset * widget.parallaxStrength;
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: Offset(0, _offset),
      child: widget.child,
    );
  }
}

/// Hero Animation Button pour Valises
class HeroAnimationCard extends StatefulWidget {
  const HeroAnimationCard({
    super.key,
    required this.child,
    required this.onTap,
    required this.tag,
  });

  final Widget child;
  final VoidCallback onTap;
  final String tag;

  @override
  State<HeroAnimationCard> createState() => _HeroAnimationCardState();
}

class _HeroAnimationCardState extends State<HeroAnimationCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        setState(() => _isPressed = true);
      },
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () {
        setState(() => _isPressed = false);
      },
      child: Hero(
        tag: widget.tag,
        flightShuttleBuilder: (context, animation, direction, fromContext, toContext) {
          return Material(
            type: MaterialType.transparency,
            child: ScaleTransition(
              scale: animation.drive(Tween<double>(begin: 1.0, end: 0.95)),
              child: toContext.widget,
            ),
          );
        },
        child: AnimatedScale(
          scale: _isPressed ? 0.95 : 1.0,
          duration: 150.ms,
          child: AnimatedOpacity(
            opacity: _isPressed ? 0.8 : 1.0,
            duration: 150.ms,
            child: widget.child,
          ),
        ),
      ),
    );
  }
}

/// Gradient Background Animé
class AnimatedGradientBackground extends StatefulWidget {
  const AnimatedGradientBackground({
    super.key,
    required this.child,
    required this.colors,
    this.duration = const Duration(seconds: 3),
  });

  final Widget child;
  final List<Color> colors;
  final Duration duration;

  @override
  State<AnimatedGradientBackground> createState() =>
      _AnimatedGradientBackgroundState();
}

class _AnimatedGradientBackgroundState extends State<AnimatedGradientBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    )..repeat();
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
      builder: (context, child) {
        final colors = widget.colors;
        final colorIndex = (_controller.value * colors.length).toInt() % colors.length;
        final nextColorIndex = (colorIndex + 1) % colors.length;
        final colorProgress = (_controller.value * colors.length) % 1.0;

        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color.lerp(colors[colorIndex], colors[nextColorIndex], colorProgress) ??
                    colors[colorIndex],
                Color.lerp(colors[nextColorIndex], colors[colorIndex], colorProgress) ??
                    colors[nextColorIndex],
              ],
            ),
          ),
          child: widget.child,
        );
      },
    );
  }
}

/// Slider avec couleurs animées
class AnimatedColorfulSlider extends StatefulWidget {
  const AnimatedColorfulSlider({
    super.key,
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.onChanged,
    this.colorStops = const [
      Color(0xFF4CAF50),
      Color(0xFFFFC107),
      Color(0xFFFF5722),
    ],
  });

  final double value;
  final double min;
  final double max;
  final int divisions;
  final ValueChanged<double> onChanged;
  final List<Color> colorStops;

  @override
  State<AnimatedColorfulSlider> createState() => _AnimatedColorfulSliderState();
}

class _AnimatedColorfulSliderState extends State<AnimatedColorfulSlider>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color _getSliderColor(double value) {
    final progress = (value - widget.min) / (widget.max - widget.min);

    if (progress <= 0.5) {
      final localProgress = progress * 2;
      return Color.lerp(
        widget.colorStops[0],
        widget.colorStops[1],
        localProgress,
      )!;
    } else {
      final localProgress = (progress - 0.5) * 2;
      return Color.lerp(
        widget.colorStops[1],
        widget.colorStops[2],
        localProgress,
      )!;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return SliderTheme(
              data: SliderThemeData(
                activeTrackColor: _getSliderColor(widget.value),
                inactiveTrackColor: Colors.grey.shade300,
                thumbColor: _getSliderColor(widget.value),
                trackHeight: 6,
              ),
              child: Slider(
                value: widget.value,
                min: widget.min,
                max: widget.max,
                divisions: widget.divisions,
                label: '${widget.value.toInt()} days',
                onChanged: (value) {
                  _controller.forward(from: 0);
                  widget.onChanged(value);
                },
              ),
            );
          },
        ),
        const SizedBox(height: 8),
        ScaleTransition(
          scale: Tween<double>(begin: 0.8, end: 1.0).animate(
            CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: _getSliderColor(widget.value).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: _getSliderColor(widget.value),
                width: 2,
              ),
            ),
            child: Text(
              '${widget.value.toInt()} days',
              style: TextStyle(
                color: _getSliderColor(widget.value),
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Shimmer Skeleton Loader
class ShimmerLoader extends StatelessWidget {
  const ShimmerLoader({
    super.key,
    this.width = double.infinity,
    this.height = 100,
    this.borderRadius = const BorderRadius.all(Radius.circular(8)),
  });

  final double width;
  final double height;
  final BorderRadius borderRadius;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius: borderRadius,
        ),
      ),
    );
  }
}

/// Pulse Animation
class PulseAnimation extends StatefulWidget {
  const PulseAnimation({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 1500),
  });

  final Widget child;
  final Duration duration;

  @override
  State<PulseAnimation> createState() => _PulseAnimationState();
}

class _PulseAnimationState extends State<PulseAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    )..repeat();

    _animation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _animation,
      child: widget.child,
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_carousel_widget/flutter_carousel_widget.dart';
import 'package:go_router/go_router.dart';
import 'package:inspiria/features/launch/data/first_launch_service.dart';
import 'package:inspiria/routes/router_enum.dart';

class LaunchPageScreen extends StatefulWidget {
  const LaunchPageScreen({super.key});

  @override
  State<LaunchPageScreen> createState() => _LaunchPageScreenState();
}

class _LaunchPageScreenState extends State<LaunchPageScreen> with TickerProviderStateMixin {
  int _currentCarouselIndex = 0;
  late final FlutterCarouselController buttonCarouselController;
  late AnimationController _fadeController;
  late AnimationController _textAnimationController;
  late Animation<double> _textFadeAnimation;
  late Animation<Offset> _textSlideAnimation;

  final List<String> _carouselTexts = [
    'Discover your unique \nstyle thanks to the AI',
    'Scan your clothes \nand create your wardrobe',
    'Ready to shine?',
  ];

  final List<String> _carouselSubtexts = [
    'Custom looks in a flash.',
    'Without moving from home, thanks to our AI \nmode.',
    'Generate your first outfit in a few minutes.',
  ];

  @override
  void initState() {
    super.initState();
    buttonCarouselController = FlutterCarouselController();
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _textAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _textFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _textAnimationController, curve: Curves.easeOut),
    );

    _textSlideAnimation = Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
      CurvedAnimation(parent: _textAnimationController, curve: Curves.easeOut),
    );

    _fadeController.forward();
    _textAnimationController.forward();
    _checkFirstLaunch();
  }

  Future<void> _checkFirstLaunch() async {
    final bool isFirst = await FirstLaunchService.isFirstLaunch();
    if (!isFirst && mounted) {
      context.goNamed(SCREEN.PRELOGIN.name);
    }
  }

  Future<void> _completeOnboarding() async {
    await FirstLaunchService.setFirstLaunchCompleted();
    if (mounted) {
      context.goNamed(SCREEN.PRELOGIN.name);
    }
  }

  void _onCarouselPageChanged(int index) {
    setState(() {
      _currentCarouselIndex = index;
    });
    _textAnimationController.reset();
    _textAnimationController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _textAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            top: screenHeight * 0.08,
            right: screenWidth * 0.08,
            child: FadeTransition(
              opacity: Tween<double>(begin: 0.0, end: 0.4).animate(
                CurvedAnimation(
                  parent: _fadeController,
                  curve: const Interval(0.2, 0.6, curve: Curves.easeOut),
                ),
              ),
              child: GestureDetector(
                onTap: _completeOnboarding,
                child: const Text(
                  'Skip',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.grey,
                  ),
                ),
              ),
            ),
          ),
          
          Positioned(
            top: screenHeight * 0.20,
            left: 0,
            right: 0,
            child: SlideTransition(
              position: Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
                CurvedAnimation(
                  parent: _fadeController,
                  curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
                ),
              ),
              child: FadeTransition(
                opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
                  CurvedAnimation(
                    parent: _fadeController,
                    curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
                  ),
                ),
                child: Center(
                  child: Container(
                    width: screenWidth * 0.85,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.15),
                          offset: const Offset(0, 10),
                          blurRadius: 25,
                        ),
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 10,
                        ),
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          offset: const Offset(5, 0),
                          blurRadius: 15,
                        ),
                      ],
                    ),
                    clipBehavior: Clip.hardEdge,
                    child: FlutterCarousel(
                      options: FlutterCarouselOptions(
                        height: 400.0,
                        controller: buttonCarouselController,
                        viewportFraction: 1,
                        slideIndicator: CircularSlideIndicator(),
                        onPageChanged: (index, reason) => _onCarouselPageChanged(index),
                        physics: const ClampingScrollPhysics(),
                        disableCenter: true,
                      ),
                      items: [
                        'assets/images/first_image_carousel.png',
                        'assets/images/seconde_image_carousel.png',
                        'assets/images/third_image_carousel.png',
                      ].map((imagePath) {
                        return Builder(
                          builder: (BuildContext context) {
                            return Container(
                              width: MediaQuery.of(context).size.width,
                              margin: const EdgeInsets.symmetric(horizontal: 5.0),
                              child: Image(
                                image: AssetImage(imagePath),
                                fit: BoxFit.cover,
                              ),
                            );
                          },
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Text content
          Positioned(
            top: screenHeight * 0.65,
            left: 20,
            right: 20,
            child: SlideTransition(
              position: _textSlideAnimation,
              child: FadeTransition(
                opacity: _textFadeAnimation,
                child: Column(
                  children: [
                    const SizedBox(height: 30),
                    Text(
                      _carouselTexts[_currentCarouselIndex],
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontFamily: 'Poppins', // Utilisation de ton asset local
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1F1B1B),
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 24),
                    FadeTransition(
                      opacity: Tween<double>(begin: 0.0, end: 0.6).animate(
                        CurvedAnimation(
                          parent: _textAnimationController,
                          curve: const Interval(0.2, 0.8, curve: Curves.easeOut),
                        ),
                      ),
                      child: Text(
                        _carouselSubtexts[_currentCarouselIndex],
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w500,
                          fontSize: 15,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:inspiria/routes/router_enum.dart';

class PreloginScreen extends StatefulWidget {
  const PreloginScreen({super.key});

  @override
  State<PreloginScreen> createState() => _PreloginScreenState();
}

class _PreloginScreenState extends State<PreloginScreen> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _carouselController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late PageController _pageController;
  int _currentCarouselIndex = 0;

  final List<Map<String, dynamic>> _carouselItems = [
    {
      'icon': Icons.luggage_outlined,
      'label': 'Luggage',
      'description': 'Organize your outfits',
    },
    {
      'icon': Icons.checkroom,
      'label': 'Outfit',
      'description': 'Create your looks',
    },
    {
      'icon': Icons.favorite,
      'label': 'Inspiration',
      'description': 'Share your styles',
    },
  ];

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1400),
      vsync: this,
    );

    _carouselController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _pageController = PageController();

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );

    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOut),
    );

    _fadeController.forward();
    _slideController.forward();

    // Auto-carousel every 4 seconds
    Future.delayed(const Duration(seconds: 3), _autoCarousel);
  }

  void _autoCarousel() {
    if (_pageController.hasClients) {
      _currentCarouselIndex = (_currentCarouselIndex + 1) % _carouselItems.length;
      _pageController.animateToPage(
        _currentCarouselIndex,
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeInOut,
      );
      Future.delayed(const Duration(seconds: 4), _autoCarousel);
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _carouselController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Stack(
        children: [
          // Hero Image Background (fullscreen)
          Positioned.fill(
            child: Image.asset(
              'assets/images/pre_loginv2.png',
              fit: BoxFit.cover,
            ),
          ),

          // Dark gradient overlay
          Positioned.fill(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.3),
                      Colors.black.withValues(alpha: 0.5),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Main Content with Glassmorphism
          SafeArea(
            child: SlideTransition(
              position: _slideAnimation,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Top Spacer
                    SizedBox(height: screenHeight * 0.04),

                    // Glassmorphism Card
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Glass Card Container
                            ClipRRect(
                              borderRadius: BorderRadius.circular(32),
                              child: BackdropFilter(
                                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                                child: Container(
                                  padding: const EdgeInsets.all(28),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(32),
                                    border: Border.all(
                                      color: Colors.white.withValues(alpha: 0.25),
                                      width: 1.5,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.1),
                                        blurRadius: 30,
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      // Carousel avec Valise / Outfit / Inspiration
                                      SizedBox(
                                        height: 150,
                                        child: PageView.builder(
                                          controller: _pageController,
                                          onPageChanged: (index) {
                                            setState(() {
                                              _currentCarouselIndex = index;
                                            });
                                          },
                                          itemCount: _carouselItems.length,
                                          itemBuilder: (context, index) {
                                            final item = _carouselItems[index];
                                            final isActive = index == _currentCarouselIndex;
                                            return AnimatedScale(
                                              scale: isActive ? 1.0 : 0.85,
                                              duration: const Duration(milliseconds: 400),
                                              child: Column(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  // Circular Icon with Black Background
                                                  Container(
                                                    height: 75,
                                                    width: 75,
                                                    decoration: BoxDecoration(
                                                      shape: BoxShape.circle,
                                                      color: Colors.black.withValues(alpha: 0.6),
                                                      boxShadow: [
                                                        BoxShadow(
                                                          color: Colors.black.withValues(alpha: 0.5),
                                                          blurRadius: 20,
                                                        ),
                                                      ],
                                                    ),
                                                    child: Icon(
                                                      item['icon'] as IconData,
                                                      size: 35,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 10),
                                                  Text(
                                                    item['label'] as String,
                                                    style: GoogleFonts.poppins(
                                                      fontSize: 18,
                                                      fontWeight: FontWeight.w700,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    item['description'] as String,
                                                    textAlign: TextAlign.center,
                                                    style: GoogleFonts.poppins(
                                                      fontSize: 12,
                                                      fontWeight: FontWeight.w400,
                                                      color: Colors.white.withValues(alpha: 0.6),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            );
                                          },
                                        ),
                                      ),

                                      const SizedBox(height: 20),

                                      // Carousel Indicators
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: List.generate(
                                          _carouselItems.length,
                                          (index) => AnimatedContainer(
                                            duration: const Duration(milliseconds: 300),
                                            margin: const EdgeInsets.symmetric(horizontal: 6),
                                            height: 8,
                                            width: index == _currentCarouselIndex ? 24 : 8,
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(4),
                                              color: index == _currentCarouselIndex
                                                  ? const Color.fromARGB(255, 255, 255, 255)
                                                  : Colors.white.withValues(alpha: 0.3),
                                            ),
                                          ),
                                        ),
                                      ),

                                      const SizedBox(height: 20),

                                      // Tagline
                                      Text(
                                        'Explore',
                                        textAlign: TextAlign.center,
                                        style: GoogleFonts.poppins(
                                          fontSize: 28,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white,
                                          letterSpacing: -0.5,
                                        ),
                                      ),

                                      const SizedBox(height: 6),

                                      // Subtitle
                                      Text(
                                        'Create • Inspire',
                                        textAlign: TextAlign.center,
                                        style: GoogleFonts.poppins(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.white.withValues(alpha: 0.8),
                                          letterSpacing: 0.5,
                                        ),
                                      ),

                                      const SizedBox(height: 8),

                                      // Description
                                      Text(
                                        'Transform your wardrobe\ninto a personal experience',
                                        textAlign: TextAlign.center,
                                        style: GoogleFonts.poppins(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w400,
                                          color: Colors.white.withValues(alpha: 0.7),
                                          height: 1.4,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Bottom Buttons Section
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Se Connecter Button - Gradient
                          SlideTransition(
                            position: Tween<Offset>(begin: const Offset(0, 0.4), end: Offset.zero)
                                .animate(
                              CurvedAnimation(
                                parent: _slideController,
                                curve: const Interval(0.2, 0.8, curve: Curves.easeOut),
                              ),
                            ),
                            child: FadeTransition(
                              opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
                                CurvedAnimation(
                                  parent: _slideController,
                                  curve: const Interval(0.2, 0.8, curve: Curves.easeOut),
                                ),
                              ),
                              child: Container(
                                height: 50,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      const Color(0xFF1F1B1B),
                                      const Color(0xFF1F1B1B).withValues(alpha: 0.85),
                                    ],
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF1F1B1B).withValues(alpha: 0.4),
                                      blurRadius: 20,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    onTap: () {
                                      context.go(SCREEN.LOGIN.path);
                                    },
                                    borderRadius: BorderRadius.circular(16),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const Icon(Icons.login, color: Colors.white, size: 20),
                                        const SizedBox(width: 12),
                                        Text(
                                          'Log In',
                                          style: GoogleFonts.poppins(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w700,
                                            color: Colors.white,
                                            letterSpacing: 0.3,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 10),

                          // Créer un compte Button - Glass effect
                          SlideTransition(
                            position: Tween<Offset>(begin: const Offset(0, 0.4), end: Offset.zero)
                                .animate(
                              CurvedAnimation(
                                parent: _slideController,
                                curve: const Interval(0.35, 0.95, curve: Curves.easeOut),
                              ),
                            ),
                            child: FadeTransition(
                              opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
                                CurvedAnimation(
                                  parent: _slideController,
                                  curve: const Interval(0.35, 0.95, curve: Curves.easeOut),
                                ),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: BackdropFilter(
                                  filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                                  child: Container(
                                    height: 50,
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: Colors.white.withValues(alpha: 0.4),
                                        width: 1.5,
                                      ),
                                    ),
                                    child: Material(
                                      color: Colors.transparent,
                                      child: InkWell(
                                        onTap: () {
                                          context.go(SCREEN.REGISTER.path);
                                        },
                                        borderRadius: BorderRadius.circular(16),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            const Icon(Icons.person_add, color: Colors.white, size: 20),
                                            const SizedBox(width: 12),
                                            Text(
                                              'Create Account',
                                              style: GoogleFonts.poppins(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w700,
                                                color: Colors.white,
                                                letterSpacing: 0.3,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 10),

                          // Continuer en tant qu'invité - Minimal
                          SlideTransition(
                            position: Tween<Offset>(begin: const Offset(0, 0.4), end: Offset.zero)
                                .animate(
                              CurvedAnimation(
                                parent: _slideController,
                                curve: const Interval(0.5, 1.0, curve: Curves.easeOut),
                              ),
                            ),
                            child: FadeTransition(
                              opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
                                CurvedAnimation(
                                  parent: _slideController,
                                  curve: const Interval(0.5, 1.0, curve: Curves.easeOut),
                                ),
                              ),
                              child: SizedBox(
                                height: 48,
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    onTap: () {
                                      context.goNamed(SCREEN.HOMEPAGE.name);
                                    },
                                    borderRadius: BorderRadius.circular(12),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          'Continue as Guest',
                                          style: GoogleFonts.poppins(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white.withValues(alpha: 0.8),
                                            decoration: TextDecoration.underline,
                                            decorationColor: Colors.white.withValues(alpha: 0.5),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 20),
                        ],
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

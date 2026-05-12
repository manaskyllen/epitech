import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:inspiria/core/api/token_storage.dart';
import 'package:inspiria/core/widgets/profile_button.dart';
import 'package:inspiria/features/outfit/data/clothing_material/clothing_service.dart';
import 'package:inspiria/features/outfit/data/outfit_service.dart';
import 'package:inspiria/features/suitcase/data/suitcase_service.dart';
import 'package:inspiria/routes/router_enum.dart';

class HomePageScreen extends StatefulWidget {
  const HomePageScreen({super.key});

  @override
  State<HomePageScreen> createState() => _HomePageScreenState();
}

class _HomePageScreenState extends State<HomePageScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // Statistics
  int clothingCount = 0;
  int dressCount = 0;
  int suitcaseCount = 0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _animationController.forward();
    _loadUserStatistics();
  }

  Future<void> _loadUserStatistics() async {
    try {
      final userId = await TokenStorage().getUserId();
      if (userId == null) {
        return;
      }

      // Fetch statistics from services (static methods)
      final clothingData = await ClothingService.getClothingByUserId(userId.toString());
      final outfitData = await OutfitService.getOutfitByUserId(userId.toString());
      final suitcaseData = await SuitcaseService.getAllSuitcaseByUserId(userId.toString());

      setState(() {
        clothingCount = clothingData?.clothingList?.length ?? 0;
        dressCount = outfitData?.outfitList?.length ?? 0;
        suitcaseCount = suitcaseData?.suitcaseList?.length ?? 0;
      });
    } catch (e) {
      debugPrint('Error loading statistics: $e');
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            // Modern Header
            SliverAppBar(
              floating: true,
              snap: true,
              elevation: 0,
              backgroundColor: const Color(0xFFFAFAFA),
              centerTitle: false,
              title: SlideTransition(
                position: _slideAnimation,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Inspiria',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF1F1B1B),
                            ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Explore. Create. Inspire.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: const Color(0xFF9CA3AF),
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: const [
                ProfileButton(),
                SizedBox(width: 8),
              ],
            ),
            // Content
            SliverToBoxAdapter(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    // Main Cards Section
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        children: [
                          // OUTFIT Card
                          _buildEnhancedCard(
                            context: context,
                            height: screenHeight * 0.22,
                            width: screenWidth - 32,
                            imagePath: 'assets/images/home_outfitv2.png',
                            label: 'OUTFIT',
                            description: 'Create your own looks',
                            icon: Icons.checkroom_outlined,
                            color: const Color(0xFF1F1B1B),
                            onTap: () => context.go(SCREEN.OUTFIT.path),
                            delay: 0.1,
                          ),
                          const SizedBox(height: 16),
                          // INSPIRATION Card - Coming Soon
                          _buildComingSoonCard(
                            context: context,
                            height: screenHeight * 0.22,
                            width: screenWidth - 32,
                            imagePath: 'assets/images/home_inspirationv2.png',
                            label: 'INSPIRATION',
                            description: 'Coming Soon',
                            delay: 0.2,
                          ),
                          const SizedBox(height: 16),
                          // TRAVEL Card
                          _buildEnhancedCard(
                            context: context,
                            height: screenHeight * 0.22,
                            width: screenWidth - 32,
                            imagePath: 'assets/images/VoyageValisev2.png',
                            label: 'TRAVEL',
                            description: 'Prepare your luggage',
                            icon: Icons.luggage_outlined,
                            color: const Color(0xFF1F1B1B),
                            onTap: () => context.go(SCREEN.TRAVEL.path),
                            delay: 0.3,
                          ),
                          const SizedBox(height: 32),
                          // Trending Stats Section
                          _buildTrendingStatsSection(context),
                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.1),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Enhanced card with animation and better styling
  Widget _buildEnhancedCard({
    required BuildContext context,
    required double height,
    required double width,
    required String imagePath,
    required String label,
    required String description,
    IconData? icon,
    Color? color,
    required VoidCallback onTap,
    required double delay,
  }) {
    return SlideTransition(
      position: Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero)
          .animate(CurvedAnimation(
            parent: _animationController,
            curve: Interval(delay, delay + 0.4, curve: Curves.easeOut),
          )),
      child: FadeTransition(
        opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Interval(delay, delay + 0.4, curve: Curves.easeOut),
          ),
        ),
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            height: height,
            width: width,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha((0.08 * 255).round()),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onTap,
                borderRadius: BorderRadius.circular(20),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Background Image
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.asset(imagePath, fit: BoxFit.cover),
                    ),

                    // Gradient Overlay
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withAlpha((0.3 * 255).round()),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Content
                    if (label.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Top Badge
                            if (icon != null)
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white.withAlpha((0.95 * 255).round()),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(icon, color: color ?? const Color(0xFF1F1B1B), size: 20),
                              ),
                            // Bottom Text
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  label,
                                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                        fontWeight: FontWeight.w800,
                                        color: Colors.white,
                                        letterSpacing: 1,
                                      ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  description,
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: Colors.white.withAlpha((0.8 * 255).round()),
                                        fontWeight: FontWeight.w500,
                                      ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Coming Soon Card
  Widget _buildComingSoonCard({
    required BuildContext context,
    required double height,
    required double width,
    required String imagePath,
    required String label,
    required String description,
    required double delay,
  }) {
    return SlideTransition(
      position: Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero)
          .animate(CurvedAnimation(
            parent: _animationController,
            curve: Interval(delay, delay + 0.4, curve: Curves.easeOut),
          )),
      child: FadeTransition(
        opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Interval(delay, delay + 0.4, curve: Curves.easeOut),
          ),
        ),
        child: Container(
          height: height,
          width: width,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha((0.08 * 255).round()),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Background Image
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.asset(imagePath, fit: BoxFit.cover),
              ),

              // Gradient Overlay - Lighter for Coming Soon
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withAlpha((0.2 * 255).round()),
                      ],
                    ),
                  ),
                ),
              ),

              // Coming Soon Badge & Content
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Top Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.schedule_outlined, size: 14, color: Color(0xFF1F1B1B)),
                          const SizedBox(width: 6),
                          Text(
                            'Coming Soon',
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                  color: const Color(0xFF1F1B1B),
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                        ],
                      ),
                    ),
                    // Bottom Text
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'INSPIRATION',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                letterSpacing: 1,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'In Development',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.white.withAlpha((0.8 * 255).round()),
                                fontWeight: FontWeight.w500,
                              ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Trending stats dashboard section
  Widget _buildTrendingStatsSection(BuildContext context) {
    return SlideTransition(
      position: Tween<Offset>(begin: const Offset(0, 0.4), end: Offset.zero).animate(
        CurvedAnimation(
          parent: _animationController,
          curve: const Interval(0.4, 0.8, curve: Curves.easeOut),
        ),
      ),
      child: FadeTransition(
        opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: const Interval(0.4, 0.8, curve: Curves.easeOut),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              // Section Title
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Your Statistics',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF1F1B1B),
                      ),
                ),
              ),
              const SizedBox(height: 16),
              // Stats Row
              Row(
                children: [
                  Expanded(
                    child: SlideTransition(
                      position: Tween<Offset>(begin: const Offset(-0.2, 0), end: Offset.zero).animate(
                        CurvedAnimation(
                          parent: _animationController,
                          curve: const Interval(0.3, 0.6, curve: Curves.easeOut),
                        ),
                      ),
                      child: FadeTransition(
                        opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
                          CurvedAnimation(
                            parent: _animationController,
                            curve: const Interval(0.3, 0.6, curve: Curves.easeOut),
                          ),
                        ),
                        child: _buildStatCard(
                          context: context,
                          icon: Icons.shopping_bag,
                          label: 'Clothing',
                          value: '$clothingCount',
                          color: const Color(0xFF1F1B1B),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SlideTransition(
                      position: Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
                        CurvedAnimation(
                          parent: _animationController,
                          curve: const Interval(0.4, 0.7, curve: Curves.easeOut),
                        ),
                      ),
                      child: FadeTransition(
                        opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
                          CurvedAnimation(
                            parent: _animationController,
                            curve: const Interval(0.4, 0.7, curve: Curves.easeOut),
                          ),
                        ),
                        child: _buildStatCard(
                          context: context,
                          icon: Icons.checkroom,
                          label: 'Looks',
                          value: '$dressCount',
                          color: const Color(0xFFFFD700),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SlideTransition(
                      position: Tween<Offset>(begin: const Offset(0.2, 0), end: Offset.zero).animate(
                        CurvedAnimation(
                          parent: _animationController,
                          curve: const Interval(0.5, 0.8, curve: Curves.easeOut),
                        ),
                      ),
                      child: FadeTransition(
                        opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
                          CurvedAnimation(
                            parent: _animationController,
                            curve: const Interval(0.5, 0.8, curve: Curves.easeOut),
                          ),
                        ),
                        child: _buildStatCard(
                          context: context,
                          icon: Icons.luggage,
                          label: 'Suitcases',
                          value: '$suitcaseCount',
                          color: const Color(0xFF8B6F47),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Individual stat card widget
  Widget _buildStatCard({
    required BuildContext context,
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white,
        border: Border.all(color: Colors.grey.withAlpha((0.1 * 255).round())),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((0.04 * 255).round()),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withAlpha((0.1 * 255).round()),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF1F1B1B),
                ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: const Color(0xFF9CA3AF),
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}

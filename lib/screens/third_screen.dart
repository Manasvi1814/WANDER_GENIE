import 'package:flutter/material.dart';
import '../app_constants.dart';

class ThirdScreen extends StatelessWidget {
  const ThirdScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Design Tokens
    const Color primaryColor = Color(0xFF894B35);
    const Color surfaceColor = Color(0xFFFBF9F4);
    const Color onSurfaceVariant = Color(0xFF53433E);
    const Color surfaceContainerHigh = Color(0xFFEAE8E3);
    const Color primaryFixedDim = Color(0xFFB59BFF); // Approximate for the blur effect
    const Color secondaryFixed = Color(0xFFBFEBEC);

    return Scaffold(
      backgroundColor: surfaceColor,
      appBar: AppBar(
        backgroundColor: surfaceColor.withOpacity(0.8),
        elevation: 0,
        scrolledUnderElevation: 0,
        toolbarHeight: 64,
        leadingWidth: 56,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: IconButton(
            icon: const Icon(Icons.menu, color: primaryColor),
            onPressed: () {},
          ),
        ),
        title: const Text(
          'Wander Genie',
          style: TextStyle(
            fontFamily: 'Serif',
            color: primaryColor,
            fontWeight: FontWeight.w700,
            fontSize: 24,
            letterSpacing: -0.5,
          ),
        ),
        centerTitle: false,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFFFDBCF), width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipOval(
                child: Image.network(
                  AppImages.profilePic,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => const Icon(Icons.person),
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Search / Entry Point
            _buildSearchSection(surfaceContainerHigh, primaryColor, primaryFixedDim, secondaryFixed),

            // 2. Recommendations Feed
            _buildRecommendationsSection(primaryColor, onSurfaceVariant),

            // 3. Trending Festivals
            _buildFestivalsSection(primaryColor, onSurfaceVariant),

            const SizedBox(height: 120), // Padding for BottomNav and FAB
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: primaryColor,
        shape: const CircleBorder(),
        elevation: 8,
        child: const Icon(Icons.auto_awesome, color: Colors.white, size: 28),
      ),
      bottomNavigationBar: _buildBottomNav(surfaceColor),
    );
  }

  Widget _buildSearchSection(Color bg, Color primary, Color blur1, Color blur2) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: primary.withOpacity(0.08),
              blurRadius: 40,
              offset: const Offset(0, 20),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            // Blur Decorations
            Positioned(
              top: -50,
              right: -50,
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  color: blur1.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              bottom: -50,
              left: -50,
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  color: blur2.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
              child: Column(
                children: [
                  const Text(
                    'Where shall your curiosity take you?',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Serif',
                      fontSize: 28,
                      fontWeight: FontWeight.w600,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'The "Genie" is ready to curate your next meaningful journey.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF53433E),
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Search Input
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(100),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(4),
                    child: Row(
                      children: [
                        const SizedBox(width: 16),
                        const Icon(Icons.auto_awesome, color: Color(0xFF894B35)),
                        const Expanded(
                          child: TextField(
                            decoration: InputDecoration(
                              hintText: 'Tell the Genie: "A 4-day food tour in Lisbon"...',
                              hintStyle: TextStyle(color: Color(0xFF86736D), fontSize: 14),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(horizontal: 12),
                            ),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primary,
                            foregroundColor: Colors.white,
                            shape: const StadiumBorder(),
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          ),
                          child: const Text('Plan', style: TextStyle(fontWeight: FontWeight.w500)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendationsSection(Color primary, Color onSurfaceVariant) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'CURATED FOR YOU',
                    style: TextStyle(
                      fontSize: 12,
                      letterSpacing: 2,
                      fontWeight: FontWeight.bold,
                      color: primary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Weekly Discoveries',
                    style: TextStyle(
                      fontFamily: 'Serif',
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              TextButton(
                onPressed: () {},
                child: Text('View Editorial', style: TextStyle(color: primary, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              _buildDiscoveryCard(
                AppImages.kyoto,
                'Best in Spring',
                const Color(0xFF3C6567),
                'A Slow Weekend in Kyoto',
                'Discover hidden tea houses and quiet bamboo paths away from the crowds.',
              ),
              _buildDiscoveryCard(
                AppImages.amalfi,
                'Coastal Luxury',
                const Color(0xFF894B35),
                'Exploring the Amalfi Coast',
                'A curated guide to the most exquisite lemon groves and seaside dining.',
              ),
              _buildDiscoveryCard(
                AppImages.iceland,
                'Unique Stays',
                const Color(0xFF827262),
                'The Nordic Solitude',
                'Where modern architecture meets the raw, untamed beauty of Iceland.',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDiscoveryCard(String image, String tag, Color tagColor, String title, String desc) {
    return Container(
      width: 280,
      margin: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Stack(
              children: [
                AspectRatio(
                  aspectRatio: 4 / 5,
                  child: Image.network(
                    image,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: tagColor,
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Text(
                      tag,
                      style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontFamily: 'Serif', fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            desc,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Color(0xFF53433E), fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildFestivalsSection(Color primary, Color onSurfaceVariant) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Trending Festivals',
                style: TextStyle(fontFamily: 'Serif', fontSize: 24, fontWeight: FontWeight.bold),
              ),
              Row(
                children: [
                  _buildNavButton(Icons.chevron_left),
                  const SizedBox(width: 8),
                  _buildNavButton(Icons.chevron_right),
                ],
              ),
            ],
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              _buildFestivalItem(AppImages.lanterns, 'Yi Peng Lanterns', 'Chiang Mai, Thailand', 'Nov 15', primary),
              _buildFestivalItem(AppImages.venice, 'Carnevale di Venezia', 'Venice, Italy', 'Feb 11', primary),
              _buildFestivalItem(AppImages.holi, 'Holi Festival', 'Mathura, India', 'Mar 25', primary),
              _buildFestivalItem(AppImages.sakura, 'Sakura Matsuri', 'Tokyo, Japan', 'Apr 02', primary),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFestivalItem(String image, String title, String loc, String date, Color primary) {
    return Container(
      width: 240,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.network(
              image,
              height: 160,
              width: 240,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                date,
                style: TextStyle(color: primary, fontSize: 12, fontWeight: FontWeight.w500),
              ),
            ],
          ),
          Text(
            loc,
            style: const TextStyle(color: Color(0xFF53433E), fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildNavButton(IconData icon) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFFD8C2BB)),
      ),
      child: Icon(icon, size: 20, color: const Color(0xFF53433E)),
    );
  }

  Widget _buildBottomNav(Color bg) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF0EEE9),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(Icons.explore, 'Home', true),
              _buildNavItem(Icons.map, 'Trips', false),
              _buildNavItem(Icons.payments, 'Expenses', false),
              _buildNavItem(Icons.person, 'Profile', false),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, bool active) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: active
          ? BoxDecoration(
              color: const Color(0xFFBFEBEC),
              borderRadius: BorderRadius.circular(100),
            )
          : null,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: active ? const Color(0xFF234D4F) : const Color(0xFF53433E),
            size: 24,
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: active ? FontWeight.bold : FontWeight.normal,
              color: active ? const Color(0xFF234D4F) : const Color(0xFF53433E),
            ),
          ),
        ],
      ),
    );
  }
}

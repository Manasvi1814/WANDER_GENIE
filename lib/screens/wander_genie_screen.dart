import 'package:flutter/material.dart';
import '../app_constants.dart';
import 'signup_screen.dart';

class WanderGenieScreen extends StatelessWidget {
  const WanderGenieScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Colors from the design system
    const Color primaryColor = Color(0xFF894B35);
    const Color onPrimaryColor = Colors.white;
    const Color surfaceColor = Color(0xFFFBF9F4);
    const Color onSurfaceVariant = Color(0xFF53433E);
    const Color outlineVariant = Color(0xFFD8C2BB);

    return Scaffold(
      backgroundColor: surfaceColor,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            bool isDesktop = constraints.maxWidth > 900;

            return Stack(
              children: [
                // 1. Top Bar / Logo
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 64,
                    alignment: Alignment.center,
                    child: const Text(
                      'Wander Genie',
                      style: TextStyle(
                        fontFamily: 'Serif',
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                        color: primaryColor,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ),
                ),

                // 2. Main Content
                Padding(
                  padding: const EdgeInsets.only(top: 64.0),
                  child: isDesktop
                      ? _buildDesktopLayout(
                          context,
                          primaryColor,
                          onPrimaryColor,
                          onSurfaceVariant,
                          outlineVariant,
                        )
                      : _buildMobileLayout(
                          context,
                          primaryColor,
                          onPrimaryColor,
                          onSurfaceVariant,
                          outlineVariant,
                        ),
                ),

                // 3. Subtle Footer (Desktop only)
                if (isDesktop)
                  const Positioned(
                    bottom: 24,
                    left: 64,
                    child: Text(
                      'Est. 2024 — Powered by Curated Intelligence',
                      style: TextStyle(
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                        color: Color(0x9986736D),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildMobileLayout(
    BuildContext context,
    Color primary,
    Color onPrimary,
    Color onSurfaceVariant,
    Color outlineVariant,
  ) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Imagery Section
          Container(
            height: 442,
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Color(0x0D894B35)],
              ),
            ),
            child: ShaderMask(
              shaderCallback: (rect) {
                return const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.black, Colors.black, Colors.transparent],
                  stops: [0.0, 0.8, 1.0],
                ).createShader(rect);
              },
              blendMode: BlendMode.dstIn,
              child: Image.network(
                AppImages.onboardingHero,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    Container(color: Colors.grey[300]),
              ),
            ),
          ),
          // Text Content Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
            child: _buildTextContent(
              context,
              primary,
              onPrimary,
              onSurfaceVariant,
              outlineVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout(
    BuildContext context,
    Color primary,
    Color onPrimary,
    Color onSurfaceVariant,
    Color outlineVariant,
  ) {
    return Row(
      children: [
        // Content (Left)
        Expanded(
          flex: 5,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 64),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 450),
                child: _buildTextContent(
                  context,
                  primary,
                  onPrimary,
                  onSurfaceVariant,
                  outlineVariant,
                  isDesktop: true,
                ),
              ),
            ),
          ),
        ),
        // Imagery (Right)
        Expanded(
          flex: 7,
          child: Stack(
            fit: StackFit.expand,
            children: [
              ShaderMask(
                shaderCallback: (rect) {
                  return const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.black, Colors.black, Colors.transparent],
                    stops: [0.0, 0.8, 1.0],
                  ).createShader(rect);
                },
                blendMode: BlendMode.dstIn,
                child: Image.network(
                  AppImages.onboardingHero,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      Container(color: Colors.grey[300]),
                ),
              ),
              Container(color: primary.withOpacity(0.05)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTextContent(
    BuildContext context,
    Color primary,
    Color onPrimary,
    Color onSurfaceVariant,
    Color outlineVariant, {
    bool isDesktop = false,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'THE FUTURE OF TRAVEL',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: primary,
            letterSpacing: 2.8,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Your journey,\nreimagined by AI.',
          style: TextStyle(
            fontFamily: 'Serif',
            fontSize: isDesktop ? 48 : 36,
            fontWeight: FontWeight.w700,
            height: 1.1,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 32),
        Text(
          'Tailored itineraries that match your rhythm, budget, and spirit.${isDesktop ? " Let our intelligent curator design the moments that linger." : ""}',
          style: TextStyle(fontSize: 18, color: onSurfaceVariant, height: 1.5),
        ),
        const SizedBox(height: 48),
        // Action Area
        Wrap(
          spacing: 24,
          runSpacing: 24,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SignupScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primary,
                foregroundColor: onPrimary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Next',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 1,
                    ),
                  ),
                  SizedBox(width: 8),
                  Icon(Icons.arrow_forward, size: 20),
                ],
              ),
            ),
            // Progress dots
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 32,
                  height: 6,
                  decoration: BoxDecoration(
                    color: primary,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: outlineVariant,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: outlineVariant,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

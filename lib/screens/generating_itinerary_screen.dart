import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../app_constants.dart';
import 'wander_genie_travel_planner_screen.dart';

class GeneratingItineraryScreen extends StatefulWidget {
  final String destination;
  final String days;
  final String budget;
  final String people;

  const GeneratingItineraryScreen({
    super.key,
    required this.destination,
    required this.days,
    required this.budget,
    required this.people,
  });

  @override
  State<GeneratingItineraryScreen> createState() =>
      _GeneratingItineraryScreenState();
}

class _GeneratingItineraryScreenState extends State<GeneratingItineraryScreen>
    with TickerProviderStateMixin {
  late AnimationController _iconController;
  int _currentStep = 0;
  double _progress = 0.0;

  final List<Map<String, dynamic>> _steps = [
    {'text': 'Searching best routes', 'icon': Icons.flight},
    {'text': 'Finding boutique stays', 'icon': Icons.hotel},
    {'text': 'Curating local experiences', 'icon': Icons.explore},
    {'text': 'Optimizing travel budget', 'icon': Icons.account_balance_wallet},
    {'text': 'Polishing your itinerary', 'icon': Icons.auto_fix_high},
  ];

  @override
  void initState() {
    super.initState();
    _iconController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _startLoading();
  }

  void _startLoading() {
    Timer.periodic(const Duration(milliseconds: 1500), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        if (_currentStep < _steps.length - 1) {
          _currentStep++;
          _progress = (_currentStep + 1) / _steps.length;
        } else {
          _progress = 1.0;
          timer.cancel();
          _finishLoading();
        }
      });
    });
  }

  void _finishLoading() {
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => WanderGenieTravelPlannerScreen(
              destination: widget.destination,
              days: widget.days,
              budget: widget.budget,
              people: widget.people,
            ),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _iconController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Animated Icon
              AnimatedBuilder(
                animation: _iconController,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(0, -10 * _iconController.value),
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.auto_awesome,
                        color: AppColors.primary,
                        size: 40,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 48),
              // Headline
              Text(
                'Crafting your perfect escape...',
                textAlign: TextAlign.center,
                style: GoogleFonts.playfairDisplay(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 16),
              // Subtext
              Text(
                'Analyzing flights, hotels, and hidden gems just for you.',
                textAlign: TextAlign.center,
                style: GoogleFonts.dmSans(
                  fontSize: 18,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 64),
              // Progress Bar
              ClipRRect(
                borderRadius: BorderRadius.circular(100),
                child: LinearProgressIndicator(
                  value: _progress,
                  backgroundColor: AppColors.surfaceContainerHigh,
                  color: AppColors.primary,
                  minHeight: 6,
                ),
              ),
              const SizedBox(height: 24),
              // Dynamic Loading Step
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 500),
                child: Row(
                  key: ValueKey(_currentStep),
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _steps[_currentStep]['icon'] as IconData,
                      color: AppColors.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      (_steps[_currentStep]['text'] as String).toUpperCase(),
                      style: GoogleFonts.dmSans(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                        letterSpacing: 2,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              // Footer
              Text(
                'Wander Genie',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 36,
                  color: AppColors.primary.withOpacity(0.1),
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }
}

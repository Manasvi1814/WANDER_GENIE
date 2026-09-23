import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import '../app_constants.dart';
import '../database/db_helper.dart';
import '../models/trip.dart';
import 'generating_itinerary_screen.dart';
import '../services/sync_service.dart';

class PlanTripDestinationScreen extends StatefulWidget {
  const PlanTripDestinationScreen({super.key});

  @override
  State<PlanTripDestinationScreen> createState() =>
      _PlanTripDestinationScreenState();
}

class _PlanTripDestinationScreenState extends State<PlanTripDestinationScreen> {
  int _currentStep = 1;
  final int _totalSteps = 5;

  final TextEditingController _destinationController = TextEditingController();

  final TextEditingController _daysController = TextEditingController();

  final TextEditingController _budgetController = TextEditingController();

  final TextEditingController _peopleController = TextEditingController();

  bool _isSaving = false;

  @override
  void dispose() {
    _destinationController.dispose();
    _daysController.dispose();
    _budgetController.dispose();
    _peopleController.dispose();
    super.dispose();
  }

  // ------------------------------------------------------------
  // NEXT STEP
  // ------------------------------------------------------------

  void _nextStep() {
    if (!_validateCurrentStep()) {
      _showValidationMessage();
      return;
    }

    if (_currentStep < _totalSteps) {
      setState(() {
        _currentStep++;
      });
    } else {
      _navigateToGenerating();
    }
  }

  // ------------------------------------------------------------
  // PREVIOUS STEP
  // ------------------------------------------------------------

  void _previousStep() {
    if (_isSaving) return;

    setState(() {
      if (_currentStep > 1) {
        _currentStep--;
      } else {
        Navigator.pop(context);
      }
    });
  }

  // ------------------------------------------------------------
  // VALIDATION
  // ------------------------------------------------------------

  bool _validateCurrentStep() {
    switch (_currentStep) {
      case 1:
        return _destinationController.text.trim().isNotEmpty;

      case 2:
        final days = int.tryParse(_daysController.text.trim());

        return days != null && days > 0;

      case 3:
        return _budgetController.text.trim().isNotEmpty;

      case 4:
        final people = int.tryParse(_peopleController.text.trim());

        return people != null && people > 0;

      case 5:
        return true;

      default:
        return false;
    }
  }

  // ------------------------------------------------------------
  // VALIDATION MESSAGE
  // ------------------------------------------------------------

  void _showValidationMessage() {
    String message;

    switch (_currentStep) {
      case 1:
        message = 'Please enter a destination.';
        break;

      case 2:
        message = 'Please enter a valid number of days.';
        break;

      case 3:
        message = 'Please enter your budget.';
        break;

      case 4:
        message = 'Please enter a valid number of travellers.';
        break;

      default:
        message = 'Please check your information.';
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  // ------------------------------------------------------------
  // SAVE TRIP + OPEN ITINERARY GENERATION
  // ------------------------------------------------------------

  Future<void> _navigateToGenerating() async {
    if (_isSaving) return;

    final destination = _destinationController.text.trim();

    final days = int.tryParse(_daysController.text.trim());

    final budget = _budgetController.text.trim();

    final people = int.tryParse(_peopleController.text.trim());

    // Final validation before saving.
    if (destination.isEmpty ||
        days == null ||
        days <= 0 ||
        budget.isEmpty ||
        people == null ||
        people <= 0) {
      _showValidationMessage();
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      // Resolve local user ID for current user (or default to 1)
      int currentUserId = 1;
      final fbUser = FirebaseAuth.instance.currentUser;
      if (fbUser != null && fbUser.email != null && fbUser.email!.isNotEmpty) {
        final localUser = await DatabaseHelper().getOrCreateUserByEmail(
          fbUser.email!,
          fbUser.displayName ?? '',
        );
        currentUserId = localUser.id ?? 1;
      }

      // --------------------------------------------------------
      // CREATE TRIP OBJECT
      // --------------------------------------------------------

      final Trip newTrip = Trip(
        userId: currentUserId,
        destination: destination,
        numberOfDays: days,
        budget: budget,
        numberOfPeople: people,
      );

      // --------------------------------------------------------
      // SAVE TO SQLITE AND CLOUD
      // --------------------------------------------------------

      final SaveTripResult saveResult = await SyncService().saveAndSyncTrip(
        newTrip,
      );

      debugPrint('========================================');
      debugPrint('TRIP SAVE RESULT');
      debugPrint('Local Trip ID : ${saveResult.localId}');
      debugPrint('Sync Status   : ${saveResult.status}');
      debugPrint('Cloud Doc ID  : ${saveResult.cloudId}');
      debugPrint('User ID       : $currentUserId');
      debugPrint('Destination   : $destination');
      debugPrint('Days          : $days');
      debugPrint('Budget        : $budget');
      debugPrint('People        : $people');
      debugPrint('========================================');

      if (!mounted) return;

      // --------------------------------------------------------
      // SHOW STATUS MESSAGE
      // --------------------------------------------------------

      String statusMessage;
      switch (saveResult.status) {
        case SyncStatusResult.synced:
          statusMessage = 'Trip saved and synchronized to Firebase.';
          break;
        case SyncStatusResult.savedLocallyNotLoggedIn:
          statusMessage =
              'Trip saved locally. Please sign in to synchronize with Firebase.';
          break;
        case SyncStatusResult.savedLocallySyncFailed:
          statusMessage =
              'Trip saved locally, but cloud synchronization failed.';
          break;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(statusMessage),
          duration: const Duration(seconds: 2),
        ),
      );

      // Small delay so the user can see the message.
      await Future.delayed(const Duration(milliseconds: 500));

      if (!mounted) return;

      // --------------------------------------------------------
      // OPEN ITINERARY GENERATION SCREEN
      // --------------------------------------------------------

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => GeneratingItineraryScreen(
            destination: destination,
            days: days.toString(),
            budget: budget,
            people: people.toString(),
          ),
        ),
      );
    } catch (e, stackTrace) {
      // --------------------------------------------------------
      // DATABASE ERROR
      // --------------------------------------------------------

      debugPrint('========================================');
      debugPrint('TRIP SAVE FAILED');
      debugPrint('Error: $e');
      debugPrint('Stack trace: $stackTrace');
      debugPrint('========================================');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not save trip: $e'),
          duration: const Duration(seconds: 4),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  // ------------------------------------------------------------
  // BUILD
  // ------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,

      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,

        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primary),
          onPressed: _previousStep,
        ),

        title: Text(
          'Wander Genie',
          style: GoogleFonts.playfairDisplay(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),

        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: CircleAvatar(
              radius: 20,
              backgroundImage: NetworkImage(AppImages.profilePic),
            ),
          ),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),

            // --------------------------------------------------
            // PROGRESS INDICATOR
            // --------------------------------------------------
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'STEP $_currentStep OF $_totalSteps',
                  style: GoogleFonts.dmSans(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                    letterSpacing: 1.2,
                  ),
                ),

                Text(
                  _getStepTitle(),
                  style: GoogleFonts.dmSans(
                    fontSize: 12,
                    color: AppColors.outline,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            LinearProgressIndicator(
              value: _currentStep / _totalSteps,
              backgroundColor: AppColors.surfaceContainerHigh,
              color: AppColors.primary,
              minHeight: 4,
              borderRadius: BorderRadius.circular(2),
            ),

            const SizedBox(height: 64),

            _buildStepContent(),
          ],
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // STEP TITLE
  // ------------------------------------------------------------

  String _getStepTitle() {
    switch (_currentStep) {
      case 1:
        return 'Destination';

      case 2:
        return 'Duration';

      case 3:
        return 'Budget';

      case 4:
        return 'Travellers';

      case 5:
        return 'Summary';

      default:
        return '';
    }
  }

  // ------------------------------------------------------------
  // STEP CONTENT
  // ------------------------------------------------------------

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 1:
        return _buildDestinationStep();

      case 2:
        return _buildDaysStep();

      case 3:
        return _buildBudgetStep();

      case 4:
        return _buildPeopleStep();

      case 5:
        return _buildSummaryStep();

      default:
        return const SizedBox.shrink();
    }
  }

  // ------------------------------------------------------------
  // DESTINATION STEP
  // ------------------------------------------------------------

  Widget _buildDestinationStep() {
    return Column(
      children: [
        Center(
          child: Text(
            'Where are you dreaming\nof going?',
            textAlign: TextAlign.center,
            style: GoogleFonts.playfairDisplay(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              height: 1.1,
              color: AppColors.onSurface,
            ),
          ),
        ),

        const SizedBox(height: 16),

        Center(
          child: Text(
            'Tell us a city, a country, or even just a mood. We\'ll handle the logistics.',
            textAlign: TextAlign.center,
            style: GoogleFonts.dmSans(
              fontSize: 18,
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ),

        const SizedBox(height: 48),

        _buildInputField(
          controller: _destinationController,
          hintText: 'Enter destination...',
          icon: Icons.travel_explore,
          onSubmitted: (_) => _nextStep(),
        ),

        const SizedBox(height: 64),

        Center(
          child: Text(
            'TRENDING INSPIRATIONS',
            style: GoogleFonts.dmSans(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.outline,
              letterSpacing: 2,
            ),
          ),
        ),

        const SizedBox(height: 24),

        _buildInspirationItem(
          'Paris, France',
          'City of Lights',
          AppImages.paris,
        ),

        _buildInspirationItem(
          'Bali, Indonesia',
          'Tropical Escape',
          AppImages.bali,
        ),

        _buildInspirationItem(
          'Tuscany, Italy',
          'Culinary Journey',
          AppImages.tuscany,
        ),
      ],
    );
  }

  // ------------------------------------------------------------
  // DAYS STEP
  // ------------------------------------------------------------

  Widget _buildDaysStep() {
    return Column(
      children: [
        Center(
          child: Text(
            'How many days are you\ntravelling?',
            textAlign: TextAlign.center,
            style: GoogleFonts.playfairDisplay(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              height: 1.1,
              color: AppColors.onSurface,
            ),
          ),
        ),

        const SizedBox(height: 48),

        _buildInputField(
          controller: _daysController,
          hintText: 'Number of days...',
          icon: Icons.calendar_today,
          keyboardType: TextInputType.number,
          onSubmitted: (_) => _nextStep(),
        ),
      ],
    );
  }

  // ------------------------------------------------------------
  // BUDGET STEP
  // ------------------------------------------------------------

  Widget _buildBudgetStep() {
    return Column(
      children: [
        Center(
          child: Text(
            'What\'s your budget?',
            textAlign: TextAlign.center,
            style: GoogleFonts.playfairDisplay(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              height: 1.1,
              color: AppColors.onSurface,
            ),
          ),
        ),

        const SizedBox(height: 48),

        _buildInputField(
          controller: _budgetController,
          hintText: 'Enter budget (e.g. ₹50,000)...',
          icon: Icons.currency_rupee,
          keyboardType: TextInputType.text,
          onSubmitted: (_) => _nextStep(),
        ),
      ],
    );
  }

  // ------------------------------------------------------------
  // PEOPLE STEP
  // ------------------------------------------------------------

  Widget _buildPeopleStep() {
    return Column(
      children: [
        Center(
          child: Text(
            'How many people are\ntravelling?',
            textAlign: TextAlign.center,
            style: GoogleFonts.playfairDisplay(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              height: 1.1,
              color: AppColors.onSurface,
            ),
          ),
        ),

        const SizedBox(height: 48),

        _buildInputField(
          controller: _peopleController,
          hintText: 'Number of people...',
          icon: Icons.people,
          keyboardType: TextInputType.number,
          onSubmitted: (_) => _nextStep(),
        ),
      ],
    );
  }

  // ------------------------------------------------------------
  // SUMMARY STEP
  // ------------------------------------------------------------

  Widget _buildSummaryStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Text(
            'Trip Summary',
            style: GoogleFonts.playfairDisplay(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              height: 1.1,
              color: AppColors.onSurface,
            ),
          ),
        ),

        const SizedBox(height: 48),

        Container(
          padding: const EdgeInsets.all(24),

          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),

            border: Border.all(
              color: AppColors.outlineVariant.withOpacity(0.5),
            ),

            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.05),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),

          child: Column(
            children: [
              _buildSummaryRow(
                Icons.location_on,
                'Destination',
                _destinationController.text,
              ),

              const Divider(height: 32),

              _buildSummaryRow(
                Icons.calendar_today,
                'Duration',
                '${_daysController.text} days',
              ),

              const Divider(height: 32),

              _buildSummaryRow(
                Icons.payments,
                'Budget',
                _budgetController.text,
              ),

              const Divider(height: 32),

              _buildSummaryRow(
                Icons.people,
                'Travellers',
                _peopleController.text,
              ),
            ],
          ),
        ),

        const SizedBox(height: 48),

        SizedBox(
          width: double.infinity,
          height: 64,

          child: ElevatedButton(
            onPressed: _isSaving ? null : _navigateToGenerating,

            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,

              disabledBackgroundColor: AppColors.primary.withOpacity(0.5),

              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),

              elevation: 0,
            ),

            child: _isSaving
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Text(
                    'Generate Itinerary',
                    style: GoogleFonts.dmSans(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  // ------------------------------------------------------------
  // SUMMARY ROW
  // ------------------------------------------------------------

  Widget _buildSummaryRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 24),

        const SizedBox(width: 16),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.dmSans(
                  fontSize: 14,
                  color: AppColors.outline,
                ),
              ),

              const SizedBox(height: 2),

              Text(
                value,
                style: GoogleFonts.dmSans(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.onSurface,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ------------------------------------------------------------
  // INPUT FIELD
  // ------------------------------------------------------------

  Widget _buildInputField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    void Function(String)? onSubmitted,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.circular(100),

        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.08),
            blurRadius: 40,
            offset: const Offset(0, 20),
          ),
        ],
      ),

      padding: const EdgeInsets.all(8),

      child: Row(
        children: [
          const SizedBox(width: 16),

          Icon(icon, color: AppColors.outlineVariant),

          Expanded(
            child: TextField(
              controller: controller,

              style: GoogleFonts.dmSans(fontSize: 18),

              keyboardType: keyboardType,

              autofocus: true,

              decoration: InputDecoration(
                hintText: hintText,

                hintStyle: GoogleFonts.dmSans(color: AppColors.outlineVariant),

                border: InputBorder.none,

                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),

              onSubmitted: onSubmitted,
            ),
          ),

          GestureDetector(
            onTap: _isSaving ? null : _nextStep,

            child: Container(
              padding: const EdgeInsets.all(12),

              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),

              child: const Icon(Icons.arrow_forward, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // INSPIRATION ITEM
  // ------------------------------------------------------------

  Widget _buildInspirationItem(String title, String subtitle, String imageUrl) {
    return GestureDetector(
      onTap: () {
        if (_isSaving) return;

        _destinationController.text = title;

        _nextStep();
      },

      child: Container(
        margin: const EdgeInsets.only(bottom: 16),

        padding: const EdgeInsets.all(12),

        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLow,

          borderRadius: BorderRadius.circular(16),
        ),

        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),

              child: Image.network(
                imageUrl,
                width: 56,
                height: 56,
                fit: BoxFit.cover,
              ),
            ),

            const SizedBox(width: 16),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.dmSans(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),

                  const SizedBox(height: 2),

                  Text(
                    subtitle,
                    style: GoogleFonts.dmSans(
                      color: AppColors.outline,
                      fontSize: 14,
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
}

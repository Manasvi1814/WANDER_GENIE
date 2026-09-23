import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../app_constants.dart';
import '../widgets/app_drawer.dart';
import 'third_screen.dart';

class ExpensesScreen extends StatelessWidget {
  const ExpensesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      drawer: const AppDrawer(),
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: AppColors.primary),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
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
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Budget Alert
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.05),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.primary.withOpacity(0.1)),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.warning_amber_rounded,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        style: GoogleFonts.dmSans(
                          color: AppColors.onSurface,
                          fontSize: 14,
                        ),
                        children: [
                          const TextSpan(
                            text: 'Budget Alert: ',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const TextSpan(
                            text:
                                'Trending 15% over budget. Want to see some free activity alternatives?',
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed: () {},
                    child: Text(
                      'View',
                      style: GoogleFonts.dmSans(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            // Header
            Text(
              'Santorini Trip',
              style: GoogleFonts.playfairDisplay(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '"The island where the sun kisses the sea." — Monitoring your indulgence in the Cyclades.',
              style: GoogleFonts.dmSans(
                fontSize: 16,
                fontStyle: FontStyle.italic,
                color: AppColors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 48),
            // Budget Ring
            Center(
              child: Container(
                width: 280,
                height: 280,
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.06),
                      blurRadius: 40,
                      offset: const Offset(0, 20),
                    ),
                  ],
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 200,
                      height: 200,
                      child: CircularProgressIndicator(
                        value: 1250 / 2000,
                        strokeWidth: 12,
                        backgroundColor: AppColors.outlineVariant.withOpacity(
                          0.3,
                        ),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          AppColors.primary,
                        ),
                        strokeCap: StrokeCap.round,
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'TOTAL SPENT',
                          style: GoogleFonts.dmSans(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.onSurfaceVariant,
                            letterSpacing: 2,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '\$1,250',
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                        Text(
                          'of \$2,000 budget',
                          style: GoogleFonts.dmSans(
                            fontSize: 12,
                            color: AppColors.outline,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildBudgetInfo('Remaining', '\$750'),
                _buildBudgetInfo('Daily Avg.', '\$156'),
              ],
            ),
            const SizedBox(height: 48),
            // Categories
            Text(
              'Spending Categories',
              style: GoogleFonts.playfairDisplay(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 24),
            _buildCategoryItem('Food & Drink', '\$540', 0.65, Icons.restaurant),
            _buildCategoryItem(
              'Transport',
              '\$310',
              0.45,
              Icons.directions_boat,
            ),
            _buildCategoryItem('Activities', '\$280', 0.30, Icons.explore),
            _buildCategoryItem('Shopping', '\$120', 0.15, Icons.shopping_bag),
            const SizedBox(height: 48),
            // Transactions
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Transactions',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  child: Text(
                    'View All',
                    style: GoogleFonts.dmSans(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildTransactionItem(
              'Sunset Wine Tasting',
              'Oct 14, 2023',
              '-\$85.00',
              Icons.wine_bar,
            ),
            _buildTransactionItem(
              'ATV Rental - 2 Days',
              'Oct 13, 2023',
              '-\$120.00',
              Icons.moped,
            ),
            _buildTransactionItem(
              'Ammoudi Fish Tavern',
              'Oct 12, 2023',
              '-\$145.50',
              Icons.dinner_dining,
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(
          'Add Expense',
          style: GoogleFonts.dmSans(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  Widget _buildBudgetInfo(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: GoogleFonts.dmSans(fontSize: 12, color: AppColors.outline),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.dmSans(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.onSurface,
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryItem(
    String title,
    String amount,
    double progress,
    IconData icon,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(icon, size: 20, color: AppColors.secondary),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: GoogleFonts.dmSans(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              Text(
                amount,
                style: GoogleFonts.dmSans(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: AppColors.outlineVariant.withOpacity(0.3),
              color: AppColors.secondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionItem(
    String title,
    String date,
    String amount,
    IconData icon,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.secondaryContainer.withOpacity(0.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.onSecondaryContainer),
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
                Text(
                  date,
                  style: GoogleFonts.dmSans(
                    color: AppColors.outline,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            amount,
            style: GoogleFonts.dmSans(
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF0EEE9),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(Icons.explore, 'Home', false, () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const ThirdScreen()),
                  (route) => route.isFirst,
                );
              }),
              _buildNavItem(Icons.map, 'Trips', false, () {
                // Should navigate back to Itinerary if it exists or My Trips
                Navigator.pop(context);
              }),
              _buildNavItem(Icons.payments, 'Expenses', true, () {}),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    IconData icon,
    String label,
    bool active,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: active
            ? BoxDecoration(
                color: AppColors.secondaryContainer,
                borderRadius: BorderRadius.circular(100),
              )
            : null,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: active
                  ? const Color(0xFF234D4F)
                  : AppColors.onSurfaceVariant,
              size: 24,
            ),
            Text(
              label,
              style: GoogleFonts.dmSans(
                fontSize: 10,
                fontWeight: active ? FontWeight.bold : FontWeight.normal,
                color: active
                    ? const Color(0xFF234D4F)
                    : AppColors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

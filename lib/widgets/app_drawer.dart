import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../app_constants.dart';
import '../screens/profile_screen.dart';
import '../screens/third_screen.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.surface,
      child: Column(
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(color: AppColors.primary),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 35,
                    backgroundImage: NetworkImage(AppImages.profilePic),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Wander Genie',
                    style: GoogleFonts.playfairDisplay(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.explore, color: AppColors.primary),
            title: Text(
              'Home',
              style: GoogleFonts.dmSans(fontWeight: FontWeight.bold),
            ),
            onTap: () {
              Navigator.pop(context); // Close drawer
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const ThirdScreen()),
                (route) => route.isFirst,
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.person, color: AppColors.primary),
            title: Text(
              'Profile',
              style: GoogleFonts.dmSans(fontWeight: FontWeight.bold),
            ),
            onTap: () {
              Navigator.pop(context); // Close drawer
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfileScreen()),
              );
            },
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'v1.0.0',
              style: GoogleFonts.dmSans(color: AppColors.outline, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}

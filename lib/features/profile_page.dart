import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/auth_service.dart';
import 'package:tourguide/features/profile/edit_profile.dart';
import 'package:tourguide/features/notifications_page.dart';
import 'package:tourguide/features/log_in_page.dart';

class ProfilePage extends StatelessWidget {
  final AuthService _authService = Get.put(AuthService());

  ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Profile",
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
              children: [
              Obx(() => Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 45,
            backgroundImage: _authService.userAvatar.startsWith('assets/')
                ? AssetImage(_authService.userAvatar) as ImageProvider
                : FileImage(File(_authService.userAvatar)),
          ),
          const SizedBox(height: 12),
          Text(
            _authService.userName,
            style: GoogleFonts.poppins(
                fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Text(
            _authService.userEmail,
            style: GoogleFonts.poppins(color: Colors.grey),
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: () async {
              final result = await Get.to(() => EditProfilePage(
                userName: _authService.userName,
                profileImagePath: _authService.userAvatar,
              ));
              if (result != null) {
                await _authService.updateProfile(
                    name: result['name'], avatar: result['avatar']);
              }
            },
            icon: const Icon(Icons.edit, size: 18),
            label: const Text("Edit Profile"),
            style: OutlinedButton.styleFrom(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30)),
            ),
          ),
        ],
      ),
    )),


    const SizedBox(height: 25),

    // Notifications
    ListTile(
    leading: const Icon(Icons.notifications),
    title: const Text("Notifications"),
    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
    onTap: () {
    Get.to(() => const NotificationsPage());
    },
    ),

    // Language
    ListTile(
    leading: const Icon(Icons.language),
    title: const Text("Language"),
    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
    onTap: () {},
    ),

    // Privacy
    ListTile(
    leading: const Icon(Icons.privacy_tip),
    title: const Text("Privacy"),
    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
    onTap: () {
    Get.defaultDialog(
    title: "Privacy Policy",
    content: const Text(
    "Here you can show your app's privacy policy details."),
    textConfirm: "Close",
    onConfirm: () => Get.back(),
    );
    },
    ),

    const SizedBox(height: 25),
    const Divider(),

    // Support Section
    Align(
    alignment: Alignment.centerLeft,
    child: Text(
    "Support",
    style: GoogleFonts.poppins(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    ),
    ),
    ),
    const SizedBox(height: 10),

    ListTile(
    leading: const Icon(Icons.help_outline),
    title: const Text("Help Center"),
    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
    onTap: () {},
    ),

    ListTile(
    leading: const Icon(Icons.mail_outline),
    title: const Text("Contact Us"),
    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
    onTap: () {},
    ),

    const SizedBox(height: 25),

    // Logout Button
    ElevatedButton.icon(
    onPressed: () async {
    await _authService.logout();
    Get.offAll(() => LogInPage());
    },
    icon: const Icon(Icons.logout),
    label: const Text("Log out"),
    style: ElevatedButton.styleFrom(
    backgroundColor: Colors.redAccent,
    foregroundColor: Colors.white,
    minimumSize: const Size(double.infinity, 50),
    shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(30),
    ),
    ),
    ),
    ],
    ),
    ),
    );


  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tourguide/main.dart';
import 'sign_up_page.dart';
import 'package:tourguide/core/auth_service.dart';

class LogInPage extends StatelessWidget {
  final AuthService service = Get.put(AuthService()); // Use singleton service
  final emailController = TextEditingController();
  final passController = TextEditingController();

  LogInPage({super.key});

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF6750A4);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.9,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(Icons.polymer_sharp, size: 80, color: primaryColor),
                const Text(
                  "Wander Guide",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Sign in to Explore the World.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 40),

                // Email
                TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: "Email Address",
                    prefixIcon: const Icon(Icons.email),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: primaryColor, width: 2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Password
                TextField(
                  controller: passController,
                  obscureText: true,
                  decoration: InputDecoration(
                    hintText: "Password",
                    prefixIcon: const Icon(Icons.lock),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: primaryColor, width: 2),
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Log in button
                ElevatedButton(
                  onPressed: () async {
                    final email = emailController.text.trim();
                    final pass = passController.text.trim();

                    if (email.isEmpty || pass.isEmpty) {
                      Get.snackbar("Error", "Please fill all fields");
                      return;
                    }

                    final result = await service.login(email, pass);

                    if (result == null) {
                      // Logged in successfully, init user data is handled in service
                      Get.snackbar("Success", "Logged in successfully", snackPosition: SnackPosition.BOTTOM);
                      Get.offAll(() => MainPage());
                    } else {
                      Get.snackbar("Error", result, snackPosition: SnackPosition.BOTTOM);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    elevation: 5,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text("LOG IN", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 20),

                // Sign up link
                TextButton(
                  onPressed: () {
                    Get.to(() => SignUpPage());
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                  ),
                  child: const Text("New User? Register Here", style: TextStyle(fontSize: 16)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

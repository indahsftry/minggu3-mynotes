import 'package:flutter/material.dart';
import '../services/auth/auth_service.dart';

class VerifyEmailView extends StatelessWidget {
  const VerifyEmailView({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthService authService = AuthService();

    return Scaffold(
      appBar: AppBar(title: const Text("Verify Email")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text("Please verify your email address."),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await authService.sendEmailVerification();
              },
              child: const Text("Resend Email"),
            ),
            TextButton(
              onPressed: () async {
                await authService.logout();
                Navigator.pushReplacementNamed(context, '/login');
              },
              child: const Text("Restart"),
            ),
          ],
        ),
      ),
    );
  }
}

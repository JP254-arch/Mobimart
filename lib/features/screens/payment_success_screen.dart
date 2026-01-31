import 'package:flutter/material.dart';
// import 'package:mobimart_app/features/screens/home_screen.dart';
import 'package:mobimart_app/features/screens/profile_screen.dart';

class PaymentSuccessScreen extends StatelessWidget {
  const PaymentSuccessScreen({super.key});

  static const String routeName = '/payment-success';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment Successful'),
        centerTitle: true,
        automaticallyImplyLeading: false, // Remove back button
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Success Icon
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.green.withOpacity(0.2),
                ),
                child: const Icon(
                  Icons.check_circle_outline,
                  color: Colors.green,
                  size: 80,
                ),
              ),
              const SizedBox(height: 24),

              // Success Text
              Text(
                'Payment Successful!',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.green[800],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'Your order has been placed successfully. You will receive a confirmation shortly.',
                style: theme.textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // Back to Dashboard Button
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const ProfileScreen()),
                    (route) => false,
                  );
                },
                icon: const Icon(Icons.home),
                label: const Text('Back to Profile'),
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

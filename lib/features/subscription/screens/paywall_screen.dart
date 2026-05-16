import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import '../../../core/widgets/app_button.dart';
import 'plans_screen.dart';

class PaywallScreen extends StatelessWidget {
  const PaywallScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    const SizedBox(height: 24),
                    Container(
                      height: 200,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [AppColors.mathBlue.withValues(alpha: 0.1), AppColors.scienceGreen.withValues(alpha: 0.1)]),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Center(
                        child: Icon(Icons.auto_awesome, size: 80, color: AppColors.accent),
                      ),
                    ),
                    const SizedBox(height: 32),
                    Text('Unlock Unlimited Learning!', textAlign: TextAlign.center, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    Text("You've completed 3 days of your campaign. Continue the learning journey with full access to all topics, quizzes, and games.",
                      textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.textSecondary)),
                    const SizedBox(height: 32),
                    _buildBenefit(context, Icons.school, '400+ Topics', 'Math, English, Science for Grades 1-5'),
                    _buildBenefit(context, Icons.quiz, '3,000+ Questions', 'Practice pads, quizzes & Beat the Parent'),
                    _buildBenefit(context, Icons.celebration, 'Certificates', 'Celebrate every milestone'),
                    _buildBenefit(context, Icons.games, 'Arcade Games', 'Learn through play'),
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10, offset: const Offset(0, -5))],
              ),
              child: SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: AppButton(
                        label: 'Start 7-Day Free Trial',
                        isGradient: true,
                        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PlansScreen())),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('Maybe Later', style: TextStyle(color: AppColors.textSecondary)),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBenefit(BuildContext context, IconData icon, String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: AppColors.mathBlue.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: AppColors.mathBlue),
          ),
          const SizedBox(width: 16),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
            Text(subtitle, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary)),
          ]),
        ],
      ),
    );
  }
}

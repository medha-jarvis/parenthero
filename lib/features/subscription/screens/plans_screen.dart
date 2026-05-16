import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import '../../../core/widgets/app_button.dart';

class PlansScreen extends StatelessWidget {
  const PlansScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Choose Your Plan')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 16),
            Text('Unlock Unlimited Learning!', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, textAlign: TextAlign.center)),
            const SizedBox(height: 8),
            Text('Start your 7-day free trial', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary, textAlign: TextAlign.center)),
            const SizedBox(height: 24),
            _buildPlanCard(context, 'Monthly', '₹499', '/month', ['Unlimited topics', 'All subjects', 'Practice & quizzes', 'Certificates'], AppColors.mathBlue, false),
            _buildPlanCard(context, 'Annual', '₹4,999', '/year', ['Everything in Monthly', '2 months free', 'Family sharing (3 kids)', 'Priority support'], AppColors.scienceGreen, true),
            _buildPlanCard(context, 'Family Annual', '₹7,999', '/year', ['Up to 5 children', 'Everything in Annual', 'Dedicated support', 'Personalized curriculum'], AppColors.accent, false),
            const SizedBox(height: 16),
            Text('Cancel anytime', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary)),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanCard(BuildContext context, String name, String price, String period, List<String> features, Color color, bool isPopular) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Stack(
        children: [
          Card(
            elevation: isPopular ? 4 : 1,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: isPopular ? BorderSide(color: color, width: 2) : BorderSide.none,
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(name, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(price, style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold, color: color)),
                          Text(period, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ...features.map((f) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(children: [
                      Icon(Icons.check_circle, size: 20, color: color),
                      const SizedBox(width: 8),
                      Text(f),
                    ]),
                  )),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: AppButton(
                      label: isPopular ? 'Start Free Trial' : 'Subscribe',
                      isOutlined: !isPopular,
                      isGradient: isPopular,
                      onPressed: () {},
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isPopular)
            Positioned(
              top: 12, right: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(color: AppColors.scienceGreen, borderRadius: BorderRadius.circular(20)),
                child: const Text('BEST VALUE', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
              ),
            ),
        ],
      ),
    );
  }
}

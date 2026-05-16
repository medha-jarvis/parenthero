import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/strings.dart';
import '../../../core/widgets/app_button.dart';
import '../../../features/subscription/screens/plans_screen.dart';
import '../../../providers/auth_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.settings)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSection(context, 'Profile', [
            _buildTile(Icons.person, 'Edit Profile', () {}),
            _buildTile(Icons.people, 'Manage Children', () {}),
          ]),
          const SizedBox(height: 16),
          _buildSection(context, 'Subscription', [
            _buildTile(Icons.card_membership, 'Plans & Billing', () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const PlansScreen()));
            }),
            _buildTile(Icons.receipt, 'Payment History', () {}),
          ]),
          const SizedBox(height: 16),
          _buildSection(context, 'Preferences', [
            _buildTile(Icons.notifications, 'Notifications', () {}),
            _buildTile(Icons.color_lens, 'Theme', () {}),
          ]),
          const SizedBox(height: 16),
          _buildSection(context, 'Support', [
            _buildTile(Icons.help, 'Help Center', () {}),
            _buildTile(Icons.info, 'About ParentHero', () {}),
          ]),
          const SizedBox(height: 32),
          AppButton(
            label: 'Sign Out',
            isOutlined: true,
            icon: const Icon(Icons.logout, size: 18),
            onPressed: () => ref.read(authProvider.notifier).signOut(),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, List<Widget> tiles) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
        const SizedBox(height: 8),
        Card(child: Column(children: tiles)),
      ],
    );
  }

  Widget _buildTile(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}

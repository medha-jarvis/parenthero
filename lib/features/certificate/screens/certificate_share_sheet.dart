import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/colors.dart';
import '../../../core/constants/strings.dart';

/// Certificate share sheet with download and share options.
class CertificateShareSheet extends StatelessWidget {
  final String campaignId;

  const CertificateShareSheet({super.key, required this.campaignId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.shareCertificate),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Spacer(),
              // Preview
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.warning, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Icon(Icons.auto_awesome_rounded,
                        size: 32, color: AppColors.warning),
                    const SizedBox(height: 8),
                    const Text(
                      'Certificate of Achievement',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '🏆',
                      style: TextStyle(fontSize: 48),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Share this certificate with family and friends!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              // Share options
              _buildShareOption(
                context,
                icon: Icons.download_rounded,
                label: AppStrings.downloadCertificate,
                color: AppColors.primary,
              ),
              const SizedBox(height: 12),
              _buildShareOption(
                context,
                icon: Icons.share_rounded,
                label: 'Share via...',
                color: AppColors.secondary,
              ),
              const SizedBox(height: 12),
              _buildShareOption(
                context,
                icon: Icons.share,
                label: 'Share on WhatsApp',
                color: const Color(0xFF25D366),
              ),
              const SizedBox(height: 12),
              _buildShareOption(
                context,
                icon: Icons.camera_alt_rounded,
                label: 'Save to Gallery',
                color: AppColors.accent,
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildShareOption(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('$label - coming soon!'),
              backgroundColor: AppColors.info,
            ),
          );
        },
        icon: Icon(icon, color: color),
        label: Text(
          label,
          style: TextStyle(color: color, fontWeight: FontWeight.w600),
        ),
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: color.withValues(alpha: 0.3)),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
}

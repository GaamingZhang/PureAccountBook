import 'package:flutter/material.dart';
import '../core/config/app_config.dart';

void showAboutPage(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => const AboutPage(),
  );
}

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return GestureDetector(
      onVerticalDragEnd: (details) {
        if (details.primaryVelocity != null && details.primaryVelocity! > 0) {
          Navigator.of(context).pop();
        }
      },
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        decoration: BoxDecoration(
          color: AppColors.backgroundOf(context),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.textSecOf(context).withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(24, 16, 24, 24 + bottomPadding),
                child: Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: primaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Icon(
                        Icons.account_balance_wallet,
                        size: 40,
                        color: primaryColor,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '纯记账',
                      style: TextStyle(
                        color: AppColors.textMainOf(context),
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '版本 1.0.0',
                      style: TextStyle(
                        color: AppColors.textSecOf(context),
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 48),
                    _buildInfoCard(
                      context,
                      icon: Icons.storage,
                      title: '纯本地数据',
                      description: '所有数据仅存储在您的设备本地，不会上传到任何服务器。您的隐私数据完全由您自己掌控。',
                      color: AppColors.emerald,
                    ),
                    const SizedBox(height: 16),
                    _buildInfoCard(
                      context,
                      icon: Icons.wifi_off,
                      title: '无联网功能',
                      description: '本应用无需网络连接即可正常使用，不包含任何联网功能，确保您的数据安全。',
                      color: primaryColor,
                    ),
                    const SizedBox(height: 16),
                    _buildInfoCard(
                      context,
                      icon: Icons.block,
                      title: '纯净无广告',
                      description: '应用内不含任何广告，为您提供清爽、专注的记账体验。',
                      color: AppColors.rose,
                    ),
                    const SizedBox(height: 48),
                    Text(
                      '© ${DateTime.now().year} 纯记账. 保留所有权利。',
                      style: TextStyle(
                        color: AppColors.textSecOf(context),
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.center,
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

  Widget _buildInfoCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceOf(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider(context)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: AppColors.textMainOf(context),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: TextStyle(
                    color: AppColors.textSecOf(context),
                    fontSize: 13,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

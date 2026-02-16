import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/config/app_config.dart';
import '../features/transaction/providers/transaction_list_provider.dart';
import '../providers/theme_provider.dart';
import '../features/settings/views/theme_settings_page.dart'
    show showThemeSettingsPage;
import '../features/settings/views/language_settings_page.dart'
    show showLanguageSettingsPage;
import '../l10n/app_localizations.dart';
import 'about_page.dart';

final userStatsProvider = FutureProvider<(int, int)>((ref) async {
  final transactionsAsync = ref.watch(transactionsProvider);

  return transactionsAsync.when(
    data: (transactions) {
      final uniqueDates = <String>{};
      for (final t in transactions) {
        uniqueDates.add(t.date);
      }
      final daysWithTransactions = uniqueDates.length;
      final totalTransactions = transactions.length;
      return (daysWithTransactions, totalTransactions);
    },
    loading: () => (0, 0),
    error: (error, stack) => (0, 0),
  );
});

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  String _getGreeting(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) {
      return l10n.goodMorning;
    } else if (hour >= 12 && hour < 18) {
      return l10n.goodAfternoon;
    } else {
      return l10n.goodEvening;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(userStatsProvider);
    final primaryColor = ref.watch(themeColorProvider);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.backgroundOf(context),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 32),
              Center(
                child: Column(
                  children: [
                    Text(
                      _getGreeting(context),
                      style: TextStyle(
                        color: AppColors.textMainOf(context),
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.welcomeText,
                      style: TextStyle(
                        color: AppColors.textMainOf(context),
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceOf(context).withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.divider(context)),
                  ),
                  child: statsAsync.when(
                    data: (stats) {
                      final (daysWithTransactions, totalTransactions) = stats;
                      return Row(
                        children: [
                          Expanded(
                            child: _buildStat(
                              context,
                              l10n.recordDays,
                              daysWithTransactions.toString(),
                              l10n.days,
                              primaryColor,
                            ),
                          ),
                          Container(
                            width: 1,
                            height: 40,
                            color: AppColors.divider(context),
                          ),
                          Expanded(
                            child: _buildStat(
                              context,
                              l10n.totalRecords,
                              _formatNumber(totalTransactions),
                              l10n.records,
                              primaryColor,
                            ),
                          ),
                        ],
                      );
                    },
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (e, _) => Center(child: Text('${l10n.loadFailed}: $e')),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    _buildMenuItem(
                      context,
                      l10n.themeSettings,
                      Icons.palette,
                      primaryColor,
                      () => showThemeSettingsPage(context),
                    ),
                    const SizedBox(height: 12),
                    _buildMenuItem(
                      context,
                      l10n.languageSettings,
                      Icons.language,
                      primaryColor,
                      () => showLanguageSettingsPage(context),
                    ),
                    const SizedBox(height: 12),
                    _buildMenuItem(
                      context,
                      l10n.aboutPureBook,
                      Icons.info,
                      primaryColor,
                      () => showAboutPage(context),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }

  String _formatNumber(int number) {
    if (number >= 10000) {
      return '${(number / 10000).toStringAsFixed(1)}万';
    }
    return number.toString();
  }

  Widget _buildStat(
    BuildContext context,
    String label,
    String value,
    String unit,
    Color color,
  ) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            color: AppColors.textSecOf(context),
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 2),
            Text(
              unit,
              style: TextStyle(
                color: AppColors.textSecOf(context),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMenuItem(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surfaceOf(context),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.divider(context)),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: AppColors.textMainOf(context),
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: AppColors.textSecOf(context),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

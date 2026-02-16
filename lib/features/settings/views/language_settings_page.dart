import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/app_config.dart';
import '../../../providers/theme_provider.dart';
import '../../../l10n/app_localizations.dart';

class LanguageSettingsPage extends ConsumerWidget {
  const LanguageSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLocale = ref.watch(localeProvider);
    final primaryColor = ref.watch(themeColorProvider);
    final l10n = AppLocalizations.of(context)!;

    return GestureDetector(
      onVerticalDragEnd: (details) {
        if (details.primaryVelocity != null && details.primaryVelocity! > 500) {
          Navigator.of(context).pop();
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.backgroundOf(context),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.divider(context),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.close,
                        color: AppColors.textSecOf(context),
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    Text(
                      l10n.languageSettings,
                      style: TextStyle(
                        color: AppColors.textMainOf(context),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.surfaceOf(context),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.divider(context)),
                      ),
                      child: Column(
                        children: [
                          _buildLocaleItem(
                            context,
                            ref,
                            l10n.followSystemLanguage,
                            null,
                            currentLocale,
                            primaryColor,
                          ),
                          Divider(color: AppColors.divider(context), height: 1),
                          ...supportedLocales.map((locale) => Column(
                                children: [
                                  _buildLocaleItem(
                                    context,
                                    ref,
                                    localeNames[locale] ?? locale.languageCode,
                                    locale,
                                    currentLocale,
                                    primaryColor,
                                  ),
                                  if (locale != supportedLocales.last)
                                    Divider(
                                        color: AppColors.divider(context),
                                        height: 1),
                                ],
                              )),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLocaleItem(
    BuildContext context,
    WidgetRef ref,
    String title,
    Locale? locale,
    Locale? currentLocale,
    Color primaryColor,
  ) {
    final isSelected = currentLocale == locale;
    return InkWell(
      onTap: () {
        ref.read(localeProvider.notifier).setLocale(locale);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Text(
              title,
              style: TextStyle(
                color: AppColors.textMainOf(context),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            if (isSelected) Icon(Icons.check, color: primaryColor, size: 20),
          ],
        ),
      ),
    );
  }
}

Future<void> showLanguageSettingsPage(BuildContext context) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => const LanguageSettingsPage(),
  );
}

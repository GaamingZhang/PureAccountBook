import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/config/app_config.dart';
import '../../../core/database/database_helper.dart';
import '../../../l10n/app_localizations.dart';
import '../../../providers/theme_provider.dart';

final splashInitializedProvider = StateProvider<bool>((ref) => false);

class SplashScreen extends ConsumerStatefulWidget {
  final Widget? nextScreen;

  const SplashScreen({super.key, this.nextScreen});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      await DatabaseHelper.instance.database;
      final version = await DatabaseHelper.instance.getDatabaseVersion();
      debugPrint('Database initialized successfully, version: $version');

      final hasDefaults = await DatabaseHelper.instance.hasDefaultCategories();
      debugPrint('Has default categories: $hasDefaults');

      if (!hasDefaults) {
        await DatabaseHelper.instance.ensureDefaultCategories();
        debugPrint('Default categories ensured');
      }
    } catch (e, stackTrace) {
      debugPrint('Database init error: $e');
      debugPrint('Stack trace: $stackTrace');
    }

    await Future.delayed(const Duration(seconds: 1));

    if (mounted) {
      ref.read(splashInitializedProvider.notifier).state = true;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => widget.nextScreen ?? const SizedBox(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final primaryColor = ref.watch(themeColorProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundOf(context),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.topLeft,
                radius: 1.5,
                colors: [
                  primaryColor.withValues(alpha: 0.15),
                  AppColors.backgroundOf(context),
                ],
              ),
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: primaryColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: primaryColor.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Icon(
                    Icons.account_balance_wallet,
                    color: primaryColor,
                    size: 40,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  l10n?.appName ?? '记账本',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textMainOf(context),
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n?.slogan ?? '简单记账，轻松理财',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.textSecOf(context),
                  ),
                ),
                const SizedBox(height: 48),
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

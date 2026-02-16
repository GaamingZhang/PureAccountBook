import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/config/app_config.dart';
import 'features/budget/views/budget_screen.dart';
import 'providers/theme_provider.dart';
import 'features/ui/views/splash_screen.dart';
import 'l10n/app_localizations.dart';
import 'screens/add_transaction_screen.dart';
import 'screens/home_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/stats_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final themeColor = ref.watch(themeColorProvider);
    final locale = ref.watch(localeProvider);

    return MaterialApp(
      title: 'FinanceFlow',
      debugShowCheckedModeBanner: false,
      themeMode: themeMode,
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      localeResolutionCallback: (deviceLocale, supportedLocales) {
        if (locale != null) {
          return locale;
        }
        if (deviceLocale == null) {
          return const Locale('zh');
        }
        for (final supportedLocale in supportedLocales) {
          if (deviceLocale.languageCode == supportedLocale.languageCode) {
            if (deviceLocale.scriptCode == supportedLocale.scriptCode) {
              return supportedLocale;
            }
            if (supportedLocale.scriptCode == null &&
                supportedLocale.countryCode == null) {
              return supportedLocale;
            }
          }
        }
        return const Locale('zh');
      },
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: themeColor,
        scaffoldBackgroundColor: AppColors.backgroundLight,
        fontFamily: 'PingFang SC',
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: AppColors.textMainLight),
          bodyMedium: TextStyle(color: AppColors.textMainLight),
          titleLarge: TextStyle(color: AppColors.textMainLight),
          titleMedium: TextStyle(color: AppColors.textMainLight),
          titleSmall: TextStyle(color: AppColors.textMainLight),
        ),
        colorScheme: ColorScheme.light(
          primary: themeColor,
          surface: AppColors.surfaceLight,
          surfaceContainerHighest: const Color(0xFFF1F5F9),
          onSurface: AppColors.textMainLight,
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: themeColor,
        scaffoldBackgroundColor: AppColors.backgroundDark,
        fontFamily: 'PingFang SC',
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: AppColors.textMainDark),
          bodyMedium: TextStyle(color: AppColors.textMainDark),
          titleLarge: TextStyle(color: AppColors.textMainDark),
          titleMedium: TextStyle(color: AppColors.textMainDark),
          titleSmall: TextStyle(color: AppColors.textMainDark),
        ),
        colorScheme: ColorScheme.dark(
          primary: themeColor,
          surface: AppColors.surfaceDark,
          surfaceContainerHighest: const Color(0xFF1E293B),
          onSurface: AppColors.textMainDark,
        ),
        useMaterial3: true,
      ),
      home: const SplashScreen(nextScreen: MainScreen()),
    );
  }
}

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const StatsScreen(),
    const BudgetScreen(),
    const ProfileScreen(),
  ];

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _showAddScreen() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: AppColors.backgroundOf(context),
      builder: (ctx) => AddTransactionScreen(onBack: () => Navigator.pop(ctx)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = ref.watch(themeColorProvider);
    return Scaffold(
      extendBody: true,
      body: _screens[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.backgroundOf(context).withValues(alpha: 0.95),
          border: Border(top: BorderSide(color: AppColors.divider(context))),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(0, Icons.home, "首页", primaryColor),
                _buildNavItem(1, Icons.pie_chart, "图表", primaryColor),
                GestureDetector(
                  onTap: _showAddScreen,
                  child: Container(
                    width: 56,
                    height: 56,
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          primaryColor,
                          Color.lerp(
                            primaryColor,
                            const Color(0xFF9333EA),
                            0.5,
                          )!,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: primaryColor.withValues(alpha: 0.4),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                      border: Border.all(
                        color: AppColors.backgroundOf(context),
                        width: 4,
                      ),
                    ),
                    child: const Icon(Icons.add, color: Colors.white, size: 32),
                  ),
                ),
                _buildNavItem(
                  2,
                  Icons.account_balance_wallet,
                  "预算",
                  primaryColor,
                ),
                _buildNavItem(3, Icons.person, "我的", primaryColor),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    int index,
    IconData icon,
    String label,
    Color primaryColor,
  ) {
    final isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () => _onTabTapped(index),
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isSelected ? primaryColor : const Color(0xFF64748B),
            size: 26,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? primaryColor : const Color(0xFF64748B),
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

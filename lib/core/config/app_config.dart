import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF7C3AED);
  static const Color primaryHover = Color(0xFF6D28D9);

  static const Color backgroundDark = Color(0xFF0F172A);
  static const Color surfaceDark = Color(0xFF1E293B);
  static const Color textMainDark = Color(0xFFF8FAFC);
  static const Color textSecDark = Color(0xFF94A3B8);

  static const Color backgroundLight = Color(0xFFF8FAFC);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color textMainLight = Color(0xFF0F172A);
  static const Color textSecLight = Color(0xFF64748B);

  static const Color background = backgroundDark;
  static const Color surface = surfaceDark;
  static const Color textMain = textMainDark;
  static const Color textSec = textSecDark;

  static const Color emerald = Color(0xFF34D399);
  static const Color rose = Color(0xFFFB7185);
  static const Color indigo = Color(0xFF818CF8);

  static Color getPrimaryColor(BuildContext context) {
    return Theme.of(context).colorScheme.primary;
  }

  static Color backgroundOf(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? backgroundDark
        : backgroundLight;
  }

  static Color surfaceOf(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? surfaceDark
        : surfaceLight;
  }

  static Color textMainOf(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? textMainDark
        : textMainLight;
  }

  static Color textSecOf(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? textSecDark
        : textSecLight;
  }

  static Color cardBackground(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? surfaceDark
        : surfaceLight;
  }

  static Color divider(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.white.withValues(alpha: 0.05)
        : Colors.black.withValues(alpha: 0.05);
  }
}

final Map<String, IconData> iconMap = {
  'restaurant': Icons.restaurant,
  'shopping_bag': Icons.shopping_bag,
  'directions_car': Icons.directions_car,
  'bolt': Icons.bolt,
  'sports_esports': Icons.sports_esports,
  'home': Icons.home,
  'medical_services': Icons.medical_services,
  'flight': Icons.flight,
  'school': Icons.school,
  'groups': Icons.groups,
  'shopping_cart': Icons.shopping_cart,
  'card_giftcard': Icons.card_giftcard,
  'payments': Icons.payments,
  'search': Icons.search,
  'notifications': Icons.notifications,
  'chevron_right': Icons.chevron_right,
  'trending_up': Icons.trending_up,
  'trending_down': Icons.trending_down,
  'help': Icons.help_outline,
  'pie_chart': Icons.pie_chart,
  'account_balance_wallet': Icons.account_balance_wallet,
  'person': Icons.person,
  'add': Icons.add,
  'arrow_back_ios_new': Icons.arrow_back_ios_new,
  'arrow_back_ios': Icons.arrow_back_ios,
  'share': Icons.share,
  'leaderboard': Icons.leaderboard,
  'close': Icons.close,
  'edit': Icons.edit,
  'backspace': Icons.backspace,
  'history': Icons.history,
  'more_horiz': Icons.more_horiz,
  'sync': Icons.sync,
  'calendar_today': Icons.calendar_today,
  'add_circle': Icons.add_circle,
  'verified': Icons.verified,
  'category': Icons.category,
  'cloud_upload': Icons.cloud_upload,
  'info': Icons.info,
};

IconData getIcon(String name) => iconMap[name] ?? Icons.help;

enum TransactionType { expense, income }

class CategoryModel {
  final String id;
  final String name;
  final String icon;
  final String? color;

  const CategoryModel({
    required this.id,
    required this.name,
    required this.icon,
    this.color,
  });
}

class TransactionModel {
  final String id;
  final double amount;
  final TransactionType type;
  final String categoryId;
  final DateTime date;
  final String? note;
  final String? merchant;

  const TransactionModel({
    required this.id,
    required this.amount,
    required this.type,
    required this.categoryId,
    required this.date,
    this.note,
    this.merchant,
  });
}

const List<CategoryModel> CATEGORIES = [
  CategoryModel(id: '1', name: '餐饮', icon: 'restaurant'),
  CategoryModel(id: '2', name: '购物', icon: 'shopping_bag'),
  CategoryModel(id: '3', name: '交通', icon: 'directions_car'),
  CategoryModel(id: '4', name: '水电', icon: 'bolt'),
  CategoryModel(id: '5', name: '娱乐', icon: 'sports_esports'),
  CategoryModel(id: '6', name: '住房', icon: 'home'),
  CategoryModel(id: '7', name: '医疗', icon: 'medical_services'),
  CategoryModel(id: '8', name: '旅行', icon: 'flight'),
  CategoryModel(id: '9', name: '教育', icon: 'school'),
  CategoryModel(id: '10', name: '社交', icon: 'groups'),
  CategoryModel(id: '11', name: '买菜', icon: 'shopping_cart'),
  CategoryModel(id: '12', name: '礼物', icon: 'card_giftcard'),
  CategoryModel(id: '13', name: '工资', icon: 'payments', color: 'emerald'),
];

final List<TransactionModel> MOCK_TRANSACTIONS = [
  TransactionModel(
    id: 't1',
    amount: 188.00,
    type: TransactionType.expense,
    categoryId: '1',
    date: DateTime(2023, 11, 24, 19, 24),
    merchant: '晚餐 - 鼎泰丰',
  ),
  TransactionModel(
    id: 't2',
    amount: 70.00,
    type: TransactionType.expense,
    categoryId: '3',
    date: DateTime(2023, 11, 24, 17, 10),
    merchant: '滴滴出行',
  ),
  TransactionModel(
    id: 't3',
    amount: 5000.00,
    type: TransactionType.income,
    categoryId: '13',
    date: DateTime(2023, 11, 23, 10, 0),
    merchant: '月度工资发放',
  ),
  TransactionModel(
    id: 't4',
    amount: 12.00,
    type: TransactionType.expense,
    categoryId: '2',
    date: DateTime(2023, 11, 23, 8, 30),
    merchant: '便利店购买',
  ),
  TransactionModel(
    id: 't5',
    amount: 1200.00,
    type: TransactionType.expense,
    categoryId: '6',
    date: DateTime(2023, 11, 22, 14, 0),
    merchant: '公寓房租',
  ),
];

const String USER_AVATAR_URL =
    "https://lh3.googleusercontent.com/aida-public/AB6AXuBef1ZfsMnmDyDV_Qijl3JIaW3RNSjnC8SOo8ZExItbw7M86ZX_eOU4-qfrtGBmJV2JbkejqI44wh6ExXVn6X_TjupJdJsxCAp6BEQpaQ5Vjs7V1xehP5nFWNR7HB6PVCM41YA5SV3Db1_jVwrGEIunCPIkwU2VAkVfrzRIDL8vhhlB0YZKnbJVLRwFTB3UKW0oY9n7a0tLr69yGxUT5TEkwgja39rIDimRIOoN-5uf9SuEKEPGoQ6y7AMOoXPcE_f-fRGbU8xJpd1Y";

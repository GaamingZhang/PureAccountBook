import 'package:flutter/material.dart';

const Map<String, IconData> categoryIconMap = {
  'restaurant': Icons.restaurant,
  'shopping_bag': Icons.shopping_bag,
  'directions_bus': Icons.directions_bus,
  'home': Icons.home,
  'sports_esports': Icons.sports_esports,
  'local_hospital': Icons.local_hospital,
  'school': Icons.school,
  'phone': Icons.phone,
  'checkroom': Icons.checkroom,
  'face': Icons.face,
  'apartment': Icons.apartment,
  'more_horiz': Icons.more_horiz,
  'account_balance_wallet': Icons.account_balance_wallet,
  'card_giftcard': Icons.card_giftcard,
  'trending_up': Icons.trending_up,
  'work': Icons.work,
  'receipt': Icons.receipt,
  'category': Icons.category,
};

IconData getIconData(String iconName) {
  return categoryIconMap[iconName] ?? Icons.category;
}

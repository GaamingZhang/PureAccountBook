import '../models/category.dart';

class DefaultCategories {
  static const List<Category> expenseCategories = [
    Category(name: '餐饮', icon: 'restaurant', type: 'expense', isDefault: true, sortOrder: 1),
    Category(name: '购物', icon: 'shopping_bag', type: 'expense', isDefault: true, sortOrder: 2),
    Category(name: '交通', icon: 'directions_bus', type: 'expense', isDefault: true, sortOrder: 3),
    Category(name: '日用', icon: 'home', type: 'expense', isDefault: true, sortOrder: 4),
    Category(name: '娱乐', icon: 'sports_esports', type: 'expense', isDefault: true, sortOrder: 5),
    Category(name: '医疗', icon: 'local_hospital', type: 'expense', isDefault: true, sortOrder: 6),
    Category(name: '教育', icon: 'school', type: 'expense', isDefault: true, sortOrder: 7),
    Category(name: '通讯', icon: 'phone', type: 'expense', isDefault: true, sortOrder: 8),
    Category(name: '服饰', icon: 'checkroom', type: 'expense', isDefault: true, sortOrder: 9),
    Category(name: '美容', icon: 'face', type: 'expense', isDefault: true, sortOrder: 10),
    Category(name: '住房', icon: 'apartment', type: 'expense', isDefault: true, sortOrder: 11),
    Category(name: '其他', icon: 'more_horiz', type: 'expense', isDefault: true, sortOrder: 12),
  ];

  static const List<Category> incomeCategories = [
    Category(name: '工资', icon: 'account_balance_wallet', type: 'income', isDefault: true, sortOrder: 1),
    Category(name: '奖金', icon: 'card_giftcard', type: 'income', isDefault: true, sortOrder: 2),
    Category(name: '理财', icon: 'trending_up', type: 'income', isDefault: true, sortOrder: 3),
    Category(name: '兼职', icon: 'work', type: 'income', isDefault: true, sortOrder: 4),
    Category(name: '报销', icon: 'receipt', type: 'income', isDefault: true, sortOrder: 5),
    Category(name: '其他', icon: 'more_horiz', type: 'income', isDefault: true, sortOrder: 6),
  ];

  static List<Category> get all => [...expenseCategories, ...incomeCategories];

  static const int expenseCount = 12;
  static const int incomeCount = 6;
  static const int totalCount = expenseCount + incomeCount;
}

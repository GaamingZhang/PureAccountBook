import 'package:flutter/material.dart';
import '../../features/category/models/category.dart';
import '../../l10n/app_localizations.dart';

class LocalizationUtils {
  static String getLocalizedCategoryName(BuildContext context, Category category) {
    final l10n = AppLocalizations.of(context)!;
    final nameMap = {
      '餐饮': l10n.category_food,
      '购物': l10n.category_shopping,
      '交通': l10n.category_transport,
      '日用': l10n.category_daily,
      '娱乐': l10n.category_entertainment,
      '医疗': l10n.category_medical,
      '教育': l10n.category_education,
      '通讯': l10n.category_communication,
      '服饰': l10n.category_clothing,
      '美容': l10n.category_beauty,
      '住房': l10n.category_housing,
      '工资': l10n.category_salary,
      '奖金': l10n.category_bonus,
      '理财': l10n.category_investment,
      '兼职': l10n.category_parttime,
      '报销': l10n.category_reimbursement,
    };
    if (category.type == 'expense' && category.name == '其他') {
      return l10n.category_other_expense;
    }
    if (category.type == 'income' && category.name == '其他') {
      return l10n.category_other_income;
    }
    return nameMap[category.name] ?? category.name;
  }
}

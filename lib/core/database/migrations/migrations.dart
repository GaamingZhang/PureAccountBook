export 'migration.dart';
export 'v2_add_category_color.dart';
export 'v3_add_transaction_updated_at.dart';
export 'v4_add_budgets_table.dart';
export 'v5_add_monthly_budgets_table.dart';

import 'migration.dart';
import 'v2_add_category_color.dart';
import 'v3_add_transaction_updated_at.dart';
import 'v4_add_budgets_table.dart';
import 'v5_add_monthly_budgets_table.dart';

final List<Migration> allMigrations = [
  MigrationV2AddCategoryColor(),
  MigrationV3AddTransactionUpdatedAt(),
  MigrationV4AddBudgetsTable(),
  MigrationV5AddMonthlyBudgetsTable(),
];

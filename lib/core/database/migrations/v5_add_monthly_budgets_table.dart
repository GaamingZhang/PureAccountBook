import 'package:sqflite/sqflite.dart';

import '../tables.dart';
import 'migration.dart';

class MigrationV5AddMonthlyBudgetsTable extends Migration {
  MigrationV5AddMonthlyBudgetsTable()
    : super(
        version: 5,
        description: 'Add monthly_budgets table for total monthly budget',
      );

  @override
  Future<void> up(DatabaseExecutor db) async {
    final tables = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type='table'",
    );
    final tableNames = tables.map((row) => row['name'] as String).toList();

    if (!tableNames.contains(tableMonthlyBudgets)) {
      await db.execute(createMonthlyBudgetsTable);
    }
  }

  @override
  Future<void> down(DatabaseExecutor db) async {
    await db.execute('DROP TABLE IF EXISTS $tableMonthlyBudgets');
  }
}

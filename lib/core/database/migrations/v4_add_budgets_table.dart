import 'package:sqflite/sqflite.dart';

import '../tables.dart';
import 'migration.dart';

class MigrationV4AddBudgetsTable extends Migration {
  MigrationV4AddBudgetsTable()
    : super(version: 4, description: 'Add budgets table');

  @override
  Future<void> up(DatabaseExecutor db) async {
    final tables = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type='table'",
    );
    final tableNames = tables.map((row) => row['name'] as String).toList();

    if (!tableNames.contains(tableBudgets)) {
      await db.execute(createBudgetsTable);
    }
  }

  @override
  Future<void> down(DatabaseExecutor db) async {
    await db.execute('DROP TABLE IF EXISTS $tableBudgets');
  }
}

import 'package:sqflite/sqflite.dart';

import 'migration.dart';
import '../tables.dart';

class MigrationV3AddTransactionUpdatedAt extends Migration {
  MigrationV3AddTransactionUpdatedAt()
    : super(
        version: 3,
        description: 'Add updated_at column to transactions table',
      );

  @override
  Future<void> up(DatabaseExecutor db) async {
    final columns = await db.rawQuery("PRAGMA table_info($tableTransactions)");
    final columnNames = columns.map((row) => row['name'] as String).toList();

    if (!columnNames.contains('updated_at')) {
      await db.execute(
        'ALTER TABLE $tableTransactions ADD COLUMN updated_at TEXT',
      );
    }
  }

  @override
  Future<void> down(DatabaseExecutor db) async {
    await db.execute(
      'CREATE TABLE ${tableTransactions}_temp AS SELECT id, amount, type, category_id, date, note, created_at FROM $tableTransactions',
    );
    await db.execute('DROP TABLE $tableTransactions');
    await db.execute(
      'ALTER TABLE ${tableTransactions}_temp RENAME TO $tableTransactions',
    );
  }
}

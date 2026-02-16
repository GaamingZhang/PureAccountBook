import 'package:sqflite/sqflite.dart';

import 'migration.dart';
import '../tables.dart';

class MigrationV2AddCategoryColor extends Migration {
  MigrationV2AddCategoryColor()
    : super(version: 2, description: 'Add color column to categories table');

  @override
  Future<void> up(DatabaseExecutor db) async {
    final columns = await db.rawQuery("PRAGMA table_info($tableCategories)");
    final columnNames = columns.map((row) => row['name'] as String).toList();

    if (!columnNames.contains('color')) {
      await db.execute('ALTER TABLE $tableCategories ADD COLUMN color TEXT');
    }
  }

  @override
  Future<void> down(DatabaseExecutor db) async {
    await db.execute(
      'CREATE TABLE ${tableCategories}_temp AS SELECT id, name, icon, type, is_default, sort_order FROM $tableCategories',
    );
    await db.execute('DROP TABLE $tableCategories');
    await db.execute(
      'ALTER TABLE ${tableCategories}_temp RENAME TO $tableCategories',
    );
  }
}

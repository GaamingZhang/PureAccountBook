import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:account_book/core/database/database_helper.dart';
import 'package:account_book/core/database/tables.dart';
import 'package:account_book/core/database/migrations/migrations.dart';

Database? _testDb;

Future<Database> _openTestDatabase() async {
  return databaseFactoryFfi.openDatabase(
    inMemoryDatabasePath,
    options: OpenDatabaseOptions(
      version: DatabaseHelper.databaseVersion,
      onCreate: DatabaseHelper.onCreate,
      onUpgrade: DatabaseHelper.onUpgrade,
      onConfigure: DatabaseHelper.onConfigure,
    ),
  );
}

void main() {
  sqfliteFfiInit();

  setUp(() async {
    _testDb = await _openTestDatabase();
  });

  tearDown(() async {
    await _testDb?.close();
    _testDb = null;
  });

  group('DatabaseHelper - table creation', () {
    test('creates categories table with correct columns', () async {
      final db = _testDb!;
      final result = await db.rawQuery(
        "PRAGMA table_info($tableCategories)",
      );

      final columnNames = result.map((row) => row['name'] as String).toList();
      expect(columnNames, containsAll([
        'id', 'name', 'icon', 'type', 'is_default', 'sort_order', 'color',
      ]));
    });

    test('creates transactions table with correct columns', () async {
      final db = _testDb!;
      final result = await db.rawQuery(
        "PRAGMA table_info($tableTransactions)",
      );

      final columnNames = result.map((row) => row['name'] as String).toList();
      expect(columnNames, containsAll([
        'id', 'amount', 'type', 'category_id', 'date', 'note', 'created_at', 'updated_at',
      ]));
    });

    test('enables foreign key constraints', () async {
      final db = _testDb!;
      final result = await db.rawQuery('PRAGMA foreign_keys');
      expect(result.first['foreign_keys'], equals(1));
    });
  });

  group('DatabaseHelper - CRUD operations', () {
    test('can insert and query a category', () async {
      final db = _testDb!;
      final id = await db.insert(tableCategories, {
        'name': '餐饮',
        'icon': 'restaurant',
        'type': 'expense',
        'is_default': 1,
        'sort_order': 0,
      });

      expect(id, greaterThan(0));

      final rows = await db.query(tableCategories, where: 'id = ?', whereArgs: [id]);
      expect(rows.length, equals(1));
      expect(rows.first['name'], equals('餐饮'));
      expect(rows.first['icon'], equals('restaurant'));
      expect(rows.first['type'], equals('expense'));
    });

    test('can insert and query a transaction', () async {
      final db = _testDb!;

      final categoryId = await db.insert(tableCategories, {
        'name': '工资',
        'icon': 'account_balance_wallet',
        'type': 'income',
        'is_default': 1,
        'sort_order': 0,
      });

      final now = DateTime.now().toIso8601String();
      final txnId = await db.insert(tableTransactions, {
        'amount': 10000.0,
        'type': 'income',
        'category_id': categoryId,
        'date': '2026-02-13',
        'note': '二月工资',
        'created_at': now,
      });

      expect(txnId, greaterThan(0));

      final rows = await db.query(tableTransactions, where: 'id = ?', whereArgs: [txnId]);
      expect(rows.length, equals(1));
      expect(rows.first['amount'], equals(10000.0));
      expect(rows.first['note'], equals('二月工资'));
    });

    test('foreign key constraint prevents invalid category_id', () async {
      final db = _testDb!;
      final now = DateTime.now().toIso8601String();

      expect(
        () => db.insert(tableTransactions, {
          'amount': 50.0,
          'type': 'expense',
          'category_id': 9999,
          'date': '2026-02-13',
          'created_at': now,
        }),
        throwsA(isA<DatabaseException>()),
      );
    });

});

  group('DatabaseHelper - migrations', () {
    test('allMigrations list is sorted by version', () {
      for (int i = 1; i < allMigrations.length; i++) {
        expect(
          allMigrations[i].version,
          greaterThan(allMigrations[i - 1].version),
        );
      }
    });

    test('migration v2 adds color column to categories', () async {
      final db = _testDb!;
      final result = await db.rawQuery(
        "PRAGMA table_info($tableCategories)",
      );
      final columnNames = result.map((row) => row['name'] as String).toList();
      expect(columnNames, contains('color'));
    });

    test('migration v3 adds updated_at column to transactions', () async {
      final db = _testDb!;
      final result = await db.rawQuery(
        "PRAGMA table_info($tableTransactions)",
      );
      final columnNames = result.map((row) => row['name'] as String).toList();
      expect(columnNames, contains('updated_at'));
    });

    test('onCreate applies all migrations up to current version', () async {
      final db = _testDb!;

      final catResult = await db.rawQuery(
        "PRAGMA table_info($tableCategories)",
      );
      final catColumns = catResult.map((row) => row['name'] as String).toList();

      final txnResult = await db.rawQuery(
        "PRAGMA table_info($tableTransactions)",
      );
      final txnColumns = txnResult.map((row) => row['name'] as String).toList();

      expect(catColumns, contains('color'));
      expect(txnColumns, contains('updated_at'));
    });

    test('migration preserves existing data during upgrade', () async {
      final dbPath = 'test_migration_${DateTime.now().millisecondsSinceEpoch}.db';
      
      final v1Db = await databaseFactoryFfi.openDatabase(
        dbPath,
        options: OpenDatabaseOptions(
          version: 1,
          onCreate: (db, version) async {
            await db.execute(createCategoriesTable);
            await db.execute(createTransactionsTable);
          },
          onConfigure: DatabaseHelper.onConfigure,
        ),
      );

      await v1Db.insert(tableCategories, {
        'name': '测试类型',
        'icon': 'test',
        'type': 'expense',
        'is_default': 0,
        'sort_order': 0,
      });

      await v1Db.close();

      final upgradedDb = await databaseFactoryFfi.openDatabase(
        dbPath,
        options: OpenDatabaseOptions(
          version: DatabaseHelper.databaseVersion,
          onUpgrade: DatabaseHelper.onUpgrade,
          onConfigure: DatabaseHelper.onConfigure,
        ),
      );

      final catResult = await upgradedDb.rawQuery(
        "PRAGMA table_info($tableCategories)",
      );
      final catColumns = catResult.map((row) => row['name'] as String).toList();

      expect(catColumns, contains('color'));

      final categories = await upgradedDb.query(tableCategories);
      expect(categories.length, equals(1));
      expect(categories.first['name'], equals('测试类型'));

      await upgradedDb.close();
      await databaseFactoryFfi.deleteDatabase(dbPath);
    });
  });

  group('DatabaseHelper - singleton', () {
    test('instance returns the same object', () {
      final a = DatabaseHelper.instance;
      final b = DatabaseHelper.instance;
      expect(identical(a, b), isTrue);
    });

    test('databaseVersion is 5', () {
      expect(DatabaseHelper.databaseVersion, equals(5));
    });

    test('databaseName is account_book.db', () {
      expect(DatabaseHelper.databaseName, equals('account_book.db'));
    });
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:account_book/core/database/database_helper.dart';
import 'package:account_book/core/database/tables.dart';
import 'package:account_book/features/category/data/default_categories.dart';

void main() {
  sqfliteFfiInit();

  group('DefaultCategories', () {
    test('contains 12 expense categories', () {
      expect(DefaultCategories.expenseCategories.length, equals(12));
    });

    test('contains 6 income categories', () {
      expect(DefaultCategories.incomeCategories.length, equals(6));
    });

    test('total count is 18', () {
      expect(DefaultCategories.totalCount, equals(18));
    });

    test('all expense categories have correct type', () {
      for (final cat in DefaultCategories.expenseCategories) {
        expect(cat.type, equals('expense'));
        expect(cat.isDefault, isTrue);
      }
    });

    test('all income categories have correct type', () {
      for (final cat in DefaultCategories.incomeCategories) {
        expect(cat.type, equals('income'));
        expect(cat.isDefault, isTrue);
      }
    });

    test('all categories have non-empty name and icon', () {
      for (final cat in DefaultCategories.all) {
        expect(cat.name.isNotEmpty, isTrue);
        expect(cat.icon.isNotEmpty, isTrue);
      }
    });

    test('expense categories have unique names', () {
      final names = DefaultCategories.expenseCategories.map((c) => c.name).toList();
      expect(names.toSet().length, equals(names.length));
    });

    test('income categories have unique names', () {
      final names = DefaultCategories.incomeCategories.map((c) => c.name).toList();
      expect(names.toSet().length, equals(names.length));
    });

    test('sort orders are sequential for expense categories', () {
      final sortOrders = DefaultCategories.expenseCategories.map((c) => c.sortOrder).toList();
      for (int i = 0; i < sortOrders.length; i++) {
        expect(sortOrders[i], equals(i + 1));
      }
    });

    test('sort orders are sequential for income categories', () {
      final sortOrders = DefaultCategories.incomeCategories.map((c) => c.sortOrder).toList();
      for (int i = 0; i < sortOrders.length; i++) {
        expect(sortOrders[i], equals(i + 1));
      }
    });
  });

  group('DatabaseHelper - default categories insertion', () {
    test('onCreate inserts all default categories', () async {
      final db = await databaseFactoryFfi.openDatabase(
        inMemoryDatabasePath,
        options: OpenDatabaseOptions(
          version: DatabaseHelper.databaseVersion,
          onCreate: DatabaseHelper.onCreate,
          onUpgrade: DatabaseHelper.onUpgrade,
          onConfigure: DatabaseHelper.onConfigure,
        ),
      );

      final count = await db.rawQuery(
        'SELECT COUNT(*) as cnt FROM $tableCategories WHERE is_default = 1',
      );
      expect(count.first['cnt'], equals(18));

      final expenseCount = await db.rawQuery(
        "SELECT COUNT(*) as cnt FROM $tableCategories WHERE type = 'expense' AND is_default = 1",
      );
      expect(expenseCount.first['cnt'], equals(12));

      final incomeCount = await db.rawQuery(
        "SELECT COUNT(*) as cnt FROM $tableCategories WHERE type = 'income' AND is_default = 1",
      );
      expect(incomeCount.first['cnt'], equals(6));

      await db.close();
    });

    test('default categories are sorted by sort_order', () async {
      final db = await databaseFactoryFfi.openDatabase(
        inMemoryDatabasePath,
        options: OpenDatabaseOptions(
          version: DatabaseHelper.databaseVersion,
          onCreate: DatabaseHelper.onCreate,
          onUpgrade: DatabaseHelper.onUpgrade,
          onConfigure: DatabaseHelper.onConfigure,
        ),
      );

      final expenseRows = await db.query(
        tableCategories,
        where: "type = 'expense' AND is_default = 1",
        orderBy: 'sort_order ASC',
      );
      expect(expenseRows.first['name'], equals('餐饮'));
      expect(expenseRows.last['name'], equals('其他'));

      final incomeRows = await db.query(
        tableCategories,
        where: "type = 'income' AND is_default = 1",
        orderBy: 'sort_order ASC',
      );
      expect(incomeRows.first['name'], equals('工资'));
      expect(incomeRows.last['name'], equals('其他'));

      await db.close();
    });

    test('default categories have correct icons', () async {
      final db = await databaseFactoryFfi.openDatabase(
        inMemoryDatabasePath,
        options: OpenDatabaseOptions(
          version: DatabaseHelper.databaseVersion,
          onCreate: DatabaseHelper.onCreate,
          onUpgrade: DatabaseHelper.onUpgrade,
          onConfigure: DatabaseHelper.onConfigure,
        ),
      );

      final rows = await db.query(
        tableCategories,
        where: "name = '餐饮' AND is_default = 1",
      );
      expect(rows.isNotEmpty, isTrue);
      expect(rows.first['icon'], equals('restaurant'));

      final incomeRows = await db.query(
        tableCategories,
        where: "name = '工资' AND is_default = 1",
      );
      expect(incomeRows.isNotEmpty, isTrue);
      expect(incomeRows.first['icon'], equals('account_balance_wallet'));

      await db.close();
    });
  });
}

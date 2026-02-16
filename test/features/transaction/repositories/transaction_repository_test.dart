import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:account_book/core/database/database_helper.dart';
import 'package:account_book/core/database/tables.dart';
import 'package:account_book/features/transaction/models/transaction.dart'
    show TransactionRecord;
import 'package:account_book/features/transaction/repositories/transaction_repository.dart';

late Database _db;
late TransactionRepository _repo;
late int _expenseCategoryId;
late int _incomeCategoryId;

Future<Database> _openTestDatabase() async {
  return databaseFactoryFfi.openDatabase(
    inMemoryDatabasePath,
    options: OpenDatabaseOptions(
      version: DatabaseHelper.databaseVersion,
      onCreate: DatabaseHelper.onCreate,
      onConfigure: DatabaseHelper.onConfigure,
    ),
  );
}

Future<void> _seedCategories(Database db) async {
  _expenseCategoryId = await db.insert(tableCategories, {
    'name': '餐饮',
    'icon': 'restaurant',
    'type': 'expense',
    'is_default': 1,
    'sort_order': 0,
  });
  _incomeCategoryId = await db.insert(tableCategories, {
    'name': '工资',
    'icon': 'account_balance_wallet',
    'type': 'income',
    'is_default': 1,
    'sort_order': 0,
  });
}

TransactionRecord _makeTransaction({
  double amount = 100.0,
  String type = 'expense',
  int? categoryId,
  String date = '2026-02-13',
  String? note,
}) {
  return TransactionRecord(
    amount: amount,
    type: type,
    categoryId: categoryId ?? _expenseCategoryId,
    date: date,
    note: note,
    createdAt: DateTime.now().toIso8601String(),
  );
}

void main() {
  sqfliteFfiInit();

  setUp(() async {
    _db = await _openTestDatabase();
    await _seedCategories(_db);
    _repo = TransactionRepository(_db);
  });

  tearDown(() async {
    await _db.close();
  });

  group('TransactionRepository - insert', () {
    test('inserts a transaction and returns its id', () async {
      final txn = _makeTransaction(note: '午餐');
      final id = await _repo.insert(txn);
      expect(id, greaterThan(0));
    });

    test('inserted transaction can be retrieved', () async {
      final txn = _makeTransaction(amount: 35.5, note: '咖啡');
      final id = await _repo.insert(txn);

      final found = await _repo.findById(id);
      expect(found, isNotNull);
      expect(found!.amount, equals(35.5));
      expect(found.note, equals('咖啡'));
      expect(found.type, equals('expense'));
    });
  });

  group('TransactionRepository - update', () {
    test('updates an existing transaction', () async {
      final txn = _makeTransaction(amount: 50.0, note: '早餐');
      final id = await _repo.insert(txn);

      final updated = txn.copyWith(id: id, amount: 60.0, note: '早午餐');
      final rowsAffected = await _repo.update(updated);
      expect(rowsAffected, equals(1));

      final found = await _repo.findById(id);
      expect(found!.amount, equals(60.0));
      expect(found.note, equals('早午餐'));
    });

    test('throws when updating without id', () {
      final txn = _makeTransaction();
      expect(() => _repo.update(txn), throwsArgumentError);
    });
  });

  group('TransactionRepository - delete', () {
    test('deletes an existing transaction', () async {
      final id = await _repo.insert(_makeTransaction());
      final rowsAffected = await _repo.delete(id);
      expect(rowsAffected, equals(1));

      final found = await _repo.findById(id);
      expect(found, isNull);
    });

    test('returns 0 when deleting non-existent id', () async {
      final rowsAffected = await _repo.delete(9999);
      expect(rowsAffected, equals(0));
    });
  });

  group('TransactionRepository - findAll', () {
    test('returns all transactions ordered by date desc', () async {
      await _repo.insert(_makeTransaction(date: '2026-02-10', note: 'a'));
      await _repo.insert(_makeTransaction(date: '2026-02-13', note: 'b'));
      await _repo.insert(_makeTransaction(date: '2026-02-11', note: 'c'));

      final all = await _repo.findAll();
      expect(all.length, equals(3));
      expect(all[0].date, equals('2026-02-13'));
      expect(all[1].date, equals('2026-02-11'));
      expect(all[2].date, equals('2026-02-10'));
    });

    test('filters by type', () async {
      await _repo.insert(_makeTransaction(type: 'expense'));
      await _repo.insert(_makeTransaction(
        type: 'income',
        categoryId: _incomeCategoryId,
      ));

      final expenses = await _repo.findAll(type: 'expense');
      expect(expenses.length, equals(1));
      expect(expenses.first.type, equals('expense'));

      final incomes = await _repo.findAll(type: 'income');
      expect(incomes.length, equals(1));
      expect(incomes.first.type, equals('income'));
    });

    test('filters by categoryId', () async {
      await _repo.insert(_makeTransaction(categoryId: _expenseCategoryId));
      await _repo.insert(_makeTransaction(
        type: 'income',
        categoryId: _incomeCategoryId,
      ));

      final filtered = await _repo.findAll(categoryId: _expenseCategoryId);
      expect(filtered.length, equals(1));
      expect(filtered.first.categoryId, equals(_expenseCategoryId));
    });
  });

  group('TransactionRepository - findByDateRange', () {
    test('returns transactions within date range', () async {
      await _repo.insert(_makeTransaction(date: '2026-02-01'));
      await _repo.insert(_makeTransaction(date: '2026-02-15'));
      await _repo.insert(_makeTransaction(date: '2026-02-28'));
      await _repo.insert(_makeTransaction(date: '2026-03-01'));

      final result = await _repo.findByDateRange(
        startDate: '2026-02-01',
        endDate: '2026-02-28',
      );
      expect(result.length, equals(3));
    });

    test('filters by type within date range', () async {
      await _repo.insert(_makeTransaction(
        date: '2026-02-10',
        type: 'expense',
      ));
      await _repo.insert(_makeTransaction(
        date: '2026-02-10',
        type: 'income',
        categoryId: _incomeCategoryId,
      ));

      final expenses = await _repo.findByDateRange(
        startDate: '2026-02-01',
        endDate: '2026-02-28',
        type: 'expense',
      );
      expect(expenses.length, equals(1));
      expect(expenses.first.type, equals('expense'));
    });
  });

  group('TransactionRepository - sumByDateRange', () {
    test('sums amounts for given type and date range', () async {
      await _repo.insert(_makeTransaction(amount: 100.0, date: '2026-02-10'));
      await _repo.insert(_makeTransaction(amount: 200.0, date: '2026-02-15'));
      await _repo.insert(_makeTransaction(amount: 50.0, date: '2026-03-01'));

      final total = await _repo.sumByDateRange(
        startDate: '2026-02-01',
        endDate: '2026-02-28',
        type: 'expense',
      );
      expect(total, equals(300.0));
    });

    test('returns 0 when no matching transactions', () async {
      final total = await _repo.sumByDateRange(
        startDate: '2026-01-01',
        endDate: '2026-01-31',
        type: 'expense',
      );
      expect(total, equals(0.0));
    });
  });

  group('TransactionRecord model', () {
    test('fromMap and toMap roundtrip', () {
      final original = TransactionRecord(
        id: 1,
        amount: 99.9,
        type: 'expense',
        categoryId: 5,
        date: '2026-02-13',
        note: 'test',
        createdAt: '2026-02-13T10:00:00.000',
      );

      final map = original.toMap();
      final restored = TransactionRecord.fromMap(map);
      expect(restored, equals(original));
    });

    test('copyWith creates new instance with changes', () {
      final original = _makeTransaction(amount: 100.0, note: 'original');
      final modified = original.copyWith(amount: 200.0, note: 'modified');

      expect(modified.amount, equals(200.0));
      expect(modified.note, equals('modified'));
      expect(original.amount, equals(100.0));
    });

    test('toMap omits id when null', () {
      final txn = _makeTransaction();
      final map = txn.toMap();
      expect(map.containsKey('id'), isFalse);
    });
  });
}

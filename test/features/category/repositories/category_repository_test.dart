import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:account_book/core/database/database_helper.dart';
import 'package:account_book/features/category/models/category.dart';
import 'package:account_book/features/category/repositories/category_repository.dart';
import 'package:account_book/features/category/data/default_categories.dart';

late Database _db;
late CategoryRepository _repo;

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

Category _makeCategory({
  String name = '自定义类型',
  String icon = 'star',
  String type = 'expense',
  bool isDefault = false,
  int sortOrder = 100,
}) {
  return Category(
    name: name,
    icon: icon,
    type: type,
    isDefault: isDefault,
    sortOrder: sortOrder,
  );
}

void main() {
  sqfliteFfiInit();

  setUp(() async {
    _db = await _openTestDatabase();
    _repo = CategoryRepository(_db);
  });

  tearDown(() async {
    await _db.close();
  });

  group('CategoryRepository - insert', () {
    test('inserts a category and returns its id', () async {
      final id = await _repo.insert(_makeCategory());
      expect(id, greaterThan(0));
    });

    test('inserted category can be retrieved', () async {
      final category = _makeCategory(name: '自定义购物', icon: 'shopping_bag');
      final id = await _repo.insert(category);

      final found = await _repo.findById(id);
      expect(found, isNotNull);
      expect(found!.name, equals('自定义购物'));
      expect(found.icon, equals('shopping_bag'));
      expect(found.type, equals('expense'));
    });

    test('inserts category with isDefault flag', () async {
      final category = _makeCategory(isDefault: false);
      final id = await _repo.insert(category);

      final found = await _repo.findById(id);
      expect(found!.isDefault, isFalse);
    });
  });

  group('CategoryRepository - update', () {
    test('updates an existing category', () async {
      final id = await _repo.insert(_makeCategory(name: '自定义餐饮'));

      final updated = _makeCategory(name: '自定义饮食').copyWith(id: id);
      final rowsAffected = await _repo.update(updated);
      expect(rowsAffected, equals(1));

      final found = await _repo.findById(id);
      expect(found!.name, equals('自定义饮食'));
    });

    test('throws when updating without id', () {
      final category = _makeCategory();
      expect(() => _repo.update(category), throwsArgumentError);
    });

    test('returns 0 when updating non-existent id', () async {
      final category = _makeCategory().copyWith(id: 9999);
      final rowsAffected = await _repo.update(category);
      expect(rowsAffected, equals(0));
    });
  });

  group('CategoryRepository - delete', () {
    test('deletes an existing category', () async {
      final id = await _repo.insert(_makeCategory());
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

  group('CategoryRepository - findAll', () {
    test('returns all categories ordered by sort_order', () async {
      await _repo.insert(_makeCategory(name: '自定义C', sortOrder: 102));
      await _repo.insert(_makeCategory(name: '自定义A', sortOrder: 100));
      await _repo.insert(_makeCategory(name: '自定义B', sortOrder: 101));

      final all = await _repo.findAll();
      expect(all.length, greaterThanOrEqualTo(3));

      final customCategories = all.where((c) => c.name.startsWith('自定义')).toList();
      expect(customCategories.length, equals(3));
      expect(customCategories[0].name, equals('自定义A'));
      expect(customCategories[1].name, equals('自定义B'));
      expect(customCategories[2].name, equals('自定义C'));
    });

    test('filters by type', () async {
      await _repo.insert(_makeCategory(name: '自定义餐饮', type: 'expense'));
      await _repo.insert(_makeCategory(name: '自定义工资', type: 'income'));
      await _repo.insert(_makeCategory(name: '自定义购物', type: 'expense'));

      final expenses = await _repo.findAll(type: 'expense');
      final customExpenses = expenses.where((c) => c.name.startsWith('自定义')).toList();
      expect(customExpenses.length, equals(2));
      expect(customExpenses.every((c) => c.type == 'expense'), isTrue);

      final incomes = await _repo.findAll(type: 'income');
      final customIncomes = incomes.where((c) => c.name.startsWith('自定义')).toList();
      expect(customIncomes.length, equals(1));
      expect(customIncomes.first.name, equals('自定义工资'));
    });

    test('returns default categories when no custom categories exist', () async {
      final all = await _repo.findAll();
      expect(all.length, equals(DefaultCategories.totalCount));
    });
  });

  group('CategoryRepository - findById', () {
    test('returns null for non-existent id', () async {
      final found = await _repo.findById(9999);
      expect(found, isNull);
    });
  });

  group('CategoryRepository - count', () {
    test('counts all categories including defaults', () async {
      await _repo.insert(_makeCategory(name: '自定义A'));
      await _repo.insert(_makeCategory(name: '自定义B'));
      await _repo.insert(_makeCategory(name: '自定义C', type: 'income'));

      final total = await _repo.count();
      expect(total, equals(DefaultCategories.totalCount + 3));
    });

    test('counts by type including defaults', () async {
      await _repo.insert(_makeCategory(name: '自定义A', type: 'expense'));
      await _repo.insert(_makeCategory(name: '自定义B', type: 'expense'));
      await _repo.insert(_makeCategory(name: '自定义C', type: 'income'));

      final expenseCount = await _repo.count(type: 'expense');
      expect(expenseCount, equals(DefaultCategories.expenseCount + 2));

      final incomeCount = await _repo.count(type: 'income');
      expect(incomeCount, equals(DefaultCategories.incomeCount + 1));
    });

    test('returns default count when empty', () async {
      final total = await _repo.count();
      expect(total, equals(DefaultCategories.totalCount));
    });
  });

  group('Category model', () {
    test('fromMap and toMap roundtrip', () {
      final original = Category(
        id: 1,
        name: '餐饮',
        icon: 'restaurant',
        type: 'expense',
        isDefault: true,
        sortOrder: 5,
      );

      final map = original.toMap();
      final restored = Category.fromMap(map);
      expect(restored, equals(original));
    });

    test('copyWith creates new instance with changes', () {
      final original = _makeCategory(name: '餐饮');
      final modified = original.copyWith(name: '饮食', sortOrder: 10);

      expect(modified.name, equals('饮食'));
      expect(modified.sortOrder, equals(10));
      expect(original.name, equals('餐饮'));
      expect(original.sortOrder, equals(100));
    });

    test('toMap omits id when null', () {
      final category = _makeCategory();
      final map = category.toMap();
      expect(map.containsKey('id'), isFalse);
    });

    test('equality works correctly', () {
      final a = Category(
        id: 1,
        name: '餐饮',
        icon: 'restaurant',
        type: 'expense',
      );
      final b = Category(
        id: 1,
        name: '餐饮',
        icon: 'restaurant',
        type: 'expense',
      );
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });
  });
}

import 'package:sqflite/sqflite.dart';

import '../../../core/database/tables.dart';
import '../models/category.dart';

class CategoryRepository {
  final Database _db;

  const CategoryRepository(this._db);

  Future<int> insert(Category category) {
    return _db.insert(tableCategories, category.toMap());
  }

  Future<int> update(Category category) {
    if (category.id == null) {
      throw ArgumentError('Cannot update category without id');
    }
    return _db.update(
      tableCategories,
      category.toMap(),
      where: 'id = ?',
      whereArgs: [category.id],
    );
  }

  Future<int> delete(int id) {
    return _db.delete(
      tableCategories,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<Category?> findById(int id) async {
    final rows = await _db.query(
      tableCategories,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (rows.isEmpty) return null;
    return Category.fromMap(rows.first);
  }

  Future<List<Category>> findAll({
    String? type,
    String orderBy = 'sort_order ASC, id ASC',
  }) async {
    String? where;
    List<dynamic>? whereArgs;

    if (type != null) {
      where = 'type = ?';
      whereArgs = [type];
    }

    final rows = await _db.query(
      tableCategories,
      where: where,
      whereArgs: whereArgs,
      orderBy: orderBy,
    );
    return rows.map(Category.fromMap).toList();
  }

  Future<int> count({String? type}) async {
    final where = type != null ? 'WHERE type = ?' : '';
    final whereArgs = type != null ? [type] : <dynamic>[];
    final result = await _db.rawQuery(
      'SELECT COUNT(*) as cnt FROM $tableCategories $where',
      whereArgs,
    );
    return (result.first['cnt'] as int?) ?? 0;
  }
}

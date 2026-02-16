import 'package:sqflite/sqflite.dart';

import '../../../core/database/tables.dart';
import '../models/transaction.dart';

class TransactionRepository {
  final Database _db;

  const TransactionRepository(this._db);

  Future<int> insert(TransactionRecord transaction) {
    return _db.insert(tableTransactions, transaction.toMap());
  }

  Future<int> update(TransactionRecord transaction) {
    if (transaction.id == null) {
      throw ArgumentError('Cannot update transaction without id');
    }
    return _db.update(
      tableTransactions,
      transaction.toMap(),
      where: 'id = ?',
      whereArgs: [transaction.id],
    );
  }

  Future<int> delete(int id) {
    return _db.delete(
      tableTransactions,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<TransactionRecord?> findById(int id) async {
    final rows = await _db.query(
      tableTransactions,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (rows.isEmpty) return null;
    return TransactionRecord.fromMap(rows.first);
  }

  Future<List<TransactionRecord>> findAll({
    String? type,
    int? categoryId,
    String orderBy = 'date DESC, created_at DESC',
  }) async {
    String? where;
    List<dynamic>? whereArgs;

    if (type != null && categoryId != null) {
      where = 'type = ? AND category_id = ?';
      whereArgs = [type, categoryId];
    } else if (type != null) {
      where = 'type = ?';
      whereArgs = [type];
    } else if (categoryId != null) {
      where = 'category_id = ?';
      whereArgs = [categoryId];
    }

    final rows = await _db.query(
      tableTransactions,
      where: where,
      whereArgs: whereArgs,
      orderBy: orderBy,
    );
    return rows.map(TransactionRecord.fromMap).toList();
  }

  Future<List<TransactionRecord>> findByDateRange({
    required String startDate,
    required String endDate,
    String? type,
  }) async {
    final where = StringBuffer('date >= ? AND date <= ?');
    final whereArgs = <dynamic>[startDate, endDate];

    if (type != null) {
      where.write(' AND type = ?');
      whereArgs.add(type);
    }

    final rows = await _db.query(
      tableTransactions,
      where: where.toString(),
      whereArgs: whereArgs,
      orderBy: 'date DESC, created_at DESC',
    );
    return rows.map(TransactionRecord.fromMap).toList();
  }

  Future<double> sumByDateRange({
    required String startDate,
    required String endDate,
    required String type,
  }) async {
    final result = await _db.rawQuery(
      'SELECT COALESCE(SUM(amount), 0) as total '
      'FROM $tableTransactions '
      'WHERE date >= ? AND date <= ? AND type = ?',
      [startDate, endDate, type],
    );
    return (result.first['total'] as num).toDouble();
  }
}

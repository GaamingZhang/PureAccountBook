import 'package:sqflite/sqflite.dart';

import '../../../core/database/tables.dart';
import '../models/monthly_budget.dart';

class MonthlyBudgetRepository {
  final Database _db;

  const MonthlyBudgetRepository(this._db);

  Future<int> insert(MonthlyBudget budget) {
    return _db.insert(tableMonthlyBudgets, budget.toMap());
  }

  Future<int> update(MonthlyBudget budget) {
    if (budget.id == null) {
      throw ArgumentError('Cannot update budget without id');
    }
    return _db.update(
      tableMonthlyBudgets,
      budget.toMap(),
      where: 'id = ?',
      whereArgs: [budget.id],
    );
  }

  Future<int> delete(int id) {
    return _db.delete(tableMonthlyBudgets, where: 'id = ?', whereArgs: [id]);
  }

  Future<MonthlyBudget?> findById(int id) async {
    final rows = await _db.query(
      tableMonthlyBudgets,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (rows.isEmpty) return null;
    return MonthlyBudget.fromMap(rows.first);
  }

  Future<MonthlyBudget?> findByMonth(String month) async {
    final rows = await _db.query(
      tableMonthlyBudgets,
      where: 'month = ?',
      whereArgs: [month],
    );
    if (rows.isEmpty) return null;
    return MonthlyBudget.fromMap(rows.first);
  }

  Future<int> upsert(MonthlyBudget budget) async {
    if (budget.id != null) {
      return update(budget);
    }

    final existing = await findByMonth(budget.month);
    if (existing != null) {
      final updated = budget.copyWith(id: existing.id);
      return update(updated);
    }

    return insert(budget);
  }

  Future<List<MonthlyBudget>> findAll() async {
    final rows = await _db.query(tableMonthlyBudgets, orderBy: 'month DESC');
    return rows.map(MonthlyBudget.fromMap).toList();
  }
}

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../models/monthly_budget.dart';
import '../repositories/monthly_budget_repository.dart';
import '../../transaction/providers/transaction_list_provider.dart';
import '../../../core/database/database_helper.dart';

final databaseProvider = FutureProvider((ref) async {
  return DatabaseHelper.instance.database;
});

final monthlyBudgetRepositoryProvider = FutureProvider<MonthlyBudgetRepository>(
  (ref) async {
    final db = await ref.watch(databaseProvider.future);
    return MonthlyBudgetRepository(db);
  },
);

class MonthlyBudgetState {
  final AsyncValue<MonthlyBudget?> budget;
  final AsyncValue<double> totalSpent;
  final double progress;
  final bool isOverBudget;

  const MonthlyBudgetState({
    this.budget = const AsyncValue.loading(),
    this.totalSpent = const AsyncValue.data(0),
    this.progress = 0,
    this.isOverBudget = false,
  });

  MonthlyBudgetState copyWith({
    AsyncValue<MonthlyBudget?>? budget,
    AsyncValue<double>? totalSpent,
    double? progress,
    bool? isOverBudget,
  }) {
    return MonthlyBudgetState(
      budget: budget ?? this.budget,
      totalSpent: totalSpent ?? this.totalSpent,
      progress: progress ?? this.progress,
      isOverBudget: isOverBudget ?? this.isOverBudget,
    );
  }
}

class MonthlyBudgetNotifier extends StateNotifier<MonthlyBudgetState> {
  final Ref _ref;
  String _currentMonth = '';

  MonthlyBudgetNotifier(this._ref) : super(const MonthlyBudgetState()) {
    _currentMonth = DateFormat('yyyy-MM').format(DateTime.now());
    loadBudget(_currentMonth);
    _listenForTransactionChanges();
  }

  void _listenForTransactionChanges() {
    _ref.listen(transactionRefreshProvider, (_, __) {
      if (_currentMonth.isNotEmpty) {
        loadBudget(_currentMonth);
      }
    });
  }

  Future<void> loadBudget(String month) async {
    _currentMonth = month;
    try {
      state = state.copyWith(budget: const AsyncValue.loading());

      final repo = await _ref.read(monthlyBudgetRepositoryProvider.future);
      final budget = await repo.findByMonth(month);

      final totalSpent = await _calculateTotalSpent(month);

      final budgetAmount = budget?.amount ?? 0;
      final progress = budgetAmount > 0
          ? (totalSpent / budgetAmount) * 100
          : 0.0;
      final isOverBudget = budgetAmount > 0 && totalSpent > budgetAmount;

      state = state.copyWith(
        budget: AsyncValue.data(budget),
        totalSpent: AsyncValue.data(totalSpent),
        progress: progress,
        isOverBudget: isOverBudget,
      );
    } catch (e, st) {
      state = state.copyWith(
        budget: AsyncValue.error(e, st),
        totalSpent: AsyncValue.error(e, st),
      );
    }
  }

  Future<double> _calculateTotalSpent(String month) async {
    final transactionsAsync = _ref.read(transactionsByMonthProvider(month));

    return transactionsAsync.when(
      data: (transactions) {
        double total = 0;
        for (final transaction in transactions) {
          if (transaction.type == 'expense') {
            total += transaction.amount;
          }
        }
        return total;
      },
      loading: () => 0,
      error: (_, StackTrace stackTrace) => 0,
    );
  }

  Future<void> setBudget(double amount) async {
    try {
      final repo = await _ref.read(monthlyBudgetRepositoryProvider.future);
      final budget = MonthlyBudget.create(amount: amount, month: _currentMonth);
      await repo.upsert(budget);
      await loadBudget(_currentMonth);
    } catch (e, st) {
      state = state.copyWith(budget: AsyncValue.error(e, st));
      rethrow;
    }
  }

  Future<void> deleteBudget() async {
    try {
      final repo = await _ref.read(monthlyBudgetRepositoryProvider.future);
      final budget = await repo.findByMonth(_currentMonth);
      if (budget?.id != null) {
        await repo.delete(budget!.id!);
      }
      await loadBudget(_currentMonth);
    } catch (e, st) {
      state = state.copyWith(budget: AsyncValue.error(e, st));
      rethrow;
    }
  }

  Future<void> refresh() async {
    await loadBudget(_currentMonth);
  }

  Future<void> applyBudgetToAllMonths(double amount) async {
    try {
      final repo = await _ref.read(monthlyBudgetRepositoryProvider.future);
      final now = DateTime.now();
      final months = <String>[];
      for (int i = 0; i < 12; i++) {
        final month = DateTime(now.year, now.month - i, 1);
        months.add(DateFormat('yyyy-MM').format(month));
      }
      for (int i = 1; i <= 12; i++) {
        final month = DateTime(now.year, now.month + i, 1);
        months.add(DateFormat('yyyy-MM').format(month));
      }
      for (final month in months) {
        final budget = MonthlyBudget.create(amount: amount, month: month);
        await repo.upsert(budget);
      }
      await loadBudget(_currentMonth);
    } catch (e, st) {
      state = state.copyWith(budget: AsyncValue.error(e, st));
      rethrow;
    }
  }
}

final monthlyBudgetProvider =
    StateNotifierProvider<MonthlyBudgetNotifier, MonthlyBudgetState>((ref) {
      return MonthlyBudgetNotifier(ref);
    });

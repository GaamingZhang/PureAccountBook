import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/transaction.dart';
import '../repositories/transaction_repository.dart';
import '../../category/providers/category_provider.dart';
import 'transaction_list_provider.dart';

final transactionRepositoryProvider = FutureProvider<TransactionRepository>((ref) async {
  final db = await ref.watch(databaseProvider.future);
  return TransactionRepository(db);
});

final transactionNotifierProvider =
    StateNotifierProvider<TransactionNotifier, AsyncValue<void>>((ref) {
  return TransactionNotifier(ref);
});

class TransactionNotifier extends StateNotifier<AsyncValue<void>> {
  final Ref _ref;

  TransactionNotifier(this._ref) : super(const AsyncValue.data(null));

  void _refresh() {
    final current = _ref.read(transactionRefreshProvider);
    _ref.read(transactionRefreshProvider.notifier).state = current + 1;
  }

  Future<int> addTransaction(TransactionRecord transaction) async {
    state = const AsyncValue.loading();
    try {
      final repo = await _ref.read(transactionRepositoryProvider.future);
      final id = await repo.insert(transaction);
      _refresh();
      state = const AsyncValue.data(null);
      return id;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> updateTransaction(TransactionRecord transaction) async {
    state = const AsyncValue.loading();
    try {
      final repo = await _ref.read(transactionRepositoryProvider.future);
      await repo.update(transaction);
      _refresh();
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> deleteTransaction(int id) async {
    state = const AsyncValue.loading();
    try {
      final repo = await _ref.read(transactionRepositoryProvider.future);
      await repo.delete(id);
      _refresh();
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }
}

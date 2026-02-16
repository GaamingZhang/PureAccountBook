import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../core/config/app_config.dart';
import '../providers/theme_provider.dart';
import '../features/transaction/providers/transaction_list_provider.dart';
import '../features/transaction/providers/transaction_provider.dart';
import '../features/transaction/models/transaction.dart';
import '../features/category/providers/category_provider.dart';
import '../features/category/models/category.dart';
import '../l10n/app_localizations.dart';
import '../core/utils/localization_utils.dart';

final currentMonthProvider = StateProvider<DateTime>((ref) => DateTime.now());
final filterTypeProvider = StateProvider<String>((ref) => 'all');

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  bool _isSearching = false;
  String _searchQuery = '';
  final _searchController = TextEditingController();
  final _searchFocusNode = FocusNode();

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  String _getGreeting(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final hour = DateTime.now().hour;
    if (hour < 12) return l10n.goodMorning;
    if (hour < 18) return l10n.goodAfternoon;
    return l10n.goodEvening;
  }

  void _startSearch() {
    setState(() {
      _isSearching = true;
    });
    _searchFocusNode.requestFocus();
  }

  void _stopSearch() {
    setState(() {
      _isSearching = false;
      _searchQuery = '';
      _searchController.clear();
    });
  }

  List<TransactionRecord> _filterTransactions(
    List<TransactionRecord> transactions,
    List<Category> allCategories,
    String filterType,
  ) {
    var filtered = filterType == 'all'
        ? transactions
        : transactions.where((t) => t.type == filterType).toList();

    if (_searchQuery.isEmpty) return filtered;

    final query = _searchQuery.toLowerCase();
    return filtered.where((t) {
      final category = allCategories
          .where((c) => c.id == t.categoryId)
          .firstOrNull;
      final categoryName = category?.name.toLowerCase() ?? '';
      final note = (t.note ?? '').toLowerCase();
      return categoryName.contains(query) || note.contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final currentMonth = ref.watch(currentMonthProvider);
    final monthKey = DateFormat('yyyy-MM').format(currentMonth);
    final transactionsAsync = ref.watch(transactionsByMonthProvider(monthKey));
    final categoriesAsync = ref.watch(expenseCategoriesProvider);
    final incomeCategoriesAsync = ref.watch(incomeCategoriesProvider);
    final filterType = ref.watch(filterTypeProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundOf(context),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: AppColors.backgroundOf(
              context,
            ).withValues(alpha: 0.9),
            floating: true,
            pinned: true,
            elevation: 0,
            titleSpacing: 16,
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(1.0),
              child: Container(color: AppColors.divider(context), height: 1.0),
            ),
            title: _isSearching ? _buildSearchBar() : _buildNormalTitle(),
            actions: _isSearching
                ? [
                    IconButton(
                      icon: Icon(
                        Icons.close,
                        color: AppColors.textSecOf(context),
                      ),
                      onPressed: _stopSearch,
                    ),
                    const SizedBox(width: 8),
                  ]
                : [
                    IconButton(
                      icon: Icon(
                        Icons.search,
                        color: AppColors.textSecOf(context),
                      ),
                      onPressed: _startSearch,
                    ),
                    const SizedBox(width: 8),
                  ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildMonthNavigator(context, currentMonth, ref),
                  const SizedBox(height: 16),
                  _buildMonthlySummary(transactionsAsync),
                  const SizedBox(height: 32),
                  _buildTransactionHeader(ref, filterType),
                  if (_isSearching && _searchQuery.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Builder(
                      builder: (ctx) {
                        final l10n = AppLocalizations.of(ctx)!;
                        return Text(
                          '${l10n.searchLabel}: "$_searchQuery"',
                          style: TextStyle(
                            color: AppColors.textSecOf(ctx),
                            fontSize: 12,
                          ),
                        );
                      },
                    ),
                  ],
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
          _buildTransactionList(
            transactionsAsync,
            categoriesAsync,
            incomeCategoriesAsync,
            filterType,
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 80)),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    final l10n = AppLocalizations.of(context)!;
    return Builder(
      builder: (ctx) => TextField(
        controller: _searchController,
        focusNode: _searchFocusNode,
        style: TextStyle(color: AppColors.textMainOf(ctx), fontSize: 16),
        decoration: InputDecoration(
          hintText: l10n.searchHint,
          hintStyle: TextStyle(color: AppColors.textSecOf(ctx), fontSize: 14),
          border: InputBorder.none,
          isDense: true,
          contentPadding: EdgeInsets.zero,
        ),
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
      ),
    );
  }

  Widget _buildNormalTitle() {
    final primaryColor = ref.watch(themeColorProvider);
    final l10n = AppLocalizations.of(context)!;
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: primaryColor.withValues(alpha: 0.2),
            border: Border.all(color: primaryColor.withValues(alpha: 0.3)),
          ),
          child: Icon(
            Icons.account_balance_wallet,
            color: primaryColor,
            size: 24,
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _getGreeting(context),
              style: TextStyle(
                color: AppColors.textSecOf(context),
                fontSize: 12,
                fontWeight: FontWeight.w400,
              ),
            ),
            Text(
              l10n.welcomeText,
              style: TextStyle(
                color: AppColors.textMainOf(context),
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMonthNavigator(
    BuildContext context,
    DateTime currentMonth,
    WidgetRef ref,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final now = DateTime.now();
    final isCurrentMonth =
        currentMonth.year == now.year && currentMonth.month == now.month;

    return Row(
      children: [
        IconButton(
          icon: Icon(Icons.chevron_left, color: AppColors.textSecOf(context)),
          onPressed: () {
            final newMonth = DateTime(
              currentMonth.year,
              currentMonth.month - 1,
            );
            ref.read(currentMonthProvider.notifier).state = newMonth;
          },
        ),
        GestureDetector(
          onTap: () async {
            final primaryColor = ref.read(themeColorProvider);
            final isDark = Theme.of(context).brightness == Brightness.dark;
            final picked = await showDatePicker(
              context: context,
              initialDate: currentMonth,
              firstDate: DateTime(2020),
              lastDate: DateTime.now(),
              builder: (context, child) {
                return Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: isDark
                        ? ColorScheme.dark(
                            primary: primaryColor,
                            surface: AppColors.surfaceDark,
                            onSurface: AppColors.textMainDark,
                          )
                        : ColorScheme.light(
                            primary: primaryColor,
                            surface: AppColors.surfaceLight,
                            onSurface: AppColors.textMainLight,
                          ),
                  ),
                  child: child!,
                );
              },
            );
            if (picked != null) {
              ref.read(currentMonthProvider.notifier).state = picked;
            }
          },
          child: Text(
            l10n.monthSummary(currentMonth.month.toString()),
            style: TextStyle(
              color: AppColors.textMainOf(context),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        if (!isCurrentMonth)
          IconButton(
            icon: Icon(
              Icons.chevron_right,
              color: AppColors.textSecOf(context),
            ),
            onPressed: () {
              final newMonth = DateTime(
                currentMonth.year,
                currentMonth.month + 1,
              );
              ref.read(currentMonthProvider.notifier).state = newMonth;
            },
          )
        else
          const SizedBox(width: 48),
      ],
    );
  }

  Widget _buildMonthlySummary(
    AsyncValue<List<TransactionRecord>> transactionsAsync,
  ) {
    final l10n = AppLocalizations.of(context)!;
    return transactionsAsync.when(
      data: (transactions) {
        double totalIncome = 0;
        double totalExpense = 0;
        for (final t in transactions) {
          if (t.type == 'income') {
            totalIncome += t.amount;
          } else {
            totalExpense += t.amount;
          }
        }
        final balance = totalIncome - totalExpense;
        final primaryColor = ref.watch(themeColorProvider);

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.surfaceOf(context),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.divider(context)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: _buildSummaryItem(
                  context,
                  l10n.totalIncome,
                  "¥${_formatAmount(totalIncome)}",
                  primaryColor,
                  AppColors.emerald,
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 16),
                  child: _buildSummaryItem(
                    context,
                    l10n.totalExpense,
                    "¥${_formatAmount(totalExpense)}",
                    AppColors.rose,
                    AppColors.rose,
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 16),
                  child: _buildSummaryItem(
                    context,
                    l10n.balance,
                    "¥${_formatAmount(balance)}",
                    AppColors.indigo,
                    AppColors.indigo,
                  ),
                ),
              ),
            ],
          ),
        );
      },
      loading: () => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surfaceOf(context),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surfaceOf(context),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(child: Text('${l10n.loadFailed}: $e')),
      ),
    );
  }

  Widget _buildTransactionHeader(WidgetRef ref, String filterType) {
    final l10n = AppLocalizations.of(context)!;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          l10n.recordList,
          style: TextStyle(
            color: AppColors.textMainOf(context),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: AppColors.surfaceOf(context),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.divider(context)),
          ),
          child: Row(
            children: [
              _buildFilterChip(context, ref, l10n.all, "all", filterType),
              _buildFilterChip(
                context,
                ref,
                l10n.expense,
                "expense",
                filterType,
              ),
              _buildFilterChip(context, ref, l10n.income, "income", filterType),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionList(
    AsyncValue<List<TransactionRecord>> transactionsAsync,
    AsyncValue<List<Category>> categoriesAsync,
    AsyncValue<List<Category>> incomeCategoriesAsync,
    String filterType,
  ) {
    final l10n = AppLocalizations.of(context)!;
    return transactionsAsync.when(
      data: (transactions) {
        return categoriesAsync.when(
          data: (expenseCategories) => incomeCategoriesAsync.when(
            data: (incomeCategories) {
              final allCategories = [...expenseCategories, ...incomeCategories];
              final filtered = _filterTransactions(
                transactions,
                allCategories,
                filterType,
              );

              if (filtered.isEmpty) {
                return SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(48),
                      child: Column(
                        children: [
                          Icon(
                            _isSearching
                                ? Icons.search_off
                                : Icons.receipt_long,
                            size: 64,
                            color: AppColors.textSecOf(
                              context,
                            ).withValues(alpha: 0.3),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _isSearching && _searchQuery.isNotEmpty
                                ? l10n.noMatchFound
                                : l10n.noRecordsYet,
                            style: TextStyle(
                              color: AppColors.textSecOf(context),
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _isSearching && _searchQuery.isNotEmpty
                                ? l10n.tryOtherKeywords
                                : l10n.addFirstRecord,
                            style: TextStyle(
                              color: AppColors.textSecOf(context),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }

              final grouped = _groupByDate(filtered);
              final sortedDates = grouped.keys.toList()
                ..sort((a, b) => b.compareTo(a));

              return SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final date = sortedDates[index];
                  final dayTransactions = grouped[date]!;
                  return _buildDateGroup(date, dayTransactions, allCategories);
                }, childCount: sortedDates.length),
              );
            },
            loading: () => const SliverToBoxAdapter(child: SizedBox()),
            error: (e, _) => const SliverToBoxAdapter(child: SizedBox()),
          ),
          loading: () => const SliverToBoxAdapter(child: SizedBox()),
          error: (e, _) => const SliverToBoxAdapter(child: SizedBox()),
        );
      },
      loading: () => const SliverToBoxAdapter(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(48),
            child: CircularProgressIndicator(),
          ),
        ),
      ),
      error: (e, _) => SliverToBoxAdapter(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(48),
            child: Text('${l10n.loadFailed}: $e'),
          ),
        ),
      ),
    );
  }

  String _formatAmount(double amount) {
    if (amount.abs() >= 10000) {
      return '${(amount / 10000).toStringAsFixed(1)}万';
    }
    return amount.toStringAsFixed(0);
  }

  Map<String, List<TransactionRecord>> _groupByDate(
    List<TransactionRecord> transactions,
  ) {
    final map = <String, List<TransactionRecord>>{};
    for (final t in transactions) {
      map.putIfAbsent(t.date, () => []).add(t);
    }
    return map;
  }

  Widget _buildSummaryItem(
    BuildContext context,
    String label,
    String amount,
    Color amountColor,
    Color trendColor,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: AppColors.textSecOf(context),
            fontSize: 14,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          amount,
          style: TextStyle(
            color: amountColor,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(
    BuildContext context,
    WidgetRef ref,
    String label,
    String value,
    String currentValue,
  ) {
    final isSelected = currentValue == value;
    final primaryColor = ref.watch(themeColorProvider);
    return GestureDetector(
      onTap: () {
        ref.read(filterTypeProvider.notifier).state = value;
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? primaryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 4,
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.textSecOf(context),
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildDateGroup(
    String dateStr,
    List<TransactionRecord> transactions,
    List<Category> categories,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final date = DateTime.parse(dateStr);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final targetDate = DateTime(date.year, date.month, date.day);

    String label;
    if (targetDate == today) {
      label = l10n.today;
    } else if (targetDate == yesterday) {
      label = l10n.yesterday;
    } else {
      label = "";
    }

    double dayIncome = 0;
    double dayExpense = 0;
    for (final t in transactions) {
      if (t.type == 'income') {
        dayIncome += t.amount;
      } else {
        dayExpense += t.amount;
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      DateFormat('MM月dd日').format(date),
                      style: TextStyle(
                        color: AppColors.textMainOf(context),
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (label.isNotEmpty) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceOf(context),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          label,
                          style: TextStyle(
                            color: AppColors.textSecOf(context),
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                Row(
                  children: [
                    Text(
                      l10n.incomeLabel,
                      style: TextStyle(
                        color: AppColors.textSecOf(context),
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      "¥${dayIncome.toStringAsFixed(0)}",
                      style: TextStyle(
                        color: AppColors.emerald,
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      l10n.expenseLabel,
                      style: TextStyle(
                        color: AppColors.textSecOf(context),
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      "¥${dayExpense.toStringAsFixed(0)}",
                      style: TextStyle(
                        color: AppColors.rose,
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Divider(color: AppColors.divider(context), height: 1),
          const SizedBox(height: 8),
          ...transactions.map((tx) {
            final category = categories.firstWhere(
              (c) => c.id == tx.categoryId,
              orElse: () => Category(
                id: tx.categoryId,
                name: l10n.unknown,
                icon: 'help',
                type: tx.type,
              ),
            );
            final isIncome = tx.type == 'income';

            return Dismissible(
              key: Key(tx.id.toString()),
              direction: DismissDirection.endToStart,
              background: Container(
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: AppColors.rose.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.delete_outline, color: AppColors.rose),
                    const SizedBox(width: 8),
                    Text(
                      l10n.delete,
                      style: TextStyle(
                        color: AppColors.rose,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              confirmDismiss: (direction) async {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    backgroundColor: AppColors.surfaceOf(ctx),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    title: Text(
                      l10n.confirmDelete,
                      style: TextStyle(
                        color: AppColors.textMainOf(ctx),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    content: Text(
                      l10n.confirmDeleteMessage,
                      style: TextStyle(color: AppColors.textSecOf(ctx)),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        child: Text(
                          l10n.cancel,
                          style: TextStyle(color: AppColors.textSecOf(ctx)),
                        ),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        child: Text(
                          l10n.delete,
                          style: TextStyle(color: AppColors.rose),
                        ),
                      ),
                    ],
                  ),
                );
                return confirmed == true;
              },
              onDismissed: (direction) async {
                try {
                  await ref
                      .read(transactionNotifierProvider.notifier)
                      .deleteTransaction(tx.id!);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(l10n.recordDeleted),
                        backgroundColor: AppColors.emerald,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${l10n.error}: $e'),
                        backgroundColor: AppColors.rose,
                      ),
                    );
                  }
                }
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceOf(context),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        _getIconData(category.icon),
                        color: AppColors.textSecOf(context),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            LocalizationUtils.getLocalizedCategoryName(context, category),
                            style: TextStyle(
                              color: AppColors.textMainOf(context),
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            tx.note ?? (isIncome ? l10n.defaultNoteIncome : l10n.defaultNoteExpense),
                            style: TextStyle(
                              color: AppColors.textSecOf(context),
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      "${isIncome ? '+' : '-'}¥${tx.amount.toStringAsFixed(2)}",
                      style: TextStyle(
                        color: isIncome ? AppColors.emerald : AppColors.rose,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  IconData _getIconData(String iconName) {
    final iconMap = <String, IconData>{
      'restaurant': Icons.restaurant,
      'shopping_bag': Icons.shopping_bag,
      'directions_car': Icons.directions_car,
      'directions_bus': Icons.directions_bus,
      'bolt': Icons.bolt,
      'sports_esports': Icons.sports_esports,
      'home': Icons.home,
      'medical_services': Icons.medical_services,
      'local_hospital': Icons.local_hospital,
      'flight': Icons.flight,
      'school': Icons.school,
      'groups': Icons.groups,
      'phone': Icons.phone,
      'checkroom': Icons.checkroom,
      'face': Icons.face,
      'apartment': Icons.apartment,
      'more_horiz': Icons.more_horiz,
      'account_balance_wallet': Icons.account_balance_wallet,
      'card_giftcard': Icons.card_giftcard,
      'trending_up': Icons.trending_up,
      'work': Icons.work,
      'receipt': Icons.receipt,
      'payments': Icons.payments,
      'savings': Icons.savings,
      'attach_money': Icons.attach_money,
      'help': Icons.help_outline,
    };
    return iconMap[iconName] ?? Icons.category;
  }
}

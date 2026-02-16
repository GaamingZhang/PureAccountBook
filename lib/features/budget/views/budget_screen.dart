import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/config/app_config.dart';
import '../../../providers/theme_provider.dart';
import '../../../shared/widgets/widgets.dart';
import '../../../l10n/app_localizations.dart';
import '../providers/monthly_budget_provider.dart';
import 'add_budget_page.dart' show showAddBudgetPage;

final currentBudgetMonthProvider = StateProvider<DateTime>(
  (ref) => DateTime.now(),
);

class BudgetScreen extends ConsumerWidget {
  const BudgetScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentMonth = ref.watch(currentBudgetMonthProvider);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.backgroundOf(context),
      appBar: CommonAppBar(title: l10n.budget),
      body: Consumer(
        builder: (context, ref, child) {
          final budgetState = ref.watch(monthlyBudgetProvider);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildMonthSelector(context, ref, currentMonth),
                const SizedBox(height: 24),
                budgetState.budget.when(
                  data: (budget) {
                    final budgetAmount = budget?.amount ?? 0.0;
                    final primaryColor = ref.watch(themeColorProvider);
                    return Column(
                      children: [
                        _buildBudgetCard(
                          context,
                          ref,
                          currentMonth,
                          budget,
                          budgetState.totalSpent.valueOrNull ?? 0,
                          budgetState.progress,
                          budgetState.isOverBudget,
                        ),
                        const SizedBox(height: 24),
                        _buildQuickActions(
                          context,
                          ref,
                          currentMonth,
                          budgetAmount,
                          primaryColor,
                        ),
                      ],
                    );
                  },
                  loading: () => _buildLoadingCard(context),
                  error: (e, _) => _buildErrorCard(context, e.toString()),
                ),
                const SizedBox(height: 80),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildMonthSelector(
    BuildContext context,
    WidgetRef ref,
    DateTime currentMonth,
  ) {
    final now = DateTime.now();
    final isCurrentMonth =
        currentMonth.year == now.year && currentMonth.month == now.month;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: Icon(Icons.chevron_left, color: AppColors.textSecOf(context)),
          onPressed: () {
            final newMonth = DateTime(
              currentMonth.year,
              currentMonth.month - 1,
            );
            ref.read(currentBudgetMonthProvider.notifier).state = newMonth;
            final monthKey = DateFormat('yyyy-MM').format(newMonth);
            ref.read(monthlyBudgetProvider.notifier).loadBudget(monthKey);
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
              builder: (ctx, child) {
                return Theme(
                  data: Theme.of(ctx).copyWith(
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
              ref.read(currentBudgetMonthProvider.notifier).state = picked;
              final monthKey = DateFormat('yyyy-MM').format(picked);
              ref.read(monthlyBudgetProvider.notifier).loadBudget(monthKey);
            }
          },
          child: Text(
            "${currentMonth.year}年${currentMonth.month}月",
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
              ref.read(currentBudgetMonthProvider.notifier).state = newMonth;
              final monthKey = DateFormat('yyyy-MM').format(newMonth);
              ref.read(monthlyBudgetProvider.notifier).loadBudget(monthKey);
            },
          )
        else
          const SizedBox(width: 48),
      ],
    );
  }

  Widget _buildBudgetCard(
    BuildContext context,
    WidgetRef ref,
    DateTime currentMonth,
    dynamic budget,
    double totalSpent,
    double progress,
    bool isOverBudget,
  ) {
    final budgetAmount = budget?.amount ?? 0.0;
    final remaining = budgetAmount - totalSpent;
    final hasBudget = budgetAmount > 0;
    final primaryColor = ref.watch(themeColorProvider);
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.all(24),
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
      child: Column(
        children: [
          Text(
            l10n.monthBudget(currentMonth.month.toString()),
            style: TextStyle(
              color: AppColors.textSecOf(context),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            hasBudget ? "¥${_formatAmount(budgetAmount)}" : l10n.noData,
            style: TextStyle(
              color: hasBudget
                  ? AppColors.textMainOf(context)
                  : AppColors.textSecOf(context),
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (hasBudget) ...[
            const SizedBox(height: 24),
            _buildProgressBar(context, progress, isOverBudget, primaryColor),
            const SizedBox(height: 16),
            Wrap(
              alignment: WrapAlignment.spaceAround,
              spacing: 16,
              runSpacing: 16,
              children: [
                _buildInfoColumn(
                  context,
                  l10n.totalSpent,
                  "¥${_formatAmount(totalSpent)}",
                  AppColors.rose,
                ),
                _buildInfoColumn(
                  context,
                  l10n.remaining,
                  isOverBudget
                      ? "${l10n.overBudget} ¥${_formatAmount(-remaining)}"
                      : "¥${_formatAmount(remaining)}",
                  isOverBudget ? AppColors.rose : AppColors.emerald,
                ),
                _buildInfoColumn(
                  context,
                  l10n.progress,
                  "${progress.toStringAsFixed(0)}%",
                  isOverBudget ? AppColors.rose : primaryColor,
                ),
              ],
            ),
            if (isOverBudget) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppColors.rose.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppColors.rose.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      color: AppColors.rose,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "${l10n.overBudget} ${(progress - 100).toStringAsFixed(0)}%",
                      style: const TextStyle(
                        color: AppColors.rose,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ] else ...[
            const SizedBox(height: 16),
            Text(
              l10n.setBudget,
              style: TextStyle(
                color: AppColors.textSecOf(context),
                fontSize: 14,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildProgressBar(
    BuildContext context,
    double progress,
    bool isOverBudget,
    Color primaryColor,
  ) {
    final displayProgress = progress.clamp(0.0, 100.0);
    final color = isOverBudget ? AppColors.rose : primaryColor;
    final l10n = AppLocalizations.of(context)!;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l10n.progress,
              style: TextStyle(
                color: AppColors.textSecOf(context),
                fontSize: 12,
              ),
            ),
            Text(
              "${progress.toStringAsFixed(0)}%",
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: displayProgress / 100,
            backgroundColor: AppColors.backgroundOf(context),
            valueColor: AlwaysStoppedAnimation(color),
            minHeight: 8,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoColumn(
    BuildContext context,
    String label,
    String value,
    Color valueColor,
  ) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(color: AppColors.textSecOf(context), fontSize: 12),
        ),
        const SizedBox(height: 4),
        Flexible(
          child: Text(
            value,
            style: TextStyle(
              color: valueColor,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions(
    BuildContext context,
    WidgetRef ref,
    DateTime currentMonth,
    double budgetAmount,
    Color primaryColor,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final hasBudget = budgetAmount > 0;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                context,
                ref,
                Icons.edit,
                hasBudget ? l10n.editBudget : l10n.setBudget,
                primaryColor,
                () async {
                  final result = await showAddBudgetPage(
                    context,
                    currentMonth,
                    initialAmount: hasBudget ? budgetAmount : null,
                  );
                  if (result == true) {
                    final monthKey = DateFormat('yyyy-MM').format(currentMonth);
                    ref
                        .read(monthlyBudgetProvider.notifier)
                        .loadBudget(monthKey);
                  }
                },
              ),
            ),
          ],
        ),
        if (hasBudget) ...[
          const SizedBox(height: 12),
          _buildApplyToAllButton(
            context,
            ref,
            budgetAmount,
            primaryColor,
            l10n,
          ),
        ],
      ],
    );
  }

  Widget _buildApplyToAllButton(
    BuildContext context,
    WidgetRef ref,
    double budgetAmount,
    Color primaryColor,
    AppLocalizations l10n,
  ) {
    return GestureDetector(
      onTap: () async {
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            backgroundColor: AppColors.surfaceOf(ctx),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Text(
              l10n.applyToAllMonths,
              style: TextStyle(
                color: AppColors.textMainOf(ctx),
                fontWeight: FontWeight.bold,
              ),
            ),
            content: Text(
              l10n.applyToAllMonthsDesc,
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
                  l10n.confirm,
                  style: TextStyle(color: primaryColor),
                ),
              ),
            ],
          ),
        );

        if (confirmed == true) {
          try {
            await ref
                .read(monthlyBudgetProvider.notifier)
                .applyBudgetToAllMonths(budgetAmount);
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(l10n.budgetAppliedToAllMonths),
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
                  content: Text('Error: $e'),
                  backgroundColor: AppColors.rose,
                ),
              );
            }
          }
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: primaryColor.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: primaryColor.withValues(alpha: 0.2)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.calendar_month, color: primaryColor, size: 20),
            const SizedBox(width: 8),
            Text(
              l10n.applyToAllMonths,
              style: TextStyle(
                color: primaryColor,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    WidgetRef ref,
    IconData icon,
    String label,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surfaceOf(context),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildErrorCard(BuildContext context, String error) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surfaceOf(context),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: Text(
          '${l10n.loadFailed}: $error',
          style: const TextStyle(color: AppColors.rose),
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
}

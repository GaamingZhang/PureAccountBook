import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../category/models/category.dart';
import '../../category/providers/category_provider.dart';
import '../../../core/config/app_config.dart';
import '../../../providers/theme_provider.dart';
import '../models/transaction.dart';
import '../providers/transaction_provider.dart';
import '../providers/transaction_list_provider.dart';

class EditTransactionPage extends ConsumerStatefulWidget {
  final TransactionRecord transaction;

  const EditTransactionPage({super.key, required this.transaction});

  @override
  ConsumerState<EditTransactionPage> createState() =>
      _EditTransactionPageState();
}

class _EditTransactionPageState extends ConsumerState<EditTransactionPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _amountController;
  late TextEditingController _noteController;
  late DateTime _selectedDate;
  Category? _selectedCategory;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.transaction.type == 'expense' ? 0 : 1,
    );
    _tabController.addListener(_onTabChanged);
    _amountController = TextEditingController(
      text: widget.transaction.amount.toString(),
    );
    _noteController = TextEditingController(
      text: widget.transaction.note ?? '',
    );
    _selectedDate = DateTime.parse(widget.transaction.date);
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    setState(() {
      _selectedCategory = null;
    });
  }

  String get _transactionType =>
      _tabController.index == 0 ? 'expense' : 'income';

  Future<void> _selectDate() async {
    final primaryColor = ref.read(themeColorProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 365)),
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
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _deleteTransaction() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: const Text('确定要删除这条记录吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('删除'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isLoading = true);

    try {
      await ref
          .read(transactionNotifierProvider.notifier)
          .deleteTransaction(widget.transaction.id!);

      // Invalidate 相关 provider 刷新数据
      ref.invalidate(transactionsProvider);
      final monthKey = DateFormat('yyyy-MM').format(_selectedDate);
      ref.invalidate(transactionsByMonthProvider(monthKey));

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('删除成功')));
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('删除失败: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _saveTransaction() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategory == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('请选择类型')));
      return;
    }

    setState(() => _isLoading = true);

    try {
      final transaction = widget.transaction.copyWith(
        amount: double.parse(_amountController.text),
        type: _transactionType,
        categoryId: _selectedCategory!.id!,
        date: DateFormat('yyyy-MM-dd').format(_selectedDate),
        note: _noteController.text.isEmpty ? null : _noteController.text,
      );

      await ref
          .read(transactionNotifierProvider.notifier)
          .updateTransaction(transaction);

      // Invalidate 相关 provider 刷新数据
      ref.invalidate(transactionsProvider);
      final monthKey = DateFormat('yyyy-MM').format(_selectedDate);
      ref.invalidate(transactionsByMonthProvider(monthKey));

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('更新成功')));
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('更新失败: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = _transactionType == 'expense'
        ? ref.watch(expenseCategoriesProvider)
        : ref.watch(incomeCategoriesProvider);
    final primaryColor = ref.watch(themeColorProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: AppColors.backgroundOf(context),
      appBar: AppBar(
        backgroundColor: AppColors.backgroundOf(context).withValues(alpha: 0.9),
        elevation: 0,
        title: Text(
          '编辑记录',
          style: TextStyle(
            color: AppColors.textMainOf(context),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: _isLoading ? null : _deleteTransaction,
            icon: const Icon(Icons.delete, color: AppColors.rose),
            tooltip: '删除',
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.05)
                      : Colors.black.withValues(alpha: 0.05),
                ),
              ),
            ),
            child: TabBar(
              controller: _tabController,
              indicatorColor: primaryColor,
              labelColor: Colors.white,
              unselectedLabelColor: AppColors.textSecOf(context),
              tabs: const [
                Tab(text: '支出'),
                Tab(text: '收入'),
              ],
            ),
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _amountController,
              decoration: const InputDecoration(
                labelText: '金额',
                prefixText: '¥',
                border: OutlineInputBorder(),
              ),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '请输入金额';
                }
                final amount = double.tryParse(value);
                if (amount == null || amount <= 0) {
                  return '请输入有效金额';
                }
                // 检查小数位数是否超过两位
                if (value.contains('.') && value.split('.')[1].length > 2) {
                  return '金额最多两位小数';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('日期'),
              subtitle: Text(DateFormat('yyyy-MM-dd').format(_selectedDate)),
              trailing: const Icon(Icons.calendar_today),
              onTap: _selectDate,
              shape: RoundedRectangleBorder(
                side: BorderSide(color: Theme.of(context).dividerColor),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              '选择类型',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            categoriesAsync.when(
              data: (categories) {
                _selectedCategory ??= categories.firstWhere(
                  (c) => c.id == widget.transaction.categoryId,
                  orElse: () => categories.first,
                );
                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                    childAspectRatio: 1,
                  ),
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final category = categories[index];
                    final isSelected = _selectedCategory?.id == category.id;
                    return InkWell(
                      onTap: () {
                        setState(() {
                          _selectedCategory = category;
                        });
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: isSelected
                                ? Theme.of(context).primaryColor
                                : Theme.of(context).dividerColor,
                            width: isSelected ? 2 : 1,
                          ),
                          borderRadius: BorderRadius.circular(8),
                          color: isSelected
                              ? Theme.of(
                                  context,
                                ).primaryColor.withValues(alpha: 0.1)
                              : null,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _getIconData(category.icon),
                              size: 28,
                              color: isSelected
                                  ? Theme.of(context).primaryColor
                                  : null,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              category.name,
                              style: TextStyle(
                                fontSize: 12,
                                color: isSelected
                                    ? Theme.of(context).primaryColor
                                    : null,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('加载失败: $e')),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _noteController,
              decoration: const InputDecoration(
                labelText: '备注（可选）',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isLoading ? null : _saveTransaction,
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('保存'),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIconData(String iconName) {
    final iconMap = {
      'restaurant': Icons.restaurant,
      'shopping_bag': Icons.shopping_bag,
      'directions_bus': Icons.directions_bus,
      'home': Icons.home,
      'sports_esports': Icons.sports_esports,
      'local_hospital': Icons.local_hospital,
      'school': Icons.school,
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
    };
    return iconMap[iconName] ?? Icons.category;
  }
}

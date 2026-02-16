import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../core/config/app_config.dart';
import '../core/utils/localization_utils.dart';
import '../providers/theme_provider.dart';
import '../features/category/models/category.dart';
import '../features/category/providers/category_provider.dart';
import '../features/transaction/models/transaction.dart';
import '../features/transaction/providers/transaction_provider.dart';
import '../features/transaction/providers/transaction_list_provider.dart';
import '../l10n/app_localizations.dart';

class AddTransactionScreen extends ConsumerStatefulWidget {
  final VoidCallback? onBack;
  const AddTransactionScreen({super.key, this.onBack});

  @override
  ConsumerState<AddTransactionScreen> createState() =>
      _AddTransactionScreenState();
}

class _AddTransactionScreenState extends ConsumerState<AddTransactionScreen> {
  TransactionType _type = TransactionType.expense;
  String _amount = '';
  Category? _selectedCategory;
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;
  final _noteController = TextEditingController();
  final _noteFocusNode = FocusNode();
  bool _showCustomKeyboard = true;

  @override
  void initState() {
    super.initState();
    _noteFocusNode.addListener(() {
      if (!mounted) return;
      if (_noteFocusNode.hasFocus) {
        setState(() => _showCustomKeyboard = false);
      } else {
        setState(() => _showCustomKeyboard = true);
      }
    });
  }

  @override
  void dispose() {
    _noteController.dispose();
    _noteFocusNode.dispose();
    super.dispose();
  }

  void _handleKeyPress(String key) {
    setState(() {
      if (key == 'backspace') {
        if (_amount.isNotEmpty)
          _amount = _amount.substring(0, _amount.length - 1);
      } else if (key == '.') {
        if (!_amount.contains('.')) _amount += key;
      } else {
        if (_amount.length < 10) _amount += key;
      }
    });
  }

  Future<void> _saveTransaction() async {
    final l10n = AppLocalizations.of(context)!;
    if (_amount.isEmpty ||
        double.tryParse(_amount) == null ||
        double.parse(_amount) <= 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.pleaseEnterValidAmount)));
      return;
    }

    if (_selectedCategory == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.pleaseSelectCategory)));
      return;
    }

    setState(() => _isLoading = true);

    try {
      final transaction = TransactionRecord(
        amount: double.parse(_amount),
        type: _type == TransactionType.expense ? 'expense' : 'income',
        categoryId: _selectedCategory!.id!,
        date: DateFormat('yyyy-MM-dd').format(_selectedDate),
        note: _noteController.text.isEmpty ? null : _noteController.text,
        createdAt: DateTime.now().toIso8601String(),
      );

      await ref
          .read(transactionNotifierProvider.notifier)
          .addTransaction(transaction);

      ref.invalidate(transactionsProvider);
      final monthKey = DateFormat('yyyy-MM').format(_selectedDate);
      ref.invalidate(transactionsByMonthProvider(monthKey));

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.saveSuccess)));
        if (widget.onBack != null) {
          widget.onBack!();
        } else {
          Navigator.pop(context);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('${l10n.saveFailed}: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

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
                    surface: AppColors.surfaceOf(context),
                  )
                : ColorScheme.light(
                    primary: primaryColor,
                    surface: AppColors.surfaceOf(context),
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final categoriesAsync = _type == TransactionType.expense
        ? ref.watch(expenseCategoriesProvider)
        : ref.watch(incomeCategoriesProvider);
    final primaryColor = ref.watch(themeColorProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: AppColors.backgroundOf(context),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 8,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            icon: Icon(
                              Icons.close,
                              color: AppColors.textSecOf(context),
                            ),
                            onPressed:
                                widget.onBack ?? () => Navigator.pop(context),
                          ),
                          Text(
                            l10n.recordATransaction,
                            style: TextStyle(
                              color: AppColors.textMainOf(context),
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 48),
                        ],
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      width: 200,
                      height: 40,
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceOf(context),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.divider(context)),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: _buildToggle(
                              TransactionType.expense,
                              l10n.expense,
                            ),
                          ),
                          Expanded(
                            child: _buildToggle(
                              TransactionType.income,
                              l10n.income,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Column(
                      children: [
                        Text(
                          l10n.amount,
                          style: TextStyle(
                            color: AppColors.textSecOf(context),
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              "¥",
                              style: TextStyle(
                                color: primaryColor,
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _amount.isEmpty ? '0.00' : _amount,
                              style: TextStyle(
                                color: _amount.isEmpty
                                    ? AppColors.textSecOf(
                                        context,
                                      ).withValues(alpha: 0.5)
                                    : AppColors.textMainOf(context),
                                fontSize: 48,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          DateFormat('yyyy-MM-dd').format(_selectedDate),
                          style: TextStyle(
                            color: AppColors.textSecOf(context),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          Text(
                            l10n.selectCategory,
                            style: TextStyle(
                              color: AppColors.textSecOf(context),
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    SizedBox(
                      height: 240,
                      child: categoriesAsync.when(
                        data: (categories) => GridView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 5,
                                mainAxisSpacing: 4,
                                crossAxisSpacing: 4,
                                childAspectRatio: 0.9,
                              ),
                          itemCount: categories.length,
                          itemBuilder: (context, index) {
                            final cat = categories[index];
                            final isSelected = _selectedCategory?.id == cat.id;
                            return GestureDetector(
                              onTap: () =>
                                  setState(() => _selectedCategory = cat),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? primaryColor
                                          : AppColors.surfaceOf(context),
                                      borderRadius: BorderRadius.circular(10),
                                      border: isSelected
                                          ? Border.all(
                                              color: primaryColor,
                                              width: 2,
                                            )
                                          : null,
                                    ),
                                    child: Icon(
                                      _getIconData(cat.icon),
                                      color: isSelected
                                          ? Colors.white
                                          : AppColors.textSecOf(context),
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    LocalizationUtils.getLocalizedCategoryName(
                                      context,
                                      cat,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: isSelected
                                          ? primaryColor
                                          : AppColors.textSecOf(context),
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                        loading: () =>
                            const Center(child: CircularProgressIndicator()),
                        error: (e, _) => Center(
                          child: Text(
                            '${l10n.loadFailed}: $e',
                            style: TextStyle(
                              color: AppColors.textSecOf(context),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: TextField(
                controller: _noteController,
                focusNode: _noteFocusNode,
                style: TextStyle(
                  color: AppColors.textMainOf(context),
                  fontSize: 16,
                ),
                decoration: InputDecoration(
                  hintText: l10n.note,
                  hintStyle: TextStyle(
                    color: AppColors.textSecOf(context),
                    fontSize: 16,
                  ),
                  filled: true,
                  fillColor: AppColors.surfaceOf(context),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                ),
                maxLines: 1,
              ),
            ),
            Container(
              height: _showCustomKeyboard ? null : 0,
              margin: _showCustomKeyboard
                  ? const EdgeInsets.fromLTRB(16, 4, 16, 8)
                  : EdgeInsets.zero,
              padding: _showCustomKeyboard
                  ? const EdgeInsets.all(12)
                  : EdgeInsets.zero,
              decoration: BoxDecoration(
                color: AppColors.surfaceOf(context),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.05)
                      : Colors.black.withValues(alpha: 0.05),
                ),
              ),
              clipBehavior: Clip.antiAlias,
              child: _showCustomKeyboard
                  ? GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 4,
                      childAspectRatio: 1.5,
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8,
                      children: [
                        ...['1', '2', '3'].map(_buildKey),
                        _buildIconKey(
                          Icons.backspace,
                          Colors.redAccent,
                          'backspace',
                        ),
                        ...['4', '5', '6'].map(_buildKey),
                        _buildTextKey(l10n.date, primaryColor, _selectDate),
                        ...['7', '8', '9'].map(_buildKey),
                        _buildKey('.'),
                        const SizedBox(),
                        _buildKey('0'),
                        GestureDetector(
                          onTap: _isLoading ? null : _saveTransaction,
                          child: Container(
                            decoration: BoxDecoration(
                              color: primaryColor,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            alignment: Alignment.center,
                            child: _isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : Text(
                                    l10n.confirm,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToggle(TransactionType type, String label) {
    final isSelected = _type == type;
    final primaryColor = ref.watch(themeColorProvider);
    return GestureDetector(
      onTap: () {
        setState(() {
          _type = type;
          _selectedCategory = null;
        });
      },
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? primaryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.textSecOf(context),
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildKey(String label) {
    return GestureDetector(
      onTap: () => _handleKeyPress(label),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.backgroundOf(context).withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            color: AppColors.textMainOf(context),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildIconKey(IconData icon, Color color, String action) {
    return GestureDetector(
      onTap: () => _handleKeyPress(action),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.backgroundOf(context).withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.center,
        child: Icon(icon, color: color, size: 20),
      ),
    );
  }

  Widget _buildTextKey(String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.backgroundOf(context).withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
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
    };
    return iconMap[iconName] ?? Icons.category;
  }
}

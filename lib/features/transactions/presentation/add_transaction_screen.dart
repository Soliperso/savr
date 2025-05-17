import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'package:flutter/animation.dart';
import '../../../providers/transaction_provider.dart';

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final List<String> _categories = [
    'General',
    'Food & Groceries',
    'Income',
    'Transportation',
    'Entertainment',
    'Health & Fitness',
    'Shopping',
    'Bills',
    'Other',
  ];
  String? _selectedCategory = 'General';
  final _noteController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  bool _isExpense = true;
  bool _isLoading = false;

  // Category icon mapping
  final Map<String, IconData> _categoryIcons = {
    'General': Icons.category,
    'Food & Groceries': Icons.shopping_basket,
    'Income': Icons.attach_money,
    'Transportation': Icons.directions_car,
    'Entertainment': Icons.movie,
    'Health & Fitness': Icons.fitness_center,
    'Shopping': Icons.shopping_cart,
    'Bills': Icons.receipt_long,
    'Other': Icons.more_horiz,
  };

  @override
  void initState() {
    super.initState();
    // Autofocus title field on open
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(_titleFocusNode);
    });
  }

  // Add focus nodes for keyboard navigation
  final FocusNode _titleFocusNode = FocusNode();
  final FocusNode _amountFocusNode = FocusNode();
  final FocusNode _noteFocusNode = FocusNode();

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    _titleFocusNode.dispose();
    _amountFocusNode.dispose();
    _noteFocusNode.dispose();
    super.dispose();
  }

  void _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).primaryColor,
              onPrimary: Colors.white,
              surface: Theme.of(context).cardColor,
              onSurface: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _saveTransaction() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      final title = _titleController.text.trim();
      final amount = double.parse(_amountController.text.replaceAll(',', '.'));
      // If it's an expense, make the amount negative
      final finalAmount = _isExpense ? -amount : amount;
      final category = _selectedCategory ?? _categories.first;
      final note = _noteController.text.trim();
      try {
        final success = await Provider.of<TransactionProvider>(
          context,
          listen: false,
        ).addTransaction(title, finalAmount, category, _selectedDate, note);

        if (!mounted) return;

        if (success) {
          HapticFeedback.lightImpact();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Transaction saved',
                semanticsLabel: 'Transaction saved',
              ),
            ),
          );
          Navigator.pop(context);
        } else {
          final error =
              Provider.of<TransactionProvider>(context, listen: false).error;
          throw Exception(error ?? 'Failed to save transaction');
        }
      } catch (e) {
        HapticFeedback.heavyImpact();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to save transaction: $e',
              semanticsLabel: 'Failed to save transaction',
            ),
          ),
        );
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    } else {
      HapticFeedback.vibrate();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cardColor = isDark ? theme.colorScheme.surface : Colors.white;
    final borderColor =
        isDark
            ? theme.dividerColor.withOpacity(0.18)
            : theme.dividerColor.withOpacity(0.10);
    final inputFillColor =
        isDark
            ? theme.colorScheme.surfaceVariant.withOpacity(0.18)
            : theme.colorScheme.surfaceVariant.withOpacity(0.10);
    final now = DateTime.now();
    final isFuture = _selectedDate.isAfter(now);
    final isPast = _selectedDate.isBefore(
      DateTime(now.year, now.month, now.day),
    );

    // For accessibility: semantic labels for all fields/buttons
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: theme.scaffoldBackgroundColor,
          title: Semantics(
            label: 'Add Transaction',
            child: Text(
              'Add Transaction',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 20.sp,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onBackground,
              ),
            ),
          ),
          elevation: 0,
          actions: [
            Semantics(
              label: 'Close',
              button: true,
              child: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
                tooltip: 'Close',
                color: theme.colorScheme.onBackground,
              ),
            ),
          ],
        ),
        body: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(16.w),
            child: Card(
              elevation: isDark ? 0 : 3,
              color: cardColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18.r),
                side: BorderSide(color: borderColor, width: 1.2),
              ),
              child: Padding(
                padding: EdgeInsets.all(20.w),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Semantics(
                        label: 'Transaction Type',
                        child: Text(
                          'Transaction Type',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Semantics(
                        label:
                            _isExpense ? 'Expense selected' : 'Income selected',
                        toggled: true,
                        child: SegmentedButton<bool>(
                          segments: const [
                            ButtonSegment<bool>(
                              value: true,
                              label: Text('Expense'),
                              icon: Icon(Icons.remove_circle_outline),
                            ),
                            ButtonSegment<bool>(
                              value: false,
                              label: Text('Income'),
                              icon: Icon(Icons.add_circle_outline),
                            ),
                          ],
                          selected: {_isExpense},
                          onSelectionChanged: (Set<bool> newSelection) {
                            setState(() {
                              _isExpense = newSelection.first;
                            });
                          },
                          style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.resolveWith<Color?>((
                                  states,
                                ) {
                                  if (states.contains(MaterialState.selected)) {
                                    if (_isExpense) {
                                      return Colors.red.withOpacity(0.13);
                                    } else {
                                      return Colors.green.withOpacity(0.13);
                                    }
                                  }
                                  return inputFillColor;
                                }),
                            foregroundColor: MaterialStateProperty.all(
                              theme.colorScheme.onSurface,
                            ),
                            shape: MaterialStateProperty.all(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                            ),
                            overlayColor: MaterialStateProperty.all(
                              theme.colorScheme.primary.withOpacity(0.08),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 16.h),
                      Semantics(
                        label: 'Title',
                        textField: true,
                        child: TextFormField(
                          controller: _titleController,
                          focusNode: _titleFocusNode,
                          decoration: InputDecoration(
                            labelText: 'Title',
                            labelStyle: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 14.sp,
                            ),
                            filled: true,
                            fillColor: inputFillColor,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.r),
                              borderSide: BorderSide(color: borderColor),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.r),
                              borderSide: BorderSide(color: borderColor),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.r),
                              borderSide: BorderSide(
                                color: theme.colorScheme.primary,
                                width: 1.5,
                              ),
                            ),
                            prefixIcon: const Icon(Icons.title),
                          ),
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 16.sp,
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a title';
                            }
                            return null;
                          },
                          textInputAction: TextInputAction.next,
                          onFieldSubmitted: (_) {
                            FocusScope.of(
                              context,
                            ).requestFocus(_amountFocusNode);
                          },
                          autofocus: true,
                        ),
                      ),
                      SizedBox(height: 16.h),
                      Semantics(
                        label: 'Amount',
                        textField: true,
                        child: TextFormField(
                          controller: _amountController,
                          focusNode: _amountFocusNode,
                          decoration: InputDecoration(
                            labelText: 'Amount',
                            labelStyle: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 14.sp,
                            ),
                            prefixText: '\u0024 ',
                            prefixStyle: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 16.sp,
                              color: _isExpense ? Colors.red : Colors.green,
                            ),
                            filled: true,
                            fillColor: inputFillColor,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.r),
                              borderSide: BorderSide(color: borderColor),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.r),
                              borderSide: BorderSide(color: borderColor),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.r),
                              borderSide: BorderSide(
                                color: theme.colorScheme.primary,
                                width: 1.5,
                              ),
                            ),
                          ),
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 16.sp,
                            color: _isExpense ? Colors.red : Colors.green,
                          ),
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter an amount';
                            }
                            final parsed = double.tryParse(
                              value.replaceAll(',', '.'),
                            );
                            if (parsed == null) {
                              return 'Please enter a valid number';
                            }
                            if (parsed <= 0) {
                              return 'Amount must be greater than zero';
                            }
                            return null;
                          },
                          textInputAction: TextInputAction.next,
                          onFieldSubmitted: (_) {
                            FocusScope.of(context).requestFocus(_noteFocusNode);
                          },
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                              RegExp(r'^[0-9]*[.,]?[0-9]{0,2}$'),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 16.h),
                      Semantics(
                        label: 'Category',
                        child: DropdownButtonFormField<String>(
                          dropdownColor: theme.cardColor,
                          value: _selectedCategory,
                          items:
                              _categories
                                  .map(
                                    (cat) => DropdownMenuItem(
                                      value: cat,
                                      child: Row(
                                        children: [
                                          Icon(
                                            _categoryIcons[cat] ??
                                                Icons.category,
                                            size: 18.sp,
                                            color:
                                                _isExpense
                                                    ? theme.colorScheme.primary
                                                    : Colors.green,
                                          ),
                                          SizedBox(width: 8.w),
                                          Text(
                                            cat,
                                            style: TextStyle(
                                              color:
                                                  theme.colorScheme.onSurface,
                                              fontFamily: 'Inter',
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                  .toList(),
                          onChanged:
                              (val) => setState(() => _selectedCategory = val),
                          decoration: InputDecoration(
                            labelText: 'Category',
                            labelStyle: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 14.sp,
                            ),
                            filled: true,
                            fillColor: inputFillColor,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.r),
                              borderSide: BorderSide(color: borderColor),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.r),
                              borderSide: BorderSide(color: borderColor),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.r),
                              borderSide: BorderSide(
                                color: theme.colorScheme.primary,
                                width: 1.5,
                              ),
                            ),
                            // Removed prefixIcon to avoid duplicate icon
                          ),
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 16.sp,
                            color: theme.colorScheme.onSurface,
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please select a category';
                            }
                            return null;
                          },
                          iconEnabledColor: theme.colorScheme.onSurface,
                          iconDisabledColor: theme.colorScheme.onSurface
                              .withOpacity(0.5),
                          borderRadius: BorderRadius.circular(14.r),
                          menuMaxHeight: 300.h,
                        ),
                      ),
                      SizedBox(height: 16.h),
                      Semantics(
                        label: 'Note (optional)',
                        textField: true,
                        child: TextFormField(
                          controller: _noteController,
                          focusNode: _noteFocusNode,
                          decoration: InputDecoration(
                            labelText: 'Note (optional)',
                            labelStyle: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 14.sp,
                            ),
                            hintText: 'Add any additional details',
                            filled: true,
                            fillColor: inputFillColor,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.r),
                              borderSide: BorderSide(color: borderColor),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.r),
                              borderSide: BorderSide(color: borderColor),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.r),
                              borderSide: BorderSide(
                                color: theme.colorScheme.primary,
                                width: 1.5,
                              ),
                            ),
                            prefixIcon: const Icon(
                              Icons.sticky_note_2_outlined,
                            ),
                          ),
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 16.sp,
                          ),
                          maxLines: 2,
                          textInputAction: TextInputAction.done,
                          onFieldSubmitted: (_) {
                            FocusScope.of(context).unfocus();
                            // Attempt to save when done typing note
                            if (_formKey.currentState?.validate() ?? false) {
                              _saveTransaction();
                            }
                          },
                        ),
                      ),
                      SizedBox(height: 16.h),
                      Row(
                        children: [
                          Expanded(
                            child: Semantics(
                              label: 'Date',
                              child: Text(
                                // Use locale-aware date formatting
                                'Date:  ${MaterialLocalizations.of(context).formatMediumDate(_selectedDate)}',
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 14.sp,
                                  color:
                                      isPast
                                          ? Colors.red.shade700
                                          : isFuture
                                          ? Colors.green.shade700
                                          : theme.colorScheme.onSurface
                                              .withOpacity(0.8),
                                  fontWeight:
                                      isPast || isFuture
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                ),
                              ),
                            ),
                          ),
                          Semantics(
                            label: 'Pick Date',
                            button: true,
                            child: TextButton.icon(
                              onPressed: _pickDate,
                              icon: Icon(
                                Icons.calendar_today_outlined,
                                color: theme.colorScheme.primary,
                                size: 20.sp,
                              ),
                              label: Text(
                                'Pick Date',
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 14.sp,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 24.h),
                      SizedBox(
                        width: double.infinity,
                        height: 50.h,
                        child: AnimatedScale(
                          scale: _isLoading ? 0.97 : 1.0,
                          duration: const Duration(milliseconds: 120),
                          child: Semantics(
                            label:
                                _isLoading ? 'Saving...' : 'Save Transaction',
                            button: true,
                            child: ElevatedButton.icon(
                              onPressed:
                                  _isLoading
                                      ? null
                                      : () {
                                        if (_formKey.currentState?.validate() ??
                                            false) {
                                          HapticFeedback.mediumImpact();
                                          _saveTransaction();
                                        } else {
                                          HapticFeedback.vibrate();
                                        }
                                      },
                              icon:
                                  _isLoading
                                      ? SizedBox(
                                        width: 20.w,
                                        height: 20.w,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: theme.colorScheme.onPrimary,
                                        ),
                                      )
                                      : const Icon(Icons.save_alt_rounded),
                              label: AnimatedSwitcher(
                                duration: const Duration(milliseconds: 200),
                                child: Text(
                                  _isLoading ? 'Saving...' : 'Save Transaction',
                                  key: ValueKey(_isLoading),
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: theme.colorScheme.primary,
                                foregroundColor: theme.colorScheme.onPrimary,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                                elevation: isDark ? 0 : 2,
                                shadowColor:
                                    isDark
                                        ? Colors.transparent
                                        : theme.shadowColor,
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 8.h),
                      if (!_isLoading)
                        Center(
                          child: TextButton(
                            onPressed: () {
                              HapticFeedback.selectionClick();
                              _formKey.currentState?.reset();
                              _titleController.clear();
                              _amountController.clear();
                              _noteController.clear();
                              setState(() {
                                _selectedCategory = _categories.first;
                                _selectedDate = DateTime.now();
                                _isExpense = true;
                              });
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Form cleared'),
                                  duration: Duration(seconds: 1),
                                ),
                              );
                            },
                            style: TextButton.styleFrom(
                              foregroundColor: theme.colorScheme.secondary,
                            ),
                            child: Text(
                              'Clear Form',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 14.sp,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:savr/providers/bill_provider.dart';
import 'package:flutter/services.dart';

class AddBillScreen extends StatefulWidget {
  const AddBillScreen({super.key});

  @override
  State<AddBillScreen> createState() => _AddBillScreenState();
}

class _AddBillScreenState extends State<AddBillScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;

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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(_titleFocusNode);
    });
  }

  void _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _saveBill() {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      final title = _titleController.text.trim();
      final amount = double.parse(_amountController.text.replaceAll(',', '.'));
      final note = _noteController.text.trim();
      try {
        Provider.of<BillProvider>(context, listen: false).addBillToGroup(
          groupId: '', // TODO: set groupId if available
          title: title,
          description: note,
          amount: amount,
          dueDate: _selectedDate,
          splitWith: const [],
        );
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Bill saved', semanticsLabel: 'Bill saved'),
          ),
        );
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to save bill: $e',
              semanticsLabel: 'Failed to save bill',
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

  // Use a custom adaptive color for all text (black on light, white on dark)
  Color getCustomTextColor(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return brightness == Brightness.dark ? Colors.white : Colors.black;
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

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: theme.scaffoldBackgroundColor,
          title: Semantics(
            label: 'Add Bill',
            child: Text(
              'Add Bill',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 20.sp,
                fontWeight: FontWeight.w600,
                color: getCustomTextColor(context),
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
                color: getCustomTextColor(context),
              ),
            ),
          ],
        ),
        body: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
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
                              color: getCustomTextColor(context),
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
                            color: getCustomTextColor(context),
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
                              color: getCustomTextColor(context),
                            ),
                            prefixText: '\u0024 ',
                            prefixStyle: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 16.sp,
                              color: getCustomTextColor(context),
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
                            color: getCustomTextColor(context),
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
                              color: getCustomTextColor(context),
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
                            color: getCustomTextColor(context),
                          ),
                          maxLines: 2,
                          textInputAction: TextInputAction.done,
                          onFieldSubmitted: (_) {
                            FocusScope.of(context).unfocus();
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
                                'Date: ${MaterialLocalizations.of(context).formatMediumDate(_selectedDate)}',
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 14.sp,
                                  color: getCustomTextColor(
                                    context,
                                  ).withOpacity(0.8),
                                ),
                              ),
                            ),
                          ),
                          Semantics(
                            label: 'Pick Date',
                            button: true,
                            child: TextButton.icon(
                              onPressed: _pickDate,
                              icon: const Icon(Icons.calendar_today_outlined),
                              label: Text(
                                'Pick Date',
                                style: TextStyle(
                                  color: getCustomTextColor(context),
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
                            label: _isLoading ? 'Saving...' : 'Save Bill',
                            button: true,
                            child: ElevatedButton.icon(
                              onPressed: _isLoading ? null : _saveBill,
                              icon:
                                  _isLoading
                                      ? SizedBox(
                                        width: 20.w,
                                        height: 20.w,
                                        child: const CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      )
                                      : const Icon(Icons.save_alt_rounded),
                              label: AnimatedSwitcher(
                                duration: const Duration(milliseconds: 200),
                                child: Text(
                                  _isLoading ? 'Saving...' : 'Save Bill',
                                  key: ValueKey(_isLoading),
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w600,
                                    color: getCustomTextColor(context),
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
                              _formKey.currentState?.reset();
                              _titleController.clear();
                              _amountController.clear();
                              _noteController.clear();
                              setState(() {
                                _selectedDate = DateTime.now();
                              });
                            },
                            child: Text(
                              'Clear Form',
                              style: TextStyle(
                                color: getCustomTextColor(context),
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

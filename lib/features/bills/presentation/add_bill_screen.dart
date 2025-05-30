import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:savr/providers/bill_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../../models/group.dart';
import '../../../features/shared/widgets/animated_snackbar.dart';

class AddBillScreen extends StatefulWidget {
  final String groupId;

  const AddBillScreen({super.key, required this.groupId});

  @override
  State<AddBillScreen> createState() => _AddBillScreenState();
}

class _AddBillScreenState extends State<AddBillScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();
  final _emailController = TextEditingController();

  DateTime _dueDate = DateTime.now().add(const Duration(days: 7));
  late final Group _group;
  final List<String> _selectedFriends = [];
  final List<String> _invitedEmails = [];
  bool _isSplitEqually = true;
  String _selectedCategory = 'Other';

  // Add custom split amount controllers
  final Map<String, TextEditingController> _splitAmountControllers = {};
  double _remainingAmount = 0.0;
  double _yourCustomShare = 0.0;

  // Bill categories
  final List<Map<String, dynamic>> _categories = [
    {'name': 'Rent', 'icon': Icons.home},
    {'name': 'Utilities', 'icon': Icons.power},
    {'name': 'Groceries', 'icon': Icons.shopping_basket},
    {'name': 'Dining', 'icon': Icons.restaurant},
    {'name': 'Transportation', 'icon': Icons.directions_car},
    {'name': 'Entertainment', 'icon': Icons.movie},
    {'name': 'Shopping', 'icon': Icons.shopping_bag},
    {'name': 'Travel', 'icon': Icons.flight},
    {'name': 'Healthcare', 'icon': Icons.local_hospital},
    {'name': 'Other', 'icon': Icons.more_horiz},
  ];

  @override
  void initState() {
    super.initState();
    final group = Provider.of<BillProvider>(
      context,
      listen: false,
    ).getGroupById(widget.groupId);
    if (group == null) {
      throw Exception('Group not found');
    }
    _group = group;
    _amountController.addListener(_updateRemainingAmount);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _amountController.dispose();
    _emailController.dispose();
    // Dispose custom split controllers
    for (var controller in _splitAmountControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _updateRemainingAmount() {
    if (_amountController.text.isEmpty) return;

    final totalAmount = double.tryParse(_amountController.text) ?? 0.0;
    if (_isSplitEqually) {
      setState(() {
        _remainingAmount = 0.0;
        _yourCustomShare = 0.0;
      });
      return;
    }

    double sumOfShares = _yourCustomShare;
    for (var controller in _splitAmountControllers.values) {
      sumOfShares += double.tryParse(controller.text) ?? 0.0;
    }

    setState(() {
      _remainingAmount = totalAmount - sumOfShares;
    });
  }

  // Helper to create or get split amount controller
  TextEditingController _getSplitController(String key) {
    if (!_splitAmountControllers.containsKey(key)) {
      final controller = TextEditingController();
      controller.addListener(_updateRemainingAmount);
      _splitAmountControllers[key] = controller;
    }
    return _splitAmountControllers[key]!;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cardColor = isDark ? Colors.grey[900] : Colors.white;
    final borderColor = isDark ? Colors.grey[800] : Colors.grey[200];
    final inputFillColor =
        isDark
            ? theme.colorScheme.surfaceVariant.withOpacity(0.18)
            : theme.colorScheme.surfaceVariant.withOpacity(0.10);
    final primaryColor = Color(_group.color ?? 0xFF000000);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Add New Bill',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 20.sp,
            fontWeight: FontWeight.w600,
            color: primaryColor,
          ),
        ),
        backgroundColor: isDark ? Colors.black : Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: isDark ? Colors.white : Colors.black),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                color: cardColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  side: BorderSide(
                    color: borderColor ?? Colors.grey,
                    width: 1.1,
                  ),
                ),
                elevation: isDark ? 0 : 2,
                child: Padding(
                  padding: EdgeInsets.all(16.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'For ${_group.name}',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 14.sp,
                          color: Colors.grey[600],
                        ),
                      ),
                      SizedBox(height: 16.h),
                      TextFormField(
                        controller: _titleController,
                        decoration: InputDecoration(
                          labelText: 'Bill Title',
                          labelStyle: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 14.sp,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          prefixIcon: const Icon(Icons.description),
                          filled: true,
                          fillColor: inputFillColor,
                          helperText: 'Enter a clear, descriptive title',
                          helperStyle: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 12.sp,
                          ),
                        ),
                        style: TextStyle(fontFamily: 'Inter', fontSize: 16.sp),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a title';
                          }
                          if (value.length < 3) {
                            return 'Title must be at least 3 characters';
                          }
                          if (value.length > 50) {
                            return 'Title must be less than 50 characters';
                          }
                          return null;
                        },
                        textInputAction: TextInputAction.next,
                        maxLength: 50,
                        buildCounter:
                            (
                              context, {
                              required currentLength,
                              required isFocused,
                              maxLength,
                            }) => Text(
                              '$currentLength/$maxLength',
                              style: TextStyle(fontSize: 12.sp),
                            ),
                      ),
                      SizedBox(height: 16.h),
                      TextFormField(
                        controller: _descriptionController,
                        decoration: InputDecoration(
                          labelText: 'Description (Optional)',
                          labelStyle: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 14.sp,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          prefixIcon: const Icon(Icons.notes),
                          filled: true,
                          fillColor: inputFillColor,
                          helperText: 'Add any details about the bill',
                          helperStyle: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 12.sp,
                          ),
                        ),
                        style: TextStyle(fontFamily: 'Inter', fontSize: 16.sp),
                        maxLines: 2,
                        maxLength: 200,
                        buildCounter:
                            (
                              context, {
                              required currentLength,
                              required isFocused,
                              maxLength,
                            }) => Text(
                              '$currentLength/$maxLength',
                              style: TextStyle(fontSize: 12.sp),
                            ),
                        textInputAction: TextInputAction.next,
                      ),
                      SizedBox(height: 16.h),
                      TextFormField(
                        controller: _amountController,
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
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          prefixIcon: const Icon(Icons.attach_money),
                          filled: true,
                          fillColor: inputFillColor,
                          helperText: 'Enter the total bill amount',
                          helperStyle: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 12.sp,
                          ),
                        ),
                        style: TextStyle(fontFamily: 'Inter', fontSize: 16.sp),
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(r'^\d*\.?\d{0,2}'),
                          ),
                        ],
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter an amount';
                          }
                          final amount = double.tryParse(value);
                          if (amount == null) {
                            return 'Please enter a valid number';
                          }
                          if (amount <= 0) {
                            return 'Amount must be greater than 0';
                          }
                          if (amount > 1000000) {
                            return 'Amount cannot exceed \$1,000,000';
                          }
                          return null;
                        },
                        textInputAction: TextInputAction.next,
                      ),
                      SizedBox(height: 16.h),
                      _buildDatePicker(),
                      SizedBox(height: 16.h),
                      _buildCategorySelector(),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 24.h),

              // Split method and friends section card
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  side: BorderSide(
                    color: borderColor ?? Colors.grey,
                    width: 1.1,
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.all(16.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Split method selector
                      Row(
                        children: [
                          Icon(
                            Icons.group_work,
                            color: primaryColor,
                            size: 24.sp,
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            'Split Method',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w500,
                              color: primaryColor,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12.h),
                      SegmentedButton<bool>(
                        segments: [
                          ButtonSegment<bool>(
                            value: true,
                            label: Text(
                              'Split Equally',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 14.sp,
                              ),
                            ),
                            icon: const Icon(Icons.balance),
                          ),
                          ButtonSegment<bool>(
                            value: false,
                            label: Text(
                              'Custom Split',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 14.sp,
                              ),
                            ),
                            icon: const Icon(Icons.pie_chart),
                          ),
                        ],
                        selected: {_isSplitEqually},
                        onSelectionChanged: (Set<bool> selection) {
                          setState(() {
                            _isSplitEqually = selection.first;
                          });
                        },
                        style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.resolveWith<Color?>((
                                states,
                              ) {
                                if (states.contains(MaterialState.selected)) {
                                  return primaryColor.withOpacity(0.13);
                                }
                                return inputFillColor;
                              }),
                          foregroundColor: MaterialStateProperty.all(
                            primaryColor,
                          ),
                          shape: MaterialStateProperty.all(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                          ),
                          overlayColor: MaterialStateProperty.all(
                            primaryColor.withOpacity(0.08),
                          ),
                        ),
                      ),
                      if (!_isSplitEqually) ...[
                        SizedBox(height: 16.h),
                        _buildCustomSplitSection(),
                      ],

                      Divider(height: 32.h, color: borderColor),

                      // Split With section
                      Row(
                        children: [
                          Icon(Icons.people, color: primaryColor, size: 24.sp),
                          SizedBox(width: 8.w),
                          Text(
                            'Split With',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w500,
                              color: primaryColor,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12.h),
                      _buildFriendSelector(),

                      Divider(height: 32.h, color: borderColor),

                      // Invite Others section
                      Row(
                        children: [
                          Icon(
                            Icons.person_add,
                            color: primaryColor,
                            size: 24.sp,
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            'Invite Others',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w500,
                              color: primaryColor,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12.h),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _emailController,
                              decoration: InputDecoration(
                                hintText: 'Enter email address',
                                hintStyle: TextStyle(fontSize: 14.sp),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.r),
                                ),
                                prefixIcon: Icon(
                                  Icons.email,
                                  color: Colors.grey[600],
                                ),
                                filled: true,
                                fillColor: inputFillColor,
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 16.w,
                                  vertical: 12.h,
                                ),
                              ),
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 16.sp,
                              ),
                              keyboardType: TextInputType.emailAddress,
                            ),
                          ),
                          SizedBox(width: 8.w),
                          ElevatedButton.icon(
                            onPressed: _inviteByEmail,
                            icon: const Icon(Icons.send),
                            label: Text(
                              'Invite',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 14.sp,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColor,
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(
                                horizontal: 16.w,
                                vertical: 12.h,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (_invitedEmails.isNotEmpty) ...[
                        SizedBox(height: 12.h),
                        Container(
                          padding: EdgeInsets.all(12.w),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Invited Users',
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey[700],
                                ),
                              ),
                              SizedBox(height: 8.h),
                              Wrap(
                                spacing: 8.w,
                                runSpacing: 8.h,
                                children:
                                    _invitedEmails.map((email) {
                                      return Chip(
                                        label: Text(
                                          email,
                                          style: TextStyle(
                                            fontFamily: 'Inter',
                                            fontSize: 12.sp,
                                            color: Colors.white,
                                          ),
                                        ),
                                        backgroundColor: primaryColor,
                                        deleteIcon: const Icon(
                                          Icons.close,
                                          size: 16,
                                        ),
                                        onDeleted: () {
                                          setState(() {
                                            _invitedEmails.remove(email);
                                          });
                                        },
                                      );
                                    }).toList(),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              SizedBox(height: 24.h),

              // Split preview
              if (_selectedFriends.isNotEmpty || _invitedEmails.isNotEmpty)
                _buildSplitPreview(),

              SizedBox(height: 24.h),

              // Save button
              ElevatedButton(
                onPressed: _saveBill,
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 50.h),
                  backgroundColor: Color(_group.color ?? 0xFF000000),
                ),
                child: Text(
                  'Save Bill',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDatePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Due Date',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 16.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 8.h),
        InkWell(
          onTap: _selectDate,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade400),
              borderRadius: BorderRadius.circular(4.r),
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today, color: Colors.grey[600]),
                SizedBox(width: 8.w),
                Text(
                  DateFormat('MMM d, yyyy').format(_dueDate),
                  style: TextStyle(fontFamily: 'Inter', fontSize: 16.sp),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFriendSelector() {
    final groupMembers = _group.members;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Wrap(
      spacing: 8.w,
      runSpacing: 8.h,
      children:
          groupMembers.map((member) {
            final isSelected = _selectedFriends.contains(member);
            return FilterChip(
              selected: isSelected,
              label: Text(
                member,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14.sp,
                  color:
                      isSelected
                          ? Colors.white
                          : isDark
                          ? Colors.white70
                          : Colors.black87,
                  fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
                ),
              ),
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _selectedFriends.add(member);
                  } else {
                    _selectedFriends.remove(member);
                  }
                });
              },
              selectedColor: Color(_group.color ?? 0xFF000000),
              backgroundColor: isDark ? Colors.grey[800] : Colors.grey[200],
              checkmarkColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
                side: BorderSide(
                  color:
                      isSelected
                          ? Color(_group.color ?? 0xFF000000)
                          : isDark
                          ? Colors.grey[600]!
                          : Colors.grey[400]!,
                  width: 1,
                ),
              ),
            );
          }).toList(),
    );
  }

  Widget _buildCustomSplitSection() {
    if (_isSplitEqually) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Custom Split Amounts',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 16.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 8.h),
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            side: BorderSide(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              children: [
                // Your share input
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Your share:',
                        style: TextStyle(fontFamily: 'Inter', fontSize: 14.sp),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    SizedBox(
                      width: 120.w,
                      child: TextFormField(
                        decoration: InputDecoration(
                          prefixText: '\$ ',
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12.w,
                            vertical: 8.h,
                          ),
                          border: const OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        style: TextStyle(fontFamily: 'Inter', fontSize: 14.sp),
                        onChanged: (value) {
                          setState(() {
                            _yourCustomShare = double.tryParse(value) ?? 0.0;
                          });
                          _updateRemainingAmount();
                        },
                      ),
                    ),
                  ],
                ),

                // Friend shares
                if (_selectedFriends.isNotEmpty) ...[
                  SizedBox(height: 16.h),
                  ..._selectedFriends.map((friend) {
                    final controller = _getSplitController(friend);
                    return Padding(
                      padding: EdgeInsets.only(bottom: 8.h),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              '${friend}\'s share:',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 14.sp,
                              ),
                            ),
                          ),
                          SizedBox(width: 8.w),
                          SizedBox(
                            width: 120.w,
                            child: TextFormField(
                              controller: controller,
                              decoration: InputDecoration(
                                prefixText: '\$ ',
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 12.w,
                                  vertical: 8.h,
                                ),
                                border: const OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 14.sp,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ],

                // Invited email shares
                if (_invitedEmails.isNotEmpty) ...[
                  SizedBox(height: 8.h),
                  ..._invitedEmails.map((email) {
                    final controller = _getSplitController(email);
                    return Padding(
                      padding: EdgeInsets.only(bottom: 8.h),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              '$email\'s share:',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 14.sp,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          SizedBox(width: 8.w),
                          SizedBox(
                            width: 120.w,
                            child: TextFormField(
                              controller: controller,
                              decoration: InputDecoration(
                                prefixText: '\$ ',
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 12.w,
                                  vertical: 8.h,
                                ),
                                border: const OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 14.sp,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ],

                // Remaining amount display
                SizedBox(height: 16.h),
                Row(
                  children: [
                    Text(
                      'Remaining to split:',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '\$${_remainingAmount.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color:
                            _remainingAmount == 0.0 ? Colors.green : Colors.red,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSplitPreview() {
    final amountText = _amountController.text;
    if (amountText.isEmpty) return const SizedBox.shrink();

    final amount = double.tryParse(amountText) ?? 0.0;
    final totalPeople = _selectedFriends.length + _invitedEmails.length + 1;

    // Calculate individual shares
    Map<String, double> shares = {};
    if (_isSplitEqually) {
      final amountPerPerson = amount / totalPeople;
      shares['user'] = amountPerPerson;
      for (var friend in _selectedFriends) {
        shares[friend] = amountPerPerson;
      }
      for (var email in _invitedEmails) {
        shares[email] = amountPerPerson;
      }
    } else {
      shares['user'] = _yourCustomShare;
      for (var friend in _selectedFriends) {
        final controller = _splitAmountControllers[friend];
        shares[friend] = double.tryParse(controller?.text ?? '') ?? 0.0;
      }
      for (var email in _invitedEmails) {
        final controller = _splitAmountControllers[email];
        shares[email] = double.tryParse(controller?.text ?? '') ?? 0.0;
      }
    }

    return Card(
      elevation: 2,
      margin: EdgeInsets.zero,
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Preview header and total amount
            Row(
              children: [
                Icon(Icons.calculate, size: 20.sp, color: Colors.grey[600]),
                SizedBox(width: 8.w),
                Text(
                  'Split Preview',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            Text(
              'Total Amount: \$${amount.toStringAsFixed(2)}',
              style: TextStyle(fontFamily: 'Inter', fontSize: 14.sp),
            ),
            SizedBox(height: 4.h),
            Text(
              _isSplitEqually
                  ? 'Split evenly among $totalPeople people'
                  : 'Custom split amount',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 14.sp,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 8.h),
            const Divider(),

            // Your share
            Row(
              children: [
                Text(
                  'Your share:',
                  style: TextStyle(fontFamily: 'Inter', fontSize: 14.sp),
                ),
                const Spacer(),
                Text(
                  '\$${shares['user']?.toStringAsFixed(2) ?? '0.00'}',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: Color(_group.color ?? 0xFF000000),
                  ),
                ),
              ],
            ),

            // Member shares
            if (_selectedFriends.isNotEmpty) ...[
              SizedBox(height: 8.h),
              ..._selectedFriends.map(
                (friend) => Padding(
                  padding: EdgeInsets.only(bottom: 4.h),
                  child: Row(
                    children: [
                      Text(
                        '${friend}\'s share:',
                        style: TextStyle(fontFamily: 'Inter', fontSize: 14.sp),
                      ),
                      const Spacer(),
                      Text(
                        '\$${shares[friend]?.toStringAsFixed(2) ?? '0.00'}',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],

            // Invited email shares
            if (_invitedEmails.isNotEmpty) ...[
              SizedBox(height: 8.h),
              ..._invitedEmails.map(
                (email) => Padding(
                  padding: EdgeInsets.only(bottom: 4.h),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          '$email\'s share:',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 14.sp,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        '\$${shares[email]?.toStringAsFixed(2) ?? '0.00'}',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCategorySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.category,
              size: 20.sp,
              color: Color(_group.color ?? 0xFF000000),
            ),
            SizedBox(width: 8.w),
            Text(
              'Category',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
                color: Color(_group.color ?? 0xFF000000),
              ),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.all(8.w),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 3,
              crossAxisSpacing: 8.w,
              mainAxisSpacing: 8.h,
            ),
            itemCount: _categories.length,
            itemBuilder: (context, index) {
              final category = _categories[index];
              final isSelected = _selectedCategory == category['name'];

              return InkWell(
                onTap:
                    () => setState(
                      () => _selectedCategory = category['name'] as String,
                    ),
                child: Container(
                  decoration: BoxDecoration(
                    color:
                        isSelected
                            ? Color(_group.color ?? 0xFF000000).withOpacity(0.1)
                            : Colors.transparent,
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(
                      color:
                          isSelected
                              ? Color(_group.color ?? 0xFF000000)
                              : Colors.grey.shade300,
                    ),
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 8.h,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        category['icon'] as IconData,
                        size: 20.sp,
                        color:
                            isSelected
                                ? Color(_group.color ?? 0xFF000000)
                                : Colors.grey.shade600,
                      ),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Text(
                          category['name'] as String,
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 14.sp,
                            color:
                                isSelected
                                    ? Color(_group.color ?? 0xFF000000)
                                    : Colors.grey.shade600,
                            fontWeight:
                                isSelected
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Future<void> _selectDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _dueDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Color(_group.color ?? 0xFF000000),
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null && pickedDate != _dueDate) {
      setState(() {
        _dueDate = pickedDate;
      });
    }
  }

  void _inviteByEmail() {
    final email = _emailController.text.trim();
    if (email.isEmpty) return;

    // Simple email validation
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[aazA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    if (!emailRegex.hasMatch(email)) {
      AnimatedSnackBar.show(
        context,
        message: 'Please enter a valid email address',
        backgroundColor: Colors.orange.withOpacity(0.9),
      );
      return;
    }

    if (_invitedEmails.contains(email)) {
      AnimatedSnackBar.show(
        context,
        message: 'This email has already been invited',
        backgroundColor: Colors.orange.withOpacity(0.9),
      );
      return;
    }

    setState(() {
      _invitedEmails.add(email);
      _emailController.clear();
    });

    // Send email invite
    final message = """
You've been invited to split a bill on SavvySplit!

Group: ${_group.name}
Bill: ${_titleController.text}
Amount: \$${_amountController.text}
Due: ${DateFormat('MMM d, yyyy').format(_dueDate)}

Download SavvySplit to start splitting bills with friends!
""";

    Share.share(message, subject: 'Join me in splitting a bill on SavvySplit');
  }

  void _saveBill() {
    if (_formKey.currentState!.validate()) {
      if (_selectedFriends.isEmpty && _invitedEmails.isEmpty) {
        AnimatedSnackBar.show(
          context,
          message: 'Please select at least one person to split with',
          backgroundColor: Colors.red.withOpacity(0.9),
        );
        return;
      }

      final title = _titleController.text;
      final description = _descriptionController.text;
      final amount = double.parse(_amountController.text);

      // Validate custom splits if not splitting equally
      Map<String, double>? customSplits;
      if (!_isSplitEqually) {
        customSplits = {'user': _yourCustomShare};

        // Add friend shares
        for (var friend in _selectedFriends) {
          final controller = _splitAmountControllers[friend];
          if (controller == null) continue;
          final shareAmount = double.tryParse(controller.text) ?? 0.0;
          customSplits[friend] = shareAmount;
        }

        // Add invited email shares
        for (var email in _invitedEmails) {
          final controller = _splitAmountControllers[email];
          if (controller == null) continue;
          final shareAmount = double.tryParse(controller.text) ?? 0.0;
          customSplits[email] = shareAmount;
        }

        // Validate total equals bill amount
        final total = customSplits.values.fold(
          0.0,
          (sum, value) => sum + value,
        );
        if ((total - amount).abs() > 0.01) {
          // Allow small rounding errors
          AnimatedSnackBar.show(
            context,
            message:
                'Custom split amounts must equal the total bill amount (\$${amount.toStringAsFixed(2)})',
            backgroundColor: Colors.red.withOpacity(0.9),
            duration: const Duration(seconds: 3),
          );
          return;
        }
      }

      // Add bill to the group
      final billProvider = Provider.of<BillProvider>(context, listen: false);
      final newBill = billProvider.addBillToGroup(
        groupId: widget.groupId,
        title: title,
        description: description,
        amount: amount,
        dueDate: _dueDate,
        splitWith: [..._selectedFriends, ..._invitedEmails],
        customSplits: customSplits,
        category: _selectedCategory,
      );

      // Show success message
      AnimatedSnackBar.show(
        context,
        message: 'Added "${newBill.title}" to ${_group.name}',
        backgroundColor: Color(_group.color ?? 0xFF000000).withOpacity(0.9),
      );

      Navigator.pop(context);
    }
  }
}

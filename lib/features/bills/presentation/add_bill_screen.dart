import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../../providers/bill_provider.dart';
import '../../../features/shared/widgets/animated_snackbar.dart';
import '../models/group.dart';

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

  // Add custom split amount controllers
  final Map<String, TextEditingController> _splitAmountControllers = {};
  double _remainingAmount = 0.0;
  double _yourCustomShare = 0.0;

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
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Add New Bill',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 20.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Group name display
              Text(
                'For ${_group.name}',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14.sp,
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(height: 16.h),

              // Bill title
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Bill Title',
                  labelStyle: TextStyle(fontFamily: 'Inter', fontSize: 14.sp),
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.description),
                ),
                style: TextStyle(fontFamily: 'Inter', fontSize: 16.sp),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),

              SizedBox(height: 16.h),

              // Bill description
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: 'Description (Optional)',
                  labelStyle: TextStyle(fontFamily: 'Inter', fontSize: 14.sp),
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.notes),
                ),
                style: TextStyle(fontFamily: 'Inter', fontSize: 16.sp),
                maxLines: 2,
              ),

              SizedBox(height: 16.h),

              // Amount
              TextFormField(
                controller: _amountController,
                decoration: InputDecoration(
                  labelText: 'Amount',
                  labelStyle: TextStyle(fontFamily: 'Inter', fontSize: 14.sp),
                  prefixText: '\$ ',
                  prefixStyle: TextStyle(fontFamily: 'Inter', fontSize: 16.sp),
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.attach_money),
                ),
                style: TextStyle(fontFamily: 'Inter', fontSize: 16.sp),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an amount';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),

              SizedBox(height: 16.h),

              _buildDatePicker(),

              SizedBox(height: 24.h),

              // Split method selector
              Text(
                'Split Method',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 8.h),
              SegmentedButton<bool>(
                segments: [
                  ButtonSegment<bool>(
                    value: true,
                    label: Text(
                      'Split Equally',
                      style: TextStyle(fontFamily: 'Inter', fontSize: 14.sp),
                    ),
                    icon: const Icon(Icons.balance),
                  ),
                  ButtonSegment<bool>(
                    value: false,
                    label: Text(
                      'Custom Split',
                      style: TextStyle(fontFamily: 'Inter', fontSize: 14.sp),
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
              ),

              SizedBox(height: 16.h),

              // Custom split section
              _buildCustomSplitSection(),

              SizedBox(height: 24.h),

              // Select friends section
              Text(
                'Split With',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 8.h),
              _buildFriendSelector(),

              SizedBox(height: 16.h),

              // Invite by email section
              Text(
                'Invite Others',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 8.h),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        hintText: 'Enter email address',
                        hintStyle: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 14.sp,
                        ),
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.email),
                      ),
                      style: TextStyle(fontFamily: 'Inter', fontSize: 16.sp),
                      keyboardType: TextInputType.emailAddress,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: _inviteByEmail,
                    style: IconButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),

              // Invited emails list
              if (_invitedEmails.isNotEmpty) ...[
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
                          backgroundColor: Theme.of(context).primaryColor,
                          deleteIcon: const Icon(Icons.close, size: 16),
                          onDeleted: () {
                            setState(() {
                              _invitedEmails.remove(email);
                            });
                          },
                        );
                      }).toList(),
                ),
              ],

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
                  backgroundColor: Color(_group.color),
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
                  color: isSelected ? Colors.white : Colors.black87,
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
              selectedColor: Color(_group.color),
              checkmarkColor: Colors.white,
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
                    color: Color(_group.color),
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

  Future<void> _selectDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _dueDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(primary: Color(_group.color)),
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
      );

      // Show success message
      AnimatedSnackBar.show(
        context,
        message: 'Added "${newBill.title}" to ${_group.name}',
        backgroundColor: Color(_group.color).withOpacity(0.9),
      );

      Navigator.pop(context);
    }
  }
}

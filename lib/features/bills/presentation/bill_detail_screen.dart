import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';

// Import with absolute paths to ensure proper resolution
import 'package:savr/models/bill.dart';
import 'package:savr/providers/bill_provider.dart';
import 'package:savr/features/shared/widgets/animated_snackbar.dart';

class BillDetailScreen extends StatelessWidget {
  final String billId;

  const BillDetailScreen({super.key, required this.billId});

  @override
  Widget build(BuildContext context) {
    // Access the BillProvider directly from the context
    final billProvider = Provider.of<BillProvider>(context, listen: true);
    // Use a try-catch to handle potential errors
    Bill? bill;
    try {
      bill = billProvider.getBillById(billId);
    } catch (e) {
      debugPrint('Error getting bill: $e');
    }
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    if (bill == null || bill.id.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Bill Details')),
        body: const Center(child: Text('Bill not found')),
      );
    }

    final double amount = bill.amount;
    final List<String> splitWith = bill.splitWith;
    final double shareAmount = billProvider.getMyShare(bill);
    final bool isPaid = bill.paid;
    final String status = bill.status;
    final String category = bill.category ?? 'Other';

    // Determine status color
    Color statusColor;
    switch (status) {
      case 'pending':
        statusColor = Colors.orange;
        break;
      case 'overdue':
        statusColor = Colors.red;
        break;
      case 'paid':
        statusColor = Colors.green;
        break;
      default:
        statusColor = Colors.grey;
    }

    // Format the due date
    final formattedDueDate = DateFormat('MMM dd, yyyy').format(bill.dueDate);

    // Calculate days remaining or overdue
    final daysRemaining = bill.dueDate.difference(DateTime.now()).inDays;
    String daysText = '';
    if (status != 'paid') {
      if (daysRemaining > 0) {
        daysText = '$daysRemaining days remaining';
      } else if (daysRemaining == 0) {
        daysText = 'Due today';
      } else {
        daysText = '${daysRemaining.abs()} days overdue';
      }
    }

    // Get category icon
    IconData categoryIcon = _getCategoryIcon(category);

    return Scaffold(
      backgroundColor:
          isDarkMode ? const Color(0xFF121212) : const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text(
          'Bill Details',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 20.sp,
            fontWeight: FontWeight.w600,
            color: isDarkMode ? Colors.white : Theme.of(context).primaryColor,
          ),
        ),
        backgroundColor:
            isDarkMode ? const Color(0xFF121212) : const Color(0xFFF5F7FA),
        elevation: 0,
        iconTheme: IconThemeData(
          color: isDarkMode ? Colors.white : Theme.of(context).primaryColor,
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.notifications_outlined,
              color: isDarkMode ? Colors.white : Theme.of(context).primaryColor,
            ),
            onPressed: () => _setReminder(context, bill),
            tooltip: 'Set Reminder',
          ),
          IconButton(
            icon: Icon(
              Icons.share,
              color: isDarkMode ? Colors.white : Theme.of(context).primaryColor,
            ),
            onPressed: () => _shareBill(context, bill),
            tooltip: 'Share Bill',
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status banner
            Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(
                    vertical: 12.h,
                    horizontal: 16.w,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        status.toUpperCase(),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: statusColor,
                        ),
                      ),
                      if (daysText.isNotEmpty)
                        Text(daysText, style: TextStyle(color: statusColor)),
                    ],
                  ),
                )
                .animate()
                .fadeIn(duration: const Duration(milliseconds: 300))
                .slideY(begin: 0.2, end: 0)
                .then(delay: const Duration(milliseconds: 200))
                .shimmer(
                  duration: const Duration(milliseconds: 800),
                  color: statusColor.withOpacity(0.2),
                ),

            SizedBox(height: 24.h),

            // Bill title and category
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        bill.title,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 24.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        'Due on $formattedDueDate',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 16.sp,
                          color: isDarkMode ? Colors.white70 : Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(14.w),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16.r),
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context).primaryColor.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Icon(
                        categoryIcon,
                        color: Theme.of(context).primaryColor,
                        size: 20.sp,
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        category,
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            SizedBox(height: 24.h),

            // Amount card - No shadow implementation
            Container(
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(
                      color:
                          isDarkMode
                              ? Colors.grey.shade800
                              : Colors.grey.shade200,
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Amount Details',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 16.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total Amount',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 16.sp,
                            ),
                          ),
                          Text(
                            '\$${amount.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 18.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      Divider(
                        height: 24.h,
                        color:
                            isDarkMode
                                ? Colors.grey.shade800
                                : Colors.grey.shade200,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Your Share',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 16.sp,
                            ),
                          ),
                          Text(
                            '\$${shareAmount.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 18.sp,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                        ],
                      ),
                      if (isPaid) ...[
                        Divider(
                          height: 24.h,
                          color:
                              isDarkMode
                                  ? Colors.grey.shade800
                                  : Colors.grey.shade200,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Payment Status',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 16.sp,
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 10.w,
                                vertical: 6.h,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.green.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(8.r),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.green.withOpacity(0.1),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Text(
                                'Paid',
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.green,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ], // End of amount card children
                  ), // End of amount card Column
                ) // End of amount card Container
                .animate()
                .fadeIn(
                  duration: const Duration(milliseconds: 300),
                  delay: const Duration(milliseconds: 100),
                )
                .slideY(begin: 0.2, end: 0)
                .then(delay: const Duration(milliseconds: 300))
                .elevation(
                  begin: 0,
                  end: 4,
                  curve: Curves.easeOut,
                  duration: const Duration(milliseconds: 500),
                ),
            SizedBox(height: 24.h),
            // Split details
            Text(
              'Split Details',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'This bill is split equally between you and ${splitWith.length} friend${splitWith.length > 1 ? 's' : ''}.',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 14.sp,
                color: isDarkMode ? Colors.white70 : Colors.black87,
              ),
            ),
            SizedBox(height: 16.h),
            // People list
            _buildPeopleListCard(context, splitWith, shareAmount, isDarkMode),
            SizedBox(height: 24.h),
            // Payment history section (new)
            if (bill.paymentHistory != null && bill.paymentHistory!.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Payment History',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Card(
                        elevation: 3,
                        shadowColor: Colors.green.withOpacity(0.2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                        child: Column(
                          children: [
                            ...bill.paymentHistory!.map((payment) {
                              final paymentDate = DateFormat(
                                'MMM dd, yyyy',
                              ).format(payment.date);
                              return ListTile(
                                leading: const Icon(Icons.payment),
                                title: Text(
                                  '\$${payment.amount.toStringAsFixed(2)}', // Dollar sign
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                subtitle: Text(
                                  'Paid on $paymentDate',
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 14.sp,
                                  ),
                                ),
                                trailing: Text(
                                  payment.method,
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 14.sp,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                ),
                              );
                            }).toList(),
                          ],
                        ),
                      )
                      .animate()
                      .fadeIn(
                        duration: const Duration(milliseconds: 300),
                        delay: const Duration(milliseconds: 300),
                      )
                      .slideY(begin: 0.2, end: 0)
                      .then(delay: const Duration(milliseconds: 200))
                      .shimmer(
                        duration: const Duration(milliseconds: 1000),
                        color: Colors.green.withOpacity(0.2),
                      ),
                  SizedBox(height: 24.h),
                ],
              ),

            // Action buttons
            if (!isPaid)
              Column(
                children: [
                  ElevatedButton(
                        onPressed: () => _markAsPaid(context, billProvider),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          minimumSize: Size(double.infinity, 54.h),
                          elevation: 4,
                          shadowColor: Colors.green.withOpacity(0.4),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.check_circle_outline,
                              color: Colors.white,
                            ),
                            SizedBox(width: 8.w),
                            Text(
                              'Mark as Paid',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      )
                      .animate()
                      .fadeIn(
                        duration: const Duration(milliseconds: 300),
                        delay: const Duration(milliseconds: 400),
                      )
                      .slideY(begin: 0.1, end: 0)
                      .then(delay: const Duration(milliseconds: 200))
                      .blurY(begin: 4, end: 0)
                      .scale(
                        begin: const Offset(0.95, 0.95),
                        end: const Offset(1.0, 1.0),
                      ),
                  SizedBox(height: 12.h),
                  OutlinedButton(
                        onPressed:
                            () => _makePartialPayment(context, billProvider),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                            color: Theme.of(context).primaryColor,
                            width: 1.5,
                          ),
                          minimumSize: Size(double.infinity, 54.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          backgroundColor:
                              isDarkMode ? Colors.black12 : Colors.white,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.payments_outlined,
                              color: Theme.of(context).primaryColor,
                            ),
                            SizedBox(width: 8.w),
                            Text(
                              'Make Partial Payment',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                          ],
                        ),
                      )
                      .animate()
                      .fadeIn(
                        duration: const Duration(milliseconds: 300),
                        delay: const Duration(milliseconds: 500),
                      )
                      .slideY(begin: 0.1, end: 0)
                      .then(delay: const Duration(milliseconds: 200))
                      .shimmer(
                        duration: const Duration(milliseconds: 800),
                        color: Theme.of(context).primaryColor.withOpacity(0.2),
                      ),
                ],
              ),

            SizedBox(height: 12.h),

            OutlinedButton(
                  onPressed: () => _deleteBill(context, billProvider),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.red, width: 1.5),
                    minimumSize: Size(double.infinity, 54.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    backgroundColor: isDarkMode ? Colors.black12 : Colors.white,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.delete_outline, color: Colors.red),
                      SizedBox(width: 8.w),
                      Text(
                        'Delete Bill',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                )
                .animate()
                .fadeIn(
                  duration: const Duration(milliseconds: 300),
                  delay: const Duration(milliseconds: 600),
                )
                .slideY(begin: 0.1, end: 0)
                .then(delay: const Duration(milliseconds: 200))
                .blurY(begin: 4, end: 0),
          ], // End of main Column children
        ), // End of main Column
      ), // End of SingleChildScrollView
    ); // End of Scaffold
  }

  Future<void> _markAsPaid(
    BuildContext context,
    BillProvider billProvider,
  ) async {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(
              'Mark as Paid',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            content: Text(
              'Are you sure you want to mark this bill as paid?',
              style: TextStyle(fontFamily: 'Inter', fontSize: 14.sp),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Cancel',
                  style: TextStyle(fontFamily: 'Inter', fontSize: 14.sp),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  billProvider.markAsPaid(billId);
                  Navigator.pop(context); // Close dialog

                  AnimatedSnackBar.show(
                    context,
                    message: 'Bill marked as paid',
                    backgroundColor: Colors.green.withOpacity(0.9),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
                child: Text(
                  'Mark as Paid',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14.sp,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
    );
  }

  Future<void> _deleteBill(
    BuildContext context,
    BillProvider billProvider,
  ) async {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16.r),
          topRight: Radius.circular(16.r),
        ),
      ),
      builder:
          (context) => Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle bar for bottom sheet
                Center(
                  child: Container(
                    width: 40.w,
                    height: 4.h,
                    decoration: BoxDecoration(
                      color:
                          isDarkMode
                              ? Colors.grey.shade700
                              : Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2.r),
                    ),
                  ),
                ),
                SizedBox(height: 16),

                // Warning icon
                Center(
                  child: Container(
                    width: 60.w,
                    height: 60.w,
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.delete_outline,
                      color: Colors.red,
                      size: 32.sp,
                    ),
                  ),
                ),
                SizedBox(height: 16),

                // Title
                Center(
                  child: Text(
                    'Delete Bill',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                SizedBox(height: 8.h),

                // Warning message
                Center(
                  child: Text(
                    'Are you sure you want to delete this bill?',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14.sp,
                      color:
                          isDarkMode
                              ? Colors.grey.shade300
                              : Colors.grey.shade700,
                    ),
                  ),
                ),
                SizedBox(height: 8.h),

                Center(
                  child: Text(
                    'This action cannot be undone.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12.sp,
                      fontStyle: FontStyle.italic,
                      color:
                          isDarkMode
                              ? Colors.grey.shade400
                              : Colors.grey.shade600,
                    ),
                  ),
                ),
                SizedBox(height: 24.h),

                // Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                            color: Theme.of(context).primaryColor,
                          ),
                          padding: EdgeInsets.symmetric(vertical: 12.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                        ),
                        child: Text(
                          'Cancel',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 14.sp,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          billProvider.deleteBill(billId);
                          Navigator.pop(context); // Close bottom sheet
                          Navigator.pop(context); // Go back to bills list

                          AnimatedSnackBar.show(
                            context,
                            message: 'Bill deleted',
                            backgroundColor: Colors.red.withOpacity(0.9),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          padding: EdgeInsets.symmetric(vertical: 12.h),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                        ),
                        child: Text(
                          'Delete',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 14.sp,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
    );
  }

  void _setReminder(BuildContext context, Bill? bill) async {
    if (bill == null) return;
    final DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (selectedDate == null) return;

    final TimeOfDay? selectedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (selectedTime == null) return;

    AnimatedSnackBar.show(
      context,
      message:
          'Reminder set for ${DateFormat('MMM dd, yyyy').format(selectedDate)} at ${selectedTime.format(context)}',
      backgroundColor: Theme.of(context).primaryColor.withOpacity(0.9),
    );
  }

  Future<void> _shareBill(BuildContext context, Bill? bill) async {
    if (bill == null) return;
    final title = bill.title;
    final amount = bill.amount;
    final dueDate = DateFormat('MMM dd, yyyy').format(bill.dueDate);
    final people = bill.splitWith.join(', ');
    final perPersonAmount = amount / (bill.splitWith.length + 1);
    final category = bill.category ?? 'Other';

    final message = """
📝 Bill: $title
📋 Category: $category
💰 Total Amount: \$${amount.toStringAsFixed(2)}
📅 Due Date: $dueDate
👥 Split with: You, $people
💸 Amount per person: \$${perPersonAmount.toStringAsFixed(2)}

Sent from Savr app
""";

    Share.share(message, subject: 'Bill Details: $title');
  }

  Future<void> _makePartialPayment(
    BuildContext context,
    BillProvider billProvider,
  ) async {
    final bill = billProvider.getBillById(billId);
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    if (bill == null) return;
    final double remainingAmount = bill.amount - (bill.paidAmount ?? 0);
    final amountController = TextEditingController();
    String? amountError;
    String? methodError;
    String? selectedMethod;
    bool isLoading = false;
    final List<String> paymentMethods = [
      'Cash',
      'Bank Transfer',
      'Venmo',
      'PayPal',
      'Other',
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16.r),
          topRight: Radius.circular(16.r),
        ),
      ),
      builder: (context) {
        final methodFocus = FocusNode();
        return StatefulBuilder(
          builder:
              (context, setState) => Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                  left: 16.w,
                  right: 16.w,
                  top: 16.h,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title bar with close button
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Make Partial Payment',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 20.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.close),
                            onPressed: () => Navigator.pop(context),
                            tooltip: 'Close',
                          ),
                        ],
                      ),
                      SizedBox(height: 8.h),
                      // Bill summary
                      Card(
                        color:
                            isDarkMode
                                ? Colors.grey.shade900
                                : Colors.grey.shade100,
                        child: ListTile(
                          title: Text(
                            bill.title,
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Text(
                            'Due: ${DateFormat('MMM dd, yyyy').format(bill.dueDate)}',
                          ),
                          trailing: Text(
                            'Remaining: \$${remainingAmount.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 16.h),
                      // Amount field
                      TextField(
                        controller: amountController,
                        keyboardType: TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        autofocus: true,
                        decoration: InputDecoration(
                          labelText: 'Payment Amount',
                          prefixText: '\$',
                          hintText: '0.00',
                          errorText: amountError,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          filled: true,
                          fillColor:
                              isDarkMode
                                  ? Colors.grey.shade800
                                  : Colors.grey.shade50,
                        ),
                        onChanged: (_) {
                          setState(() => amountError = null);
                        },
                        onSubmitted:
                            (_) => FocusScope.of(
                              context,
                            ).requestFocus(methodFocus),
                      ),
                      SizedBox(height: 16.h),
                      // Payment method dropdown
                      DropdownButtonFormField<String>(
                        value: selectedMethod,
                        items:
                            paymentMethods
                                .map(
                                  (m) => DropdownMenuItem(
                                    value: m,
                                    child: Text(m),
                                  ),
                                )
                                .toList(),
                        onChanged: (val) {
                          setState(() {
                            selectedMethod = val;
                            methodError = null;
                          });
                        },
                        focusNode: methodFocus,
                        decoration: InputDecoration(
                          labelText: 'Payment Method',
                          hintText: 'Select method',
                          errorText: methodError,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          filled: true,
                          fillColor:
                              isDarkMode
                                  ? Colors.grey.shade800
                                  : Colors.grey.shade50,
                        ),
                      ),
                      SizedBox(height: 24.h),
                      // Buttons
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed:
                                  isLoading
                                      ? null
                                      : () => Navigator.pop(context),
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(
                                  color: Theme.of(context).primaryColor,
                                ),
                                padding: EdgeInsets.symmetric(vertical: 12.h),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.r),
                                ),
                              ),
                              child: Text(
                                'Cancel',
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 14.sp,
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: ElevatedButton(
                              onPressed:
                                  isLoading
                                      ? null
                                      : () async {
                                        final amount = double.tryParse(
                                          amountController.text,
                                        );
                                        setState(() {
                                          amountError = null;
                                          methodError = null;
                                        });
                                        if (amount == null || amount <= 0) {
                                          setState(
                                            () =>
                                                amountError =
                                                    'Enter a valid amount',
                                          );
                                          return;
                                        }
                                        if (amount > remainingAmount) {
                                          setState(
                                            () =>
                                                amountError =
                                                    'Cannot exceed remaining',
                                          );
                                          return;
                                        }
                                        if (selectedMethod == null ||
                                            selectedMethod!.isEmpty) {
                                          setState(
                                            () =>
                                                methodError =
                                                    'Select a payment method',
                                          );
                                          return;
                                        }
                                        setState(() => isLoading = true);
                                        await Future.delayed(
                                          const Duration(milliseconds: 600),
                                        );
                                        billProvider.addPayment(
                                          billId,
                                          amount,
                                          selectedMethod!,
                                          DateTime.now(),
                                        );
                                        setState(() => isLoading = false);
                                        Navigator.pop(context);
                                        AnimatedSnackBar.show(
                                          context,
                                          message:
                                              'Payment of \$${amount.toStringAsFixed(2)} recorded',
                                          backgroundColor: Colors.green
                                              .withOpacity(0.9),
                                        );
                                      },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(context).primaryColor,
                                padding: EdgeInsets.symmetric(vertical: 12.h),
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.r),
                                ),
                              ),
                              child:
                                  isLoading
                                      ? SizedBox(
                                        width: 20.w,
                                        height: 20.h,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2.5,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                Colors.white,
                                              ),
                                        ),
                                      )
                                      : Text(
                                        'Submit Payment',
                                        style: TextStyle(
                                          fontFamily: 'Inter',
                                          fontSize: 14.sp,
                                          color: Colors.white,
                                        ),
                                      ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16.h),
                    ],
                  ),
                ),
              ),
        );
      },
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'rent':
        return Icons.home;
      case 'utilities':
        return Icons.electric_bolt;
      case 'groceries':
        return Icons.shopping_cart;
      case 'dining':
        return Icons.restaurant;
      case 'entertainment':
        return Icons.movie;
      case 'transportation':
        return Icons.directions_car;
      case 'travel':
        return Icons.flight;
      case 'health':
        return Icons.medical_services;
      case 'education':
        return Icons.school;
      case 'subscription':
        return Icons.subscriptions;
      default:
        return Icons.receipt;
    }
  }

  Widget _buildPeopleListCard(
    BuildContext context,
    List<String> splitWith,
    double shareAmount,
    bool isDarkMode,
  ) {
    return Card(
          elevation: 3,
          shadowColor: Colors.grey.withOpacity(0.2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Column(
            children: [
              // You (current user)
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: Theme.of(
                    context,
                  ).primaryColor.withOpacity(0.2),
                  child: Text(
                    'You',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ),
                title: Text(
                  'You',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                trailing: Text(
                  '\$${shareAmount.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              // Friends list
              ...splitWith.map(
                (person) => ListTile(
                  leading: CircleAvatar(
                    backgroundColor:
                        isDarkMode
                            ? Colors.grey.shade800
                            : Colors.grey.shade200,
                    child: Text(
                      person[0],
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: isDarkMode ? Colors.white : Colors.black87,
                      ),
                    ),
                  ),
                  title: Text(
                    person,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  trailing: Text(
                    '\$${shareAmount.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
        )
        .animate()
        .fadeIn(
          duration: const Duration(milliseconds: 300),
          delay: const Duration(milliseconds: 200),
        )
        .slideY(begin: 0.2, end: 0)
        .then(delay: const Duration(milliseconds: 400))
        .scale(
          begin: const Offset(0.95, 0.95),
          end: const Offset(1.0, 1.0),
          curve: Curves.easeOut,
          duration: const Duration(milliseconds: 300),
        );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../../providers/bill_provider.dart';
import '../../../features/shared/widgets/animated_snackbar.dart';
import '../models/bill.dart';
import '../models/bill_status.dart';

class BillDetailScreen extends StatelessWidget {
  final String billId;

  const BillDetailScreen({super.key, required this.billId});

  @override
  Widget build(BuildContext context) {
    final billProvider = Provider.of<BillProvider>(context);
    final bill = billProvider.getBillById(billId);

    if (bill == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Bill Details')),
        body: const Center(child: Text('Bill not found')),
      );
    }

    final double amount = bill.amount;
    final List<String> splitWith = bill.splitWith;
    final double shareAmount = billProvider.getMyShare(bill);
    final bool isPaid = bill.paid;
    final BillStatus status = bill.status;

    // Determine status color
    Color statusColor;
    switch (status) {
      case BillStatus.pending:
        statusColor = Colors.orange;
        break;
      case BillStatus.overdue:
        statusColor = Colors.red;
        break;
      case BillStatus.paid:
        statusColor = Colors.green;
        break;
      default:
        statusColor = Colors.grey;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Bill Details',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 20.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () => _shareBill(context, bill),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status banner
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 16.w),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(color: statusColor.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(
                    status == BillStatus.pending
                        ? Icons.access_time
                        : status == BillStatus.overdue
                        ? Icons.warning
                        : Icons.check_circle,
                    color: statusColor,
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    status == BillStatus.pending
                        ? 'Pending'
                        : status == BillStatus.overdue
                        ? 'Overdue'
                        : 'Paid',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: statusColor,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 24.h),

            // Bill title
            Text(
              bill.title,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 24.sp,
                fontWeight: FontWeight.w600,
              ),
            ),

            SizedBox(height: 4.h),

            // Due date
            Text(
              'Due on ${bill.dueDate.toString().split(' ')[0]}',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 16.sp,
                color: Colors.black54,
              ),
            ),

            SizedBox(height: 24.h),

            // Amount card
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Padding(
                padding: EdgeInsets.all(16.w),
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
                          '\$${amount.toStringAsFixed(1)}',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    Divider(height: 24.h),
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
                          '\$${shareAmount.toStringAsFixed(1)}',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
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
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 16.h),

            // People list
            Card(
              elevation: 1,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
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
                      '\$${shareAmount.toStringAsFixed(1)}',
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
                        backgroundColor: Colors.grey.shade200,
                        child: Text(
                          person[0],
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
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
                        '\$${shareAmount.toStringAsFixed(1)}',
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
            ),

            SizedBox(height: 24.h),

            // Action buttons
            if (!isPaid)
              ElevatedButton(
                onPressed: () => _markAsPaid(context, billProvider),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  minimumSize: Size(double.infinity, 50.h),
                ),
                child: Text(
                  'Mark as Paid',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),

            SizedBox(height: 12.h),

            OutlinedButton(
              onPressed: () => _deleteBill(context, billProvider),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.red),
                minimumSize: Size(double.infinity, 50.h),
              ),
              child: Text(
                'Delete Bill',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.red,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _markAsPaid(BuildContext context, BillProvider billProvider) {
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
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
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

  void _deleteBill(BuildContext context, BillProvider billProvider) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(
              'Delete Bill',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            content: Text(
              'Are you sure you want to delete this bill?',
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
              TextButton(
                onPressed: () {
                  billProvider.deleteBill(billId);
                  Navigator.pop(context); // Close dialog
                  Navigator.pop(context); // Go back to bills list

                  AnimatedSnackBar.show(
                    context,
                    message: 'Bill deleted',
                    backgroundColor: Colors.red.withOpacity(0.9),
                  );
                },
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: Text(
                  'Delete',
                  style: TextStyle(fontFamily: 'Inter', fontSize: 14.sp),
                ),
              ),
            ],
          ),
    );
  }

  void _shareBill(BuildContext context, Bill bill) {
    final title = bill.title;
    final amount = bill.amount;
    final dueDate = bill.dueDate.toString().split(' ')[0];
    final people = bill.splitWith.join(', ');
    final perPersonAmount = amount / (bill.splitWith.length + 1);

    final message = """
📝 Bill: $title
💰 Total Amount: \$${amount.toStringAsFixed(1)}
📅 Due Date: $dueDate
👥 Split with: You, $people
💸 Amount per person: \$${perPersonAmount.toStringAsFixed(1)}

Sent from SavvySplit app
""";

    Share.share(message, subject: 'Bill Details: $title');
  }
}

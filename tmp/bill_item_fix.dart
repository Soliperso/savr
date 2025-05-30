import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

// This is a standalone example of the corrected bill item implementation
// without the red left border and with proper horizontal alignment

Widget buildBillItem(
  BuildContext context,
  Map<String, dynamic> bill,
  VoidCallback onTap,
) {
  final dueDate = DateTime.tryParse(bill['due']?.toString() ?? '');

  // Determine due status
  Color iconColor = Theme.of(context).hintColor;
  String dueStatus = '';
  if (dueDate != null) {
    final now = DateTime.now();
    final days = dueDate.difference(now).inDays;
    if (dueDate.isBefore(now)) {
      iconColor = Colors.red;
      dueStatus = 'Overdue';
    } else if (days <= 3) {
      iconColor = Colors.orange;
      dueStatus = 'Due soon';
    } else {
      dueStatus = '$days days left';
      iconColor = Colors.green;
    }
  }

  return InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(8),
    child: Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // Leading icon
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.15),
              shape: BoxShape.circle,
              border: Border.all(color: iconColor.withOpacity(0.3), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: iconColor.withOpacity(0.15),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Icon(
              dueDate?.isBefore(DateTime.now()) ?? false
                  ? Icons.warning_amber_rounded
                  : Icons.calendar_today_rounded,
              color: iconColor,
              size: 22,
            ),
          ),

          SizedBox(width: 12),

          // Content column (title and subtitle)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  bill['title'] as String? ?? '',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      dueDate != null
                          ? DateFormat('MMM d').format(dueDate)
                          : '--',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: iconColor,
                      ),
                    ),
                    SizedBox(width: 6),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: iconColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(4),
                        boxShadow: [
                          BoxShadow(
                            color: iconColor.withOpacity(0.1),
                            blurRadius: 2,
                            spreadRadius: 0,
                          ),
                        ],
                      ),
                      child: Text(
                        dueStatus,
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: iconColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Amount display (trailing)
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Colors.red.withOpacity(0.08),
              boxShadow: [
                BoxShadow(
                  color: Colors.red.withOpacity(0.08),
                  blurRadius: 4,
                  spreadRadius: 0,
                ),
              ],
            ),
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Text(
              '\$${(bill['amount'] as num?)?.toStringAsFixed(2) ?? '--'}',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
                fontSize: 15,
                color: Colors.red,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

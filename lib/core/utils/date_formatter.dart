import 'package:intl/intl.dart';

/// Utility class for formatting dates in a consistent way throughout the app
class DateFormatter {
  /// Format a date as "MMM dd, yyyy" (e.g., "May 15, 2025")
  static String formatDate(DateTime date) {
    return DateFormat('MMM dd, yyyy').format(date);
  }
  
  /// Format a date as "MMM dd, yyyy" with time (e.g., "May 15, 2025 at 3:30 PM")
  static String formatDateWithTime(DateTime date) {
    return DateFormat('MMM dd, yyyy \'at\' h:mm a').format(date);
  }
  
  /// Format a date as relative to now (e.g., "2 days ago", "in 3 days")
  static String getRelativeDate(DateTime date) {
    final now = DateTime.now();
    final difference = date.difference(now).inDays;
    
    if (difference == 0) {
      // Today
      return 'Today';
    } else if (difference == 1) {
      // Tomorrow
      return 'Tomorrow';
    } else if (difference == -1) {
      // Yesterday
      return 'Yesterday';
    } else if (difference > 1) {
      // Future date
      return 'In $difference days';
    } else {
      // Past date
      return '${difference.abs()} days ago';
    }
  }
  
  /// Get days remaining or overdue text
  static String getDaysRemainingText(DateTime dueDate, bool isPaid) {
    if (isPaid) return '';
    
    final daysRemaining = dueDate.difference(DateTime.now()).inDays;
    
    if (daysRemaining > 0) {
      return '$daysRemaining days remaining';
    } else if (daysRemaining == 0) {
      return 'Due today';
    } else {
      return '${daysRemaining.abs()} days overdue';
    }
  }
}

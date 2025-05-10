import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TransactionProvider extends ChangeNotifier {
  final List<Map<String, dynamic>> _transactions = [
    {
      'title': 'Groceries',
      'amount': -50.0,
      'category': 'Food & Groceries',
      'date': 'May 8',
      'fullDate': '2025-05-08',
    },
    {
      'title': 'Salary',
      'amount': 2000.0,
      'category': 'Income',
      'date': 'May 7',
      'fullDate': '2025-05-07',
    },
    {
      'title': 'Coffee',
      'amount': -4.0,
      'category': 'Food & Drinks',
      'date': 'May 7',
      'fullDate': '2025-05-07',
    },
    {
      'title': 'Gas',
      'amount': -45.0,
      'category': 'Transportation',
      'date': 'May 6',
      'fullDate': '2025-05-06',
    },
    {
      'title': 'Movie Tickets',
      'amount': -30.0,
      'category': 'Entertainment',
      'date': 'May 5',
      'fullDate': '2025-05-05',
    },
    {
      'title': 'Gym Membership',
      'amount': -50.0,
      'category': 'Health & Fitness',
      'date': 'May 4',
      'fullDate': '2025-05-04',
    },
  ];

  List<Map<String, dynamic>> get transactions => _transactions;

  double get totalBalance {
    return _transactions.fold(
      0,
      (sum, transaction) => sum + (transaction['amount'] as double),
    );
  }

  double get totalIncome {
    return _transactions
        .where((transaction) => (transaction['amount'] as double) > 0)
        .fold(0, (sum, transaction) => sum + (transaction['amount'] as double));
  }

  double get totalExpenses {
    return _transactions
        .where((transaction) => (transaction['amount'] as double) < 0)
        .fold(
          0,
          (sum, transaction) => sum + (transaction['amount'] as double).abs(),
        );
  }

  void addTransaction(String title, double amount, bool isExpense) {
    final now = DateTime.now();
    final dateStr = DateFormat('MMM d').format(now);

    final transaction = {
      'title': title,
      'amount': isExpense ? -amount : amount,
      'date': dateStr,
    };

    _transactions.insert(0, transaction); // Add at the beginning of the list
    notifyListeners();
  }

  void deleteTransaction(int index) {
    _transactions.removeAt(index);
    notifyListeners();
  }
}

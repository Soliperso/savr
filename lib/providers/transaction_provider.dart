import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../features/transactions/models/transaction.dart'; // Changed import

class TransactionProvider extends ChangeNotifier {
  List<Transaction> _transactions = [];
  bool _isLoading = false;
  String? _error;
  final _storage = const FlutterSecureStorage();

  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchTransactionsFromApi() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final token = await _storage.read(key: 'auth_token');
      if (token == null) {
        throw Exception('Not authenticated');
      }

      final response = await http.get(
        Uri.parse('https://srv797850.hstgr.cloud/api/transactions'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      debugPrint('Transaction Response Status: ${response.statusCode}');
      debugPrint('Transaction Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Handle different API response formats
        List<dynamic> transactionData;

        if (data['transactions'] is List) {
          transactionData = data['transactions'] as List;
        } else if (data['data'] is List) {
          transactionData = data['data'] as List;
        } else if (data is List) {
          transactionData = data;
        } else {
          throw Exception('Invalid transaction data format');
        }

        _transactions =
            transactionData.map((item) {
              final Map<String, dynamic> jsonItem = Map<String, dynamic>.from(
                item,
              );

              // Convert API response to match consolidated Transaction model
              // Ensure all required fields are present
              if (!jsonItem.containsKey('title') &&
                  jsonItem.containsKey('description')) {
                jsonItem['title'] = jsonItem['description'];
              } else if (!jsonItem.containsKey('title')) {
                jsonItem['title'] = 'Transaction';
              }

              if (!jsonItem.containsKey('category')) {
                jsonItem['category'] = 'General';
              }

              // Handle date conversion
              if (jsonItem.containsKey('date') && jsonItem['date'] is String) {
                try {
                  jsonItem['date'] = DateTime.parse(jsonItem['date']);
                } catch (e) {
                  jsonItem['date'] = DateTime.now();
                }
              } else if (!jsonItem.containsKey('date')) {
                jsonItem['date'] = DateTime.now();
              }

              return Transaction.fromJson(jsonItem);
            }).toList();

        _isLoading = false;
        _error = null;
        notifyListeners();
      } else if (response.statusCode == 401) {
        // Token expired
        _error = 'Authentication expired. Please log in again.';
        _isLoading = false;
        notifyListeners();
        throw Exception('Authentication expired');
      } else {
        _error = 'Failed to load transactions: ${response.statusCode}';
        _isLoading = false;
        notifyListeners();
        throw Exception('Failed to load transactions');
      }
    } catch (e) {
      _error = 'Error: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      debugPrint('Transaction fetch error: $e');
    }
  }

  List<Transaction> get transactions => _transactions;

  double get totalBalance {
    return _transactions.fold(
      0,
      (sum, transaction) => sum + transaction.amount,
    );
  }

  double get totalIncome {
    return _transactions
        .where((transaction) => transaction.amount > 0)
        .fold(0, (sum, transaction) => sum + transaction.amount);
  }

  double get totalExpenses {
    return _transactions
        .where((transaction) => transaction.amount < 0)
        .fold(0, (sum, transaction) => sum + transaction.amount.abs());
  }

  Future<bool> addTransaction(Transaction transaction) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final token = await _storage.read(key: 'auth_token');
      if (token == null) {
        throw Exception('Not authenticated');
      }

      final response = await http.post(
        Uri.parse('https://srv797850.hstgr.cloud/api/transactions'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(transaction.toJson()),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        // Successfully added
        _transactions.add(transaction);
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = 'Failed to add transaction: ${response.statusCode}';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Error: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteTransaction(String transactionId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final token = await _storage.read(key: 'auth_token');
      if (token == null) {
        throw Exception('Not authenticated');
      }

      final response = await http.delete(
        Uri.parse(
          'https://srv797850.hstgr.cloud/api/transactions/$transactionId',
        ),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        _transactions.removeWhere((t) => t.id == transactionId);
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = 'Failed to delete transaction: ${response.statusCode}';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Error: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}

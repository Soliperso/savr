import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TransactionProvider extends ChangeNotifier {
  List<Map<String, dynamic>> _transactions = [];
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
        if (data['transactions'] is List) {
          _transactions = List<Map<String, dynamic>>.from(data['transactions']);
        } else if (data['data'] is List) {
          _transactions = List<Map<String, dynamic>>.from(data['data']);
        } else if (data is List) {
          _transactions = List<Map<String, dynamic>>.from(data);
        } else {
          throw Exception('Invalid transaction data format');
        }
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

  List<Map<String, dynamic>> get transactions => _transactions;

  double get totalBalance {
    return _transactions.fold(
      0,
      (sum, transaction) =>
          sum + (double.tryParse(transaction['amount'].toString()) ?? 0),
    );
  }

  double get totalIncome {
    return _transactions
        .where(
          (transaction) =>
              (double.tryParse(transaction['amount'].toString()) ?? 0) > 0,
        )
        .fold(
          0,
          (sum, transaction) =>
              sum + (double.tryParse(transaction['amount'].toString()) ?? 0),
        );
  }

  double get totalExpenses {
    return _transactions
        .where(
          (transaction) =>
              (double.tryParse(transaction['amount'].toString()) ?? 0) < 0,
        )
        .fold(
          0,
          (sum, transaction) =>
              sum +
              (double.tryParse(transaction['amount'].toString()) ?? 0).abs(),
        );
  }

  Future<bool> addTransaction(
    String title,
    double amount,
    String category,
    DateTime date,
    String description,
  ) async {
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
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'title': title,
          'amount': amount,
          'category': category,
          'date': DateFormat('yyyy-MM-dd').format(date),
          'description': description,
        }),
      );

      debugPrint('Add Transaction Response Status: ${response.statusCode}');
      debugPrint('Add Transaction Response Body: ${response.body}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        await fetchTransactionsFromApi(); // Refresh the list
        return true;
      } else {
        final data = jsonDecode(response.body);
        _error = data['message'] ?? 'Failed to add transaction';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Error: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      debugPrint('Add transaction error: $e');
      return false;
    }
  }

  Future<bool> deleteTransaction(String transactionId) async {
    _isLoading = true;
    _error = null;
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
        await fetchTransactionsFromApi(); // Refresh the list
        return true;
      } else {
        final data = jsonDecode(response.body);
        _error = data['message'] ?? 'Failed to delete transaction';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Error: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      debugPrint('Delete transaction error: $e');
      return false;
    }
  }

  Future<bool> updateTransaction(
    String transactionId,
    Map<String, dynamic> updates,
  ) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final token = await _storage.read(key: 'auth_token');
      if (token == null) {
        throw Exception('Not authenticated');
      }

      final response = await http.put(
        Uri.parse(
          'https://srv797850.hstgr.cloud/api/transactions/$transactionId',
        ),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(updates),
      );

      if (response.statusCode == 200) {
        await fetchTransactionsFromApi(); // Refresh the list
        return true;
      } else {
        final data = jsonDecode(response.body);
        _error = data['message'] ?? 'Failed to update transaction';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Error: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      debugPrint('Update transaction error: $e');
      return false;
    }
  }
}

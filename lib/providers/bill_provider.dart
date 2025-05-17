import 'dart:convert';
import 'dart:io'; // Add import for File
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:savr/models/bill.dart';
import 'package:savr/models/group.dart';
import 'package:savr/models/payment.dart';

class BillProvider extends ChangeNotifier {
  List<Group> _groups = [];
  List<Bill> _bills = [];
  bool _isLoading = false;
  String? _error;
  final _storage = const FlutterSecureStorage();

  List<Group> get groups => _groups;
  List<Bill> get bills => _bills;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Get all pending bills (not paid and with status not 'paid')
  List<Bill> get pendingBills =>
      _bills
          .where(
            (bill) =>
                !bill.paid &&
                (bill.status == 'pending' || bill.status == 'overdue'),
          )
          .toList();

  // Handle token retrieval
  Future<String?> _getValidToken() async {
    try {
      // Get token directly from secure storage, avoid unnecessary validation
      final token = await _storage.read(key: 'auth_token');
      if (token == null) {
        debugPrint("No auth token found in secure storage");
        _error = 'Not authenticated';
        return null;
      }

      // Log the token for debugging (partial for security)
      final tokenPreview =
          token.length > 10 ? "${token.substring(0, 10)}..." : token;
      debugPrint("Using token: $tokenPreview (${token.length} chars)");

      return token;
    } catch (e) {
      debugPrint('Error getting token: $e');
      _error = 'Authentication error: Please log in again.';
      notifyListeners();
      return null;
    }
  }

  // Constructor - initialize with dummy data but fetch from API
  BillProvider() {
    // Initialize with mock data
    _groups = [
      Group(
        id: 'g1',
        name: 'Apartment 304',
        members: ['John', 'Sarah', 'Mike'],
        description: 'Shared apartment expenses',
        color: 0xFF4CAF50,
        createdAt: DateTime.parse('2025-05-01'),
      ),
      Group(
        id: 'g2',
        name: 'Weekend Trip',
        members: ['Lisa', 'David', 'Sarah'],
        description: 'Beach vacation expenses',
        color: 0xFF2196F3,
        createdAt: DateTime.parse('2025-05-05'),
      ),
    ];

    // Initialize with mock bills data temporarily
    _initializeMockBills();

    // Fetch actual data from API
    _initializeData();
  }

  // Method to initialize mock bills for UI display while fetching real data
  void _initializeMockBills() {
    _bills = [
      Bill(
        id: '1',
        groupId: 'g1',
        title: 'Internet',
        description: 'Monthly internet bill',
        dueDate: DateTime.parse('2025-05-10'),
        amount: 40.0,
        splitWith: [],
        status: 'pending',
        paid: false,
        paidBy: const [],
        category: 'Utilities',
        paidAmount: 0.0,
        paymentHistory: [],
      ),
      Bill(
        id: '2',
        groupId: 'g1',
        title: 'Electricity',
        description: 'May electricity bill',
        dueDate: DateTime.parse('2025-05-12'),
        amount: 60.0,
        splitWith: [],
        status: 'pending',
        paid: false,
        paidBy: const [],
        category: 'Utilities',
        paidAmount: 0.0,
        paymentHistory: [],
      ),
      Bill(
        id: '3',
        groupId: 'g1',
        title: 'Rent',
        description: '',
        dueDate: DateTime.parse('2025-05-15'),
        amount: 800.0,
        splitWith: [],
        status: 'pending',
        paid: false,
        paidBy: const [],
        category: 'Rent',
        paidAmount: 0.0,
        paymentHistory: [],
      ),
      Bill(
        id: '4',
        groupId: 'g2',
        title: 'Hotel',
        description: '',
        dueDate: DateTime.parse('2025-05-05'),
        amount: 250.0,
        splitWith: [],
        status: 'overdue',
        paid: false,
        paidBy: const [],
        category: 'Travel',
        paidAmount: 0.0,
        paymentHistory: [],
      ),
      Bill(
        id: '5',
        groupId: 'g2',
        title: 'Car Rental',
        description: '',
        dueDate: DateTime.parse('2025-05-01'),
        amount: 150.0,
        splitWith: [],
        status: 'paid',
        paid: true,
        paidBy: ['Lisa', 'David'],
        category: 'Transportation',
        paidAmount: 150.0,
        paymentHistory: [
          Payment(
            id: 'p1',
            amount: 150.0,
            date: DateTime.parse('2025-05-01'),
            method: 'Credit Card',
            paidBy: 'Lisa',
          ),
        ],
      ),
    ];
  }

  // Initialize data by fetching from API
  Future<void> _initializeData() async {
    // Use a delay to allow UI to render first with mock data
    await Future.delayed(const Duration(milliseconds: 100));

    // Check authentication status before making API calls
    _verifyAuthentication();

    // Fetch actual bills and groups
    fetchBills();
    fetchGroups();
  }

  // Verify authentication status before making API calls
  Future<void> _verifyAuthentication() async {
    try {
      // Use _getValidToken for consistency across all authentication checks
      final token = await _getValidToken();
      if (token == null) {
        debugPrint("No valid token available during initialization");
        _error = 'Please log in to access your bills and groups.';
        notifyListeners();
        return;
      }

      debugPrint("Token validation successful during initialization");
    } catch (e) {
      debugPrint("Error verifying authentication: $e");
      _error = 'Authentication error: Please restart the app or log in again.';
      notifyListeners();
    }
  }

  Future<void> fetchGroups() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final token = await _getValidToken();
      if (token == null) {
        throw Exception('Not authenticated');
      }

      final response = await http.get(
        Uri.parse('https://srv797850.hstgr.cloud/api/groups'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      debugPrint('Groups Response Status: ${response.statusCode}');
      debugPrint('Groups Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> groupsData;

        // Handle different API response formats
        if (data['groups'] is List) {
          groupsData = data['groups'] as List<dynamic>;
        } else if (data['data'] is List) {
          groupsData = data['data'] as List<dynamic>;
        } else if (data is List) {
          groupsData = data;
        } else {
          throw Exception('Invalid groups data format');
        }

        _groups =
            groupsData.map((groupData) {
              return Group(
                id: groupData['id'].toString(),
                name: groupData['name'],
                members:
                    (groupData['members'] as List<dynamic>?)
                        ?.map((m) => m['name'].toString())
                        .toList() ??
                    [],
                description: groupData['description'] ?? '',
                color:
                    int.tryParse(groupData['color'] ?? '0xFF4CAF50') ??
                    0xFF4CAF50,
                createdAt:
                    DateTime.tryParse(groupData['created_at']) ??
                    DateTime.now(),
              );
            }).toList();
      } else {
        _error = 'Failed to load groups';
      }
    } catch (e) {
      _error = 'Error: $e';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchBills() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      debugPrint("Attempting to fetch bills...");

      // Use _getValidToken for consistency across all API requests
      final token = await _getValidToken();
      if (token == null) {
        debugPrint("No valid token available to fetch bills");
        _error = 'Authentication required. Please log in.';
        _isLoading = false;
        notifyListeners();
        return;
      }

      final url = 'https://srv797850.hstgr.cloud/api/bills';
      debugPrint("Fetching bills from: $url");

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      debugPrint('Bills Response Status: ${response.statusCode}');
      // Only print first 100 chars of response body to avoid log flooding
      if (response.body.isNotEmpty) {
        final preview =
            response.body.length > 100
                ? response.body.substring(0, 100) + "..."
                : response.body;
        debugPrint('Bills Response Body (preview): $preview');
      }

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> billsData;

        // Handle different API response formats
        if (data['bills'] is List) {
          billsData = data['bills'] as List<dynamic>;
        } else if (data['data'] is List) {
          billsData = data['data'] as List<dynamic>;
        } else if (data is List) {
          billsData = data;
        } else {
          throw Exception('Invalid bills data format');
        }

        _bills =
            billsData.map((billData) {
              return Bill(
                id: billData['id'].toString(),
                groupId: billData['group_id'].toString(),
                title: billData['title'],
                description: billData['description'] ?? '',
                dueDate:
                    DateTime.tryParse(billData['due_date']) ?? DateTime.now(),
                amount: double.tryParse(billData['amount'].toString()) ?? 0.0,
                splitWith:
                    (billData['split_with'] as List<dynamic>?)
                        ?.map((m) => m.toString())
                        .toList() ??
                    [],
                status: billData['status'] ?? 'pending',
                paid: billData['paid'] == true || billData['paid'] == 1,
                paidBy:
                    (billData['paid_by'] as List<dynamic>?)
                        ?.map((p) => p.toString())
                        .toList() ??
                    const [],
                category: billData['category'] ?? 'Other',
                paidAmount:
                    double.tryParse(billData['paid_amount'].toString()) ?? 0.0,
                paymentHistory: _parsePaymentHistory(
                  billData['payment_history'],
                ),
                customSplits: _parseCustomSplits(billData['custom_splits']),
              );
            }).toList();
      } else if (response.statusCode == 401) {
        _error = 'Authentication expired. Please log in again.';
        // Clear the invalid token
        await _storage.delete(key: 'auth_token');
        debugPrint("Auth token cleared due to 401 error");
      } else {
        _error = 'Failed to load bills: ${response.statusCode}';
      }
    } catch (e) {
      _error = 'Error fetching bills: $e';
      debugPrint('Error fetching bills: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  List<Payment> _parsePaymentHistory(dynamic paymentData) {
    if (paymentData == null) return [];

    if (paymentData is List) {
      return paymentData.map((payment) {
        return Payment(
          id: payment['id'].toString(),
          amount: double.tryParse(payment['amount'].toString()) ?? 0.0,
          method: payment['method'] ?? 'Unknown',
          date: DateTime.tryParse(payment['date']) ?? DateTime.now(),
          paidBy: payment['paid_by'] ?? '',
        );
      }).toList();
    }
    return [];
  }

  Map<String, double>? _parseCustomSplits(dynamic splitsData) {
    if (splitsData == null) return null;

    if (splitsData is Map) {
      return Map<String, double>.from(
        splitsData.map(
          (key, value) => MapEntry(
            key.toString(),
            double.tryParse(value.toString()) ?? 0.0,
          ),
        ),
      );
    }
    return null;
  }

  Future<void> addGroup(Group group) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final token = await _getValidToken();
      if (token == null) {
        throw Exception('Not authenticated');
      }

      final response = await http.post(
        Uri.parse('https://srv797850.hstgr.cloud/api/groups'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'name': group.name,
          'description': group.description,
          'members': group.members,
          'color': group.color.toString(),
        }),
      );

      debugPrint('Add Group Response Status: ${response.statusCode}');
      debugPrint('Add Group Response Body: ${response.body}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final newGroup = Group(
          id: data['id'].toString(),
          name: data['name'],
          members:
              (data['members'] as List<dynamic>?)
                  ?.map((m) => m['name'].toString())
                  .toList() ??
              [],
          description: data['description'] ?? '',
          color: int.tryParse(data['color'] ?? '0xFF4CAF50') ?? 0xFF4CAF50,
          createdAt: DateTime.tryParse(data['created_at']) ?? DateTime.now(),
        );
        _groups.add(newGroup);
      } else if (response.statusCode == 401) {
        _error = 'Authentication expired. Please log in again.';
        throw Exception('Authentication expired');
      } else {
        _error = 'Failed to add group: ${response.statusCode}';
      }
    } catch (e) {
      _error = 'Error: $e';
      debugPrint('Error adding group: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> addBill(Bill bill) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final token = await _getValidToken();
      if (token == null) {
        throw Exception('Not authenticated');
      }

      final response = await http.post(
        Uri.parse('https://srv797850.hstgr.cloud/api/bills'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'group_id': bill.groupId,
          'title': bill.title,
          'description': bill.description,
          'due_date': bill.dueDate.toIso8601String(),
          'amount': bill.amount,
          'split_with': bill.splitWith,
          'status': bill.status,
          'paid': bill.paid,
          'paid_by': bill.paidBy,
          'category': bill.category,
          'paid_amount': bill.paidAmount,
          'custom_splits': bill.customSplits,
        }),
      );

      debugPrint('Add Bill Response Status: ${response.statusCode}');
      debugPrint('Add Bill Response Body: ${response.body}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final newBill = Bill(
          id: data['id'].toString(),
          groupId: data['group_id'].toString(),
          title: data['title'],
          description: data['description'] ?? '',
          dueDate: DateTime.tryParse(data['due_date']) ?? DateTime.now(),
          amount: double.tryParse(data['amount'].toString()) ?? 0.0,
          splitWith:
              (data['split_with'] as List<dynamic>?)
                  ?.map((m) => m.toString())
                  .toList() ??
              [],
          status: data['status'] ?? 'pending',
          paid: data['paid'] == true || data['paid'] == 1,
          paidBy:
              (data['paid_by'] as List<dynamic>?)
                  ?.map((p) => p.toString())
                  .toList() ??
              const [],
          category: data['category'] ?? 'Other',
          paidAmount: double.tryParse(data['paid_amount'].toString()) ?? 0.0,
          paymentHistory: _parsePaymentHistory(data['payment_history']),
          customSplits: _parseCustomSplits(data['custom_splits']),
        );
        _bills.add(newBill);
      } else if (response.statusCode == 401) {
        _error = 'Authentication expired. Please log in again.';
        throw Exception('Authentication expired');
      } else {
        _error = 'Failed to add bill: ${response.statusCode}';
      }
    } catch (e) {
      _error = 'Error: $e';
      debugPrint('Error adding bill: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> updateGroup(Group group) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final token = await _getValidToken();
      if (token == null) {
        throw Exception('Not authenticated');
      }

      final response = await http.put(
        Uri.parse('https://srv797850.hstgr.cloud/api/groups/${group.id}'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'name': group.name,
          'description': group.description,
          'members': group.members,
          'color': group.color.toString(),
        }),
      );

      debugPrint('Update Group Response Status: ${response.statusCode}');
      debugPrint('Update Group Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final updatedGroup = Group(
          id: data['id'].toString(),
          name: data['name'],
          members:
              (data['members'] as List<dynamic>?)
                  ?.map((m) => m['name'].toString())
                  .toList() ??
              [],
          description: data['description'] ?? '',
          color: int.tryParse(data['color'] ?? '0xFF4CAF50') ?? 0xFF4CAF50,
          createdAt: DateTime.tryParse(data['created_at']) ?? DateTime.now(),
        );

        final index = _groups.indexWhere((g) => g.id == group.id);
        if (index != -1) {
          _groups[index] = updatedGroup;
        }
      } else if (response.statusCode == 401) {
        _error = 'Authentication expired. Please log in again.';
        throw Exception('Authentication expired');
      } else {
        _error = 'Failed to update group: ${response.statusCode}';
      }
    } catch (e) {
      _error = 'Error: $e';
      debugPrint('Error updating group: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> updateBill(Bill bill) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final token = await _getValidToken();
      if (token == null) {
        throw Exception('Not authenticated');
      }

      final response = await http.put(
        Uri.parse('https://srv797850.hstgr.cloud/api/bills/${bill.id}'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'group_id': bill.groupId,
          'title': bill.title,
          'description': bill.description,
          'due_date': bill.dueDate.toIso8601String(),
          'amount': bill.amount,
          'split_with': bill.splitWith,
          'status': bill.status,
          'paid': bill.paid,
          'paid_by': bill.paidBy,
          'category': bill.category,
          'paid_amount': bill.paidAmount,
          'custom_splits': bill.customSplits,
        }),
      );

      debugPrint('Update Bill Response Status: ${response.statusCode}');
      debugPrint('Update Bill Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final updatedBill = Bill(
          id: data['id'].toString(),
          groupId: data['group_id'].toString(),
          title: data['title'],
          description: data['description'] ?? '',
          dueDate: DateTime.tryParse(data['due_date']) ?? DateTime.now(),
          amount: double.tryParse(data['amount'].toString()) ?? 0.0,
          splitWith:
              (data['split_with'] as List<dynamic>?)
                  ?.map((m) => m.toString())
                  .toList() ??
              [],
          status: data['status'] ?? 'pending',
          paid: data['paid'] == true || data['paid'] == 1,
          paidBy:
              (data['paid_by'] as List<dynamic>?)
                  ?.map((p) => p.toString())
                  .toList() ??
              const [],
          category: data['category'] ?? 'Other',
          paidAmount: double.tryParse(data['paid_amount'].toString()) ?? 0.0,
          paymentHistory: _parsePaymentHistory(data['payment_history']),
          customSplits: _parseCustomSplits(data['custom_splits']),
        );

        final index = _bills.indexWhere((b) => b.id == bill.id);
        if (index != -1) {
          _bills[index] = updatedBill;
        }
      } else if (response.statusCode == 401) {
        _error = 'Authentication expired. Please log in again.';
        throw Exception('Authentication expired');
      } else {
        _error = 'Failed to update bill: ${response.statusCode}';
      }
    } catch (e) {
      _error = 'Error: $e';
      debugPrint('Error updating bill: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> deleteGroup(String groupId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final token = await _getValidToken();
      if (token == null) {
        throw Exception('Not authenticated');
      }

      final response = await http.delete(
        Uri.parse('https://srv797850.hstgr.cloud/api/groups/$groupId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      debugPrint('Delete Group Response Status: ${response.statusCode}');
      debugPrint('Delete Group Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 204) {
        // Remove the group and all its bills
        _groups.removeWhere((group) => group.id == groupId);
        _bills.removeWhere((bill) => bill.groupId == groupId);
      } else if (response.statusCode == 401) {
        _error = 'Authentication expired. Please log in again.';
        throw Exception('Authentication expired');
      } else {
        _error = 'Failed to delete group: ${response.statusCode}';
      }
    } catch (e) {
      _error = 'Error: $e';
      debugPrint('Error deleting group: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> deleteBill(String billId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final token = await _getValidToken();
      if (token == null) {
        throw Exception('Not authenticated');
      }

      final response = await http.delete(
        Uri.parse('https://srv797850.hstgr.cloud/api/bills/$billId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      debugPrint('Delete Bill Response Status: ${response.statusCode}');
      debugPrint('Delete Bill Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 204) {
        _bills.removeWhere((bill) => bill.id == billId);
      } else if (response.statusCode == 401) {
        _error = 'Authentication expired. Please log in again.';
        throw Exception('Authentication expired');
      } else {
        _error = 'Failed to delete bill: ${response.statusCode}';
      }
    } catch (e) {
      _error = 'Error: $e';
      debugPrint('Error deleting bill: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  double get totalPendingAmount => _bills
      .where((bill) => bill.status == 'pending')
      .fold(0, (sum, bill) => sum + bill.amount);

  double get totalOverdueAmount => _bills
      .where((bill) => bill.status == 'overdue')
      .fold(0, (sum, bill) => sum + bill.amount);

  double getMyShare(Bill bill) {
    if (bill.customSplits?.isNotEmpty == true) {
      return bill.customSplits?['user'] ?? 0.0; // User's custom split amount
    }

    // Default to equal split
    int totalPeople = bill.splitWith.length + 1; // +1 for the user
    return bill.amount / totalPeople;
  }

  Bill? getBillById(String id) {
    return _bills.firstWhere(
      (bill) => bill.id == id,
      orElse:
          () => Bill(
            id: '',
            groupId: '',
            title: '',
            description: '',
            dueDate: DateTime.now(),
            amount: 0,
            splitWith: [],
            status: 'pending',
            paid: false,
            paidBy: const [],
          ),
    );
  }

  Group? getGroupById(String id) {
    try {
      return _groups.firstWhere((group) => group.id == id);
    } catch (e) {
      return null;
    }
  }

  List<Bill> getBillsByGroupId(String groupId) {
    return _bills.where((bill) => bill.groupId == groupId).toList();
  }

  Future<void> markAsPaid(String billId) async {
    final index = _bills.indexWhere((bill) => bill.id == billId);
    if (index != -1) {
      final bill = _bills[index];
      final updatedBill = bill.copyWith(
        paid: true,
        status: 'paid',
        paidBy: ['user'], // Add current user to paidBy list
        paidAmount: bill.amount,
      );

      _bills[index] = updatedBill;
      notifyListeners();

      // Update on server
      await updateBill(updatedBill);
    }
  }

  Future<void> addMemberToGroup(String groupId, String memberName) async {
    final groupIndex = _groups.indexWhere((group) => group.id == groupId);
    if (groupIndex != -1) {
      final group = _groups[groupIndex];
      if (!group.members.contains(memberName)) {
        final List<String> updatedMembers = List.from(group.members)
          ..add(memberName);
        final updatedGroup = group.copyWith(members: updatedMembers);

        _groups[groupIndex] = updatedGroup;
        notifyListeners();

        // Update on server
        await updateGroup(updatedGroup);
      }
    }
  }

  Future<void> addPayment(
    String billId,
    double amount,
    String method,
    DateTime date,
  ) async {
    final index = _bills.indexWhere((bill) => bill.id == billId);
    if (index != -1) {
      final bill = _bills[index];

      // Create new payment
      final payment = Payment(
        id:
            DateTime.now().millisecondsSinceEpoch
                .toString(), // Temporary local ID
        amount: amount,
        method: method,
        date: date,
        paidBy: 'user', // Current user
      );

      // Add payment to bill history and update paid amount
      List<Payment> updatedPaymentHistory = List.from(bill.paymentHistory ?? [])
        ..add(payment);
      double updatedPaidAmount = (bill.paidAmount ?? 0) + amount;
      bool isPaid = updatedPaidAmount >= bill.amount;

      // Update bill
      final updatedBill = bill.copyWith(
        paymentHistory: updatedPaymentHistory,
        paidAmount: updatedPaidAmount,
        paid: isPaid,
        status: isPaid ? 'paid' : bill.status,
        paidBy: isPaid ? (List.from(bill.paidBy)..add('user')) : bill.paidBy,
      );

      _bills[index] = updatedBill;
      notifyListeners();

      // Update on server
      await updateBill(updatedBill);
    }
  }

  Future<void> createGroup({
    required String name,
    required String description,
    required List<String> members,
    File? avatarFile,
  }) async {
    // Generate a temporary ID for the group
    final String tempId = 'temp_${DateTime.now().millisecondsSinceEpoch}';

    // Create a new Group object
    final group = Group(
      id: tempId,
      name: name,
      description: description,
      members: members,
      color: 0xFF4CAF50, // Default to green
      createdAt: DateTime.now(),
    );

    // Add the group using the existing addGroup method
    await addGroup(group);

    // Note: If avatarFile is provided, we would handle avatar upload here
    // but that would require additional API support
  }

  Bill addBillToGroup({
    required String groupId,
    required String title,
    required String description,
    required double amount,
    required DateTime dueDate,
    required List<String> splitWith,
    Map<String, double>? customSplits,
  }) {
    // Create new bill object
    final newBill = Bill(
      id:
          DateTime.now().millisecondsSinceEpoch
              .toString(), // Temporary local ID
      groupId: groupId,
      title: title,
      description: description,
      dueDate: dueDate,
      amount: amount,
      splitWith: splitWith,
      status: 'pending',
      paid: false,
      paidBy: const [],
      category: 'Other',
      paidAmount: 0.0,
      paymentHistory: [],
      customSplits: customSplits,
    );

    // Add bill to local list
    _bills.add(newBill);
    notifyListeners();

    // Submit to server in background
    addBill(newBill);

    return newBill;
  }
}

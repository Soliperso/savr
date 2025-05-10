import 'package:flutter/material.dart';
import '../features/bills/models/bill.dart';
import '../features/bills/models/bill_status.dart';
import '../features/bills/models/group.dart';

class BillProvider extends ChangeNotifier {
  final List<Group> _groups = [
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

  final List<Bill> _bills = [
    Bill(
      id: '1',
      groupId: 'g1',
      title: 'Internet',
      description: 'Monthly internet bill',
      dueDate: DateTime.parse('2025-05-10'),
      amount: 40.0,
      status: BillStatus.pending,
      splitWith: ['John', 'Sarah'],
      customSplits: {},
      paid: false,
      paidBy: const [],
    ),
    Bill(
      id: '2',
      groupId: 'g1',
      title: 'Electricity',
      description: 'May electricity bill',
      dueDate: DateTime.parse('2025-05-12'),
      amount: 60.0,
      status: BillStatus.pending,
      splitWith: ['John'],
      customSplits: {},
      paid: false,
      paidBy: const [],
    ),
    Bill(
      id: '3',
      groupId: 'g1',
      title: 'Rent',
      description: '',
      dueDate: DateTime.parse('2025-05-15'),
      amount: 800.0,
      status: BillStatus.pending,
      splitWith: ['John', 'Sarah', 'Mike'],
      paid: false,
      paidBy: const [],
    ),
    Bill(
      id: '4',
      groupId: 'g2',
      title: 'Hotel',
      description: '',
      dueDate: DateTime.parse('2025-05-05'),
      amount: 250.0,
      status: BillStatus.overdue,
      splitWith: ['Lisa', 'David', 'Sarah'],
      paid: false,
      paidBy: const [],
    ),
    Bill(
      id: '5',
      groupId: 'g2',
      title: 'Car Rental',
      description: '',
      dueDate: DateTime.parse('2025-05-01'),
      amount: 150.0,
      status: BillStatus.paid,
      splitWith: ['Lisa', 'David'],
      paid: true,
      paidBy: ['Lisa', 'David'],
    ),
  ];

  List<Bill> get bills => _bills;
  List<Group> get groups => _groups;

  List<Bill> get pendingBills =>
      _bills.where((bill) => bill.status == BillStatus.pending).toList();

  List<Bill> get overdueBills =>
      _bills.where((bill) => bill.status == BillStatus.overdue).toList();

  List<Bill> get paidBills => _bills.where((bill) => bill.paid).toList();

  List<Bill> getBillsByGroupId(String groupId) {
    return _bills.where((bill) => bill.groupId == groupId).toList();
  }

  Group? getGroupById(String id) {
    return _groups.firstWhere(
      (group) => group.id == id,
      orElse:
          () => Group(
            id: '',
            name: '',
            description: '',
            members: const [],
            color: 0xFF000000,
            createdAt: DateTime.now(),
          ),
    );
  }

  double get totalPendingAmount =>
      pendingBills.fold(0, (sum, bill) => sum + bill.amount);

  double get totalOverdueAmount =>
      overdueBills.fold(0, (sum, bill) => sum + bill.amount);

  Bill addBillToGroup({
    required String groupId,
    required String title,
    required String description,
    required double amount,
    required DateTime dueDate,
    required List<String> splitWith,
    Map<String, double>? customSplits,
  }) {
    // Generate a unique ID (in a real app, this would come from the backend)
    String id = DateTime.now().millisecondsSinceEpoch.toString();

    // Determine status based on due date
    BillStatus status =
        dueDate.isAfter(DateTime.now())
            ? BillStatus.pending
            : BillStatus.overdue;

    final newBill = Bill(
      id: id,
      groupId: groupId,
      title: title,
      description: description,
      dueDate: dueDate,
      amount: amount,
      status: status,
      splitWith: splitWith,
      customSplits: customSplits ?? {},
      paid: false,
      paidBy: const [],
    );

    _bills.insert(0, newBill);
    notifyListeners();

    return newBill;
  }

  Group createGroup({
    required String name,
    required String description,
    required List<String> members,
  }) {
    final groupId = 'g${DateTime.now().millisecondsSinceEpoch}';
    final newGroup = Group(
      id: groupId,
      name: name,
      members: members,
      description: description,
      color: _getRandomColor(),
      createdAt: DateTime.now(),
    );

    _groups.insert(0, newGroup);
    notifyListeners();
    return newGroup;
  }

  void addMemberToGroup(String groupId, String member) {
    final index = _groups.indexWhere((group) => group.id == groupId);
    if (index != -1) {
      final currentGroup = _groups[index];
      final members = List<String>.from(currentGroup.members);
      if (!members.contains(member)) {
        members.add(member);
        _groups[index] = currentGroup.copyWith(members: members);
        notifyListeners();
      }
    }
  }

  void removeMemberFromGroup(String groupId, String member) {
    final index = _groups.indexWhere((group) => group.id == groupId);
    if (index != -1) {
      final currentGroup = _groups[index];
      final members = List<String>.from(currentGroup.members);
      if (members.contains(member)) {
        members.remove(member);
        _groups[index] = currentGroup.copyWith(members: members);
        notifyListeners();
      }
    }
  }

  void deleteGroup(String groupId) {
    _groups.removeWhere((group) => group.id == groupId);
    _bills.removeWhere((bill) => bill.groupId == groupId);
    notifyListeners();
  }

  void markAsPaid(String id) {
    final index = _bills.indexWhere((bill) => bill.id == id);
    if (index != -1) {
      _bills[index] = _bills[index].copyWith(
        status: BillStatus.paid,
        paid: true,
      );
      notifyListeners();
    }
  }

  void markBillPaidByMember(String billId, String member) {
    final index = _bills.indexWhere((bill) => bill.id == billId);
    if (index != -1) {
      final currentBill = _bills[index];
      final paidBy = List<String>.from(currentBill.paidBy);
      if (!paidBy.contains(member)) {
        paidBy.add(member);

        final allPaid = currentBill.splitWith.every(
          (person) => paidBy.contains(person),
        );

        _bills[index] = currentBill.copyWith(
          paidBy: paidBy,
          paid: allPaid,
          status: allPaid ? BillStatus.paid : currentBill.status,
        );
        notifyListeners();
      }
    }
  }

  void deleteBill(String id) {
    _bills.removeWhere((bill) => bill.id == id);
    notifyListeners();
  }

  double getMyShare(Bill bill) {
    if (bill.customSplits.isNotEmpty) {
      return bill.customSplits['user'] ?? 0.0; // User's custom split amount
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
            status: BillStatus.pending,
            splitWith: const [],
          ),
    );
  }

  int _getRandomColor() {
    final colors = [
      0xFF4CAF50, // Green
      0xFF2196F3, // Blue
      0xFFFFC107, // Amber
      0xFFE91E63, // Pink
      0xFF9C27B0, // Purple
      0xFFFF5722, // Deep Orange
    ];

    return colors[_groups.length % colors.length];
  }
}

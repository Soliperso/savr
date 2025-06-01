import 'dart:async'; // Added for Timer

import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

// Placeholder for the current user's ID - replace with actual auth logic
const String _currentUserId = 'user123';
// Add a map for mock user data
final Map<String, Map<String, String?>> _mockUsersDb = {
  // Changed to String? for imageUrl
  _currentUserId: {
    'name': 'You',
    'imageUrl': '''https://example.com/currentUser.jpg''',
  }, // Example with image
  'user456': {
    'name': 'Ahmed Chebli',
    'imageUrl': '''https://example.com/user456.jpg''',
  },
  'supportAgent1': {
    'name': 'Support Agent',
    'imageUrl': null,
  }, // Example without image
  'system': {'name': 'System', 'imageUrl': null},
  'exampleUser1': {
    'name': 'Alice Wonderland',
    'imageUrl': '''https://example.com/alice.jpg''',
  },
  'exampleUser2': {'name': 'Bob The Builder', 'imageUrl': null},
};

enum MessageStatus { sending, sent, delivered, read, failed }

class ChatMessage {
  final String id;
  final String text;
  final String userId;
  final DateTime timestamp;
  MessageStatus status;
  final String? userName; // Added userName
  final String? userImageUrl; // Added userImageUrl

  ChatMessage({
    required this.id,
    required this.text,
    required this.userId,
    required this.timestamp,
    this.status = MessageStatus.sending,
    this.userName, // Added
    this.userImageUrl, // Added
  });
}

class ChatProvider with ChangeNotifier {
  final Map<String, List<ChatMessage>> _billMessages = {};
  List<ChatMessage> _currentBillMessages = [];
  bool _isLoading = false;
  String? _currentBillId;

  // Typing status state
  final Map<String, Set<String>> _typingUsersByBillId = {};
  Timer? _typingTimer;

  List<ChatMessage> get messages => _currentBillMessages;
  bool get isLoading => _isLoading;
  Set<String> get typingUsers {
    if (_currentBillId == null) return {};
    return _typingUsersByBillId[_currentBillId] ?? {};
  }

  // Helper to get user data
  Map<String, String?> getUserDetails(String userId) {
    final user = _mockUsersDb[userId];
    if (user != null) {
      return {'name': user['name'], 'imageUrl': user['imageUrl']};
    }
    return {
      'name': 'Unknown User',
      'imageUrl': null,
    }; // Default if user not found
  }

  // Mock data source - updated to include userName and userImageUrl by fetching from _mockUsersDb
  Map<String, List<ChatMessage>> get _mockMessagesDb {
    // Note: This is now a getter to dynamically build messages with user details
    // This is a simplified approach. In a real app, user details might be part of the message data from backend.
    return {
      'bill_123': [
        ChatMessage(
          id: const Uuid().v4(),
          text: 'Welcome to the chat for Bill 123!',
          userId: 'system',
          userName: getUserDetails('system')['name'],
          userImageUrl: getUserDetails('system')['imageUrl'],
          timestamp: DateTime.now().subtract(const Duration(minutes: 10)),
          status: MessageStatus.delivered,
        ),
        ChatMessage(
          id: const Uuid().v4(),
          text: 'I have a question about this bill.',
          userId: _currentUserId,
          userName: getUserDetails(_currentUserId)['name'],
          userImageUrl: getUserDetails(_currentUserId)['imageUrl'],
          timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
          status: MessageStatus.read,
        ),
        ChatMessage(
          id: const Uuid().v4(),
          text: 'Sure, what is it?',
          userId: 'supportAgent1',
          userName: getUserDetails('supportAgent1')['name'],
          userImageUrl: getUserDetails('supportAgent1')['imageUrl'],
          timestamp: DateTime.now().subtract(const Duration(minutes: 4)),
          status: MessageStatus.delivered,
        ),
      ],
      'bill_456': [
        ChatMessage(
          id: const Uuid().v4(),
          text: 'Discussion for Bill 456.',
          userId: 'system',
          userName: getUserDetails('system')['name'],
          userImageUrl: getUserDetails('system')['imageUrl'],
          timestamp: DateTime.now().subtract(const Duration(minutes: 8)),
          status: MessageStatus.delivered,
        ),
      ],
    };
  }

  Future<void> loadMessages(String billId) async {
    if (_currentBillId == billId && _currentBillMessages.isNotEmpty) {
      // Already loaded and for the same bill
      // Potentially add logic here to check for new messages if implementing real-time updates
      return;
    }
    _currentBillId = billId;
    _isLoading = true;
    notifyListeners();

    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    if (_billMessages.containsKey(billId)) {
      _currentBillMessages = List.from(_billMessages[billId]!);
      // Ensure cached messages also have user details if they were added later
      // This is a simple refresh, a more robust solution might involve updating cached items
      // or ensuring they are always stored with full details.
      _currentBillMessages =
          _currentBillMessages.map((msg) {
            final userDetails = getUserDetails(msg.userId);
            return ChatMessage(
              id: msg.id,
              text: msg.text,
              userId: msg.userId,
              timestamp: msg.timestamp,
              status: msg.status,
              userName: userDetails['name'],
              userImageUrl: userDetails['imageUrl'],
            );
          }).toList();
    } else {
      // Try to load from mock DB if not in memory
      _currentBillMessages = List.from(_mockMessagesDb[billId] ?? []);
      _billMessages[billId] = List.from(_currentBillMessages); // Cache it
    }

    _currentBillMessages.sort(
      (a, b) => b.timestamp.compareTo(a.timestamp),
    ); // Newest first for reverse list display

    _isLoading = false;
    notifyListeners();
  }

  Future<void> sendMessage(String billId, String text, String userId) async {
    if (text.trim().isEmpty) return;
    final userDetails = getUserDetails(userId);
    final newMessage = ChatMessage(
      id: const Uuid().v4(),
      text: text,
      userId: userId,
      userName: userDetails['name'],
      userImageUrl: userDetails['imageUrl'],
      timestamp: DateTime.now(),
      status: MessageStatus.sending, // Initial status
    );

    // Add to the local cache
    if (!_billMessages.containsKey(billId)) {
      _billMessages[billId] = [];
    }
    _billMessages[billId]!.insert(0, newMessage); // Add to top for newest first

    // If this is the currently viewed bill, update the live list
    if (_currentBillId == billId) {
      _currentBillMessages.insert(0, newMessage);
    }
    notifyListeners();

    // Simulate message sending and status updates
    if (userId == _currentUserId) {
      Future.delayed(const Duration(milliseconds: 500), () {
        updateMessageStatus(billId, newMessage.id, MessageStatus.sent);
        // Simulate delivery after another second
        Future.delayed(const Duration(seconds: 1), () {
          updateMessageStatus(billId, newMessage.id, MessageStatus.delivered);
          // Simulate read after some more time if the other user is "active"
          // This is a very basic simulation
          if (_typingUsersByBillId[billId]?.isNotEmpty ?? false) {
            Future.delayed(const Duration(seconds: 2), () {
              updateMessageStatus(billId, newMessage.id, MessageStatus.read);
            });
          }
        });
      });
    }
    // TODO: Add logic to send message to a backend service
  }

  void updateMessageStatus(
    String billId,
    String messageId,
    MessageStatus newStatus,
  ) {
    final billMessageList = _billMessages[billId];
    if (billMessageList != null) {
      final messageIndex = billMessageList.indexWhere(
        (msg) => msg.id == messageId,
      );
      if (messageIndex != -1) {
        billMessageList[messageIndex].status = newStatus;
        if (_currentBillId == billId) {
          // Also update the live list if it's the current bill
          final liveMessageIndex = _currentBillMessages.indexWhere(
            (msg) => msg.id == messageId,
          );
          if (liveMessageIndex != -1) {
            _currentBillMessages[liveMessageIndex].status = newStatus;
          }
        }
        notifyListeners();
      }
    }
  }

  void userStartedTyping(String billId, String userId) {
    if (!_typingUsersByBillId.containsKey(billId)) {
      _typingUsersByBillId[billId] = {};
    }
    _typingUsersByBillId[billId]!.add(userId);
    notifyListeners();

    // Simulate other user typing for a few seconds for demo
    if (userId != _currentUserId) {
      Future.delayed(const Duration(seconds: 3), () {
        userStoppedTyping(billId, userId);
      });
    }
  }

  void userStoppedTyping(String billId, String userId) {
    _typingUsersByBillId[billId]?.remove(userId);
    if (_typingUsersByBillId[billId]?.isEmpty ?? false) {
      _typingUsersByBillId.remove(billId);
    }
    notifyListeners();
  }

  // Call this when the current user types in the input field
  void currentUsersTypingActivity(String billId, String text) {
    _typingTimer?.cancel();
    if (text.isNotEmpty) {
      if (!(_typingUsersByBillId[_currentBillId]?.contains(_currentUserId) ??
          false)) {
        userStartedTyping(billId, _currentUserId);
      }
      _typingTimer = Timer(const Duration(seconds: 2), () {
        userStoppedTyping(billId, _currentUserId);
      });
    } else {
      userStoppedTyping(billId, _currentUserId);
    }
  }

  // Optional: Method to clear messages when leaving a chat or logging out
  void clearChatData() {
    _billMessages.clear();
    _currentBillMessages.clear();
    _currentBillId = null;
    notifyListeners();
  }
}

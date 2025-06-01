import 'dart:async'; // Added for Timer

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../providers/chat_provider.dart'; // Corrected import path

// Placeholder for the current user's ID - replace with actual auth logic
const String _currentUserId = 'user123';
const String _otherUserId = 'user456'; // For example messages

class ChatBubbleClipper extends CustomClipper<Path> {
  final bool isMe;
  final double radius;
  final double tailSize;

  ChatBubbleClipper({
    required this.isMe,
    this.radius = 12.0,
    this.tailSize = 10.0,
  });

  @override
  Path getClip(Size size) {
    final path = Path();
    final double r = radius; // Corner radius
    final double t = tailSize; // How far the tail's base extends

    if (isMe) {
      // Outgoing message: Tail bottom-right. Rounded TL, TR, BL.
      path.moveTo(r, 0); // Start after top-left arc: (r,0)

      path.lineTo(size.width - r, 0); // Top edge: (width-r, 0)
      path.arcToPoint(
        Offset(size.width, r),
        radius: Radius.circular(r),
      ); // Top-right arc: (width, r)

      // Right edge leading to tail
      path.lineTo(size.width, size.height - t); // Point (width, height - t)
      // Tail itself (sharp, pointing to bottom-right corner)
      path.lineTo(size.width, size.height); // Tip of tail at (width, height)
      path.lineTo(
        size.width - t,
        size.height,
      ); // Point (width - t, height) on bottom edge

      path.lineTo(r, size.height); // Bottom edge: (r, height)
      path.arcToPoint(
        Offset(0, size.height - r),
        radius: Radius.circular(r),
      ); // Bottom-left arc: (0, height-r)

      path.lineTo(0, r); // Left edge: (0,r)
      path.arcToPoint(
        Offset(r, 0),
        radius: Radius.circular(r),
      ); // Top-left arc, completes loop to (r,0)
    } else {
      // Incoming message: Tail bottom-left. Rounded TL, TR, BR.
      path.moveTo(r, 0); // Start after top-left arc
      path.lineTo(size.width - r, 0); // Top edge
      path.arcToPoint(
        Offset(size.width, r),
        radius: Radius.circular(r), // Top-right corner
      );
      path.lineTo(size.width, size.height - r); // Right edge
      path.arcToPoint(
        Offset(size.width - r, size.height),
        radius: Radius.circular(r), // Bottom-right corner
      );
      path.lineTo(
        t, // Horizontal position of the tail's inner base point (from left)
        size.height,
      ); // Bottom edge, to the start of the tail base
      path.lineTo(
        0,
        size.height,
      ); // Tip of the tail (bottom-left point of the bubble)
      path.lineTo(
        0,
        r,
      ); // Left edge (straight part of the tail side, using radius for y-coordinate)
      path.arcToPoint(
        Offset(r, 0),
        radius: Radius.circular(r), // Top-left corner
      );
    }

    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant ChatBubbleClipper oldClipper) {
    return oldClipper.isMe != isMe ||
        oldClipper.radius != radius ||
        oldClipper.tailSize != tailSize;
  }
}

class ChatScreen extends StatefulWidget {
  final String billId;
  final String billName; // Add billName

  const ChatScreen({
    super.key,
    required this.billId,
    required this.billName,
  }); // Update constructor

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  Timer? _typingIndicatorTimer;
  ChatProvider? _chatProvider; // Make nullable
  VoidCallback? _messageControllerListenerCallback; // Make nullable

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _chatProvider = Provider.of<ChatProvider>(context, listen: false);
        _chatProvider!.loadMessages(
          widget.billId,
        ); // Use ! as it's assigned above
        _chatProvider!.addListener(_scrollToBottom);

        _messageControllerListenerCallback = () {
          if (mounted && _chatProvider != null) {
            _chatProvider!.currentUsersTypingActivity(
              widget.billId,
              _messageController.text,
            );
          }
        };
        _messageController.addListener(_messageControllerListenerCallback!);
      }
    });
  }

  @override
  void dispose() {
    if (_chatProvider != null) {
      _chatProvider!.removeListener(_scrollToBottom);
      if (_messageControllerListenerCallback != null) {
        _messageController.removeListener(_messageControllerListenerCallback!);
      }
      if (_chatProvider!.typingUsers.contains(_currentUserId)) {
        _chatProvider!.userStoppedTyping(widget.billId, _currentUserId);
      }
    }
    _messageController.dispose();
    _scrollController.dispose();
    _typingIndicatorTimer?.cancel();
    super.dispose();
  }

  void _scrollToBottom() {
    // Scroll to bottom when new messages are added
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController
            .position
            .minScrollExtent, // Use minScrollExtent because reverse is true
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _sendMessage() {
    // Removed ChatProvider argument, will use _chatProvider
    if (_messageController.text.isNotEmpty && _chatProvider != null) {
      _chatProvider!.sendMessage(
        widget.billId,
        _messageController.text,
        _currentUserId,
      );
      _messageController.clear();
      _chatProvider!.userStoppedTyping(widget.billId, _currentUserId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor:
          isDarkMode ? const Color(0xFF1C1C1E) : const Color(0xFFF2F2F7),
      appBar: AppBar(
        title: Text(
          widget.billName,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: isDarkMode ? Colors.white : Colors.black87,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        iconTheme: IconThemeData(
          color: isDarkMode ? Colors.white : Theme.of(context).primaryColor,
        ),
      ),
      body: Consumer<ChatProvider>(
        builder: (context, chatProvider, child) {
          // This chatProvider from Consumer is the source of truth for UI building.
          // _chatProvider instance is used for imperative calls.
          if (_chatProvider == null && mounted) {
            // If _chatProvider hasn't been initialized by addPostFrameCallback yet,
            // but the Consumer has a valid provider, we can assign it here.
            // This is a fallback, ideally addPostFrameCallback handles it.
            // Or, ensure that operations in initState that depend on _chatProvider
            // are also safe if it's null initially.
            // For now, the primary initialization is in addPostFrameCallback.
          }

          return Column(
            children: [
              Expanded(
                child:
                    chatProvider.isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : chatProvider.messages.isEmpty &&
                            !(chatProvider.typingUsers.isNotEmpty &&
                                chatProvider.typingUsers.first !=
                                    _currentUserId)
                        ? _buildExampleChat()
                        : ListView.builder(
                          controller: _scrollController,
                          padding: EdgeInsets.symmetric(
                            horizontal: 12.w,
                            vertical: 16.h,
                          ),
                          reverse: true,
                          itemCount: chatProvider.messages.length,
                          itemBuilder: (context, index) {
                            final message = chatProvider.messages[index];
                            return _ChatMessageBubble(
                              message: message,
                              currentUserId: _currentUserId,
                            );
                          },
                        ),
              ),
              // Typing indicator
              if (chatProvider.typingUsers.isNotEmpty &&
                  (chatProvider.typingUsers.length > 1 ||
                      chatProvider.typingUsers.first != _currentUserId))
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 4.h,
                  ),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      _getTypingIndicatorText(chatProvider.typingUsers),
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12.sp,
                        color: Colors.grey[600],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ),
              _MessageInputField(
                controller: _messageController,
                onSend: _sendMessage,
              ),
            ],
          );
        },
      ),
    );
  }
}

String _getTypingIndicatorText(Set<String> typingUserIds) {
  if (typingUserIds.isEmpty) return '';
  // In a real app, you'd resolve user IDs to names.
  // For now, we'll just show generic text if it's not the current user.
  final otherTypingUsers =
      typingUserIds.where((id) => id != _currentUserId).toList();
  if (otherTypingUsers.isEmpty)
    return ''; // Don't show if only current user is typing

  if (otherTypingUsers.length == 1) {
    // Replace with actual name if available: e.g., "${chatProvider.getUserName(otherTypingUsers.first)} is typing..."
    return "Someone is typing...";
  }
  return "Multiple people are typing...";
}

Widget _buildExampleChat() {
  final now = DateTime.now();
  final exampleMessages = [
    ChatMessage(
      id: 'example1',
      text: 'Hey, did everyone see the electricity bill?',
      timestamp: now.subtract(const Duration(minutes: 5)),
      userId: _otherUserId,
      status: MessageStatus.read, // Example status
    ),
    ChatMessage(
      id: 'example2',
      text: 'Yeah, I saw it. Looks a bit high this month!',
      timestamp: now.subtract(const Duration(minutes: 4)),
      userId: _currentUserId,
      status: MessageStatus.delivered, // Example status
    ),
    ChatMessage(
      id: 'example3',
      text:
          'Maybe we left the AC on too much?  गर्मी बहुत है! (It\'s very hot!)',
      timestamp: now.subtract(const Duration(minutes: 3)),
      userId: _otherUserId,
      status: MessageStatus.delivered,
    ),
    ChatMessage(
      id: 'example4',
      text: 'Possibly. We should discuss how to split it.',
      timestamp: now.subtract(const Duration(minutes: 2)),
      userId: _currentUserId,
      status: MessageStatus.sent,
    ),
  ];

  return Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Text(
        "Start discussing this bill!",
        style: TextStyle(
          fontSize: 18.sp,
          fontWeight: FontWeight.w500,
          color: Colors.grey.shade600,
        ),
        textAlign: TextAlign.center,
      ),
      SizedBox(height: 10.h),
      Text(
        "Here's how your chat might look:",
        style: TextStyle(fontSize: 14.sp, color: Colors.grey.shade500),
        textAlign: TextAlign.center,
      ),
      SizedBox(height: 20.h),
      Expanded(
        child: ListView(
          reverse: true, // To match the real chat behavior
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 16.h),
          children:
              exampleMessages
                  .map(
                    (msg) => _ChatMessageBubble(
                      message: msg,
                      currentUserId: _currentUserId,
                    ),
                  )
                  .toList(),
        ),
      ),
    ],
  );
}

// ChatMessage class is now defined in chat_provider.dart.

class _ChatMessageBubble extends StatelessWidget {
  final ChatMessage message;
  final String currentUserId;

  const _ChatMessageBubble({
    required this.message,
    required this.currentUserId,
  });

  Widget _buildStatusIcon(
    MessageStatus status,
    bool isMe,
    BuildContext context,
  ) {
    if (!isMe)
      return const SizedBox.shrink(); // Only show status for own messages

    IconData iconData;
    Color iconColor = Colors.grey.shade500;
    double iconSize = 12.sp;

    switch (status) {
      case MessageStatus.sending:
        iconData = Icons.access_time_filled_rounded;
        break;
      case MessageStatus.sent:
        iconData = Icons.done_rounded;
        break;
      case MessageStatus.delivered:
        iconData = Icons.done_all_rounded;
        break;
      case MessageStatus.read:
        iconData = Icons.done_all_rounded;
        iconColor =
            Theme.of(context).primaryColorLight; // Or a distinct color for read
        break;
      case MessageStatus.failed:
        iconData = Icons.error_outline_rounded;
        iconColor = Colors.redAccent;
        break;
    }
    return Icon(iconData, size: iconSize, color: iconColor);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final isMe = message.userId == currentUserId;

    // Determine avatar content
    Widget avatarContent;
    if (message.userImageUrl != null && message.userImageUrl!.isNotEmpty) {
      avatarContent = CircleAvatar(
        backgroundImage: NetworkImage(message.userImageUrl!),
        radius: 15.r,
      );
    } else if (message.userName != null && message.userName!.isNotEmpty) {
      avatarContent = CircleAvatar(
        radius: 15.r,
        backgroundColor:
            isMe
                ? theme.primaryColor.withOpacity(0.7)
                : (isDarkMode ? Colors.grey.shade700 : Colors.grey.shade300),
        child: Text(
          message.userName![0].toUpperCase(),
          style: TextStyle(
            fontSize: 12.sp,
            color:
                isMe
                    ? Colors.white
                    : (isDarkMode ? Colors.white70 : Colors.black87),
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    } else {
      avatarContent = CircleAvatar(
        radius: 15.r,
        backgroundColor:
            isMe
                ? theme.primaryColor.withOpacity(0.7)
                : (isDarkMode ? Colors.grey.shade700 : Colors.grey.shade300),
        child: Icon(
          Icons.person,
          size: 18.sp,
          color:
              isMe
                  ? Colors.white
                  : (isDarkMode ? Colors.white70 : Colors.black87),
        ),
      );
    }

    final messageBubbleContent = Column(
      crossAxisAlignment:
          isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          message.text,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 15.sp,
            color:
                isMe
                    ? Colors.white
                    : (isDarkMode
                        ? Colors.white.withOpacity(0.9)
                        : Colors.black87),
            fontWeight: FontWeight.w500, // Slightly bolder
          ),
        ),
        SizedBox(height: 6.h),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              DateFormat('HH:mm').format(message.timestamp),
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 10.sp, // Smaller timestamp
                color:
                    isMe
                        ? Colors.white.withOpacity(0.8)
                        : (isDarkMode ? Colors.grey[400] : Colors.black54),
              ),
            ),
            if (isMe) SizedBox(width: 4.w), // Spacing for status icon
            if (isMe) _buildStatusIcon(message.status, isMe, context),
          ],
        ),
      ],
    );

    final messageBubbleContainer = Container(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.65,
      ),
      margin: EdgeInsets.symmetric(vertical: 5.h),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
      decoration: BoxDecoration(
        color:
            isMe
                ? theme.primaryColor
                : (isDarkMode
                    ? const Color(0xFF2C2C2E)
                    : const Color(0xFFE5E5EA)),
        // borderRadius: BorderRadius.circular(20.r), // Removed: Clipper handles shape
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDarkMode ? 0.15 : 0.08),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: messageBubbleContent,
    );

    final clippedBubble = ClipPath(
      clipper: ChatBubbleClipper(isMe: isMe, radius: 20.r, tailSize: 10.r),
      child: messageBubbleContainer,
    );

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      child: Row(
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) ...[avatarContent, SizedBox(width: 8.w)],
          clippedBubble, // Use the clipped bubble
          if (isMe) ...[SizedBox(width: 8.w), avatarContent],
        ],
      ),
    );
  }
}

class _MessageInputField extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;

  const _MessageInputField({required this.controller, required this.onSend});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h).copyWith(
        bottom: MediaQuery.of(context).padding.bottom + 10.h,
      ), // Handle safe area
      decoration: BoxDecoration(
        color:
            isDarkMode
                ? const Color(0xFF1C1C1E)
                : theme.cardColor, // Match screen bg or card color
        border: Border(
          top: BorderSide(
            color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade300,
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 15.sp,
                color: isDarkMode ? Colors.white : Colors.black87,
              ),
              decoration: InputDecoration(
                hintText: 'Message...', // Shorter hint
                hintStyle: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 15.sp,
                  color: isDarkMode ? Colors.grey[600] : Colors.grey[500],
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25.r), // More rounded
                  borderSide: BorderSide.none, // No border by default
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25.r),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25.r),
                  borderSide: BorderSide(
                    // Subtle border on focus
                    color: theme.primaryColor.withOpacity(0.5),
                    width: 1.5,
                  ),
                ),
                filled: true,
                fillColor:
                    isDarkMode
                        ? const Color(0xFF2C2C2E)
                        : const Color(0xFFEFEFF4), // Input field background
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 20.w,
                  vertical: 14.h, // Adjusted padding
                ),
                isDense: true,
              ),
              onSubmitted: (_) => onSend(),
              minLines: 1,
              maxLines: 5,
              textCapitalization: TextCapitalization.sentences,
              textInputAction: TextInputAction.send, // Set input action
            ),
          ),
          SizedBox(width: 10.w),
          Material(
            color: theme.primaryColor,
            borderRadius: BorderRadius.circular(25.r), // Match input field
            elevation: 2.0, // Add slight elevation
            shadowColor: theme.primaryColor.withOpacity(0.4),
            child: InkWell(
              borderRadius: BorderRadius.circular(25.r),
              onTap: onSend,
              child: Padding(
                padding: EdgeInsets.all(12.r), // Consistent padding
                child: Icon(
                  Icons.send_rounded,
                  color: Colors.white,
                  size: 22.sp,
                ), // Rounded send icon
              ),
            ),
          ),
        ],
      ),
    );
  }
}

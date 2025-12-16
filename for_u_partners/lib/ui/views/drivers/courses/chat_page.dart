import 'dart:async';

import 'package:flutter/material.dart';
import 'package:for_u_partners/app/app.locator.dart';
import 'package:for_u_partners/models/chat/chat_message_entity.dart';
import 'package:for_u_partners/models/chat/typing_status_entity.dart';
import 'package:for_u_partners/services/chat_service_api.dart';
import 'package:for_u_partners/ui/common/app_colors.dart';
import 'package:for_u_partners/ui/common/text_component.dart';

class ChatPage extends StatefulWidget {
  final String receiverUserName;
  final int courseId;
  final String driverPhone;

  const ChatPage({
    super.key,
    required this.receiverUserName,
    required this.courseId,
    required this.driverPhone,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final ChatServiceApi _chatService = locator<ChatServiceApi>();
  final ScrollController _scrollController = ScrollController();
  Timer? _typingDebounceTimer;
  Timer? _typingSendTimer;
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    // Mark messages as read when opening the chat
    _chatService.markMessagesAsRead(widget.courseId);

    // Listen to text changes
    _messageController.addListener(_onTextChanged);

    print("📱 [CHAT_PAGE] Receiver Name: ${widget.receiverUserName}");
    print("📱 [CHAT_PAGE] Course ID: ${widget.courseId}");
    print("📱 [CHAT_PAGE] Driver Phone: ${widget.driverPhone}");
  }

  @override
  void dispose() {
    // Stop typing status before leaving
    _typingDebounceTimer?.cancel();
    _typingSendTimer?.cancel();

    _messageController.removeListener(_onTextChanged);
    _messageController.dispose();
    _scrollController.dispose();

    // Stop polling when leaving the chat
    _chatService.stopMessagesPolling();
    _chatService.stopTypingPolling();

    super.dispose();
  }

  void _onTextChanged() {
    final text = _messageController.text.trim();

    if (text.isNotEmpty && !_isTyping) {
      // Start indicating typing
      _startTyping();
    }

    // Cancel previous timer
    _typingDebounceTimer?.cancel();

    // Create a new timer that will stop typing after 1 second of inactivity
    _typingDebounceTimer = Timer(const Duration(seconds: 1), () {
      if (_isTyping) {
        _stopTyping();
      }
    });

    // If field is empty, stop typing immediately
    if (text.isEmpty && _isTyping) {
      _stopTyping();
    }
  }

  void _startTyping() {
    setState(() {
      _isTyping = true;
    });

    // Send typing status to backend
    _chatService.setTypingStatus(widget.courseId);

    // Send typing status every 2 seconds while typing
    _typingSendTimer?.cancel();
    _typingSendTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      if (_isTyping) {
        _chatService.setTypingStatus(widget.courseId);
      }
    });
  }

  void _stopTyping() {
    setState(() {
      _isTyping = false;
    });
    _typingSendTimer?.cancel();
  }

  void _sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    try {
      // Stop typing when sending
      _stopTyping();

      await _chatService.sendMessage(widget.courseId, message);

      _messageController.clear();
      _scrollToBottom();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0.0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: primaryColor,
              child: Text(
                widget.receiverUserName.isNotEmpty
                    ? widget.receiverUserName[0].toUpperCase()
                    : 'C',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextComponent(
                    widget.receiverUserName,
                    fontsize: 16,
                    fontweight: FontWeight.w600,
                  ),
                  // Typing status indicator
                  StreamBuilder<TypingStatusEntity>(
                    stream: _chatService.getTypingStatusStream(widget.courseId),
                    builder: (context, snapshot) {
                      if (snapshot.hasData && snapshot.data!.isTyping) {
                        return const TextComponent(
                          'écrit...',
                          fontsize: 12,
                          textcolor: Colors.green,
                          fontweight: FontWeight.w500,
                        );
                      }

                      return const TextComponent(
                        'Client',
                        fontsize: 12,
                        textcolor: Colors.grey,
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.phone),
            onPressed: () {
              // TODO: Implement call functionality
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Message list
          Expanded(
            child: StreamBuilder<List<ChatMessageEntity>>(
              stream: _chatService.getMessagesStream(widget.courseId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: TextComponent(
                      'Erreur: ${snapshot.error}',
                      textcolor: Colors.red,
                    ),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: TextComponent(
                      'Aucun message pour le moment.\nCommencez la conversation !',
                      textAlign: TextAlign.center,
                      textcolor: Colors.grey,
                    ),
                  );
                }

                final messages = snapshot.data!;

                return ListView.builder(
                  controller: _scrollController,
                  reverse: true,
                  padding: const EdgeInsets.all(16),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    // For driver app, current user is the driver
                    final isCurrentUser = message.isFromDriver;

                    return _buildMessageBubble(
                      message: message.message,
                      isCurrentUser: isCurrentUser,
                      timestamp: message.createdAt,
                      isRead: message.isRead,
                    );
                  },
                );
              },
            ),
          ),

          // Typing indicator at the bottom
          StreamBuilder<TypingStatusEntity>(
            stream: _chatService.getTypingStatusStream(widget.courseId),
            builder: (context, snapshot) {
              if (snapshot.hasData && snapshot.data!.isTyping) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 12,
                        backgroundColor: primaryColor,
                        child: Text(
                          widget.receiverUserName.isNotEmpty
                              ? widget.receiverUserName[0].toUpperCase()
                              : 'C',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const TextComponent(
                              'écrit',
                              fontsize: 13,
                              textcolor: Colors.grey,
                            ),
                            const SizedBox(width: 4),
                            // Animated dots
                            SizedBox(
                              width: 20,
                              child: Row(
                                children: List.generate(3, (index) {
                                  return AnimatedContainer(
                                    duration: Duration(milliseconds: 600 + (index * 200)),
                                    curve: Curves.easeInOut,
                                    margin: const EdgeInsets.symmetric(horizontal: 1),
                                    child: Container(
                                      width: 4,
                                      height: 4,
                                      decoration: BoxDecoration(
                                        color: Colors.grey[400],
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  );
                                }),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }

              return const SizedBox.shrink();
            },
          ),

          // Message input
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble({
    required String message,
    required bool isCurrentUser,
    required DateTime timestamp,
    required bool isRead,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment:
            isCurrentUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isCurrentUser) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: primaryColor,
              child: Text(
                widget.receiverUserName.isNotEmpty
                    ? widget.receiverUserName[0].toUpperCase()
                    : 'C',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: isCurrentUser ? primaryColor : Colors.grey[200],
                borderRadius: BorderRadius.circular(18).copyWith(
                  bottomLeft: isCurrentUser
                      ? const Radius.circular(18)
                      : const Radius.circular(4),
                  bottomRight: isCurrentUser
                      ? const Radius.circular(4)
                      : const Radius.circular(18),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextComponent(
                    message,
                    textcolor: isCurrentUser ? Colors.white : Colors.black87,
                    fontsize: 15,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextComponent(
                        _formatTime(timestamp),
                        fontsize: 11,
                        textcolor:
                            isCurrentUser ? Colors.white70 : Colors.grey[600],
                      ),
                      if (isCurrentUser) ...[
                        const SizedBox(width: 4),
                        Icon(
                          isRead ? Icons.done_all : Icons.done,
                          size: 14,
                          color: isRead ? Colors.blue[300] : Colors.white70,
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (isCurrentUser) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 16,
              backgroundColor: Colors.grey[300],
              child: const Icon(Icons.person, size: 16, color: Colors.grey),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(25),
                ),
                child: TextField(
                  controller: _messageController,
                  decoration: const InputDecoration(
                    hintText: 'Tapez votre message...',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                  ),
                  maxLines: null,
                  onSubmitted: (_) => _sendMessage(),
                ),
              ),
            ),
            const SizedBox(width: 12),
            GestureDetector(
              onTap: _sendMessage,
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: primaryColor,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Icon(Icons.send, color: Colors.white, size: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays == 0) {
      return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays == 1) {
      return 'Hier';
    } else {
      return '${dateTime.day}/${dateTime.month}';
    }
  }
}

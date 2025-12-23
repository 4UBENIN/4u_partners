# Chat API Migration Guide

## Overview
This document explains how to migrate from Firestore-based chat to the new backend REST API-based chat system. The migration removes Firebase/Firestore dependencies from the chat feature and replaces them with HTTP REST API calls.

## Backend API Endpoints

### 1. Get Messages
**Endpoint:** `GET /api/courses/{course}/messages`

Retrieves all messages for a specific course/ride.

**Response (200 OK):**
```json
[
  {
    "id": 45,
    "course_id": 12,
    "sender_id": 3,
    "sender_type": "client",
    "message": "Je suis devant l'immeuble",
    "is_read": false,
    "created_at": "2025-01-10 14:32:11",
    "updated_at": "2025-01-10 14:32:11"
  }
]
```

**Error Responses:**
- `401`: Non authentifié
- `403`: Accès refusé à cette course
- `404`: Course introuvable

---

### 2. Send Message
**Endpoint:** `POST /api/courses/{course}/messages`

Sends a message in the chat for a specific course.

**Request Body:**
```json
{
  "message": "J'arrive dans 2 minutes"
}
```

**Response (201 Created):**
```json
{
  "id": 46,
  "course_id": 12,
  "sender_id": 8,
  "sender_type": "conducteur",
  "message": "J'arrive dans 2 minutes",
  "is_read": false,
  "created_at": "2025-01-10 14:35:22",
  "updated_at": "2025-01-10 14:35:22"
}
```

**Error Responses:**
- `401`: Non authentifié
- `403`: Chat non autorisé ou accès refusé
- `404`: Course introuvable
- `422`: Erreur de validation

---

### 3. Mark Messages as Read
**Endpoint:** `POST /api/courses/{course}/messages/read`

Marks all messages from the other participant as read.

**Response (200 OK):**
```json
{
  "status": "ok"
}
```

**Error Responses:**
- `401`: Non authentifié
- `403`: Accès refusé
- `404`: Course introuvable

---

### 4. Check Typing Status
**Endpoint:** `GET /api/courses/{course}/typing`

Checks if the other participant is currently typing.

**Response (200 OK):**
```json
{
  "is_typing": true
}
```

**Error Responses:**
- `401`: Non authentifié
- `403`: Accès refusé à la discussion
- `404`: Course introuvable

---

### 5. Set Typing Status
**Endpoint:** `POST /api/courses/{course}/typing`

Indicates that the current user is typing.

**Response (200 OK):**
```json
{
  "status": "ok"
}
```

**Error Responses:**
- `401`: Non authentifié
- `403`: Accès refusé ou discussion non autorisée pour cette course
- `404`: Course introuvable

---

## Implementation Architecture

### 1. Data Models

#### ChatMessageEntity (Domain Layer)
```dart
class ChatMessageEntity {
  final int id;
  final int courseId;
  final int senderId;
  final String senderType; // "client" or "conducteur"
  final String message;
  final bool isRead;
  final DateTime createdAt;
  final DateTime updatedAt;

  bool get isFromClient => senderType == 'client';
  bool get isFromDriver => senderType == 'conducteur';
}
```

#### ChatMessageModel (Data Layer)
```dart
class ChatMessageModel extends ChatMessageEntity {
  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    return ChatMessageModel(
      id: json['id'],
      courseId: json['course_id'],
      senderId: json['sender_id'],
      senderType: json['sender_type'],
      message: json['message'],
      isRead: json['is_read'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
}
```

#### TypingStatusEntity & Model
```dart
class TypingStatusEntity {
  final bool isTyping;
}

class TypingStatusModel extends TypingStatusEntity {
  factory TypingStatusModel.fromJson(Map<String, dynamic> json) {
    return TypingStatusModel(isTyping: json['is_typing'] ?? false);
  }
}
```

---

### 2. Repository Pattern

#### ChatRepository Interface (Domain)
```dart
abstract class ChatRepository {
  Future<List<ChatMessageEntity>> getMessages(int courseId);
  Future<ChatMessageEntity> sendMessage(int courseId, String message);
  Future<void> markMessagesAsRead(int courseId);
  Future<TypingStatusEntity> getTypingStatus(int courseId);
  Future<void> setTypingStatus(int courseId);
}
```

#### ChatRepositoryImpl (Data)
```dart
@Injectable(as: ChatRepository)
class ChatRepositoryImpl implements ChatRepository {
  final http.Client _client;

  @override
  Future<List<ChatMessageEntity>> getMessages(int courseId) async {
    final headers = await ApiConstant.authenticatedHeaders;
    final url = '${ApiConstant.baseUrl}/courses/$courseId/messages';

    final response = await _client.get(Uri.parse(url), headers: headers);

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((json) => ChatMessageModel.fromJson(json)).toList();
    }
    throw Exception('Failed to load messages');
  }

  // ... implement other methods
}
```

---

### 3. Service Layer with Polling

#### ChatServiceApi
This service manages real-time updates via polling and provides streams for the UI.

```dart
@injectable
class ChatServiceApi {
  final ChatRepository _chatRepository;
  Timer? _messagesPollingTimer;
  Timer? _typingPollingTimer;

  final StreamController<List<ChatMessageEntity>> _messagesController =
      StreamController<List<ChatMessageEntity>>.broadcast();

  final StreamController<TypingStatusEntity> _typingController =
      StreamController<TypingStatusEntity>.broadcast();

  // Stream for listening to messages (with polling)
  Stream<List<ChatMessageEntity>> getMessagesStream(int courseId) {
    _startMessagesPolling(courseId);
    return _messagesController.stream;
  }

  // Start polling messages every 2 seconds
  void _startMessagesPolling(int courseId) {
    _messagesPollingTimer?.cancel();
    _fetchMessages(courseId);

    _messagesPollingTimer = Timer.periodic(
      const Duration(seconds: 2),
      (_) => _fetchMessages(courseId),
    );
  }

  Future<void> _fetchMessages(int courseId) async {
    try {
      final messages = await _chatRepository.getMessages(courseId);
      _messagesController.add(messages);
    } catch (e) {
      _messagesController.addError(e);
    }
  }

  void dispose() {
    _messagesPollingTimer?.cancel();
    _typingPollingTimer?.cancel();
    _messagesController.close();
    _typingController.close();
  }
}
```

**Key Features:**
- **Polling**: Fetches messages every 2 seconds to simulate real-time updates
- **Streams**: Provides broadcast streams for UI to listen to
- **Automatic cleanup**: Cancels timers and closes streams on dispose

---

### 4. UI Integration (ChatPage)

#### Constructor Changes
**Old (Firestore):**
```dart
ChatPage({
  required String receiverUserName,
  required String receiverUserId,
  required String conversationId,
  required String currentUserId,
  required String driverPhone,
})
```

**New (API):**
```dart
ChatPage({
  required String receiverUserName,
  required int courseId,  // Changed from conversationId
  required String driverPhone,
})
```

#### Key Changes:
1. **No more Firestore imports** - Remove `cloud_firestore` imports
2. **Use ChatServiceApi** - Inject via `GetIt.instance<ChatServiceApi>()`
3. **StreamBuilder changes**:
   - `StreamBuilder<QuerySnapshot>` → `StreamBuilder<List<ChatMessageEntity>>`
   - `StreamBuilder<DocumentSnapshot>` → `StreamBuilder<TypingStatusEntity>`
4. **Remove Timestamp** - Use `DateTime` instead
5. **Simplified initialization** - No need to create/get conversation

---

## Migration Steps for Driver App

### Step 1: Create Data Models
Copy these files to your driver app:
- `lib/features/transport/car/domain/entities/chat_message_entity.dart`
- `lib/features/transport/car/domain/entities/typing_status_entity.dart`
- `lib/features/transport/car/data/models/chat_message_model.dart`
- `lib/features/transport/car/data/models/typing_status_model.dart`

### Step 2: Create Repository
Copy these files:
- `lib/features/transport/car/domain/repositories/chat_repository.dart`
- `lib/features/transport/car/data/repositories/chat_repository_impl.dart`

**Note:** Ensure `@Injectable(as: ChatRepository)` annotation is present for dependency injection.

### Step 3: Create Service
Copy this file:
- `lib/features/transport/car/data/datasources/chat_service_api.dart`

**Note:** Ensure `@injectable` annotation is present.

### Step 4: Update ChatPage
Replace your existing `ChatPage` with the new implementation from:
- `lib/features/transport/chat_page.dart`

### Step 5: Update Navigation Calls
Find all places where `ChatPage` is navigated to and update:

**Before:**
```dart
final conversationId = await _chatService.createOrGetConversation(
  currentUserId: currentUserInfo['id'],
  driverId: driverId,
  driverName: driverName,
  tripId: tripId,
);

context.pushTo(
  ChatPage(
    receiverUserName: driverName,
    receiverUserId: driverId,
    conversationId: conversationId,
    currentUserId: currentUserId,
    driverPhone: driverPhone,
  ),
);
```

**After:**
```dart
final courseId = int.parse(tripId);

context.pushTo(
  ChatPage(
    receiverUserName: clientName,  // For driver app: client's name
    courseId: courseId,
    driverPhone: clientPhone,  // For driver app: client's phone
  ),
);
```

### Step 6: Remove Old Firestore Code
Delete or remove:
- `lib/features/transport/car/data/datasources/chat_service.dart` (old Firestore service)
- All Firestore `conversations` collection logic
- `createOrGetConversation` method calls
- `getCurrentUserInfo` method calls from ChatService

### Step 7: Run Code Generation
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

This will register the new `ChatRepository` and `ChatServiceApi` with the dependency injection system.

### Step 8: Update Dependency Injection
Make sure your `service_locator.dart` or DI configuration includes:
```dart
import 'package:http/http.dart' as http;

// In your DI module
@module
abstract class NetworkModule {
  @lazySingleton
  http.Client get httpClient => http.Client();
}
```

---

## Key Differences: Driver vs Client App

### Sender Type
- **Client app**: Messages sent have `sender_type: "client"`
- **Driver app**: Messages sent have `sender_type: "conducteur"`

The backend automatically sets this based on the authenticated user.

### Message Identification
```dart
// Client app
final isCurrentUser = message.isFromClient;

// Driver app
final isCurrentUser = message.isFromDriver;
```

### Receiver Name
- **Client app**: Shows driver's name (`receiverUserName: driverName`)
- **Driver app**: Shows client's name (`receiverUserName: clientName`)

---

## Polling vs Real-Time

### Why Polling?
The new implementation uses polling (fetching messages every 2 seconds) instead of WebSockets or Firestore real-time listeners.

**Advantages:**
- ✅ Simple to implement
- ✅ No persistent connections needed
- ✅ Works well for short-lived chats during rides
- ✅ No Firebase dependencies

**Considerations:**
- ⚠️ 2-second delay for new messages
- ⚠️ More API requests (mitigated by short ride durations)

**Polling Intervals:**
- **Messages**: 2 seconds (defined in `ChatServiceApi._startMessagesPolling`)
- **Typing status**: 2 seconds (defined in `ChatServiceApi._startTypingPolling`)

To change polling intervals, modify the `Duration` in the `Timer.periodic` calls.

---

## Testing Checklist

### Client App
- [ ] Can open chat page for an active ride
- [ ] Can send messages successfully
- [ ] Can receive messages from driver (polling works)
- [ ] Typing indicator shows when driver is typing
- [ ] Messages marked as read when chat is opened
- [ ] Chat closes cleanly (no timer leaks)
- [ ] Works on both iOS and Android

### Driver App
- [ ] Can open chat page for an active ride
- [ ] Can send messages successfully
- [ ] Can receive messages from client (polling works)
- [ ] Typing indicator shows when client is typing
- [ ] Messages marked as read when chat is opened
- [ ] Sender type is "conducteur" for sent messages
- [ ] Chat closes cleanly (no timer leaks)
- [ ] Works on both iOS and Android

---

## Troubleshooting

### Messages not updating in real-time
- Check that polling is active (debug logs in `_fetchMessages`)
- Verify API endpoint returns correct data
- Check authentication token is valid

### Typing indicator not showing
- Verify typing status API endpoint is working
- Check that typing status is sent every 2 seconds while typing
- Ensure typing status expires correctly on backend (5-second timeout)

### 401 Unauthorized errors
- Verify bearer token is included in headers
- Check token hasn't expired
- Ensure user is authenticated

### 403 Forbidden errors
- Verify user has access to the course (is participant)
- Check that courseId is correct

### Build runner errors
- Run `flutter clean`
- Delete `*.g.dart` files
- Run `flutter pub get`
- Run build_runner again

---

## Performance Optimization

### Reduce Polling Frequency
For production, consider:
- Increasing polling interval to 3-5 seconds
- Stopping polling when app is in background
- Using exponential backoff on errors

### Example: Background-aware polling
```dart
@override
void didChangeAppLifecycleState(AppLifecycleState state) {
  if (state == AppLifecycleState.paused) {
    _chatService.stopMessagesPolling();
  } else if (state == AppLifecycleState.resumed) {
    _chatService.getMessagesStream(widget.courseId);
  }
}
```

---

## Summary

### What Changed
- ❌ Removed: Firestore real-time listeners
- ❌ Removed: Firestore conversations collection
- ❌ Removed: `createOrGetConversation` logic
- ✅ Added: REST API-based chat repository
- ✅ Added: Polling-based real-time updates
- ✅ Added: Simpler ChatPage with fewer parameters

### Benefits
- 🎯 Centralized chat data on backend
- 🎯 No Firebase/Firestore dependency for chat
- 🎯 Simpler implementation
- 🎯 Better control over chat data and privacy

### Migration Effort
- **Client app**: Already completed ✅
- **Driver app**: Follow steps above (~1-2 hours)

---

## Support

If you encounter issues during migration:
1. Check API endpoint connectivity
2. Verify authentication headers
3. Review console logs for errors
4. Test with small courseId values first
5. Compare with client app implementation

---

**Last Updated:** 2025-12-16
**Version:** 1.0.0

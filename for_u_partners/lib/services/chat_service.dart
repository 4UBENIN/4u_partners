import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:for_u_partners/app/app.locator.dart';
import 'package:for_u_partners/services/sharedpreferences_service.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _sharedPreferencesServices = locator<SharedpreferencesService>();
  Timer? _typingTimer;

  // Récupérer les infos de l'utilisateur connecté (client)
  Future<Map<String, dynamic>?> getCurrentUserInfo() async {
    try {
      final userId = await _sharedPreferencesServices.getUserTypeId();
      print(" BB CURRENT USER ID chat Service : $userId");
      if (userId == null) return null;

      final userDoc =
          await _firestore.collection('users').doc(userId.toString()).get();

      if (userDoc.exists) {
        return {
          'id': userId.toString(),
          'name':
              '${userDoc.data()?['prenom'] ?? ''} ${userDoc.data()?['nom'] ?? ''}',
          'email': userDoc.data()?['email'] ?? '',
          'telephone': userDoc.data()?['telephone'] ?? '',
          'role': userDoc.data()?['role'] ?? '',
        };
      }
      return null;
    } catch (e) {
      print('Erreur récupération infos utilisateur: $e');
      return null;
    }
  }

  // Créer ou récupérer une conversation
  Future<String?> createOrGetConversation({
    required String currentUserId,
    required String clientId,
    required String clientName,
    String? tripId,
  }) async {
    try {
      print('📱 [CHAT_SERVICE] createOrGetConversation called');
      print('📱 [CHAT_SERVICE] currentUserId: $currentUserId');
      print('📱 [CHAT_SERVICE] clientId: $clientId');
      print('📱 [CHAT_SERVICE] clientName: $clientName');
      print('📱 [CHAT_SERVICE] tripId: $tripId');

      // IMPORTANT: Ensure both users have Firestore documents
      await _ensureUserDocumentExists(clientId, clientName, 'client');
      print('✅ [CHAT_SERVICE] Client document verified/created');

      // Créer un ID de conversation unique basé sur les deux utilisateurs
      final List<String> participants = [currentUserId, clientId];
      participants.sort(); // Trier pour avoir toujours le même ordre
      final String conversationId = '${participants[0]}_${participants[1]}';
      print('📱 [CHAT_SERVICE] conversationId: $conversationId');

      final conversationRef =
          _firestore.collection('conversations').doc(conversationId);

      final conversationDoc = await conversationRef.get();

      if (!conversationDoc.exists) {
        print('📱 [CHAT_SERVICE] Conversation does not exist, creating new one');
        // Créer une nouvelle conversation
        await conversationRef.set({
          'participants': participants,
          'participantNames': {
            currentUserId: await _getCurrentUserName(currentUserId),
            clientId: clientName,
          },
          'lastMessage': '',
          'lastMessageTime': FieldValue.serverTimestamp(),
          'createdAt': FieldValue.serverTimestamp(),
          'tripId': tripId, // Optionnel : lier à un trajet spécifique
          // Nouveaux champs pour le typing status
          'typingUsers': <String>[],
          'typingTimestamps': <String, dynamic>{},
        });
        print('✅ [CHAT_SERVICE] Conversation created successfully');
      } else {
        print('📱 [CHAT_SERVICE] Conversation already exists');
        // Si la conversation existe déjà mais n'a pas les champs typing, les ajouter
        final data = conversationDoc.data();
        if (data != null && !data.containsKey('typingUsers')) {
          await conversationRef.update({
            'typingUsers': <String>[],
            'typingTimestamps': <String, dynamic>{},
          });
          print('✅ [CHAT_SERVICE] Added typing fields to existing conversation');
        }
      }

      print('✅ [CHAT_SERVICE] Returning conversationId: $conversationId');
      return conversationId;
    } catch (e) {
      print('❌ [CHAT_SERVICE] Erreur création conversation: $e');
      print('❌ [CHAT_SERVICE] Stack trace: ${StackTrace.current}');
      return null;
    }
  }

  // Méthode helper pour s'assurer qu'un document utilisateur existe
  Future<void> _ensureUserDocumentExists(
      String userId, String userName, String role) async {
    try {
      print('📱 [CHAT_SERVICE] _ensureUserDocumentExists for userId: $userId');
      final userDoc = _firestore.collection('users').doc(userId);
      final docSnapshot = await userDoc.get();

      if (!docSnapshot.exists) {
        print('⚠️ [CHAT_SERVICE] User document does not exist, creating it');

        // Parse the name into first and last name
        final nameParts = userName.trim().split(' ');
        final prenom = nameParts.isNotEmpty ? nameParts.first : '';
        final nom = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';

        await userDoc.set({
          'id': userId,
          'prenom': prenom,
          'nom': nom,
          'role': role,
          'createdAt': FieldValue.serverTimestamp(),
          'lastSeen': FieldValue.serverTimestamp(),
        });
        print('✅ [CHAT_SERVICE] User document created for $userId');
      } else {
        print('✅ [CHAT_SERVICE] User document already exists for $userId');
        // Update lastSeen
        await userDoc.update({
          'lastSeen': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      print('❌ [CHAT_SERVICE] Error ensuring user document exists: $e');
      // Don't throw - we can still create the conversation even if this fails
    }
  }

  // Méthode helper pour récupérer le nom de l'utilisateur actuel
  Future<String> _getCurrentUserName(String userId) async {
    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();

      if (userDoc.exists) {
        final data = userDoc.data();
        return '${data?['prenom'] ?? ''} ${data?['nom'] ?? ''}'.trim();
      }
      return 'Utilisateur';
    } catch (e) {
      return 'Utilisateur';
    }
  }

  // Envoyer un message
  Future<void> sendMessage({
    required String conversationId,
    required String senderId,
    required String receiverId,
    required String message,
    String messageType = 'text',
  }) async {
    try {
      // D'abord, arrêter le statut typing
      await stopTyping(conversationId: conversationId, userId: senderId);

      // Ajouter le message à la sous-collection 'messages'
      await _firestore
          .collection('conversations')
          .doc(conversationId)
          .collection('messages')
          .add({
        'senderId': senderId,
        'receiverId': receiverId,
        'message': message,
        'messageType': messageType,
        'timestamp': FieldValue.serverTimestamp(),
        'isRead': false,
      });

      // Mettre à jour la conversation avec le dernier message
      await _firestore.collection('conversations').doc(conversationId).update({
        'lastMessage': message,
        'lastMessageTime': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Erreur envoi message: $e');
      throw Exception('Erreur lors de l\'envoi du message');
    }
  }

  // Écouter les messages d'une conversation
  Stream<QuerySnapshot> getMessages(String conversationId) {
    return _firestore
        .collection('conversations')
        .doc(conversationId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  // Marquer les messages comme lus
  Future<void> markMessagesAsRead({
    required String conversationId,
    required String currentUserId,
  }) async {
    try {
      final messagesQuery = await _firestore
          .collection('conversations')
          .doc(conversationId)
          .collection('messages')
          .where('receiverId', isEqualTo: currentUserId)
          .where('isRead', isEqualTo: false)
          .get();

      final batch = _firestore.batch();
      for (final doc in messagesQuery.docs) {
        batch.update(doc.reference, {'isRead': true});
      }
      await batch.commit();
    } catch (e) {
      print('Erreur marquage messages lus: $e');
    }
  }

  // ==================== FONCTIONNALITÉS TYPING ====================

  // Indiquer que l'utilisateur est en train d'écrire
  Future<void> startTyping({
    required String conversationId,
    required String userId,
  }) async {
    try {
      final conversationRef =
          _firestore.collection('conversations').doc(conversationId);

      await _firestore.runTransaction((transaction) async {
        final conversationDoc = await transaction.get(conversationRef);

        if (conversationDoc.exists) {
          final data = conversationDoc.data() as Map<String, dynamic>;
          final List<String> typingUsers =
              List<String>.from(data['typingUsers'] ?? []);
          final Map<String, dynamic> typingTimestamps =
              Map<String, dynamic>.from(data['typingTimestamps'] ?? {});

          // Ajouter l'utilisateur à la liste des utilisateurs qui tapent
          if (!typingUsers.contains(userId)) {
            typingUsers.add(userId);
          }

          // Mettre à jour le timestamp
          typingTimestamps[userId] = FieldValue.serverTimestamp();

          transaction.update(conversationRef, {
            'typingUsers': typingUsers,
            'typingTimestamps': typingTimestamps,
          });
        }
      });

      // Programmer l'arrêt automatique du typing après 3 secondes
      _typingTimer?.cancel();
      _typingTimer = Timer(const Duration(seconds: 3), () {
        stopTyping(conversationId: conversationId, userId: userId);
      });
    } catch (e) {
      print('Erreur start typing: $e');
    }
  }

  // Arrêter d'indiquer que l'utilisateur est en train d'écrire
  Future<void> stopTyping({
    required String conversationId,
    required String userId,
  }) async {
    try {
      _typingTimer?.cancel();

      final conversationRef =
          _firestore.collection('conversations').doc(conversationId);

      await _firestore.runTransaction((transaction) async {
        final conversationDoc = await transaction.get(conversationRef);

        if (conversationDoc.exists) {
          final data = conversationDoc.data() as Map<String, dynamic>;
          final List<String> typingUsers =
              List<String>.from(data['typingUsers'] ?? []);
          final Map<String, dynamic> typingTimestamps =
              Map<String, dynamic>.from(data['typingTimestamps'] ?? {});

          // Retirer l'utilisateur de la liste
          typingUsers.remove(userId);
          typingTimestamps.remove(userId);

          transaction.update(conversationRef, {
            'typingUsers': typingUsers,
            'typingTimestamps': typingTimestamps,
          });
        }
      });
    } catch (e) {
      print('Erreur stop typing: $e');
    }
  }

  // Écouter le statut typing d'une conversation
  Stream<DocumentSnapshot> getTypingStatus(String conversationId) {
    return _firestore
        .collection('conversations')
        .doc(conversationId)
        .snapshots();
  }

  // Vérifier si quelqu'un d'autre que l'utilisateur actuel est en train d'écrire
  bool isOtherUserTyping({
    required Map<String, dynamic> conversationData,
    required String currentUserId,
  }) {
    final List<String> typingUsers =
        List<String>.from(conversationData['typingUsers'] ?? []);
    final Map<String, dynamic> typingTimestamps =
        Map<String, dynamic>.from(conversationData['typingTimestamps'] ?? {});

    // Filtrer les utilisateurs qui tapent (exclure l'utilisateur actuel)
    final otherTypingUsers =
        typingUsers.where((userId) => userId != currentUserId).toList();

    // Vérifier si les timestamps sont récents (moins de 5 secondes)
    final now = DateTime.now();
    final validTypingUsers = otherTypingUsers.where((userId) {
      final timestamp = typingTimestamps[userId];
      if (timestamp is Timestamp) {
        final typingTime = timestamp.toDate();
        return now.difference(typingTime).inSeconds < 5;
      }
      return false;
    }).toList();

    return validTypingUsers.isNotEmpty;
  }

  // Nettoyer les anciens statuts typing (à appeler périodiquement)
  Future<void> cleanupOldTypingStatus(String conversationId) async {
    try {
      final conversationRef =
          _firestore.collection('conversations').doc(conversationId);

      await _firestore.runTransaction((transaction) async {
        final conversationDoc = await transaction.get(conversationRef);

        if (conversationDoc.exists) {
          final data = conversationDoc.data() as Map<String, dynamic>;
          final List<String> typingUsers =
              List<String>.from(data['typingUsers'] ?? []);
          final Map<String, dynamic> typingTimestamps =
              Map<String, dynamic>.from(data['typingTimestamps'] ?? {});

          final now = DateTime.now();
          final List<String> validUsers = [];
          final Map<String, dynamic> validTimestamps = {};

          // Garder seulement les utilisateurs avec des timestamps récents
          for (final userId in typingUsers) {
            final timestamp = typingTimestamps[userId];
            if (timestamp is Timestamp) {
              final typingTime = timestamp.toDate();
              if (now.difference(typingTime).inSeconds < 5) {
                validUsers.add(userId);
                validTimestamps[userId] = timestamp;
              }
            }
          }

          transaction.update(conversationRef, {
            'typingUsers': validUsers,
            'typingTimestamps': validTimestamps,
          });
        }
      });
    } catch (e) {
      print('Erreur cleanup typing: $e');
    }
  }

  // Dispose method pour nettoyer les timers
  void dispose() {
    _typingTimer?.cancel();
  }
}

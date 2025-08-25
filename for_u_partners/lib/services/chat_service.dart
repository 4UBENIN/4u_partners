import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:for_u_partners/app/app.locator.dart';
import 'package:for_u_partners/services/sharedpreferences_service.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _sharedPreferencesServices = locator<SharedpreferencesService>();

  // Récupérer les infos de l'utilisateur connecté (client)
  Future<Map<String, dynamic>?> getCurrentUserInfo() async {
    try {
      final userId = await _sharedPreferencesServices.getUserTypeId();
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
      // Créer un ID de conversation unique basé sur les deux utilisateurs
      final List<String> participants = [currentUserId, clientId];
      participants.sort(); // Trier pour avoir toujours le même ordre
      final String conversationId = '${participants[0]}_${participants[1]}';

      final conversationRef =
          _firestore.collection('conversations').doc(conversationId);

      final conversationDoc = await conversationRef.get();

      if (!conversationDoc.exists) {
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
        });
      }

      return conversationId;
    } catch (e) {
      print('Erreur création conversation: $e');
      return null;
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
}

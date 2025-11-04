import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:for_u_partners/app/app.locator.dart';
import 'package:for_u_partners/app/app.router.dart';
import 'package:for_u_partners/services/course_event_service.dart';
import 'package:for_u_partners/services/course_notificationstorage_service.dart';
import 'package:for_u_partners/services/sharedpreferences_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:stacked_services/stacked_services.dart';

class FirebaseMessagingService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final CourseEventService _courseEventService = CourseEventService();
  final _sharedPreferencesServices = locator<SharedpreferencesService>();
  final navigationServices = locator<NavigationService>();
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  // Token FCM stocké localement
  static String? _currentToken;

  // Callbacks pour les mises à jour de l'UI
  static Function(String?)? onTokenUpdate;

  /// Initialise Firebase Messaging
  Future<void> init() async {
    try {
      // Demander les permissions

      await initAndCleanStorage();
      NotificationSettings settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional) {
        // Configurer les handlers de messages
        await _setupMessageHandlers();

        // Récupérer le token selon la plateforme
        await _getToken();

        // Écouter les mises à jour de token
        _setupTokenListener();
      }
    } catch (e) {
      print('Erreur initialisation FCM: $e');
    }
  }

  /// Récupère le token FCM
  Future<void> _getToken() async {
    try {
      // Pour iOS, on attend un peu pour laisser le temps à APNS de s'initialiser
      if (Platform.isIOS) {
        await Future.delayed(const Duration(seconds: 2));
      }

      // Récupérer le token FCM
      final String? token = await _messaging.getToken();

      if (token != null) {
        _currentToken = token; // Stocker le token
        onTokenUpdate?.call(token);
        print('Token FCM obtenu avec succès');
      } else {
        print('Le token FCM est null');
      }
    } catch (e) {
      print('Erreur lors de la récupération du token FCM: $e');
    }
  }

  /// Configure l'écoute des mises à jour de token
  void _setupTokenListener() {
    _messaging.onTokenRefresh.listen((newToken) async {
      print('🔄 [FCM] Token rafraîchi automatiquement par Firebase');
      print('🔄 [FCM] Nouveau token : $newToken)...');
      _currentToken = newToken; // Mettre à jour le token stocké
      onTokenUpdate?.call(newToken);
      print('🔄 [FCM] Token mis en cache, prêt à être envoyé au backend');
    });
  }

  /// Configure les handlers pour les messages

  void _handleIncomingMessage(RemoteMessage message) async {
    try {
      final data = message.data;

      // Vérifier si c'est une notification de course
      if (data.containsKey('course_id') &&
          data.containsKey('client_nom') &&
          data.containsKey('eta_minutes')) {
        print('📱 Course détectée dans la notification');

        // ✨ Créer l'objet CourseNotificationData avec timestamp actuel
        final courseData = CourseNotificationData.fromFirebaseData(
          data,
          receivedAt: DateTime.now(), // ✨ Timestamp de réception côté client
        );

        // ✨ Sauvegarder en mémoire
        await CourseNotificationStorage.saveNotification(courseData);

        // Transmettre au service d'événements (comme avant)
        _courseEventService.onNewCourseReceived(data);

        navigationServices.navigateToCoursesView();

        print(
            '✅ Notification course sauvée: ${courseData.courseId} à ${courseData.timestamp}');
      } else {
        print('📱 Message non-course reçu: $data');
      }
    } catch (e) {
      print('❌ Erreur traitement message: $e');
    }
  }

  Future<void> _setupMessageHandlers() async {
    // Messages en premier plan - DÉSACTIVÉ car géré par setupFlutterNotifications()
    // La gestion est centralisée dans setupFlutterNotifications() pour éviter les doublons

    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      print('Notification ouverte: ${message.notification?.body}');
      _handleIncomingMessage(message);
    });

    // Tap sur notification (app fermée)
    RemoteMessage? initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      print(
          'App ouvert depuis notification: ${initialMessage.notification?.title}');
      _handleIncomingMessage(initialMessage);
    }
  }

  /// Envoie le token au backend (méthode publique)
  Future<bool> sendTokenToBackend(String token, String url) async {
    try {
      print('🔐 [FCM] Début envoi du token vers le backend');
      print('🔐 [FCM] URL cible: $url');

      final authToken = await _sharedPreferencesServices.getToken();
      print('🔐 [FCM] FCM Token : $token...');
      print('🔐 [FCM] Auth Token disponible: ${authToken != null && authToken.isNotEmpty}');

      if (authToken == null || authToken.isEmpty) {
        print('❌ [FCM] Échec: Token d\'authentification manquant');
        return false;
      }

      print('🔐 [FCM] Envoi de la requête POST...');
      final response = await http
          .post(
            Uri.parse(url),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $authToken',
            },
            body: jsonEncode({'fcm_token': token}),
          )
          .timeout(const Duration(seconds: 10));

      print('🔐 [FCM] Code de réponse HTTP: ${response.statusCode}');
      print('🔐 [FCM] Corps de la réponse: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('✅ [FCM] Token envoyé avec succès vers: $url');
        return true;
      } else {
        print('❌ [FCM] Erreur HTTP ${response.statusCode}: ${response.body}');
        return false;
      }
    } catch (e) {
      print('❌ [FCM] Exception lors de l\'envoi du token: $e');
      return false;
    }
  }

  Future<void> initAndCleanStorage() async {
    try {
      // Nettoyer les notifications expirées au démarrage
      await CourseNotificationStorage.cleanExpiredNotifications(
        maxAge: const Duration(hours: 24), // ou la durée que tu veux
      );

      final count = await CourseNotificationStorage.getValidNotificationCount();
      print('📱 $count notifications valides en mémoire');
    } catch (e) {
      print('❌ Erreur nettoyage storage: $e');
    }
  }

  /// Récupère le token FCM actuel (depuis le cache ou Firebase)
  static Future<String?> getCurrentToken() async {
    try {
      // Retourner le token en cache s'il existe
      if (_currentToken != null && _currentToken!.isNotEmpty) {
        return _currentToken;
      }

      // Sinon, récupérer depuis Firebase
      String? token = await _messaging.getToken();
      if (token != null) {
        _currentToken = token; // Mettre en cache
      }
      return token;
    } catch (e) {
      print('Erreur récupération token: $e');
      return null;
    }
  }

  /// Récupère le token depuis le cache uniquement (plus rapide)
  static String? getCachedToken() {
    return _currentToken;
  }

  /// Récupère le token actuel et l'envoie au backend
  Future<bool> sendCurrentTokenToBackend(String url, {int maxRetries = 3}) async {
    print('🔐 [FCM] sendCurrentTokenToBackend appelé avec URL: $url');

    for (int attempt = 1; attempt <= maxRetries; attempt++) {
      try {
        print('🔐 [FCM] Tentative $attempt/$maxRetries de récupération du token');
        String? token = await getCurrentToken();

        if (token != null && token.isNotEmpty) {
          print('🔐 [FCM] Token récupéré avec succès');
          final success = await sendTokenToBackend(token, url);

          if (success) {
            print('✅ [FCM] Token envoyé avec succès au backend (tentative $attempt)');
            return true;
          } else {
            print('⚠️ [FCM] Échec envoi token (tentative $attempt)');
            if (attempt < maxRetries) {
              print('🔐 [FCM] Nouvelle tentative dans 2 secondes...');
              await Future.delayed(Duration(seconds: 2));
            }
          }
        } else {
          print('⚠️ [FCM] Aucun token FCM disponible (tentative $attempt)');
          if (attempt < maxRetries) {
            await Future.delayed(Duration(seconds: 2));
          }
        }
      } catch (e) {
        print('❌ [FCM] Erreur récupération/envoi token (tentative $attempt): $e');
        if (attempt < maxRetries) {
          await Future.delayed(Duration(seconds: 2));
        }
      }
    }

    print('❌ [FCM] Échec définitif après $maxRetries tentatives');
    return false;
  }

  /// Actualise le token manuellement
  Future<bool> refreshToken() async {
    try {
      print('🔄 [FCM] Début du rafraîchissement du token FCM');
      print('🔄 [FCM] Suppression de l\'ancien token...');
      await _messaging.deleteToken();

      print('🔄 [FCM] Récupération d\'un nouveau token...');
      await _getToken();

      if (_currentToken != null && _currentToken!.isNotEmpty) {
        print('✅ [FCM] Token rafraîchi avec succès');
        print('🔄 [FCM] Nouveau token: ${_currentToken!}');
        return true;
      } else {
        print('⚠️ [FCM] Token rafraîchi mais vide ou null');
        return false;
      }
    } catch (e) {
      print('❌ [FCM] Erreur lors du rafraîchissement du token: $e');
      return false;
    }
  }

  /// S'abonne à un topic
  static Future<bool> subscribeToTopic(String topic) async {
    try {
      if (Platform.isIOS) {
        String? apnsToken = await _messaging.getAPNSToken();
        if (apnsToken == null) {
          await Future.delayed(const Duration(seconds: 3));
          apnsToken = await _messaging.getAPNSToken();
        }
        if (apnsToken == null) return false;
      }

      await _messaging.subscribeToTopic(topic);
      return true;
    } catch (e) {
      print('Erreur abonnement topic: $e');
      return false;
    }
  }

  /// Se désabonne d'un topic
  static Future<bool> unsubscribeFromTopic(String topic) async {
    try {
      await _messaging.unsubscribeFromTopic(topic);
      return true;
    } catch (e) {
      print('Erreur désabonnement topic: $e');
      return false;
    }
  }

  /// Supprime le token (désabonnement)
  Future<void> deleteToken() async {
    try {
      await _messaging.deleteToken();
      _currentToken = null; // Clear cache
    } catch (e) {
      print('Erreur suppression token: $e');
    }
  }

  Future<void> setupFlutterNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestSoundPermission: true,
      requestBadgePermission: true,
      requestAlertPermission: true,
    );

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (details) {
        // Gère la réponse à la notification si besoin
        print("Notification reçue: ${details.data}");
      },
    );

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;

      // ✨ Traiter le message pour les courses
      _handleIncomingMessage(message);

      // Afficher la notification locale (votre code existant)
      if (notification != null) {
        flutterLocalNotificationsPlugin.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
            android: android != null
                ? const AndroidNotificationDetails(
                    'channel_id',
                    'channel_name',
                    importance: Importance.max,
                    priority: Priority.high,
                    icon: '@mipmap/ic_launcher',
                  )
                : null,
            iOS: const DarwinNotificationDetails(
              presentAlert: true,
              presentBadge: true,
              presentSound: true,
            ),
          ),
        );
      }
    });
  }
}

/// Handler pour les messages en arrière-plan
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Initialize Firebase
  await Firebase.initializeApp();
  
  try {
    // Set up dependency injection
    await setupLocator();
    
    print("Message en arrière-plan: ${message.messageId}");

    // Process message data if available
    final data = message.data;
    if (data.isNotEmpty) {
      print('Données du message: $data');
      
      // Handle course notifications if the required data is present
      if (data.containsKey('course_id') && data.containsKey('client_nom')) {
        try {
          // Try to save the notification
          final courseData = CourseNotificationData.fromFirebaseData(
            data,
            receivedAt: DateTime.now(),
          );
          await CourseNotificationStorage.saveNotification(courseData);
          print('Notification background sauvée: ${data['course_id']}');
        } catch (e) {
          print('Erreur lors du traitement de la notification de course: $e');
        }
      }
    }
  } catch (e) {
    print('Erreur traitement background: $e');
  }
}
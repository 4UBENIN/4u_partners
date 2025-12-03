import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:for_u_partners/app/app.locator.dart';
import 'package:for_u_partners/app/app.router.dart';
import 'package:for_u_partners/services/course_event_service.dart';
import 'package:for_u_partners/services/course_notificationstorage_service.dart';
import 'package:for_u_partners/services/sharedpreferences_service.dart';
import 'package:for_u_partners/services/local_notif_service.dart';
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
      print('🚀 [FCM] Début de l\'initialisation Firebase Messaging');

      await initAndCleanStorage();
      print('🚀 [FCM] Demande des permissions...');

      NotificationSettings settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      print('🚀 [FCM] Permission status: ${settings.authorizationStatus}');

      if (settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional) {
        print('🚀 [FCM] Permissions accordées, configuration des handlers...');

        await _setupMessageHandlers();
        print('🚀 [FCM] Handlers configurés');

        print('🚀 [FCM] Récupération du token FCM...');
        await _getToken();

        print('🚀 [FCM] Configuration du listener de token...');
        _setupTokenListener();

        print('✅ [FCM] Initialisation complète avec succès');
      } else {
        print('⚠️ [FCM] Permissions non accordées: ${settings.authorizationStatus}');
      }
    } catch (e, stackTrace) {
      print('❌ [FCM] Erreur initialisation FCM: $e');
      print('❌ [FCM] Stack trace: $stackTrace');
    }
  }

  /// Récupère le token FCM
  Future<void> _getToken() async {
    try {
      print('🎯 [FCM] _getToken appelé');
      print('🎯 [FCM] Platform: ${Platform.isIOS ? "iOS" : "Android"}');

      if (Platform.isIOS) {
        print('🎯 [FCM] Attente de 2 secondes pour iOS APNS...');
        await Future.delayed(const Duration(seconds: 2));
      }

      print('🎯 [FCM] Appel de _messaging.getToken()...');
      final String? token = await _messaging.getToken();

      if (token != null) {
        print('🎯 [FCM] Token FCM obtenu avec succès');
        print('🎯 [FCM] Token length: ${token.length}');
        print('🎯 [FCM] Token complet: $token');
        _currentToken = token;
        onTokenUpdate?.call(token);
      } else {
        print('⚠️ [FCM] Le token FCM est null');
      }
    } catch (e, stackTrace) {
      print('❌ [FCM] Erreur lors de la récupération du token FCM: $e');
      print('❌ [FCM] Stack trace: $stackTrace');
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

        // Show local notification with custom sound
        await LocalNotificationService.showNewCourseNotification(
          courseId: data['course_id'].toString(),
          pickupAddress: data['depart_adresse'] ?? 'Adresse de départ',
          price: double.tryParse(data['prix']?.toString() ?? '0') ?? 0.0,
          distance: int.tryParse(data['distance']?.toString() ?? '0') ?? 0,
        );

        // Transmettre au service d'événements (comme avant)
        _courseEventService.onNewCourseReceived(data);

        navigationServices.navigateToCoursesView();

        print(
            '✅ Notification course sauvée: ${courseData.courseId} à ${courseData.timestamp}');
      } else if (_isCancellationPayload(data)) {
        final courseId = data['course_id']?.toString();
        final reason = _extractCancellationReason(data);

        print('📱 Annulation détectée pour la course: $courseId');

        if (courseId != null && courseId.isNotEmpty) {
          await CourseNotificationStorage.removeNotification(courseId);

          await LocalNotificationService.showCourseCancelledNotification(
            courseId: courseId,
            reason: reason,
          );

          _courseEventService.onCourseCancelled(data);
        } else {
          print('⚠️ Impossible de traiter l\'annulation: course_id manquant');
        }
      } else {
        print('📱 Message non-course reçu: $data');
      }
    } catch (e) {
      print('❌ Erreur traitement message: $e');
    }
  }

  bool _isCancellationPayload(Map<String, dynamic> data) {
    final hasCourseId =
        data['course_id'] != null && data['course_id'].toString().isNotEmpty;
    if (!hasCourseId) return false;

    final status = data['status']?.toString().toLowerCase();
    final type = data['type']?.toString().toLowerCase();
    final hasDriverId = data.containsKey('conducteur_id');
    final missingCourseDetails =
        !data.containsKey('client_nom') && !data.containsKey('eta_minutes');

    final explicitlyCancelled = status == 'cancelled' ||
        type == 'cancelled' ||
        type == 'course_cancelled';

    // Cas observé : message avec seulement course_id, conducteur_id, etc.
    return explicitlyCancelled || (hasDriverId && missingCourseDetails);
  }

  String? _extractCancellationReason(Map<String, dynamic> data) {
    final possibleKeys = ['reason', 'motif', 'message'];
    for (final key in possibleKeys) {
      final value = data[key]?.toString();
      if (value != null && value.isNotEmpty) return value;
    }
    return null;
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
      print('════════════════════════════════════════════════════════════');
      print('📤 [FCM SEND] ENVOI DU TOKEN FCM VERS LE BACKEND');
      print('════════════════════════════════════════════════════════════');
      print('📤 [FCM SEND] Timestamp: ${DateTime.now().toIso8601String()}');
      print('📤 [FCM SEND] URL cible: $url');
      print('📤 [FCM SEND] FCM Token à envoyer:');
      print('📤 [FCM SEND] >>> $token <<<');
      print('📤 [FCM SEND] Token length: ${token.length} caractères');

      final authToken = await _sharedPreferencesServices.getToken();
      print('📤 [FCM SEND] Auth Token disponible: ${authToken != null && authToken.isNotEmpty}');
      if (authToken != null && authToken.isNotEmpty) {
        print('📤 [FCM SEND] Auth Token (preview): ${authToken.substring(0, 20)}...');
      }

      if (authToken == null || authToken.isEmpty) {
        print('❌ [FCM SEND] ÉCHEC: Token d\'authentification manquant');
        print('════════════════════════════════════════════════════════════');
        return false;
      }

      final requestBody = {'fcm_token': token};
      print('📤 [FCM SEND] ─────────────────────────────────────────────');
      print('📤 [FCM SEND] Request Body JSON:');
      print('📤 [FCM SEND] ${jsonEncode(requestBody)}');
      print('📤 [FCM SEND] ─────────────────────────────────────────────');
      print('📤 [FCM SEND] Headers:');
      print('📤 [FCM SEND]   - Content-Type: application/json');
      print('📤 [FCM SEND]   - Authorization: Bearer ${authToken.substring(0, 20)}...');
      print('📤 [FCM SEND]   - Accept: application/json');
      print('📤 [FCM SEND] ─────────────────────────────────────────────');
      print('📤 [FCM SEND] Envoi de la requête POST en cours...');

      final response = await http
          .post(
            Uri.parse(url),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $authToken',
              'Accept': 'application/json',
            },
            body: jsonEncode(requestBody),
          )
          .timeout(const Duration(seconds: 10));

      print('📥 [FCM SEND] ─────────────────────────────────────────────');
      print('📥 [FCM SEND] RÉPONSE DU SERVEUR:');
      print('📥 [FCM SEND] HTTP Status: ${response.statusCode}');
      print('📥 [FCM SEND] Response Headers: ${response.headers}');
      print('📥 [FCM SEND] Response Body: ${response.body}');
      print('📥 [FCM SEND] ─────────────────────────────────────────────');

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('✅ [FCM SEND] SUCCÈS! Token FCM envoyé et accepté par le backend');
        print('✅ [FCM SEND] URL: $url');
        print('✅ [FCM SEND] Token envoyé: $token');
        try {
          final responseData = jsonDecode(response.body);
          print('✅ [FCM SEND] Données de réponse parsées: $responseData');
        } catch (e) {
          print('⚠️ [FCM SEND] Réponse non-JSON (probablement OK): ${response.body}');
        }
        print('════════════════════════════════════════════════════════════');
        return true;
      } else {
        print('❌ [FCM SEND] ÉCHEC HTTP ${response.statusCode}');
        print('❌ [FCM SEND] URL: $url');
        print('❌ [FCM SEND] Token qui a échoué: $token');
        print('❌ [FCM SEND] Réponse du serveur: ${response.body}');
        print('════════════════════════════════════════════════════════════');
        return false;
      }
    } catch (e, stackTrace) {
      print('❌ [FCM SEND] EXCEPTION lors de l\'envoi du token!');
      print('❌ [FCM SEND] URL: $url');
      print('❌ [FCM SEND] Token concerné: $token');
      print('❌ [FCM SEND] Exception: $e');
      print('❌ [FCM SEND] Stack trace: $stackTrace');
      print('════════════════════════════════════════════════════════════');
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
  static Future<String?> getCurrentToken({int maxWaitSeconds = 10}) async {
    try {
      print('🔍 [FCM] getCurrentToken appelé');

      if (_currentToken != null && _currentToken!.isNotEmpty) {
        print('🔍 [FCM] Token trouvé en cache');
        print('🔍 [FCM] Cache token length: ${_currentToken!.length}');
        return _currentToken;
      }

      print('🔍 [FCM] Aucun token en cache, récupération depuis Firebase...');

      int attempts = 0;
      while (attempts < maxWaitSeconds) {
        String? token = await _messaging.getToken();

        if (token != null && token.isNotEmpty) {
          print('🔍 [FCM] Token récupéré depuis Firebase après ${attempts + 1}s');
          print('🔍 [FCM] Token length: ${token.length}');
          print('🔍 [FCM] Token: $token');
          _currentToken = token;
          return token;
        }

        if (attempts < maxWaitSeconds - 1) {
          print('⚠️ [FCM] Token null, attente de 1 seconde... (tentative ${attempts + 1}/$maxWaitSeconds)');
          await Future.delayed(Duration(seconds: 1));
        }
        attempts++;
      }

      print('⚠️ [FCM] Firebase a retourné un token null après $maxWaitSeconds tentatives');
      return null;
    } catch (e, stackTrace) {
      print('❌ [FCM] Erreur récupération token: $e');
      print('❌ [FCM] Stack trace: $stackTrace');
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
    print('🔐 [FCM] Nombre de tentatives maximum: $maxRetries');

    for (int attempt = 1; attempt <= maxRetries; attempt++) {
      try {
        print('🔐 [FCM] ===== Tentative $attempt/$maxRetries =====');
        print('🔐 [FCM] Récupération du token FCM...');
        String? token = await getCurrentToken();

        if (token != null && token.isNotEmpty) {
          print('🔐 [FCM] Token récupéré avec succès');
          print('🔐 [FCM] Longueur du token: ${token.length} caractères');
          print('🔐 [FCM] Appel de sendTokenToBackend...');

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
          print('⚠️ [FCM] Token est ${token == null ? "null" : "vide"}');
          if (attempt < maxRetries) {
            print('🔐 [FCM] Attente de 2 secondes avant nouvelle tentative...');
            await Future.delayed(Duration(seconds: 2));
          }
        }
      } catch (e, stackTrace) {
        print('❌ [FCM] Erreur récupération/envoi token (tentative $attempt): $e');
        print('❌ [FCM] Stack trace: $stackTrace');
        if (attempt < maxRetries) {
          print('🔐 [FCM] Attente de 2 secondes avant nouvelle tentative...');
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
      print('🔄 [FCM] Ancien token: ${_currentToken ?? "null"}');
      print('🔄 [FCM] Suppression de l\'ancien token...');
      await _messaging.deleteToken();
      _currentToken = null;

      print('🔄 [FCM] Récupération d\'un nouveau token...');
      await _getToken();

      if (_currentToken != null && _currentToken!.isNotEmpty) {
        print('✅ [FCM] Token rafraîchi avec succès');
        print('🔄 [FCM] Nouveau token: $_currentToken');
        print('🔄 [FCM] Token length: ${_currentToken!.length}');
        return true;
      } else {
        print('⚠️ [FCM] Token rafraîchi mais vide ou null');
        return false;
      }
    } catch (e, stackTrace) {
      print('❌ [FCM] Erreur lors du rafraîchissement du token: $e');
      print('❌ [FCM] Stack trace: $stackTrace');
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

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
      print('🚀 Initialisation Firebase Messaging...');
      
      // Nettoyer et initialiser le storage
      await initAndCleanStorage();
      
      // Initialiser les notifications locales AVANT de demander les permissions
      await setupFlutterNotifications();
      
      // Demander les permissions avec plus d'options pour iOS
      NotificationSettings settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false, // Demander explicitement les permissions
        criticalAlert: false,
        announcement: false,
      );

      print('📱 Statut des permissions: ${settings.authorizationStatus}');
      print('📱 Alert: ${settings.alert}');
      print('📱 Badge: ${settings.badge}');
      print('📱 Sound: ${settings.sound}');

      if (settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional) {
        
        print('✅ Permissions accordées, configuration des handlers...');
        
        // Configurer les handlers de messages
        await _setupMessageHandlers();

        // Récupérer le token selon la plateforme
        await _getToken();

        // Écouter les mises à jour de token
        _setupTokenListener();
        
        print('✅ Firebase Messaging initialisé avec succès');
      } else {
        print('❌ Permissions refusées: ${settings.authorizationStatus}');
      }
    } catch (e) {
      print('❌ Erreur initialisation FCM: $e');
    }
  }

  /// Récupère le token FCM avec gestion améliorée pour iOS
  Future<void> _getToken() async {
    try {
      print('🔑 Récupération du token FCM...');
      
      // Pour iOS, vérifier d'abord le token APNS
      if (Platform.isIOS) {
        print('📱 Plateforme iOS détectée, vérification APNS...');
        
        // Attendre que APNS soit prêt
        String? apnsToken = await _messaging.getAPNSToken();
        int attempts = 0;
        while (apnsToken == null && attempts < 5) {
          print('⏳ Attente du token APNS (tentative ${attempts + 1}/5)...');
          await Future.delayed(const Duration(seconds: 2));
          apnsToken = await _messaging.getAPNSToken();
          attempts++;
        }
        
        if (apnsToken != null) {
          print('✅ Token APNS obtenu: ${apnsToken.substring(0, 20)}...');
        } else {
          print('❌ Impossible d\'obtenir le token APNS après 5 tentatives');
          return;
        }
      }

      // Récupérer le token FCM
      final String? token = await _messaging.getToken();

      if (token != null) {
        _currentToken = token;
        onTokenUpdate?.call(token);
        print('✅ Token FCM obtenu avec succès');
        print('🔑 Token FCM: $token');
      } else {
        print('❌ Le token FCM est null');
      }
    } catch (e) {
      print('❌ Erreur lors de la récupération du token FCM: $e');
    }
  }

  /// Configure l'écoute des mises à jour de token
  void _setupTokenListener() {
    _messaging.onTokenRefresh.listen((newToken) async {
      print('🔄 Token FCM mis à jour');
      print('🔑 Nouveau token: ${newToken.substring(0, 50)}...');
      _currentToken = newToken;
      onTokenUpdate?.call(newToken);
    });
  }

  /// Gère les messages entrants avec logging détaillé
  void _handleIncomingMessage(RemoteMessage message) async {
    try {
      print('📨 === MESSAGE REÇU ===');
      print('📨 Message ID: ${message.messageId}');
      print('📨 From: ${message.from}');
      print('📨 Sent Time: ${message.sentTime}');
      print('📨 TTL: ${message.ttl}');
      
      // Afficher la notification si elle existe
      if (message.notification != null) {
        print('🔔 Notification:');
        print('   Title: ${message.notification!.title}');
        print('   Body: ${message.notification!.body}');
        print('   Android: ${message.notification!.android}');
        print('   Apple: ${message.notification!.apple}');
      }
      
      // Afficher les données
      print('📊 Data: ${message.data}');
      
      final data = message.data;

      // Vérifier si c'est une notification de course
      if (data.containsKey('course_id') &&
          data.containsKey('client_nom') &&
          data.containsKey('eta_minutes')) {
        print('🚗 Course détectée dans la notification');

        // Créer l'objet CourseNotificationData avec timestamp actuel
        final courseData = CourseNotificationData.fromFirebaseData(
          data,
          receivedAt: DateTime.now(),
        );

        // Sauvegarder en mémoire
        await CourseNotificationStorage.saveNotification(courseData);

        // Transmettre au service d'événements
        _courseEventService.onNewCourseReceived(data);

        // Naviguer vers la vue des courses
        navigationServices.navigateToCoursesView();

        print('✅ Notification course sauvée: ${courseData.courseId} à ${courseData.timestamp}');
      } else {
        print('📱 Message non-course reçu');
      }
      
      print('📨 === FIN MESSAGE ===');
    } catch (e) {
      print('❌ Erreur traitement message: $e');
    }
  }

  Future<void> _setupMessageHandlers() async {
    print('🔧 Configuration des handlers de messages...');
    
    // Messages en premier plan (app ouverte)
    FirebaseMessaging.onMessage.listen((message) {
      print('📱 Message reçu en PREMIER PLAN');
      _handleIncomingMessage(message);
    });

    // App ouverte depuis une notification (app en arrière-plan)
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      print('📱 App ouverte depuis notification (arrière-plan)');
      _handleIncomingMessage(message);
    });

    // App ouverte depuis une notification (app fermée)
    RemoteMessage? initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      print('📱 App ouverte depuis notification (app fermée)');
      _handleIncomingMessage(initialMessage);
    }
    
    print('✅ Handlers configurés');
  }

  /// Configuration améliorée des notifications locales
  Future<void> setupFlutterNotifications() async {
    print('🔧 Configuration des notifications locales...');
    
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestSoundPermission: true,
      requestBadgePermission: true,
      requestAlertPermission: true,
      requestCriticalPermission: false,
      requestProvisionalPermission: false,
    );

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (details) {
        print("📱 Réponse notification locale: ${details.payload}");
      },
    );

    // Handler pour les messages en premier plan
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('📱 Message en premier plan, affichage notification locale...');
      
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;

      // Traiter le message pour les courses
      _handleIncomingMessage(message);

      // Afficher la notification locale si elle existe
      if (notification != null) {
        flutterLocalNotificationsPlugin.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
            android: android != null
                ? const AndroidNotificationDetails(
                    'high_importance_channel',
                    'High Importance Notifications',
                    channelDescription: 'This channel is used for important notifications.',
                    importance: Importance.max,
                    priority: Priority.high,
                    icon: '@mipmap/ic_launcher',
                  )
                : null,
            iOS: const DarwinNotificationDetails(
              presentAlert: true,
              presentBadge: true,
              presentSound: true,
              sound: 'default',
            ),
          ),
          payload: jsonEncode(message.data),
        );
        print('✅ Notification locale affichée');
      }
    });
    
    print('✅ Notifications locales configurées');
  }

  /// Envoie le token au backend (méthode publique)
  Future<bool> sendTokenToBackend(String token, String url) async {
    try {
      final authToken = await _sharedPreferencesServices.getToken();
      print("🔑 === ENVOI TOKEN AU BACKEND ===");
      print("🔑 FCM Token: ${token.substring(0, 50)}...");
      print("🔑 Auth Token: ${authToken?.substring(0, 20)}...");
      print("🔑 URL: $url");
      
      if (authToken == null || authToken.isEmpty) {
        print('❌ Token d\'authentification manquant');
        return false;
      }

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

      print("📡 Réponse serveur: ${response.statusCode}");
      print("📡 Body: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('✅ Token envoyé avec succès vers: $url');
        return true;
      } else {
        print('❌ Erreur HTTP: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('❌ Erreur envoi token: $e');
      return false;
    }
  }

  Future<void> initAndCleanStorage() async {
    try {
      // Nettoyer les notifications expirées au démarrage
      await CourseNotificationStorage.cleanExpiredNotifications(
        maxAge: const Duration(hours: 24),
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
        print('🔑 Token depuis cache: ${_currentToken!.substring(0, 50)}...');
        return _currentToken;
      }

      // Sinon, récupérer depuis Firebase
      String? token = await _messaging.getToken();
      if (token != null) {
        _currentToken = token;
        print('🔑 Token depuis Firebase: ${token.substring(0, 50)}...');
      }
      return token;
    } catch (e) {
      print('❌ Erreur récupération token: $e');
      return null;
    }
  }

  /// Récupère le token depuis le cache uniquement (plus rapide)
  static String? getCachedToken() {
    if (_currentToken != null) {
      print('🔑 Token cached: ${_currentToken!.substring(0, 50)}...');
    }
    return _currentToken;
  }

  /// Récupère le token actuel et l'envoie au backend
  Future<bool> sendCurrentTokenToBackend(String url) async {
    try {
      String? token = await getCurrentToken();
      if (token != null) {
        return await sendTokenToBackend(token, url);
      }
      print('❌ Aucun token FCM disponible');
      return false;
    } catch (e) {
      print('❌ Erreur récupération token actuel: $e');
      return false;
    }
  }

  /// Actualise le token manuellement
  Future<bool> refreshToken() async {
    try {
      print('🔄 Actualisation du token...');
      await _messaging.deleteToken();
      await _getToken();
      print('✅ Token actualisé');
      return true;
    } catch (e) {
      print('❌ Erreur actualisation token: $e');
      return false;
    }
  }

  /// S'abonne à un topic avec vérification APNS pour iOS
  static Future<bool> subscribeToTopic(String topic) async {
    try {
      print('📡 Abonnement au topic: $topic');
      
      if (Platform.isIOS) {
        String? apnsToken = await _messaging.getAPNSToken();
        if (apnsToken == null) {
          print('⏳ Attente du token APNS...');
          await Future.delayed(const Duration(seconds: 3));
          apnsToken = await _messaging.getAPNSToken();
        }
        if (apnsToken == null) {
          print('❌ Token APNS non disponible');
          return false;
        }
        print('✅ Token APNS disponible pour l\'abonnement');
      }

      await _messaging.subscribeToTopic(topic);
      print('✅ Abonné au topic: $topic');
      return true;
    } catch (e) {
      print('❌ Erreur abonnement topic: $e');
      return false;
    }
  }

  /// Se désabonne d'un topic
  static Future<bool> unsubscribeFromTopic(String topic) async {
    try {
      print('📡 Désabonnement du topic: $topic');
      await _messaging.unsubscribeFromTopic(topic);
      print('✅ Désabonné du topic: $topic');
      return true;
    } catch (e) {
      print('❌ Erreur désabonnement topic: $e');
      return false;
    }
  }

  /// Supprime le token (désabonnement)
  Future<void> deleteToken() async {
    try {
      print('🗑️ Suppression du token...');
      await _messaging.deleteToken();
      _currentToken = null;
      print('✅ Token supprimé');
    } catch (e) {
      print('❌ Erreur suppression token: $e');
    }
  }
}

/// Handler amélioré pour les messages en arrière-plan
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  
  print('🌙 === MESSAGE EN ARRIÈRE-PLAN ===');
  print('🌙 Message ID: ${message.messageId}');
  print('🌙 From: ${message.from}');
  print('🌙 Sent Time: ${message.sentTime}');
  
  // Afficher la notification si elle existe
  if (message.notification != null) {
    print('🔔 Notification en arrière-plan:');
    print('   Title: ${message.notification!.title}');
    print('   Body: ${message.notification!.body}');
  }
  
  // Afficher les données
  print('📊 Data en arrière-plan: ${message.data}');

  // Initialiser le plugin de notifications locales pour l'arrière-plan
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  const DarwinInitializationSettings initializationSettingsIOS =
      DarwinInitializationSettings(
    requestSoundPermission: false, // Déjà demandé
    requestBadgePermission: false,
    requestAlertPermission: false,
  );

  const InitializationSettings initializationSettings =
      InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: initializationSettingsIOS,
  );

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  // Afficher une notification locale si le message contient une notification
  RemoteNotification? notification = message.notification;
  if (notification != null) {
    print('🔔 Affichage notification locale en arrière-plan...');
    
    await flutterLocalNotificationsPlugin.show(
      notification.hashCode,
      notification.title,
      notification.body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'high_importance_channel',
          'High Importance Notifications',
          channelDescription: 'This channel is used for important notifications.',
          importance: Importance.max,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
          sound: 'default',
        ),
      ),
      payload: jsonEncode(message.data),
    );
    
    print('✅ Notification locale affichée en arrière-plan');
  }

  // Traiter les données de course
  try {
    final data = message.data;
    if (data.containsKey('course_id') && data.containsKey('client_nom')) {
      print('🚗 Course reçue en arrière-plan');

      final courseData = CourseNotificationData.fromFirebaseData(
        data,
        receivedAt: DateTime.now(),
      );

      await CourseNotificationStorage.saveNotification(courseData);

      print('✅ Notification background sauvée: ${courseData.courseId}');
    }
  } catch (e) {
    print('❌ Erreur traitement background: $e');
  }
  
  print('🌙 === FIN MESSAGE ARRIÈRE-PLAN ===');
}

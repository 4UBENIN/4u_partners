import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:for_u_partners/app/app.locator.dart';
import 'package:for_u_partners/services/sharedpreferences_service.dart';
import 'package:for_u_partners/ui/common/api_constant.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class FirebaseMessagingService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final _sharedPreferencesServices = locator<SharedpreferencesService>();
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
      String? token;

      // Pour iOS, attendre le token APNS si nécessaire
      if (Platform.isIOS) {
        String? apnsToken = await _messaging.getAPNSToken();

        if (apnsToken == null) {
          // Attendre 3 secondes comme recommandé
          await Future.delayed(const Duration(seconds: 3));
          apnsToken = await _messaging.getAPNSToken();
        }
      }

      // Récupérer le token FCM
      token = await _messaging.getToken();

      if (token != null) {
        _currentToken = token; // Stocker le token
        onTokenUpdate?.call(token);
        // Ne pas envoyer automatiquement lors de l'init
        // L'envoi se fera manuellement selon le contexte
      }
    } catch (e) {
      print('Erreur récupération token: $e');
    }
  }

  /// Configure l'écoute des mises à jour de token
  void _setupTokenListener() {
    _messaging.onTokenRefresh.listen((newToken) async {
      _currentToken = newToken; // Mettre à jour le token stocké
      onTokenUpdate?.call(newToken);
      // Le token sera envoyé manuellement selon le contexte
    });
  }

  /// Configure les handlers pour les messages
  Future<void> _setupMessageHandlers() async {
    // Messages en premier plan
    FirebaseMessaging.onMessage.listen((message) {
      print('Message reçu: ${message.notification?.title}');
    });

    // Tap sur notification (app en arrière-plan)
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      print('Notification ouverte: ${message.notification?.title}');
    });

    // Tap sur notification (app fermée)
    RemoteMessage? initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      print(
          'App ouvert depuis notification: ${initialMessage.notification?.title}');
    }
  }

  /// Envoie le token au backend (méthode publique)
  Future<bool> sendTokenToBackend(String token, String url) async {
    try {
      final authToken = await _sharedPreferencesServices.getToken();
      print("=== AUTH TOKEN: $authToken ===");
      print("=== TOKEN: $token ===");
      if (authToken == null || authToken.isEmpty) {
        print('Token d\'authentification manquant');
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
          .timeout(Duration(seconds: 10));

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('Token envoyé avec succès vers: $url');
        return true;
      } else {
        print('Erreur HTTP: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('Erreur envoi token: $e');
      return false;
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
  Future<bool> sendCurrentTokenToBackend(String url) async {
    try {
      String? token = await getCurrentToken();
      if (token != null) {
        return await sendTokenToBackend(token, url);
      }
      print('Aucun token FCM disponible');
      return false;
    } catch (e) {
      print('Erreur récupération token actuel: $e');
      return false;
    }
  }

  /// Actualise le token manuellement
  Future<bool> refreshToken() async {
    try {
      await _messaging.deleteToken();
      await _getToken();
      return true;
    } catch (e) {
      print('Erreur actualisation token: $e');
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

  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: initializationSettingsIOS,
  );

  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse: (details) {
      // Gère la réponse à la notification si besoin
    },
  );

  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;

    if (notification != null) {
      flutterLocalNotificationsPlugin.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: android != null
              ? AndroidNotificationDetails(
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
  await Firebase.initializeApp();
  print("Message en arrière-plan: ${message.messageId}");
}


import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:logger/logger.dart';

class LocalNotificationService {
  static final FlutterLocalNotificationsPlugin
      _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 5,
      lineLength: 50,
      colors: true,
      printEmojis: true,
    ),
  );

  // Canaux de notification pour les chauffeurs
  static const String _channelId = '4u_driver_notifications';
  static const String _channelName = 'Notifications Chauffeur';
  static const String _channelDescription =
      'Notifications pour les chauffeurs (nouvelles courses, mises à jour, etc.)';

  // Types de notifications
  static const String _typeNewCourse = 'new_course';
  static const String _typeCourseAccepted = 'course_accepted';
  static const String _typeCourseCancelled = 'course_cancelled';
  static const String _typePaymentReceived = 'payment_received';
  static const String _typeCourseCompleted = 'course_completed';
  static const String _typeCourseStatusUpdate = 'course_status_update';

  // Initialiser le service de notifications
  static Future<void> initialize() async {
    try {
      tz.initializeTimeZones();

      // Configuration pour Android
      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      // Configuration pour iOS
      const DarwinInitializationSettings initializationSettingsIOS =
          DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      // Configuration générale
      const InitializationSettings initializationSettings =
          InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsIOS,
      );

      // Initialiser le plugin
      await _flutterLocalNotificationsPlugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );

      // Créer le canal de notification pour Android
      if (Platform.isAndroid) {
        await _createNotificationChannel();
      }

      // Demander les permissions pour iOS
      if (Platform.isIOS) {
        await _requestIOSPermissions();
      }

      _logger.i('Service de notifications locales initialisé avec succès');
    } catch (e) {
      _logger.e(
          'Erreur lors de l\'initialisation du service de notifications: $e');
    }
  }

  // Créer le canal de notification pour Android
  static Future<void> _createNotificationChannel() async {
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      _channelId,
      _channelName,
      description: _channelDescription,
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
      enableLights: true,
      ledColor: Color(0xFF184E9C), // Couleur de votre app
    );

    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  // Demander les permissions pour iOS
  static Future<void> _requestIOSPermissions() async {
    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(alert: true, badge: true, sound: true);
  }

  // Gestionnaire pour les taps sur les notifications
  static void _onNotificationTapped(NotificationResponse response) {
    final payload = response.payload?.split('|');
    final type = payload?.first ?? '';
    final data =
        payload != null && payload.length > 1 ? payload.sublist(1) : [];

    _logger.i(
        'Notification tappée - ID: ${response.id}, Type: $type, Data: $data');

    // Navigation en fonction du type de notification
    switch (type) {
      case _typeNewCourse:
        if (data.isNotEmpty) {
          // Naviguer vers la page de détails de la nouvelle course
          // Ex: NavigationService.navigateTo('/course/${data[0]}');
        }
        break;
      case _typeCourseAccepted:
        // Naviguer vers la page de suivi de course
        // Ex: NavigationService.navigateTo('/course/tracking/${data[0]}');
        break;
      case _typeCourseCancelled:
        // Afficher un message d'annulation
        break;
      case _typePaymentReceived:
        // Naviguer vers l'historique des paiements
        // Ex: NavigationService.navigateTo('/wallet');
        break;
      case _typeCourseCompleted:
        // Naviguer vers les détails de la course terminée
        // Ex: NavigationService.navigateTo('/course/${data[0]}/completed');
        break;
      case _typeCourseStatusUpdate:
        // Mettre à jour l'interface utilisateur avec le nouveau statut
        break;
      default:
        _logger.w('Type de notification inconnu: $type');
        break;
    }
  }

  // Afficher une notification pour une nouvelle course disponible
  static Future<void> showNewCourseNotification({
    required String courseId,
    required String pickupAddress,
    required double price,
    required int distance,
  }) async {
    try {
      final androidNotificationDetails = AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription: _channelDescription,
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
        color: const Color(0xFF184E9C),
        enableVibration: true,
        playSound: true,
        timeoutAfter: const Duration(seconds: 30).inMilliseconds,
        styleInformation: BigTextStyleInformation(
          'Nouvelle course disponible à $pickupAddress\n'
          'Prix: ${price.toStringAsFixed(2)}€ • Distance: ${distance}km',
          contentTitle: '🚖 Nouvelle course disponible',
          htmlFormatBigText: true,
        ),
        actions: <AndroidNotificationAction>[
          const AndroidNotificationAction(
            'accept',
            'Accepter',
            showsUserInterface: true,
          ),
          const AndroidNotificationAction(
            'reject',
            'Refuser',
            showsUserInterface: true,
          ),
        ],
      );

      const DarwinNotificationDetails iosNotificationDetails =
          DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        subtitle: 'Nouvelle course disponible',
        categoryIdentifier: 'NEW_COURSE',
      );

      final details = NotificationDetails(
        android: androidNotificationDetails,
        iOS: iosNotificationDetails,
      );

      await _flutterLocalNotificationsPlugin.show(
        DateTime.now().millisecondsSinceEpoch ~/ 1000, // ID unique
        '🚖 Nouvelle course disponible',
        'À $pickupAddress • ${price.toStringAsFixed(2)}€ • ${distance}km',
        details,
        payload: '$_typeNewCourse|$courseId',
      );

      _logger.i('Notification de nouvelle course envoyée: $courseId');
    } catch (e) {
      _logger.e(
          'Erreur lors de l\'envoi de la notification de nouvelle course: $e');
    }
  }

  // Afficher une notification de confirmation d'acceptation de course
  static Future<void> showCourseAcceptedNotification({
    required String courseId,
  }) async {
    try {
      const androidNotificationDetails = AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription: _channelDescription,
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
        color: Color(0xFF22C55E), // Vert pour succès
        enableVibration: true,
        playSound: true,
        styleInformation: BigTextStyleInformation(
          'Vous pouvez commencer le ramassage',
          contentTitle: 'Course acceptée',
          htmlFormatBigText: true,
        ),
      );

      const iosNotificationDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        //subtitle: 'Vous pouvez commencer le ramassage',
      );

      await _flutterLocalNotificationsPlugin.show(
        DateTime.now().millisecondsSinceEpoch ~/ 1000,
        'Course acceptée',
        'Vous pouvez commencer le ramassage',
        const NotificationDetails(
          android: androidNotificationDetails,
          iOS: iosNotificationDetails,
        ),
        payload: '$_typeCourseAccepted|$courseId',
      );
    } catch (e) {
      _logger
          .e('Erreur lors de l\'envoi de la notification d\'acceptation: $e');
    }
  }

  // Afficher une notification de paiement reçu
  static Future<void> showPaymentReceivedNotification({
    required double amount,
    required String courseId,
  }) async {
    try {
      final androidDetails = AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription: _channelDescription,
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
        color: const Color(0xFF22C55E), // Vert pour succès
        enableVibration: true,
        playSound: true,
        styleInformation: BigTextStyleInformation(
          'Paiement de ${amount.toStringAsFixed(2)}€ reçu pour la course #$courseId.\n'
          'Merci pour votre confiance!',
          contentTitle: '💳 Paiement reçu',
          htmlFormatBigText: true,
        ),
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        subtitle: 'Paiement reçu',
      );

      await _flutterLocalNotificationsPlugin.show(
        DateTime.now().millisecondsSinceEpoch ~/ 1000, // ID unique
        '💳 Paiement reçu',
        '${amount.toStringAsFixed(2)}€ pour la course #$courseId',
        NotificationDetails(
          android: androidDetails,
          iOS: iosDetails,
        ),
        payload: '$_typePaymentReceived|$courseId|$amount',
      );
    } catch (e) {
      _logger.e('Erreur lors de l\'envoi de la notification de paiement: $e');
    }
  }

  // Afficher une notification de course annulée
  static Future<void> showCourseCancelledNotification({
    required String courseId,
    String? reason,
  }) async {
    try {
      final message = reason != null
          ? 'La course #$courseId a été annulée. Raison: $reason'
          : 'La course #$courseId a été annulée';

      final androidDetails = AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription: _channelDescription,
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
        color: const Color(0xFFEF4444), // Rouge pour alerte
        enableVibration: true,
        playSound: true,
        styleInformation: BigTextStyleInformation(
          message,
          contentTitle: '❌ Course annulée',
          htmlFormatBigText: true,
        ),
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        subtitle: 'Course annulée',
      );

      await _flutterLocalNotificationsPlugin.show(
        DateTime.now().millisecondsSinceEpoch ~/ 1000, // ID unique
        '❌ Course annulée',
        reason ?? 'La course #$courseId a été annulée',
        NotificationDetails(
          android: androidDetails,
          iOS: iosDetails,
        ),
        payload: '$_typeCourseCancelled|$courseId',
      );
    } catch (e) {
      _logger.e('Erreur lors de l\'envoi de la notification d\'annulation: $e');
    }
  }

  // Afficher une notification de course terminée
  static Future<void> showCourseCompletedNotification({
    required String courseId,
    required double amount,
  }) async {
    try {
      final androidDetails = AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription: _channelDescription,
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
        color: const Color(0xFF10B981), // Vert émeraude
        enableVibration: true,
        playSound: true,
        styleInformation: BigTextStyleInformation(
          'Course #$courseId terminée avec succès !\n'
          'Montant gagné: ${amount.toStringAsFixed(2)}€',
          contentTitle: '✅ Course terminée',
          htmlFormatBigText: true,
        ),
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        subtitle: 'Course terminée',
      );

      await _flutterLocalNotificationsPlugin.show(
        DateTime.now().millisecondsSinceEpoch ~/ 1000, // ID unique
        '✅ Course terminée',
        'Vous avez gagné ${amount.toStringAsFixed(2)}€',
        NotificationDetails(
          android: androidDetails,
          iOS: iosDetails,
        ),
        payload: '$_typeCourseCompleted|$courseId|$amount',
      );
    } catch (e) {
      _logger.e(
          'Erreur lors de l\'envoi de la notification de course terminée: $e');
    }
  }

  // Afficher une notification de mise à jour de statut de course
  static Future<void> showCourseStatusUpdate({
    required String courseId,
    required String status,
    String? message,
  }) async {
    try {
      final androidDetails = AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription: _channelDescription,
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
        color: const Color(0xFF3B82F6), // Bleu
        enableVibration: true,
        playSound: true,
        styleInformation: BigTextStyleInformation(
          message ?? 'Statut de la course #$courseId mis à jour: $status',
          contentTitle: '🔄 Mise à jour de course',
          htmlFormatBigText: true,
        ),
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        subtitle: 'Mise à jour de course',
      );

      await _flutterLocalNotificationsPlugin.show(
        DateTime.now().millisecondsSinceEpoch ~/ 1000, // ID unique
        '🔄 Mise à jour de course #$courseId',
        'Nouveau statut: $status',
        NotificationDetails(
          android: androidDetails,
          iOS: iosDetails,
        ),
        payload: '$_typeCourseStatusUpdate|$courseId|$status',
      );
    } catch (e) {
      _logger.e(
          'Erreur lors de l\'envoi de la notification de mise à jour de statut: $e');
    }
  }

  // Afficher une notification d'attente de confirmation du client
  static Future<void> showWaitingForClientConfirmation({
    required String courseId,
  }) async {
    try {
      const androidNotificationDetails = AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription: _channelDescription,
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
        color: Color(0xFFF59E0B), // Orange pour mise en attente
        enableVibration: true,
        playSound: true,
        styleInformation: BigTextStyleInformation(
          'Veuillez patienter pendant que le client confirme la course.\n'
          'Vous recevrez une notification dès que la course sera confirmée.',
          contentTitle: '⏳ En attente de confirmation',
          htmlFormatBigText: true,
        ),
      );

      const iosNotificationDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        //subtitle: 'En attente de confirmation',
      );

      await _flutterLocalNotificationsPlugin.show(
        DateTime.now().millisecondsSinceEpoch ~/ 1000,
        '⏳ En attente de confirmation',
        'Veuillez patienter pendant que le client confirme la course.Vous recevrez une notification dès que la course sera confirmée.',
        const NotificationDetails(
          android: androidNotificationDetails,
          iOS: iosNotificationDetails,
        ),
        payload: '$_typeCourseStatusUpdate|$courseId|waiting_confirmation',
      );
    } catch (e) {
      _logger.e('Erreur lors de l\'envoi de la notification d\'attente: $e');
    }
  }

  // Afficher une notification de confirmation du client
  static Future<void> showClientConfirmedNotification({
    required String courseId,
  }) async {
    try {
      const androidNotificationDetails = AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription: _channelDescription,
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
        color: Color(0xFF22C55E), // Vert pour confirmation
        enableVibration: true,
        playSound: true,
        styleInformation: BigTextStyleInformation(
          'Le client a confirmé la course.\n'
          'Vous pouvez maintenant commencer le ramassage.',
          contentTitle: '✅ Course confirmée',
          htmlFormatBigText: true,
        ),
      );

      const iosNotificationDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        subtitle: 'Course confirmée',
      );

      await _flutterLocalNotificationsPlugin.show(
        DateTime.now().millisecondsSinceEpoch ~/ 1000,
        '✅ Course confirmée',
        'Vous pouvez commencer le ramassage',
        const NotificationDetails(
          android: androidNotificationDetails,
          iOS: iosNotificationDetails,
        ),
        payload: '$_typeCourseStatusUpdate|$courseId|confirmed',
      );
    } catch (e) {
      _logger
          .e('Erreur lors de l\'envoi de la notification de confirmation: $e');
    }
  }

  // Afficher une notification de démarrage de course
  static Future<void> showCourseStartedNotification({
    required String courseId,
  }) async {
    try {
      const androidNotificationDetails = AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription: _channelDescription,
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
        color: Color(0xFF3B82F6), // Bleu pour démarrage
        enableVibration: true,
        playSound: true,
        styleInformation: BigTextStyleInformation(
          'La course a démarré. Bonne route !',
          contentTitle: '🚗 Course démarrée',
          htmlFormatBigText: true,
        ),
      );

      const iosNotificationDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        subtitle: 'Course démarrée',
      );

      await _flutterLocalNotificationsPlugin.show(
        DateTime.now().millisecondsSinceEpoch ~/ 1000,
        '🚗 Course démarrée',
        'Bonne route !',
        const NotificationDetails(
          android: androidNotificationDetails,
          iOS: iosNotificationDetails,
        ),
        payload: '$_typeCourseStatusUpdate|$courseId|started',
      );
    } catch (e) {
      _logger.e('Erreur lors de l\'envoi de la notification de démarrage: $e');
    }
  }

  // Afficher une notification de fin de course
  static Future<void> showCourseFinishedNotification({
    required String courseId,
    required double amount,
  }) async {
    try {
      final androidNotificationDetails = AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription: _channelDescription,
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
        color: const Color(0xFF10B981), // Vert pour succès
        enableVibration: true,
        playSound: true,
        styleInformation: BigTextStyleInformation(
          'Course terminée avec succès !\n'
          'Montant gagné: ${amount.toStringAsFixed(2)}€',
          contentTitle: '🏁 Course terminée',
          htmlFormatBigText: true,
        ),
      );

      const iosNotificationDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        subtitle: 'Course terminée',
      );

      await _flutterLocalNotificationsPlugin.show(
        DateTime.now().millisecondsSinceEpoch ~/ 1000,
        '🏁 Course terminée',
        'Montant gagné: ${amount.toStringAsFixed(2)}€',
        NotificationDetails(
          android: androidNotificationDetails,
          iOS: iosNotificationDetails,
        ),
        payload: '$_typeCourseCompleted|$courseId',
      );
    } catch (e) {
      _logger
          .e('Erreur lors de l\'envoi de la notification de fin de course: $e');
    }
  }

  // Afficher une notification d'annulation de course
  static Future<void> showCourseAbortedNotification({
    required String courseId,
    String? reason,
  }) async {
    try {
      final message = reason != null
          ? 'La course a été annulée. Raison: $reason'
          : 'La course a été annulée';

      final androidNotificationDetails = AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription: _channelDescription,
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
        color: const Color(0xFFEF4444), // Rouge pour annulation
        enableVibration: true,
        playSound: true,
        styleInformation: BigTextStyleInformation(
          message,
          contentTitle: '❌ Course annulée',
          htmlFormatBigText: true,
        ),
      );

      const iosNotificationDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        subtitle: 'Course annulée',
      );

      await _flutterLocalNotificationsPlugin.show(
        DateTime.now().millisecondsSinceEpoch ~/ 1000,
        '❌ Course annulée',
        reason ?? 'La course a été annulée',
        NotificationDetails(
          android: androidNotificationDetails,
          iOS: iosNotificationDetails,
        ),
        payload: '$_typeCourseCancelled|$courseId',
      );
    } catch (e) {
      _logger.e('Erreur lors de l\'envoi de la notification d\'annulation: $e');
    }
  }

  // Annuler une notification spécifique
  static Future<void> cancelNotification(int notificationId) async {
    await _flutterLocalNotificationsPlugin.cancel(notificationId);
  }

  // Annuler toutes les notifications
  static Future<void> cancelAllNotifications() async {
    await _flutterLocalNotificationsPlugin.cancelAll();
  }
}

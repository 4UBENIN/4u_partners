import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:logger/logger.dart';
import 'package:for_u_partners/app/app.locator.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:for_u_partners/app/app.router.dart';

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
  static const String _channelId = '4u_driver_notifications_v4'; // Updated to v4 with proper AudioAttributes
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
    try {
      _logger.i('🔔 Creating notification channel: $_channelId');

      final androidPlugin = _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      if (androidPlugin != null) {
        // Only delete OLD channel versions (not the current one)
        // Once a channel is created with a specific ID, it cannot be modified
        // We should only delete truly obsolete versions
        try {
          await androidPlugin.deleteNotificationChannel('4u_driver_notifications_v2');
          await androidPlugin.deleteNotificationChannel('4u_driver_notifications_v3');
          _logger.i('🗑️ Deleted obsolete notification channels (v2, v3)');
        } catch (e) {
          _logger.w('⚠️ Could not delete old channels (might not exist): $e');
        }
      }

      // Create the notification channel with sound
      // Note: On Android 8.0+, once a channel is created, it CANNOT be modified
      // Users can only change settings manually in system settings
      final AndroidNotificationChannel channel = AndroidNotificationChannel(
        _channelId,
        _channelName,
        description: _channelDescription,
        importance: Importance.max, // Maximum importance for loudest volume
        playSound: true,
        sound: const RawResourceAndroidNotificationSound('car_horn_beep'),
        enableVibration: true,
        enableLights: true,
        ledColor: const Color(0xFF184E9C), // Couleur de votre app
        audioAttributesUsage: AudioAttributesUsage.notification, // Ensure proper audio routing
      );

      await androidPlugin?.createNotificationChannel(channel);
      _logger.i('✅ Notification channel $_channelId created/verified successfully');
      _logger.i('🔊 Sound configured: car_horn_beep (RawResourceAndroidNotificationSound)');
      _logger.i('🔊 Importance: MAX, AudioAttributesUsage: notification');

      // Log the actual sound resource path for debugging production builds
      debugPrint('🔊 [PRODUCTION DEBUG] Sound resource: android/app/src/main/res/raw/car_horn_beep.mp3');
      debugPrint('🔊 [PRODUCTION DEBUG] Channel ID: $_channelId');
      debugPrint('🔊 [PRODUCTION DEBUG] Play sound enabled: true');
    } catch (e, stackTrace) {
      _logger.e('❌ Error creating notification channel: $e');
      _logger.e('❌ Stack trace: $stackTrace');
      debugPrint('❌ [PRODUCTION DEBUG] Notification channel creation failed: $e');
    }
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

    try {
      final navigationService = locator<NavigationService>();

      // Navigation en fonction du type de notification
      switch (type) {
        case _typeNewCourse:
          _logger.i('📱 [LOCAL NOTIF TAP] New course notification tapped, navigating to CoursesView');
          // Navigate to courses view to show the accept ride bottom sheet
          navigationService.navigateTo(Routes.coursesView);
          break;
        case _typeCourseAccepted:
        case _typeCourseStatusUpdate:
          _logger.i('📱 [LOCAL NOTIF TAP] Course status notification tapped, navigating to CoursesView');
          // Navigate to courses view to show course status
          navigationService.navigateTo(Routes.coursesView);
          break;
        case _typeCourseCancelled:
          _logger.i('📱 [LOCAL NOTIF TAP] Course cancelled notification tapped');
          // Just navigate to courses view to show current state
          navigationService.navigateTo(Routes.coursesView);
          break;
        case _typePaymentReceived:
        case _typeCourseCompleted:
          _logger.i('📱 [LOCAL NOTIF TAP] Payment/completion notification tapped');
          // Could navigate to activity/history view in the future
          break;
        default:
          _logger.w('Type de notification inconnu: $type');
          break;
      }
    } catch (e) {
      _logger.e('❌ Error handling notification tap: $e');
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
      _logger.i('🔊 Showing new course notification for course: $courseId');
      _logger.i('🔊 Channel ID: $_channelId');
      _logger.i('🔊 Sound: car_horn_beep.mp3');
      _logger.i('🔊 Importance: MAX, Priority: MAX');

      // Production debug logging
      debugPrint('🔊 [PRODUCTION DEBUG] ==========================================');
      debugPrint('🔊 [PRODUCTION DEBUG] NEW COURSE NOTIFICATION');
      debugPrint('🔊 [PRODUCTION DEBUG] Course ID: $courseId');
      debugPrint('🔊 [PRODUCTION DEBUG] Platform: ${Platform.isAndroid ? "Android" : "iOS"}');
      debugPrint('🔊 [PRODUCTION DEBUG] Channel ID: $_channelId');
      debugPrint('🔊 [PRODUCTION DEBUG] Play sound: true');
      debugPrint('🔊 [PRODUCTION DEBUG] Sound resource: car_horn_beep');
      debugPrint('🔊 [PRODUCTION DEBUG] ==========================================');

      final androidNotificationDetails = AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription: _channelDescription,
        importance: Importance.max, // Maximum importance for loudest volume
        priority: Priority.max, // Maximum priority
        icon: '@mipmap/ic_launcher',
        color: const Color(0xFF184E9C),
        enableVibration: true,
        playSound: true,
        sound: const RawResourceAndroidNotificationSound('car_horn_beep'),
        timeoutAfter: const Duration(seconds: 30).inMilliseconds,
        audioAttributesUsage: AudioAttributesUsage.notification,
        styleInformation: BigTextStyleInformation(
          'Nouvelle course disponible à $pickupAddress\n'
          'Prix: ${price.toStringAsFixed(2)}€ • Distance: ${distance}km',
          contentTitle: 'Nouvelle course disponible',
          htmlFormatBigText: true,
        ),
      );

      const DarwinNotificationDetails iosNotificationDetails =
          DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        sound: 'car_horn_beep.mp3',
        subtitle: 'Nouvelle course disponible',
        categoryIdentifier: 'NEW_COURSE',
        interruptionLevel: InterruptionLevel.timeSensitive, // iOS: time-sensitive for maximum prominence
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

      _logger.i('✅ Notification de nouvelle course envoyée: $courseId');
      debugPrint('✅ [PRODUCTION DEBUG] Notification shown successfully');
    } catch (e, stackTrace) {
      _logger.e(
          '❌ Erreur lors de l\'envoi de la notification de nouvelle course: $e');
      _logger.e('❌ Stack trace: $stackTrace');
      debugPrint('❌ [PRODUCTION DEBUG] Failed to show notification: $e');
      debugPrint('❌ [PRODUCTION DEBUG] Stack: $stackTrace');
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

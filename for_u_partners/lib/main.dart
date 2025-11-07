import 'package:flutter/material.dart' as _i27 show Key;
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_platform_interface/webview_flutter_platform_interface.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';
import 'package:flutter/widgets.dart';

// Importations de l'application
import 'package:for_u_partners/app/app.router.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:for_u_partners/app/app.locator.dart';
import 'package:for_u_partners/app/app.dialogs.dart';
import 'package:for_u_partners/ui/common/get_fcm_token.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:for_u_partners/services/active_course_checker_service.dart';
import 'package:for_u_partners/services/course_restoration_service.dart';

// Gestionnaire de messages en arrière-plan
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print("Message en arrière-plan: ${message.messageId}");
}

// Point d'entrée principal de l'application
Future<void> main() async {
  // Initialisation du WebView
  if (WebViewPlatform.instance == null) {
    // Pour Android
    WebViewPlatform.instance = AndroidWebViewPlatform();
    
    // Pour iOS, on utilise WebKit
    if (WebViewPlatform.instance is! AndroidWebViewPlatform) {
      WebViewPlatform.instance = WebKitWebViewPlatform();
    }
  }
  
  // Initialisation de Firebase et des services
  WidgetsFlutterBinding.ensureInitialized();

  // Charger les variables d'environnement
print("🔄 Tentative de chargement du .env...");
try {
  await dotenv.load(fileName: ".env");
  print("✅ .env chargé");
  print("📍 API_ENDPOINT = ${dotenv.env['API_ENDPOINT']}");
  print("📍 Clés disponibles: ${dotenv.env.keys.toList()}");
} catch (e) {
  print("❌ Erreur chargement .env: $e");
}
  // Initialiser Firebase
  await Firebase.initializeApp();
  
  // Configurer l'injection de dépendances
  await setupLocator();
  setupDialogUi();
  initializeDateFormatting();
  
  // Configuration des notifications push
  final FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;
  await firebaseMessaging.setAutoInitEnabled(true);
  
  // Demander la permission pour les notifications
  final NotificationSettings settings = await firebaseMessaging.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );
  
  print('Permission status: ${settings.authorizationStatus}');
  
  // Configurer le gestionnaire de messages en arrière-plan
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  // Initialiser le service FCM complet avec gestion des notifications foreground
  final fcmService = FirebaseMessagingService();
  await fcmService.init();
  await fcmService.setupFlutterNotifications();

  // Lancer l'application
  runApp(const MainApp());
}


class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> with WidgetsBindingObserver {
  bool _hasCheckedOnInit = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Check for active course on app initialization
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAndRestoreActiveCourse(isInitialLoad: true);
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.resumed) {
      debugPrint('🔄 App resumed from background');
      // Add delay to allow router to finish navigation
      Future.delayed(const Duration(milliseconds: 1500), () {
        _checkAndRestoreActiveCourse(isInitialLoad: false);
      });
    }
  }

  Future<void> _checkAndRestoreActiveCourse({required bool isInitialLoad}) async {
    try {
      // Prevent multiple checks during initial load
      if (isInitialLoad && _hasCheckedOnInit) return;
      if (isInitialLoad) _hasCheckedOnInit = true;

      debugPrint('🔍 Checking for active course (initial: $isInitialLoad)...');

      // Wait for router to finish initial navigation
      await Future.delayed(const Duration(milliseconds: 2000));

      final activeCourseChecker = locator<ActiveCourseCheckerService>();
      final navigationService = locator<NavigationService>();
      final restorationService = locator<CourseRestorationService>();

      // Check for active course
      final activeCourseDetails = await activeCourseChecker.checkForActiveCourse();

      if (activeCourseDetails != null) {
        debugPrint('✅ Active course found, preparing restoration...');

        // Store the course data for restoration
        restorationService.setPendingRestoration(activeCourseDetails);

        // Navigate to courses view
        await navigationService.navigateTo(Routes.coursesView);

        debugPrint('✅ Navigated to courses view, restoration will happen on init');
      } else {
        debugPrint('ℹ️ No active course found');
      }
    } catch (e) {
      debugPrint('❌ Error during active course check: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'For U Partners',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      navigatorKey: StackedService.navigatorKey,
      onGenerateRoute: StackedRouter().onGenerateRoute,
      navigatorObservers: [
        StackedService.routeObserver,
      ],
      // Définir la route initiale
      initialRoute: Routes.startupView,
      // Gestionnaire de routes inconnues
      onUnknownRoute: (settings) => MaterialPageRoute(
        builder: (context) => Scaffold(
          body: Center(
            child: Text('Page non trouvée: ${settings.name}'),
          ),
        ),
      ),
    );
  }

}

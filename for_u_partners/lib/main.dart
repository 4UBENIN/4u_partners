import 'package:flutter/material.dart';
import 'package:for_u_partners/app/app.router.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:for_u_partners/app/app.dialogs.dart';
import 'package:for_u_partners/app/app.locator.dart';
import 'package:for_u_partners/ui/common/get_fcm_token.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:for_u_partners/services/active_course_checker_service.dart';
import 'package:for_u_partners/services/course_restoration_service.dart';

final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
Future<void> initNotifications() async {
  // Demander la permission
  NotificationSettings settings = await _firebaseMessaging.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );

  print('Permission status: ${settings.authorizationStatus}');
}
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print("📱 Message en arrière-plan: ${message.messageId}");
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupLocator();
  await Firebase.initializeApp();
  await FirebaseMessaging.instance.setAutoInitEnabled(true);
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  await FirebaseMessagingService().init();
  await FirebaseMessaging.instance.requestPermission();
  await FirebaseMessagingService().setupFlutterNotifications();
  setupDialogUi();
  await dotenv.load(fileName: ".env");
  await initializeDateFormatting('fr_FR');

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
      debugShowCheckedModeBanner: false,
      initialRoute: Routes.startupView,
      onGenerateRoute: StackedRouter().onGenerateRoute,
      navigatorKey: StackedService.navigatorKey,
      navigatorObservers: [StackedService.routeObserver],
    );
  }
}

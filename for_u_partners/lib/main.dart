import 'package:flutter/material.dart';
import 'package:for_u_partners/app/app.router.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:for_u_partners/app/app.dialogs.dart';
import 'package:for_u_partners/app/app.locator.dart';
import 'package:for_u_partners/ui/common/get_fcm_token.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:for_u_partners/app/app.bottomsheets.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

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
  setupBottomSheetUi();
  await dotenv.load(fileName: ".env");
  await initializeDateFormatting('fr_FR');

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

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

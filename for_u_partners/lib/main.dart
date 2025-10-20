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
  await dotenv.load(fileName: ".env");
  
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
  
  // Lancer l'application
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  
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

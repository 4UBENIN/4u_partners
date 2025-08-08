import 'package:flutter/material.dart';
import 'package:for_u_partners/app/app.router.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:for_u_partners/app/app.dialogs.dart';
import 'package:for_u_partners/app/app.locator.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:for_u_partners/app/app.bottomsheets.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupLocator();

  setupDialogUi();
  setupBottomSheetUi();
  await dotenv.load(fileName: ".env");

  // Initialisation des données locales pour le français
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

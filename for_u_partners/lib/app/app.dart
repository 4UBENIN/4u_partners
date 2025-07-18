import 'package:stacked/stacked_annotations.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:for_u_partners/ui/views/home/home_view.dart';
import 'package:for_u_partners/ui/views/login/login_view.dart';
import 'package:for_u_partners/ui/views/startup/startup_view.dart';
import 'package:for_u_partners/ui/views/register/register_view.dart';
import 'package:for_u_partners/ui/bottom_sheets/notice/notice_sheet.dart';
import 'package:for_u_partners/ui/dialogs/info_alert/info_alert_dialog.dart';
import 'package:for_u_partners/ui/views/register_profile/register_profile_view.dart';
// @stacked-import

@StackedApp(
  routes: [
    MaterialRoute(page: HomeView),
    MaterialRoute(page: StartupView),
    MaterialRoute(page: RegisterView),
    MaterialRoute(page: LoginView),
    MaterialRoute(page: RegisterProfileView),
// @stacked-route
  ],
  dependencies: [
    LazySingleton(classType: BottomSheetService),
    LazySingleton(classType: DialogService),
    LazySingleton(classType: NavigationService),
    // @stacked-service
  ],
  bottomsheets: [
    StackedBottomsheet(classType: NoticeSheet),
    // @stacked-bottom-sheet
  ],
  dialogs: [
    StackedDialog(classType: InfoAlertDialog),
    // @stacked-dialog
  ],
)
class App {}

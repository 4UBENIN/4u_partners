import 'package:stacked/stacked_annotations.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:for_u_partners/ui/views/startup/startup_view.dart';
import 'package:for_u_partners/ui/views/auth/login/login_view.dart';
import 'package:for_u_partners/ui/views/drivers/home/home_view.dart';
import 'package:for_u_partners/services/sharedpreferences_service.dart';
import 'package:for_u_partners/ui/views/drivers/profil/profil_view.dart';
import 'package:for_u_partners/ui/views/auth/register/register_view.dart';
import 'package:for_u_partners/ui/bottom_sheets/notice/notice_sheet.dart';
import 'package:for_u_partners/ui/views/drivers/courses/courses_view.dart';
import 'package:for_u_partners/ui/views/drivers/homemain/homemain_view.dart';
import 'package:for_u_partners/ui/dialogs/info_alert/info_alert_dialog.dart';
import 'package:for_u_partners/ui/views/drivers/activity/activity_view.dart';
import 'package:for_u_partners/ui/views/drivers/notifications/notifications_view.dart';
import 'package:for_u_partners/ui/views/pressing/home_pressing/home_pressing_view.dart';
import 'package:for_u_partners/ui/views/auth/register_profile/register_profile_view.dart';
import 'package:for_u_partners/ui/views/drivers/activitydetails/activitydetails_view.dart';
import 'package:for_u_partners/ui/views/pressing/compte_pressing/compte_pressing_view.dart';
import 'package:for_u_partners/ui/views/pressing/nav_bar_pressing/nav_bar_pressing_view.dart';
import 'package:for_u_partners/ui/views/pressing/activites_pressing/activites_pressing_view.dart';
import 'package:for_u_partners/ui/views/pressing/notifications_pressing/notifications_pressing_view.dart';
// @stacked-import

@StackedApp(
  routes: [
    MaterialRoute(page: StartupView),
    MaterialRoute(page: HomeView),
    MaterialRoute(page: ActivityView),
    MaterialRoute(page: CoursesView),
    MaterialRoute(page: NotificationsView),
    MaterialRoute(page: ProfilView),
    MaterialRoute(page: HomemainView),
    MaterialRoute(page: ActivitydetailsView),
    MaterialRoute(page: LoginView),
    MaterialRoute(page: RegisterView),
    MaterialRoute(page: RegisterProfileView),
    MaterialRoute(page: HomePressingView),
    MaterialRoute(page: NavBarPressingView),
    MaterialRoute(page: ActivitesPressingView),
    MaterialRoute(page: NotificationsPressingView),
    MaterialRoute(page: ComptePressingView),
// @stacked-route
  ],
  dependencies: [
    LazySingleton(classType: BottomSheetService),
    LazySingleton(classType: DialogService),
    LazySingleton(classType: NavigationService),
    LazySingleton(classType: SharedpreferencesService),
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

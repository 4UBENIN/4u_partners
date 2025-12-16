import 'package:for_u_partners/services/profile_photo_service.dart';
import 'package:for_u_partners/ui/views/drivers/documents/documents_viewmodel.dart';
import 'package:for_u_partners/ui/views/drivers/documents/add_document.dart';
import 'package:for_u_partners/ui/views/drivers/homemain/homemain_viewmodel.dart';
import 'package:for_u_partners/ui/views/drivers/vehicles/vehicles_viewmodel.dart' as vehicle_vm;
import 'package:for_u_partners/ui/views/drivers/courses/courses_viewmodel.dart';
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
import 'package:for_u_partners/ui/views/delivery/delivery_home/delivery_home_view.dart';
import 'package:for_u_partners/ui/views/pressing/home_pressing/home_pressing_view.dart';
import 'package:for_u_partners/ui/views/auth/register_profile/register_profile_view.dart';
import 'package:for_u_partners/ui/views/drivers/activitydetails/activitydetails_view.dart';
import 'package:for_u_partners/ui/views/drivers/vehicles/vehicles_view.dart';
import 'package:for_u_partners/ui/views/drivers/documents/documents_view.dart';
import 'package:for_u_partners/ui/views/drivers/documents/document_viewer_view.dart';
import 'package:for_u_partners/ui/views/pressing/compte_pressing/compte_pressing_view.dart';
import 'package:for_u_partners/ui/views/delivery/compte_delivery/compte_delivery_view.dart';
import 'package:for_u_partners/ui/views/delivery/delivery_nav_bar/delivery_nav_bar_view.dart';
import 'package:for_u_partners/ui/views/pressing/nav_bar_pressing/nav_bar_pressing_view.dart';
import 'package:for_u_partners/ui/views/delivery/courses_delivery/courses_delivery_view.dart';
import 'package:for_u_partners/ui/views/pressing/activites_pressing/activites_pressing_view.dart';
import 'package:for_u_partners/ui/views/delivery/activities_delivery/activities_delivery_view.dart';
import 'package:for_u_partners/ui/views/delivery/notifications_delivery/notifications_delivery_view.dart';
import 'package:for_u_partners/ui/views/pressing/notifications_pressing/notifications_pressing_view.dart';
import 'package:for_u_partners/services/auth_service.dart';
import 'package:for_u_partners/services/driver_service.dart';
import 'package:for_u_partners/services/wallet_service.dart';
// import 'package:for_u_partners/services/chat_service.dart'; // OLD Firestore-based chat
import 'package:for_u_partners/services/chat_service_api.dart';
import 'package:for_u_partners/repositories/chat_repository.dart';
import 'package:for_u_partners/repositories/chat_repository_impl.dart';
import 'package:for_u_partners/services/pickers_service.dart';
import 'package:http/http.dart' as http;
import 'package:for_u_partners/services/vehicle_service.dart';
import 'package:for_u_partners/services/active_course_checker_service.dart';
import 'package:for_u_partners/services/course_restoration_service.dart';
import 'package:for_u_partners/services/arrival_state_service.dart';
import 'package:for_u_partners/services/pause_state_service.dart';
import 'package:for_u_partners/services/location_tracking_service.dart';
import 'package:for_u_partners/services/payout_service.dart';
import 'package:for_u_partners/ui/views/drivers/payout/create_payout_view.dart';
import 'package:for_u_partners/ui/views/drivers/payout/payout_history_view.dart';
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
    MaterialRoute(page: DeliveryNavBarView),
    MaterialRoute(page: DeliveryHomeView),
    MaterialRoute(page: NotificationsDeliveryView),
    MaterialRoute(page: CompteDeliveryView),
    MaterialRoute(page: ActivitiesDeliveryView),
    MaterialRoute(page: CoursesDeliveryView),
    MaterialRoute(page: MesVehiculesView),
    MaterialRoute(page: DocumentsView),
    MaterialRoute(page: AddDocumentView),
    MaterialRoute(page: DocumentViewerView),
    MaterialRoute(page: CreatePayoutView),
    MaterialRoute(page: PayoutHistoryView),
// @stacked-route
  ],
  dependencies: const [
    LazySingleton(classType: BottomSheetService),
    LazySingleton(classType: DialogService),
    LazySingleton(classType: NavigationService),
    LazySingleton(classType: SnackbarService),
    LazySingleton(classType: SharedpreferencesService),
    LazySingleton(classType: AuthService),
    LazySingleton(classType: DriverService),
    LazySingleton(classType: WalletService),
    // OLD: LazySingleton(classType: ChatService), // Replaced by ChatServiceApi
    // New Chat API dependencies
    LazySingleton(classType: ChatRepositoryImpl, asType: ChatRepository),
    LazySingleton(classType: ChatServiceApi),
    LazySingleton(classType: PickersService),
    LazySingleton(classType: VehicleService),
    LazySingleton(classType: ActiveCourseCheckerService),
    LazySingleton(classType: CourseRestorationService),
    LazySingleton(classType: ArrivalStateService),
    LazySingleton(classType: PauseStateService),
    LazySingleton(classType: LocationTrackingService),
    LazySingleton(classType: PayoutService),
    Singleton(classType: HomemainViewModel),
    Singleton(classType: vehicle_vm.MesVehiculesViewModel),
    Singleton(classType: DocumentsViewModel),
    Singleton(classType: CoursesViewModel),
    LazySingleton(classType: ProfilePhotoService),
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

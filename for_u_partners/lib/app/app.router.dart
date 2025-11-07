// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// StackedNavigatorGenerator
// **************************************************************************

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:flutter/material.dart' as _i28;
import 'package:flutter/material.dart';
import 'package:for_u_partners/models/document_model.dart' as _i30;
import 'package:for_u_partners/ui/views/auth/login/login_view.dart' as _i10;
import 'package:for_u_partners/ui/views/auth/register/register_view.dart'
    as _i11;
import 'package:for_u_partners/ui/views/auth/register_profile/register_profile_view.dart'
    as _i12;
import 'package:for_u_partners/ui/views/delivery/activities_delivery/activities_delivery_view.dart'
    as _i22;
import 'package:for_u_partners/ui/views/delivery/compte_delivery/compte_delivery_view.dart'
    as _i21;
import 'package:for_u_partners/ui/views/delivery/courses_delivery/courses_delivery_view.dart'
    as _i23;
import 'package:for_u_partners/ui/views/delivery/delivery_home/delivery_home_view.dart'
    as _i19;
import 'package:for_u_partners/ui/views/delivery/delivery_nav_bar/delivery_nav_bar_view.dart'
    as _i18;
import 'package:for_u_partners/ui/views/delivery/notifications_delivery/notifications_delivery_view.dart'
    as _i20;
import 'package:for_u_partners/ui/views/drivers/activity/activity_view.dart'
    as _i4;
import 'package:for_u_partners/ui/views/drivers/activity/models/activity_model.dart'
    as _i29;
import 'package:for_u_partners/ui/views/drivers/activitydetails/activitydetails_view.dart'
    as _i9;
import 'package:for_u_partners/ui/views/drivers/courses/courses_view.dart'
    as _i5;
import 'package:for_u_partners/ui/views/drivers/documents/add_document.dart'
    as _i26;
import 'package:for_u_partners/ui/views/drivers/documents/document_viewer_view.dart'
    as _i27;
import 'package:for_u_partners/ui/views/drivers/documents/documents_view.dart'
    as _i25;
import 'package:for_u_partners/ui/views/drivers/home/home_view.dart' as _i3;
import 'package:for_u_partners/ui/views/drivers/homemain/homemain_view.dart'
    as _i8;
import 'package:for_u_partners/ui/views/drivers/notifications/notifications_view.dart'
    as _i6;
import 'package:for_u_partners/ui/views/drivers/profil/profil_view.dart' as _i7;
import 'package:for_u_partners/ui/views/drivers/vehicles/vehicles_view.dart'
    as _i24;
import 'package:for_u_partners/ui/views/pressing/activites_pressing/activites_pressing_view.dart'
    as _i15;
import 'package:for_u_partners/ui/views/pressing/compte_pressing/compte_pressing_view.dart'
    as _i17;
import 'package:for_u_partners/ui/views/pressing/home_pressing/home_pressing_view.dart'
    as _i13;
import 'package:for_u_partners/ui/views/pressing/nav_bar_pressing/nav_bar_pressing_view.dart'
    as _i14;
import 'package:for_u_partners/ui/views/pressing/notifications_pressing/notifications_pressing_view.dart'
    as _i16;
import 'package:for_u_partners/ui/views/startup/startup_view.dart' as _i2;
import 'package:stacked/stacked.dart' as _i1;
import 'package:stacked_services/stacked_services.dart' as _i31;

class Routes {
  static const startupView = '/startup-view';

  static const homeView = '/home-view';

  static const activityView = '/activity-view';

  static const coursesView = '/courses-view';

  static const notificationsView = '/notifications-view';

  static const profilView = '/profil-view';

  static const homemainView = '/homemain-view';

  static const activitydetailsView = '/activitydetails-view';

  static const loginView = '/login-view';

  static const registerView = '/register-view';

  static const registerProfileView = '/register-profile-view';

  static const homePressingView = '/home-pressing-view';

  static const navBarPressingView = '/nav-bar-pressing-view';

  static const activitesPressingView = '/activites-pressing-view';

  static const notificationsPressingView = '/notifications-pressing-view';

  static const comptePressingView = '/compte-pressing-view';

  static const deliveryNavBarView = '/delivery-nav-bar-view';

  static const deliveryHomeView = '/delivery-home-view';

  static const notificationsDeliveryView = '/notifications-delivery-view';

  static const compteDeliveryView = '/compte-delivery-view';

  static const activitiesDeliveryView = '/activities-delivery-view';

  static const coursesDeliveryView = '/courses-delivery-view';

  static const mesVehiculesView = '/mes-vehicules-view';

  static const documentsView = '/documents-view';

  static const addDocumentView = '/add-document-view';

  static const documentViewerView = '/document-viewer-view';

  static const all = <String>{
    startupView,
    homeView,
    activityView,
    coursesView,
    notificationsView,
    profilView,
    homemainView,
    activitydetailsView,
    loginView,
    registerView,
    registerProfileView,
    homePressingView,
    navBarPressingView,
    activitesPressingView,
    notificationsPressingView,
    comptePressingView,
    deliveryNavBarView,
    deliveryHomeView,
    notificationsDeliveryView,
    compteDeliveryView,
    activitiesDeliveryView,
    coursesDeliveryView,
    mesVehiculesView,
    documentsView,
    addDocumentView,
    documentViewerView,
  };
}

class StackedRouter extends _i1.RouterBase {
  final _routes = <_i1.RouteDef>[
    _i1.RouteDef(
      Routes.startupView,
      page: _i2.StartupView,
    ),
    _i1.RouteDef(
      Routes.homeView,
      page: _i3.HomeView,
    ),
    _i1.RouteDef(
      Routes.activityView,
      page: _i4.ActivityView,
    ),
    _i1.RouteDef(
      Routes.coursesView,
      page: _i5.CoursesView,
    ),
    _i1.RouteDef(
      Routes.notificationsView,
      page: _i6.NotificationsView,
    ),
    _i1.RouteDef(
      Routes.profilView,
      page: _i7.ProfilView,
    ),
    _i1.RouteDef(
      Routes.homemainView,
      page: _i8.HomemainView,
    ),
    _i1.RouteDef(
      Routes.activitydetailsView,
      page: _i9.ActivitydetailsView,
    ),
    _i1.RouteDef(
      Routes.loginView,
      page: _i10.LoginView,
    ),
    _i1.RouteDef(
      Routes.registerView,
      page: _i11.RegisterView,
    ),
    _i1.RouteDef(
      Routes.registerProfileView,
      page: _i12.RegisterProfileView,
    ),
    _i1.RouteDef(
      Routes.homePressingView,
      page: _i13.HomePressingView,
    ),
    _i1.RouteDef(
      Routes.navBarPressingView,
      page: _i14.NavBarPressingView,
    ),
    _i1.RouteDef(
      Routes.activitesPressingView,
      page: _i15.ActivitesPressingView,
    ),
    _i1.RouteDef(
      Routes.notificationsPressingView,
      page: _i16.NotificationsPressingView,
    ),
    _i1.RouteDef(
      Routes.comptePressingView,
      page: _i17.ComptePressingView,
    ),
    _i1.RouteDef(
      Routes.deliveryNavBarView,
      page: _i18.DeliveryNavBarView,
    ),
    _i1.RouteDef(
      Routes.deliveryHomeView,
      page: _i19.DeliveryHomeView,
    ),
    _i1.RouteDef(
      Routes.notificationsDeliveryView,
      page: _i20.NotificationsDeliveryView,
    ),
    _i1.RouteDef(
      Routes.compteDeliveryView,
      page: _i21.CompteDeliveryView,
    ),
    _i1.RouteDef(
      Routes.activitiesDeliveryView,
      page: _i22.ActivitiesDeliveryView,
    ),
    _i1.RouteDef(
      Routes.coursesDeliveryView,
      page: _i23.CoursesDeliveryView,
    ),
    _i1.RouteDef(
      Routes.mesVehiculesView,
      page: _i24.MesVehiculesView,
    ),
    _i1.RouteDef(
      Routes.documentsView,
      page: _i25.DocumentsView,
    ),
    _i1.RouteDef(
      Routes.addDocumentView,
      page: _i26.AddDocumentView,
    ),
    _i1.RouteDef(
      Routes.documentViewerView,
      page: _i27.DocumentViewerView,
    ),
  ];

  final _pagesMap = <Type, _i1.StackedRouteFactory>{
    _i2.StartupView: (data) {
      return _i28.MaterialPageRoute<dynamic>(
        builder: (context) => const _i2.StartupView(),
        settings: data,
      );
    },
    _i3.HomeView: (data) {
      return _i28.MaterialPageRoute<dynamic>(
        builder: (context) => const _i3.HomeView(),
        settings: data,
      );
    },
    _i4.ActivityView: (data) {
      return _i28.MaterialPageRoute<dynamic>(
        builder: (context) => const _i4.ActivityView(),
        settings: data,
      );
    },
    _i5.CoursesView: (data) {
      return _i28.MaterialPageRoute<dynamic>(
        builder: (context) => const _i5.CoursesView(),
        settings: data,
      );
    },
    _i6.NotificationsView: (data) {
      return _i28.MaterialPageRoute<dynamic>(
        builder: (context) => const _i6.NotificationsView(),
        settings: data,
      );
    },
    _i7.ProfilView: (data) {
      return _i28.MaterialPageRoute<dynamic>(
        builder: (context) => const _i7.ProfilView(),
        settings: data,
      );
    },
    _i8.HomemainView: (data) {
      return _i28.MaterialPageRoute<dynamic>(
        builder: (context) => const _i8.HomemainView(),
        settings: data,
      );
    },
    _i9.ActivitydetailsView: (data) {
      final args = data.getArgs<ActivitydetailsViewArguments>(
        orElse: () => const ActivitydetailsViewArguments(),
      );
      return _i28.MaterialPageRoute<dynamic>(
        builder: (context) =>
            _i9.ActivitydetailsView(key: args.key, activity: args.activity),
        settings: data,
      );
    },
    _i10.LoginView: (data) {
      return _i28.MaterialPageRoute<dynamic>(
        builder: (context) => const _i10.LoginView(),
        settings: data,
      );
    },
    _i11.RegisterView: (data) {
      return _i28.MaterialPageRoute<dynamic>(
        builder: (context) => const _i11.RegisterView(),
        settings: data,
      );
    },
    _i12.RegisterProfileView: (data) {
      final args = data.getArgs<RegisterProfileViewArguments>(nullOk: false);
      return _i28.MaterialPageRoute<dynamic>(
        builder: (context) => _i12.RegisterProfileView(
            args.selectedProfile,
            args.phoneNumber,
            args.mail,
            args.password,
            args.firstName,
            args.lastName,
            args.address,
            key: args.key),
        settings: data,
      );
    },
    _i13.HomePressingView: (data) {
      return _i28.MaterialPageRoute<dynamic>(
        builder: (context) => const _i13.HomePressingView(),
        settings: data,
      );
    },
    _i14.NavBarPressingView: (data) {
      return _i28.MaterialPageRoute<dynamic>(
        builder: (context) => const _i14.NavBarPressingView(),
        settings: data,
      );
    },
    _i15.ActivitesPressingView: (data) {
      return _i28.MaterialPageRoute<dynamic>(
        builder: (context) => const _i15.ActivitesPressingView(),
        settings: data,
      );
    },
    _i16.NotificationsPressingView: (data) {
      return _i28.MaterialPageRoute<dynamic>(
        builder: (context) => const _i16.NotificationsPressingView(),
        settings: data,
      );
    },
    _i17.ComptePressingView: (data) {
      return _i28.MaterialPageRoute<dynamic>(
        builder: (context) => const _i17.ComptePressingView(),
        settings: data,
      );
    },
    _i18.DeliveryNavBarView: (data) {
      return _i28.MaterialPageRoute<dynamic>(
        builder: (context) => const _i18.DeliveryNavBarView(),
        settings: data,
      );
    },
    _i19.DeliveryHomeView: (data) {
      return _i28.MaterialPageRoute<dynamic>(
        builder: (context) => const _i19.DeliveryHomeView(),
        settings: data,
      );
    },
    _i20.NotificationsDeliveryView: (data) {
      return _i28.MaterialPageRoute<dynamic>(
        builder: (context) => const _i20.NotificationsDeliveryView(),
        settings: data,
      );
    },
    _i21.CompteDeliveryView: (data) {
      return _i28.MaterialPageRoute<dynamic>(
        builder: (context) => const _i21.CompteDeliveryView(),
        settings: data,
      );
    },
    _i22.ActivitiesDeliveryView: (data) {
      return _i28.MaterialPageRoute<dynamic>(
        builder: (context) => const _i22.ActivitiesDeliveryView(),
        settings: data,
      );
    },
    _i23.CoursesDeliveryView: (data) {
      return _i28.MaterialPageRoute<dynamic>(
        builder: (context) => const _i23.CoursesDeliveryView(),
        settings: data,
      );
    },
    _i24.MesVehiculesView: (data) {
      return _i28.MaterialPageRoute<dynamic>(
        builder: (context) => const _i24.MesVehiculesView(),
        settings: data,
      );
    },
    _i25.DocumentsView: (data) {
      return _i28.MaterialPageRoute<dynamic>(
        builder: (context) => const _i25.DocumentsView(),
        settings: data,
      );
    },
    _i26.AddDocumentView: (data) {
      return _i28.MaterialPageRoute<dynamic>(
        builder: (context) => const _i26.AddDocumentView(),
        settings: data,
      );
    },
    _i27.DocumentViewerView: (data) {
      final args = data.getArgs<DocumentViewerViewArguments>(nullOk: false);
      return _i28.MaterialPageRoute<dynamic>(
        builder: (context) =>
            _i27.DocumentViewerView(key: args.key, document: args.document),
        settings: data,
      );
    },
  };

  @override
  List<_i1.RouteDef> get routes => _routes;

  @override
  Map<Type, _i1.StackedRouteFactory> get pagesMap => _pagesMap;
}

class ActivitydetailsViewArguments {
  const ActivitydetailsViewArguments({
    this.key,
    this.activity,
  });

  final _i28.Key? key;

  final _i29.ActivityModel? activity;

  @override
  String toString() {
    return '{"key": "$key", "activity": "$activity"}';
  }

  @override
  bool operator ==(covariant ActivitydetailsViewArguments other) {
    if (identical(this, other)) return true;
    return other.key == key && other.activity == activity;
  }

  @override
  int get hashCode {
    return key.hashCode ^ activity.hashCode;
  }
}

class RegisterProfileViewArguments {
  const RegisterProfileViewArguments({
    required this.selectedProfile,
    required this.phoneNumber,
    required this.mail,
    required this.password,
    required this.firstName,
    required this.lastName,
    required this.address,
    this.key,
  });

  final String selectedProfile;

  final String phoneNumber;

  final String mail;

  final String password;

  final String firstName;

  final String lastName;

  final String address;

  final _i28.Key? key;

  @override
  String toString() {
    return '{"selectedProfile": "$selectedProfile", "phoneNumber": "$phoneNumber", "mail": "$mail", "password": "$password", "firstName": "$firstName", "lastName": "$lastName", "address": "$address", "key": "$key"}';
  }

  @override
  bool operator ==(covariant RegisterProfileViewArguments other) {
    if (identical(this, other)) return true;
    return other.selectedProfile == selectedProfile &&
        other.phoneNumber == phoneNumber &&
        other.mail == mail &&
        other.password == password &&
        other.firstName == firstName &&
        other.lastName == lastName &&
        other.address == address &&
        other.key == key;
  }

  @override
  int get hashCode {
    return selectedProfile.hashCode ^
        phoneNumber.hashCode ^
        mail.hashCode ^
        password.hashCode ^
        firstName.hashCode ^
        lastName.hashCode ^
        address.hashCode ^
        key.hashCode;
  }
}

class DocumentViewerViewArguments {
  const DocumentViewerViewArguments({
    this.key,
    required this.document,
  });

  final _i28.Key? key;

  final _i30.Document document;

  @override
  String toString() {
    return '{"key": "$key", "document": "$document"}';
  }

  @override
  bool operator ==(covariant DocumentViewerViewArguments other) {
    if (identical(this, other)) return true;
    return other.key == key && other.document == document;
  }

  @override
  int get hashCode {
    return key.hashCode ^ document.hashCode;
  }
}

extension NavigatorStateExtension on _i31.NavigationService {
  Future<dynamic> navigateToStartupView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return navigateTo<dynamic>(Routes.startupView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToHomeView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return navigateTo<dynamic>(Routes.homeView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToActivityView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return navigateTo<dynamic>(Routes.activityView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToCoursesView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return navigateTo<dynamic>(Routes.coursesView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToNotificationsView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return navigateTo<dynamic>(Routes.notificationsView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToProfilView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return navigateTo<dynamic>(Routes.profilView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToHomemainView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return navigateTo<dynamic>(Routes.homemainView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToActivitydetailsView({
    _i28.Key? key,
    _i29.ActivityModel? activity,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return navigateTo<dynamic>(Routes.activitydetailsView,
        arguments: ActivitydetailsViewArguments(key: key, activity: activity),
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToLoginView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return navigateTo<dynamic>(Routes.loginView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToRegisterView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return navigateTo<dynamic>(Routes.registerView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToRegisterProfileView({
    required String selectedProfile,
    required String phoneNumber,
    required String mail,
    required String password,
    required String firstName,
    required String lastName,
    required String address,
    _i28.Key? key,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return navigateTo<dynamic>(Routes.registerProfileView,
        arguments: RegisterProfileViewArguments(
            selectedProfile: selectedProfile,
            phoneNumber: phoneNumber,
            mail: mail,
            password: password,
            firstName: firstName,
            lastName: lastName,
            address: address,
            key: key),
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToHomePressingView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return navigateTo<dynamic>(Routes.homePressingView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToNavBarPressingView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return navigateTo<dynamic>(Routes.navBarPressingView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToActivitesPressingView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return navigateTo<dynamic>(Routes.activitesPressingView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToNotificationsPressingView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return navigateTo<dynamic>(Routes.notificationsPressingView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToComptePressingView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return navigateTo<dynamic>(Routes.comptePressingView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToDeliveryNavBarView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return navigateTo<dynamic>(Routes.deliveryNavBarView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToDeliveryHomeView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return navigateTo<dynamic>(Routes.deliveryHomeView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToNotificationsDeliveryView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return navigateTo<dynamic>(Routes.notificationsDeliveryView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToCompteDeliveryView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return navigateTo<dynamic>(Routes.compteDeliveryView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToActivitiesDeliveryView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return navigateTo<dynamic>(Routes.activitiesDeliveryView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToCoursesDeliveryView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return navigateTo<dynamic>(Routes.coursesDeliveryView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToMesVehiculesView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return navigateTo<dynamic>(Routes.mesVehiculesView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToDocumentsView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return navigateTo<dynamic>(Routes.documentsView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToAddDocumentView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return navigateTo<dynamic>(Routes.addDocumentView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToDocumentViewerView({
    _i28.Key? key,
    required _i30.Document document,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return navigateTo<dynamic>(Routes.documentViewerView,
        arguments: DocumentViewerViewArguments(key: key, document: document),
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithStartupView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return replaceWith<dynamic>(Routes.startupView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithHomeView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return replaceWith<dynamic>(Routes.homeView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithActivityView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return replaceWith<dynamic>(Routes.activityView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithCoursesView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return replaceWith<dynamic>(Routes.coursesView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithNotificationsView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return replaceWith<dynamic>(Routes.notificationsView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithProfilView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return replaceWith<dynamic>(Routes.profilView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithHomemainView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return replaceWith<dynamic>(Routes.homemainView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithActivitydetailsView({
    _i28.Key? key,
    _i29.ActivityModel? activity,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return replaceWith<dynamic>(Routes.activitydetailsView,
        arguments: ActivitydetailsViewArguments(key: key, activity: activity),
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithLoginView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return replaceWith<dynamic>(Routes.loginView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithRegisterView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return replaceWith<dynamic>(Routes.registerView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithRegisterProfileView({
    required String selectedProfile,
    required String phoneNumber,
    required String mail,
    required String password,
    required String firstName,
    required String lastName,
    required String address,
    _i28.Key? key,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return replaceWith<dynamic>(Routes.registerProfileView,
        arguments: RegisterProfileViewArguments(
            selectedProfile: selectedProfile,
            phoneNumber: phoneNumber,
            mail: mail,
            password: password,
            firstName: firstName,
            lastName: lastName,
            address: address,
            key: key),
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithHomePressingView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return replaceWith<dynamic>(Routes.homePressingView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithNavBarPressingView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return replaceWith<dynamic>(Routes.navBarPressingView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithActivitesPressingView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return replaceWith<dynamic>(Routes.activitesPressingView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithNotificationsPressingView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return replaceWith<dynamic>(Routes.notificationsPressingView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithComptePressingView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return replaceWith<dynamic>(Routes.comptePressingView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithDeliveryNavBarView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return replaceWith<dynamic>(Routes.deliveryNavBarView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithDeliveryHomeView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return replaceWith<dynamic>(Routes.deliveryHomeView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithNotificationsDeliveryView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return replaceWith<dynamic>(Routes.notificationsDeliveryView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithCompteDeliveryView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return replaceWith<dynamic>(Routes.compteDeliveryView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithActivitiesDeliveryView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return replaceWith<dynamic>(Routes.activitiesDeliveryView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithCoursesDeliveryView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return replaceWith<dynamic>(Routes.coursesDeliveryView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithMesVehiculesView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return replaceWith<dynamic>(Routes.mesVehiculesView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithDocumentsView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return replaceWith<dynamic>(Routes.documentsView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithAddDocumentView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return replaceWith<dynamic>(Routes.addDocumentView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithDocumentViewerView({
    _i28.Key? key,
    required _i30.Document document,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return replaceWith<dynamic>(Routes.documentViewerView,
        arguments: DocumentViewerViewArguments(key: key, document: document),
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }
}

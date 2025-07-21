// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// StackedNavigatorGenerator
// **************************************************************************

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:flutter/material.dart' as _i13;
import 'package:flutter/material.dart';
import 'package:for_u_partners/ui/views/activity/activity_view.dart' as _i4;
import 'package:for_u_partners/ui/views/activity/models/activity_model.dart'
    as _i14;
import 'package:for_u_partners/ui/views/activitydetails/activitydetails_view.dart'
    as _i9;
import 'package:for_u_partners/ui/views/courses/courses_view.dart' as _i5;
import 'package:for_u_partners/ui/views/home/home_view.dart' as _i3;
import 'package:for_u_partners/ui/views/homemain/homemain_view.dart' as _i8;
import 'package:for_u_partners/ui/views/login/login_view.dart' as _i10;
import 'package:for_u_partners/ui/views/notifications/notifications_view.dart'
    as _i6;
import 'package:for_u_partners/ui/views/profil/profil_view.dart' as _i7;
import 'package:for_u_partners/ui/views/register/register_view.dart' as _i11;
import 'package:for_u_partners/ui/views/register_profile/register_profile_view.dart'
    as _i12;
import 'package:for_u_partners/ui/views/startup/startup_view.dart' as _i2;
import 'package:stacked/stacked.dart' as _i1;
import 'package:stacked_services/stacked_services.dart' as _i15;

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
  ];

  final _pagesMap = <Type, _i1.StackedRouteFactory>{
    _i2.StartupView: (data) {
      return _i13.MaterialPageRoute<dynamic>(
        builder: (context) => const _i2.StartupView(),
        settings: data,
      );
    },
    _i3.HomeView: (data) {
      return _i13.MaterialPageRoute<dynamic>(
        builder: (context) => const _i3.HomeView(),
        settings: data,
      );
    },
    _i4.ActivityView: (data) {
      return _i13.MaterialPageRoute<dynamic>(
        builder: (context) => const _i4.ActivityView(),
        settings: data,
      );
    },
    _i5.CoursesView: (data) {
      return _i13.MaterialPageRoute<dynamic>(
        builder: (context) => const _i5.CoursesView(),
        settings: data,
      );
    },
    _i6.NotificationsView: (data) {
      return _i13.MaterialPageRoute<dynamic>(
        builder: (context) => const _i6.NotificationsView(),
        settings: data,
      );
    },
    _i7.ProfilView: (data) {
      return _i13.MaterialPageRoute<dynamic>(
        builder: (context) => const _i7.ProfilView(),
        settings: data,
      );
    },
    _i8.HomemainView: (data) {
      return _i13.MaterialPageRoute<dynamic>(
        builder: (context) => const _i8.HomemainView(),
        settings: data,
      );
    },
    _i9.ActivitydetailsView: (data) {
      final args = data.getArgs<ActivitydetailsViewArguments>(
        orElse: () => const ActivitydetailsViewArguments(),
      );
      return _i13.MaterialPageRoute<dynamic>(
        builder: (context) =>
            _i9.ActivitydetailsView(key: args.key, activity: args.activity),
        settings: data,
      );
    },
    _i10.LoginView: (data) {
      return _i13.MaterialPageRoute<dynamic>(
        builder: (context) => const _i10.LoginView(),
        settings: data,
      );
    },
    _i11.RegisterView: (data) {
      return _i13.MaterialPageRoute<dynamic>(
        builder: (context) => const _i11.RegisterView(),
        settings: data,
      );
    },
    _i12.RegisterProfileView: (data) {
      final args = data.getArgs<RegisterProfileViewArguments>(nullOk: false);
      return _i13.MaterialPageRoute<dynamic>(
        builder: (context) =>
            _i12.RegisterProfileView(args.selectedProfile, key: args.key),
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

  final _i13.Key? key;

  final _i14.ActivityModel? activity;

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
    this.key,
  });

  final String selectedProfile;

  final _i13.Key? key;

  @override
  String toString() {
    return '{"selectedProfile": "$selectedProfile", "key": "$key"}';
  }

  @override
  bool operator ==(covariant RegisterProfileViewArguments other) {
    if (identical(this, other)) return true;
    return other.selectedProfile == selectedProfile && other.key == key;
  }

  @override
  int get hashCode {
    return selectedProfile.hashCode ^ key.hashCode;
  }
}

extension NavigatorStateExtension on _i15.NavigationService {
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
    _i13.Key? key,
    _i14.ActivityModel? activity,
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
    _i13.Key? key,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return navigateTo<dynamic>(Routes.registerProfileView,
        arguments: RegisterProfileViewArguments(
            selectedProfile: selectedProfile, key: key),
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
    _i13.Key? key,
    _i14.ActivityModel? activity,
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
    _i13.Key? key,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return replaceWith<dynamic>(Routes.registerProfileView,
        arguments: RegisterProfileViewArguments(
            selectedProfile: selectedProfile, key: key),
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }
}

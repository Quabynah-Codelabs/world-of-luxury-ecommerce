// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouteGenerator
// **************************************************************************

// ignore_for_file: public_member_api_docs

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

import '../../domain/services/messaging.dart';
import '../pages/account_completion.dart';
import '../pages/client/checkout.dart';
import '../pages/client/home.dart';
import '../pages/client/profile.dart';
import '../pages/client/provider_details.dart';
import '../pages/client/providers.dart';
import '../pages/client/request_booking.dart';
import '../pages/client/user_info.dart';
import '../pages/conversation.dart';
import '../pages/login.dart';
import '../pages/notification.dart';
import '../pages/onboarding.dart';
import '../pages/provider/bookings.dart';
import '../pages/provider/dashboard.dart';
import '../pages/provider/settings.dart';
import '../pages/register.dart';
import '../pages/search.dart';
import '../pages/splash.dart';
import 'guard.dart';

class Routes {
  static const String onboardingPage = '/onboarding-page';
  static const String splashPage = '/';
  static const String loginPage = '/login-page';
  static const String registerPage = '/register-page';
  static const String checkoutPage = '/checkout-page';
  static const String searchPage = '/search-page';
  static const String notificationPage = '/notification-page';
  static const String bookingsDetailsPage = '/bookings-details-page';
  static const String accountCompletionPage = '/account-completion-page';
  static const String conversationPage = '/conversation-page';
  static const String userInfoPage = '/user-info-page';
  static const String homePage = '/home-page';
  static const String profilePage = '/profile-page';
  static const String requestBookingPage = '/request-booking-page';
  static const String categoryProvidersPage = '/category-providers-page';
  static const String serviceProviderDetails = '/service-provider-details';
  static const String providerSettingsPage = '/provider-settings-page';
  static const String dashboardPage = '/dashboard-page';
  static const all = <String>{
    onboardingPage,
    splashPage,
    loginPage,
    registerPage,
    checkoutPage,
    searchPage,
    notificationPage,
    bookingsDetailsPage,
    accountCompletionPage,
    conversationPage,
    userInfoPage,
    homePage,
    profilePage,
    requestBookingPage,
    categoryProvidersPage,
    serviceProviderDetails,
    providerSettingsPage,
    dashboardPage,
  };
}

class Router extends RouterBase {
  @override
  List<RouteDef> get routes => _routes;
  final _routes = <RouteDef>[
    RouteDef(Routes.onboardingPage, page: OnboardingPage),
    RouteDef(Routes.splashPage, page: SplashPage),
    RouteDef(Routes.loginPage, page: LoginPage),
    RouteDef(Routes.registerPage, page: RegisterPage),
    RouteDef(Routes.checkoutPage, page: CheckoutPage, guards: [AuthGuard]),
    RouteDef(Routes.searchPage, page: SearchPage, guards: [AuthGuard]),
    RouteDef(Routes.notificationPage,
        page: NotificationPage, guards: [AuthGuard]),
    RouteDef(Routes.bookingsDetailsPage,
        page: BookingsDetailsPage, guards: [AuthGuard]),
    RouteDef(Routes.accountCompletionPage,
        page: AccountCompletionPage, guards: [AuthGuard]),
    RouteDef(Routes.conversationPage,
        page: ConversationPage, guards: [AuthGuard]),
    RouteDef(Routes.userInfoPage, page: UserInfoPage, guards: [AuthGuard]),
    RouteDef(Routes.homePage, page: HomePage, guards: [AuthGuard, ClientGuard]),
    RouteDef(Routes.profilePage,
        page: ProfilePage, guards: [AuthGuard, ClientGuard]),
    RouteDef(Routes.requestBookingPage,
        page: RequestBookingPage, guards: [AuthGuard, ClientGuard]),
    RouteDef(Routes.categoryProvidersPage,
        page: CategoryProvidersPage, guards: [AuthGuard, ClientGuard]),
    RouteDef(Routes.serviceProviderDetails,
        page: ServiceProviderDetails, guards: [AuthGuard, ClientGuard]),
    RouteDef(Routes.providerSettingsPage,
        page: ProviderSettingsPage, guards: [AuthGuard, ProviderGuard]),
    RouteDef(Routes.dashboardPage,
        page: DashboardPage, guards: [AuthGuard, ProviderGuard]),
  ];
  @override
  Map<Type, AutoRouteFactory> get pagesMap => _pagesMap;
  final _pagesMap = <Type, AutoRouteFactory>{
    OnboardingPage: (data) {
      return buildAdaptivePageRoute<dynamic>(
        builder: (context) => OnboardingPage(),
        settings: data,
      );
    },
    SplashPage: (data) {
      return buildAdaptivePageRoute<dynamic>(
        builder: (context) => SplashPage(),
        settings: data,
      );
    },
    LoginPage: (data) {
      return buildAdaptivePageRoute<dynamic>(
        builder: (context) => LoginPage(),
        settings: data,
      );
    },
    RegisterPage: (data) {
      return buildAdaptivePageRoute<dynamic>(
        builder: (context) => RegisterPage(),
        settings: data,
      );
    },
    CheckoutPage: (data) {
      final args = data.getArgs<CheckoutPageArguments>(nullOk: false);
      return buildAdaptivePageRoute<dynamic>(
        builder: (context) => CheckoutPage(
          key: args.key,
          booking: args.booking,
          artisan: args.artisan,
        ),
        settings: data,
      );
    },
    SearchPage: (data) {
      return buildAdaptivePageRoute<dynamic>(
        builder: (context) => SearchPage(),
        settings: data,
      );
    },
    NotificationPage: (data) {
      final args = data.getArgs<NotificationPageArguments>(
        orElse: () => NotificationPageArguments(),
      );
      return buildAdaptivePageRoute<dynamic>(
        builder: (context) => NotificationPage(
          key: args.key,
          payload: args.payload,
        ),
        settings: data,
      );
    },
    BookingsDetailsPage: (data) {
      final args = data.getArgs<BookingsDetailsPageArguments>(nullOk: false);
      return buildAdaptivePageRoute<dynamic>(
        builder: (context) => BookingsDetailsPage(
          key: args.key,
          booking: args.booking,
        ),
        settings: data,
      );
    },
    AccountCompletionPage: (data) {
      return buildAdaptivePageRoute<dynamic>(
        builder: (context) => AccountCompletionPage(),
        settings: data,
      );
    },
    ConversationPage: (data) {
      final args = data.getArgs<ConversationPageArguments>(
        orElse: () => ConversationPageArguments(),
      );
      return buildAdaptivePageRoute<dynamic>(
        builder: (context) => ConversationPage(
          key: args.key,
          recipient: args.recipient,
          isCustomer: args.isCustomer,
        ),
        settings: data,
      );
    },
    UserInfoPage: (data) {
      final args = data.getArgs<UserInfoPageArguments>(nullOk: false);
      return buildAdaptivePageRoute<dynamic>(
        builder: (context) => UserInfoPage(
          key: args.key,
          customer: args.customer,
        ),
        settings: data,
      );
    },
    HomePage: (data) {
      return buildAdaptivePageRoute<dynamic>(
        builder: (context) => HomePage(),
        settings: data,
      );
    },
    ProfilePage: (data) {
      return buildAdaptivePageRoute<dynamic>(
        builder: (context) => ProfilePage(),
        settings: data,
      );
    },
    RequestBookingPage: (data) {
      final args = data.getArgs<RequestBookingPageArguments>(
        orElse: () => RequestBookingPageArguments(),
      );
      return buildAdaptivePageRoute<dynamic>(
        builder: (context) => RequestBookingPage(
          key: args.key,
          artisan: args.artisan,
        ),
        settings: data,
      );
    },
    CategoryProvidersPage: (data) {
      final args = data.getArgs<CategoryProvidersPageArguments>(
        orElse: () => CategoryProvidersPageArguments(),
      );
      return buildAdaptivePageRoute<dynamic>(
        builder: (context) => CategoryProvidersPage(
          key: args.key,
          category: args.category,
        ),
        settings: data,
      );
    },
    ServiceProviderDetails: (data) {
      final args = data.getArgs<ServiceProviderDetailsArguments>(
        orElse: () => ServiceProviderDetailsArguments(),
      );
      return buildAdaptivePageRoute<dynamic>(
        builder: (context) => ServiceProviderDetails(
          key: args.key,
          artisan: args.artisan,
        ),
        settings: data,
      );
    },
    ProviderSettingsPage: (data) {
      final args = data.getArgs<ProviderSettingsPageArguments>(
        orElse: () => ProviderSettingsPageArguments(),
      );
      return buildAdaptivePageRoute<dynamic>(
        builder: (context) => ProviderSettingsPage(
          key: args.key,
          activeTabIndex: args.activeTabIndex,
        ),
        settings: data,
      );
    },
    DashboardPage: (data) {
      return buildAdaptivePageRoute<dynamic>(
        builder: (context) => DashboardPage(),
        settings: data,
      );
    },
  };
}

/// ************************************************************************
/// Arguments holder classes
/// *************************************************************************

/// CheckoutPage arguments holder class
class CheckoutPageArguments {
  final Key key;
  final dynamic booking;
  final dynamic artisan;
  CheckoutPageArguments(
      {this.key, @required this.booking, @required this.artisan});
}

/// NotificationPage arguments holder class
class NotificationPageArguments {
  final Key key;
  final NotificationPayload payload;
  NotificationPageArguments({this.key, this.payload});
}

/// BookingsDetailsPage arguments holder class
class BookingsDetailsPageArguments {
  final Key key;
  final dynamic booking;
  BookingsDetailsPageArguments({this.key, @required this.booking});
}

/// ConversationPage arguments holder class
class ConversationPageArguments {
  final Key key;
  final String recipient;
  final bool isCustomer;
  ConversationPageArguments({this.key, this.recipient, this.isCustomer});
}

/// UserInfoPage arguments holder class
class UserInfoPageArguments {
  final Key key;
  final dynamic customer;
  UserInfoPageArguments({this.key, @required this.customer});
}

/// RequestBookingPage arguments holder class
class RequestBookingPageArguments {
  final Key key;
  final dynamic artisan;
  RequestBookingPageArguments({this.key, this.artisan});
}

/// CategoryProvidersPage arguments holder class
class CategoryProvidersPageArguments {
  final Key key;
  final dynamic category;
  CategoryProvidersPageArguments({this.key, this.category});
}

/// ServiceProviderDetails arguments holder class
class ServiceProviderDetailsArguments {
  final Key key;
  final dynamic artisan;
  ServiceProviderDetailsArguments({this.key, this.artisan});
}

/// ProviderSettingsPage arguments holder class
class ProviderSettingsPageArguments {
  final Key key;
  final int activeTabIndex;
  ProviderSettingsPageArguments({this.key, this.activeTabIndex = 1});
}

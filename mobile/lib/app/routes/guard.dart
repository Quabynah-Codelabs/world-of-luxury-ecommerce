import 'package:auto_route/auto_route.dart';
import 'package:handyman/core/constants.dart';
import 'package:handyman/core/service_locator.dart';
import 'package:handyman/core/utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthGuard extends RouteGuard {
  @override
  Future<bool> canNavigate(ExtendedNavigatorState<RouterBase> navigator,
      String routeName, Object args) async {
    var preferences = await sl.getAsync<SharedPreferences>();
    final isLoggedIn = preferences.getString(PrefsUtils.USER_ID) != null;
    return isLoggedIn;
  }
}

class ProviderGuard extends RouteGuard {
  @override
  Future<bool> canNavigate(ExtendedNavigatorState<RouterBase> navigator,
      String routeName, Object args) async {
    var preferences = await sl.getAsync<SharedPreferences>();
    final isLoggedIn = preferences.getString(PrefsUtils.USER_ID) != null;
    final userType = preferences.getString(PrefsUtils.USER_TYPE);
    return isLoggedIn && userType != null && userType == kArtisanString;
  }
}

class ClientGuard extends RouteGuard {
  @override
  Future<bool> canNavigate(ExtendedNavigatorState<RouterBase> navigator,
      String routeName, Object args) async {
    var preferences = await sl.getAsync<SharedPreferences>();
    final isLoggedIn = preferences.getString(PrefsUtils.USER_ID) != null;
    final userType = preferences.getString(PrefsUtils.USER_TYPE);
    return isLoggedIn && userType != null && userType == kCustomerString;
  }
}

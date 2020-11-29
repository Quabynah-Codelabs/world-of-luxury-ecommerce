import 'package:flutter_test/flutter_test.dart';
import 'package:handyman/app/model/prefs_provider.dart';
import 'package:handyman/core/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

void main() async {
  TestWidgetsFlutterBinding.ensureInitialized();

  test("Test prefs provider", () async {
    SharedPreferences.setMockInitialValues({});
    final prefsProvider = PrefsProvider.instance;
    final uid = Uuid().v4();
    prefsProvider.saveUserId(uid);
    expect(uid, prefsProvider.userId);

    await Future.delayed(kTestDuration);
    await prefsProvider.clearUserData();
    expect(null, prefsProvider.userId);
  });
}

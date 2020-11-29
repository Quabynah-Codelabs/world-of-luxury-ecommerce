import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:handyman/app/app.dart';
import 'package:handyman/core/service_locator.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/utils.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Locale support for calendar date formatting
  await initializeDateFormatting();

  // Initialize Firebase App
  await Firebase.initializeApp();

  // Inject service locator here
  await registerServiceLocator();

  final preferences = await sl.getAsync<SharedPreferences>();
  final isLightTheme = preferences.getBool(PrefsUtils.THEME_MODE) ?? true;

  // Set orientation
  if (defaultTargetPlatform == TargetPlatform.android ||
      defaultTargetPlatform == TargetPlatform.iOS) {
    SystemChrome.setSystemUIOverlayStyle(
      isLightTheme ? SystemUiOverlayStyle.dark : SystemUiOverlayStyle.light,
    );
    SystemChrome.setEnabledSystemUIOverlays([
      SystemUiOverlay.bottom,
      SystemUiOverlay.top,
    ]);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  runApp(HandyManApp());
}

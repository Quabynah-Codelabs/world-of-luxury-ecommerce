import 'package:algolia/algolia.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:handyman/app/model/prefs_provider.dart';
import 'package:handyman/data/local_database.dart';
import 'package:handyman/data/services/auth.dart';
import 'package:handyman/data/services/data.dart';
import 'package:handyman/data/services/messaging.dart';
import 'package:handyman/data/services/storage.dart';
import 'package:handyman/domain/services/auth.dart';
import 'package:handyman/domain/services/data.dart';
import 'package:handyman/domain/services/messaging.dart';
import 'package:handyman/domain/services/storage.dart';
import 'package:meta/meta.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import 'constants.dart';

// Instance of service locator
GetIt sl = GetIt.instance;

// Instance of Algolia
Algolia algolia = Algolia.init(
  applicationId: kAlgoliaAppId,
  apiKey: kAlgoliaKey,
);

// Instance of url launcher
void launchUrl({@required String url}) async {
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    throw 'Could not launch $url';
  }
}

Future<void> registerServiceLocator() async {
  // Shared Preferences
  sl.registerLazySingletonAsync<SharedPreferences>(
      () => SharedPreferences.getInstance());

  // Local database
  sl.registerSingleton<LocalDatabase>(LocalDatabase.instance);

  // Services
  sl.registerLazySingleton<DataService>(() => DataServiceImpl.instance);
  sl.registerLazySingleton<AuthService>(() => FirebaseAuthService.instance);
  sl.registerLazySingleton<StorageService>(() => StorageServiceImpl.instance);
  sl.registerLazySingleton<MessagingService>(
      () => MessagingServiceImpl.instance);

  // Firebase APIs
  sl.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);
  sl.registerLazySingleton<FirebaseFirestore>(() => FirebaseFirestore.instance);
  sl.registerLazySingleton<FirebaseMessaging>(() => FirebaseMessaging());
  sl.registerLazySingleton<StorageReference>(() => FirebaseStorage.instance
      .ref()
      .child(kAppName.toLowerCase().replaceAll(" ", "_")));
}

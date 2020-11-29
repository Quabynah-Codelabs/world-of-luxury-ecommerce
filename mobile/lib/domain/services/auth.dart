import 'dart:async' show Future, Stream;

import 'package:handyman/domain/models/user.dart';
import 'package:meta/meta.dart';

enum AuthState { NONE, AUTHENTICATING, ERROR, SUCCESS }

/// Base authentication service
abstract class AuthService {
  Stream<BaseUser> currentUser();

  Future<BaseUser> signInWithGoogle({@required bool isCustomer});

  Future<BaseUser> signInWithEmailAndPassword({
    @required String email,
    @required String password,
    bool isCustomer,
  });

  Future<BaseUser> createUserWithEmailAndPassword({
    @required String username,
    @required String email,
    @required String password,
    bool isCustomer,
  });

  Future<void> sendPasswordReset({@required String email});

  Future<bool> signOut();

  Stream<BaseUser> get onAuthStateChanged;

  Stream<AuthState> get onProcessingStateChanged;

  void dispose();
}

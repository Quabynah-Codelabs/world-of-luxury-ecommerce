import 'package:flutter/foundation.dart';
import 'package:handyman/data/local_database.dart';
import 'package:handyman/domain/models/user.dart';

/// Implementation of [BaseUser] for [Artisan]
@immutable
class ArtisanModel implements BaseUser {
  final Artisan artisan;

  const ArtisanModel({this.artisan});

  @override
  bool get isCustomer => false;

  @override
  get user => artisan;
}

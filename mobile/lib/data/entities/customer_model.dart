import 'package:flutter/foundation.dart';
import 'package:handyman/data/local_database.dart';
import 'package:handyman/domain/models/user.dart';

/// Implementation of [BaseUser] for [Customer]
@immutable
class CustomerModel implements BaseUser {
  final Customer customer;

  const CustomerModel({this.customer});

  @override
  bool get isCustomer => true;

  @override
  get user => customer;
}

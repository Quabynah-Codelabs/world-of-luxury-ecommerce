/// Base class for all users
abstract class BaseUser {
  bool get isCustomer;

  dynamic get user;

  @override
  String toString() => user.toString();
}

import 'package:moor/moor.dart';

@DataClassName("Artisan")
class ServiceProvider extends Table {
  TextColumn get id => text()();

  TextColumn get name => text()();

  TextColumn get business => text().nullable()();

  TextColumn get phone => text().nullable()();

  TextColumn get email => text()();

  TextColumn get token => text().nullable()();

  @JsonKey("certified")
  BoolColumn get isCertified =>
      boolean().nullable().named("certified").withDefault(Constant(false))();

  @JsonKey("available")
  BoolColumn get isAvailable =>
      boolean().nullable().named("available").withDefault(Constant(false))();

  TextColumn get category =>
      text().withDefault(Constant("598d67f5-b84b-4572-9058-57f36463aeac"))();

  @JsonKey("start_working_hours")
  IntColumn get startWorkingHours =>
      integer().nullable().withDefault(Constant(DateTime.now().hour))();

  @JsonKey("completed_bookings_count")
  IntColumn get completedBookingsCount =>
      integer().nullable().withDefault(Constant(0))();

  @JsonKey("ongoing_bookings_count")
  IntColumn get ongoingBookingsCount =>
      integer().nullable().withDefault(Constant(0))();

  @JsonKey("cancelled_bookings_count")
  IntColumn get cancelledBookingsCount =>
      integer().nullable().withDefault(Constant(0))();

  @JsonKey("requests_count")
  IntColumn get requestsCount =>
      integer().nullable().withDefault(Constant(0))();

  @JsonKey("reports_count")
  IntColumn get reportsCount => integer().nullable().withDefault(Constant(0))();

  @JsonKey("end_working_hours")
  IntColumn get endWorkingHours =>
      integer().nullable().withDefault(Constant(DateTime.now().hour + 12))();

  TextColumn get avatar => text().nullable()();

  @JsonKey("about_me")
  TextColumn get aboutMe => text().nullable().withLength(max: 5000)();

  @JsonKey("start_price")
  RealColumn get startPrice => real().withDefault(Constant(19.99))();

  @JsonKey("end_price")
  RealColumn get endPrice => real().withDefault(Constant(119.99))();

  RealColumn get rating => real().withDefault(Constant(3.5))();

  @JsonKey("created_at")
  IntColumn get createdAt => integer()
      .nullable()
      .withDefault(Constant(DateTime.now().millisecondsSinceEpoch))();

  @override
  Set<Column> get primaryKey => {id};
}

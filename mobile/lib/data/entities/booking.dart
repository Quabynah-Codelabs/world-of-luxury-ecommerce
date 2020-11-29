import 'package:moor/moor.dart';

class Bookings extends Table {
  TextColumn get id => text()();

  @JsonKey("customer_id")
  TextColumn get customerId => text()();

  @JsonKey("provider_id")
  TextColumn get providerId => text()();

  TextColumn get category => text()();

  @JsonKey("image_url")
  TextColumn get imageUrl => text().nullable()();

  TextColumn get description => text()
      .nullable()
      .withDefault(Constant(
          "Ipsum suspendisse ultrices gravida dictum fusce ut placerat. Cursus sit amet dictum sit amet. Vel elit scelerisque mauris pellentesque pulvinar pellentesque habitant morbi tristique"))
      .withLength(max: 1000)();

  TextColumn get reason => text()();

  @JsonKey("is_accepted")
  BoolColumn get isAccepted =>
      boolean().withDefault(Constant(false)).nullable()();

  @JsonKey("lat")
  RealColumn get locationLat =>
      real().nullable().named("lat").withDefault(Constant(5.5329650))();

  @JsonKey("lng")
  RealColumn get locationLng =>
      real().nullable().named("lng").withDefault(Constant(-0.2592160))();

  RealColumn get value => real().withDefault(Constant(10.99))();

  RealColumn get progress => real().withDefault(Constant(0.45))();

  @JsonKey("created_at")
  IntColumn get createdAt => integer()
      .nullable()
      .withDefault(Constant(DateTime.now().millisecondsSinceEpoch))();

  @JsonKey("due_date")
  IntColumn get dueDate => integer().nullable().withDefault(
      Constant(DateTime.now().millisecondsSinceEpoch + 430000000))();

  @override
  Set<Column> get primaryKey => {id};
}

enum BookingType { NEW, ONGOING, COMPLETED }

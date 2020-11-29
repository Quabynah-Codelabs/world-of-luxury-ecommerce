import 'package:moor/moor.dart';

@DataClassName("CustomerReview")
class Review extends Table {
  TextColumn get id => text()();

  TextColumn get review => text().withLength(max: 5000)();

  @JsonKey("customer_id")
  TextColumn get customerId => text()();

  @JsonKey("provider_id")
  TextColumn get providerId => text()();

  RealColumn get rating => real().withDefault(Constant(1.5)).nullable()();

  @JsonKey("created_at")
  DateTimeColumn get createdAt =>
      dateTime().withDefault(Constant(DateTime.now()))();

  @override
  Set<Column> get primaryKey => {id, customerId, providerId};
}

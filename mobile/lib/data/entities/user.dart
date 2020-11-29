import 'package:moor/moor.dart';

@DataClassName("Customer")
class User extends Table {
  TextColumn get id => text()();

  TextColumn get name => text()();

  TextColumn get email => text()();

  TextColumn get avatar => text().nullable()();

  TextColumn get phone => text().nullable()();

  TextColumn get token => text().nullable()();

  @JsonKey("created_at")
  IntColumn get createdAt => integer()
      .nullable()
      .withDefault(Constant(DateTime.now().millisecondsSinceEpoch))();

  @override
  Set<Column> get primaryKey => {id};
}

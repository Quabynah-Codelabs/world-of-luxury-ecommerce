import 'package:moor/moor.dart';

@DataClassName("Conversation")
class Message extends Table {
  TextColumn get id => text()();

  TextColumn get author => text()();

  TextColumn get recipient => text()();

  TextColumn get content => text()();

  @JsonKey("created_at")
  TextColumn get createdAt => text().nullable().withDefault(
      Constant(DateTime.now().millisecondsSinceEpoch.toString()))();

  TextColumn get image => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

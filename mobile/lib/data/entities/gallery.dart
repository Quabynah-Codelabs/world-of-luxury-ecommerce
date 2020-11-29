import 'package:moor/moor.dart';

@DataClassName("Gallery")
class PhotoGallery extends Table {
  TextColumn get id => text()();

  @JsonKey("user_id")
  TextColumn get userId => text()();

  @JsonKey("image_url")
  TextColumn get imageUrl => text()();

  @JsonKey("created_at")
  IntColumn get createdAt => integer()
      .nullable()
      .withDefault(Constant(DateTime.now().millisecondsSinceEpoch))();

  @override
  Set<Column> get primaryKey => {id};
}

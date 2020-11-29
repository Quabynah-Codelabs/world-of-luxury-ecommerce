import 'package:moor/moor.dart';

@DataClassName("ServiceCategory")
class CategoryItem extends Table {
  TextColumn get id => text()();

  TextColumn get name => text()();

  TextColumn get avatar => text()();

  @JsonKey("group_name")
  IntColumn get groupName =>
      integer().named("groupName").withDefault(Constant(0))();

  IntColumn get artisans => integer().withDefault(Constant(0))();

  @override
  Set<Column> get primaryKey => {id};
}

enum CategoryGroup {
  FEATURED,
  MOST_RATED,
  RECENT,
  POPULAR,
  RECOMMENDED,
}

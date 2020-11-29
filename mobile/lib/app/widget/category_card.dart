import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:handyman/app/routes/route.gr.dart';
import 'package:handyman/app/widget/user_avatar.dart';
import 'package:handyman/core/constants.dart';
import 'package:handyman/core/service_locator.dart';
import 'package:handyman/core/size_config.dart';
import 'package:handyman/data/local_database.dart';
import 'package:handyman/domain/models/user.dart';
import 'package:handyman/domain/services/data.dart';

class GridCategoryCardItem extends StatefulWidget {
  final List<ServiceCategory> categories;

  const GridCategoryCardItem({Key key, this.categories}) : super(key: key);

  @override
  _GridCategoryCardItemState createState() => _GridCategoryCardItemState();
}

class _GridCategoryCardItemState extends State<GridCategoryCardItem> {
  final _dataService = sl.get<DataService>();

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);

    return AnimationLimiter(
      child: GridView.builder(
        itemCount: widget.categories.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          // childAspectRatio: 4 / 3,
          crossAxisSpacing: getProportionateScreenWidth(kSpacingX8),
          mainAxisSpacing: getProportionateScreenHeight(kSpacingX4),
        ),
        clipBehavior: Clip.hardEdge,
        itemBuilder: (_, index) {
          final category = widget.categories[index];
          return AnimationConfiguration.staggeredGrid(
            position: index,
            duration: kScaleDuration,
            columnCount: 2,
            child: ScaleAnimation(
              child: FadeInAnimation(
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      getProportionateScreenWidth(kSpacingX12),
                    ),
                  ),
                  color: themeData.cardColor,
                  clipBehavior: Clip.hardEdge,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(
                        getProportionateScreenWidth(kSpacingX12)),
                    onTap: () => context.navigator.push(
                      Routes.categoryProvidersPage,
                      arguments:
                          CategoryProvidersPageArguments(category: category),
                    ),
                    child: Stack(
                      children: [
                        Hero(
                          tag: category.avatar,
                          child: CachedNetworkImage(
                            imageUrl: category.avatar,
                            height: getProportionateScreenHeight(kSpacingX250),
                            width: double.infinity,
                            progressIndicatorBuilder:
                                (context, url, downloadProgress) => Center(
                              child: CircularProgressIndicator(
                                  value: downloadProgress.progress),
                            ),
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          top: getProportionateScreenHeight(kSpacingX250) / 2,
                          right: kSpacingNone,
                          left: kSpacingNone,
                          bottom: kSpacingNone,
                          child: Container(
                            decoration: BoxDecoration(
                              color: themeData.scaffoldBackgroundColor
                                  .withOpacity(kOpacityX70),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              category.name,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: themeData.textTheme.button.copyWith(
                                color: themeData.textTheme.bodyText1.color,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class ListCategoryCardItem extends StatefulWidget {
  final List<ServiceCategory> categories;

  const ListCategoryCardItem({Key key, this.categories}) : super(key: key);

  @override
  _ListCategoryCardItemState createState() => _ListCategoryCardItemState();
}

class _ListCategoryCardItemState extends State<ListCategoryCardItem> {
  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    return AnimationLimiter(
      child: ListView.builder(
        itemBuilder: (_, index) {
          final category = widget.categories[index];
          return AnimationConfiguration.staggeredList(
            position: index,
            duration: kScaleDuration,
            child: SlideAnimation(
              verticalOffset: kSlideOffset,
              child: FadeInAnimation(
                child: Card(
                  child: ListTile(
                    onTap: () => context.navigator.push(
                      Routes.categoryProvidersPage,
                      arguments:
                          CategoryProvidersPageArguments(category: category),
                    ),
                    leading: UserAvatar(
                      url: category.avatar,
                      ringColor: themeData.scaffoldBackgroundColor,
                    ),
                    trailing: IconButton(
                      icon: Icon(
                        Icons.arrow_right_alt,
                        color: themeData.iconTheme.color,
                      ),
                      onPressed: () => context.navigator.push(
                        Routes.categoryProvidersPage,
                        arguments:
                            CategoryProvidersPageArguments(category: category),
                      ),
                    ),
                    // subtitle: Text(
                    //   "127 available",
                    //   // FIXME: Added # of registered artisans here
                    //   style: themeData.textTheme.bodyText1.copyWith(
                    //     color: themeData.primaryColor,
                    //   ),
                    // ),
                    // onLongPress: () {},
                    title: Text(category.name),
                  ),
                ),
              ),
            ),
          );
        },
        itemCount: widget.categories.length,
      ),
    );
  }
}

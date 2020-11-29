import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:handyman/app/routes/route.gr.dart';
import 'package:handyman/app/widget/user_avatar.dart';
import 'package:handyman/core/constants.dart';
import 'package:handyman/core/size_config.dart';
import 'package:handyman/domain/models/user.dart';
import 'package:random_color/random_color.dart';

class GridArtisanCardItem extends StatefulWidget {
  final BaseUser artisan;

  const GridArtisanCardItem({Key key, this.artisan}) : super(key: key);

  @override
  _GridArtisanCardItemState createState() => _GridArtisanCardItemState();
}

class _GridArtisanCardItemState extends State<GridArtisanCardItem> {
  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);

    return Card(
      key: ValueKey<String>(widget.artisan?.user?.id),
      clipBehavior: Clip.hardEdge,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
          getProportionateScreenWidth(kSpacingX8),
        ),
      ),
      child: GestureDetector(
        onTap: () => context.navigator.push(
          Routes.serviceProviderDetails,
          arguments: ServiceProviderDetailsArguments(
            artisan: widget.artisan?.user,
          ),
        ),
        child: Container(
          height: getProportionateScreenHeight(kSpacingX300),
          width: double.infinity,
          child: Stack(
            children: [
              Hero(
                tag: widget.artisan?.user?.id,
                child: CachedNetworkImage(
                    imageUrl: widget.artisan?.user?.avatar ?? "",
                    height: getProportionateScreenHeight(kSpacingX300),
                    width: double.infinity,
                    progressIndicatorBuilder:
                        (context, url, downloadProgress) => Center(
                            child: CircularProgressIndicator(
                                value: downloadProgress.progress)),
                    errorWidget: (_, __, chunk) => Container(
                          color: RandomColor()
                              .randomColor(
                                colorBrightness: ColorBrightness.dark,
                              )
                              .withOpacity(kOpacityX14),
                        ),
                    fit: BoxFit.cover),
              ),
              widget.artisan?.user?.isCertified ?? false
                  ? Positioned(
                      top: kSpacingNone,
                      right: kSpacingNone,
                      child: Container(
                        height: getProportionateScreenHeight(kSpacingX48),
                        width: getProportionateScreenHeight(kSpacingX48),
                        decoration: BoxDecoration(
                          color: kGreenColor,
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(kSpacingX24),
                          ),
                        ),
                        child: Icon(
                          Feather.award,
                          color: kWhiteColor,
                        ),
                      ),
                    )
                  : SizedBox.shrink(),
              Positioned(
                top: getProportionateScreenHeight(kSpacingX96),
                left: kSpacingNone,
                right: kSpacingNone,
                bottom: kSpacingNone,
                child: Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: getProportionateScreenWidth(kSpacingX8)),
                  decoration: BoxDecoration(
                    color: themeData.scaffoldBackgroundColor
                        .withOpacity(kOpacityX90),
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(kSpacingX8),
                      topLeft: Radius.circular(kSpacingX8),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        widget.artisan?.user?.name ?? "",
                        style: themeData.textTheme.headline6,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(
                          height: getProportionateScreenHeight(kSpacingX4)),
                      Text(
                        widget.artisan?.user?.business ?? "",
                        style: themeData.textTheme.caption,
                        overflow: TextOverflow.fade,
                        maxLines: 2,
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(
                          height: getProportionateScreenHeight(kSpacingX8)),
                      Text(
                        "\₵${widget.artisan?.user?.startPrice}",
                        style: themeData.textTheme.headline6.copyWith(
                          color: themeData.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class ListArtisanCardItem extends StatefulWidget {
  final BaseUser artisan;

  const ListArtisanCardItem({Key key, this.artisan}) : super(key: key);

  @override
  _ListArtisanCardItemState createState() => _ListArtisanCardItemState();
}

class _ListArtisanCardItemState extends State<ListArtisanCardItem> {
  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    // final kHeight = MediaQuery.of(context).size.height;
    final kWidth = MediaQuery.of(context).size.width;

    return Container(
      margin: EdgeInsets.only(bottom: getProportionateScreenHeight(kSpacingX4)),
      width: kWidth,
      child: Card(
        clipBehavior: Clip.hardEdge,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            getProportionateScreenWidth(kSpacingX8),
          ),
        ),
        child: GestureDetector(
          onTap: () => context.navigator.push(
            Routes.serviceProviderDetails,
            arguments: ServiceProviderDetailsArguments(
              artisan: widget.artisan?.user,
            ),
          ),
          child: Padding(
            padding: EdgeInsets.all(getProportionateScreenHeight(kSpacingX8)),
            child: Row(
              children: [
                UserAvatar(
                  url: widget.artisan?.user?.avatar,
                  ringColor: RandomColor(1)
                      .randomColor(colorBrightness: ColorBrightness.dark),
                ),
                SizedBox(width: getProportionateScreenWidth(kSpacingX8)),
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.artisan.user?.name,
                      maxLines: 1,
                      style: themeData.textTheme.headline6,
                    ),
                    SizedBox(height: getProportionateScreenHeight(kSpacingX4)),
                    Text(
                      widget.artisan.user?.business,
                      maxLines: 2,
                      overflow: TextOverflow.fade,
                      style: themeData.textTheme.caption,
                    ),
                  ],
                ),
                Spacer(),
                Text(
                  "\₵${widget.artisan.user?.startPrice}",
                  style: themeData.textTheme.headline6.copyWith(
                    color: themeData.colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

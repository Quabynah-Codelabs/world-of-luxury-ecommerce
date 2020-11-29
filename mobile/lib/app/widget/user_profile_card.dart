import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:handyman/app/widget/buttons.dart';
import 'package:handyman/core/constants.dart';
import 'package:handyman/core/size_config.dart';

class UserProfileCard extends StatefulWidget {
  final Function(bool, int) hasSelection;
  final List<String> profiles;
  final List<String> description;

  const UserProfileCard(
      {Key key, this.profiles, this.description, this.hasSelection})
      : super(key: key);

  @override
  _UserProfileCardState createState() => _UserProfileCardState();
}

class _UserProfileCardState extends State<UserProfileCard> {
  final _avatars = <String>[
    "https://images.unsplash.com/photo-1556742049-0cfed4f6a45d?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=600&q=60",
    "https://images.unsplash.com/photo-1511306162219-1c5a469ab86c?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=600&q=60"
  ];

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    final size = MediaQuery.of(context).size;
    final kWidth = size.width;
    final kHeight = size.height;

    return Container(
      width: kWidth,
      child: CarouselSlider.builder(
        itemCount: widget.profiles.length,
        itemBuilder: (_, index) {
          return InkWell(
            onTap: () {
              widget.hasSelection(true, index);
            },
            borderRadius: BorderRadius.circular(kSpacingX24),
            child: Container(
              clipBehavior: Clip.hardEdge,
              height: kHeight * 0.3,
              width: kWidth,
              margin: EdgeInsets.only(
                  right: getProportionateScreenWidth(kSpacingX24)),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: themeData.cardColor,
                borderRadius: BorderRadius.circular(kSpacingX24),
              ),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    color: themeData.disabledColor,
                    child: CachedNetworkImage(
                      imageUrl: _avatars[index],
                      fit: BoxFit.cover,
                      height: kHeight * 0.3,
                      width: kWidth,
                    ),
                  ),
                  Positioned(
                    top: kHeight * 0.18,
                    left: kSpacingNone,
                    right: kSpacingNone,
                    bottom: kSpacingNone,
                    child: Container(
                      color: themeData.scaffoldBackgroundColor
                          .withOpacity(kOpacityX90),
                      padding: EdgeInsets.symmetric(
                          horizontal: getProportionateScreenWidth(kSpacingX24)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            widget.profiles[index],
                            style: themeData.textTheme.headline5,
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(
                              height: getProportionateScreenHeight(kSpacingX4)),
                          Text(
                            widget.description[index],
                            style: themeData.textTheme.bodyText1,
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(
                              height:
                                  getProportionateScreenHeight(kSpacingX12)),
                          ButtonOutlined(
                            width: kWidth * 0.3,
                            themeData: themeData,
                            onTap: () =>
                                _showLearnMoreFor(widget.profiles[index]),
                            label: "Learn more",
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          );
        },
        options: CarouselOptions(
          initialPage: 0,
          autoPlay: false,
          enableInfiniteScroll: false,
          height: kHeight * 0.35,
          aspectRatio: 16 / 9,
          onPageChanged: (index, _) => widget.hasSelection(false, index),
        ),
      ),
    );
  }

  void _showLearnMoreFor(String profile) async {
    // TODO: Show bottom sheet with information for current profile
    ScaffoldMessenger.of(context)
      ..removeCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text("Feature unavailable"),
        behavior: SnackBarBehavior.floating,
      ));
  }
}

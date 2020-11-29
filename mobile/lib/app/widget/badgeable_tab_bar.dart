import 'package:flutter/material.dart';
import 'package:handyman/core/constants.dart';
import 'package:handyman/core/size_config.dart';
import 'package:meta/meta.dart';

class BadgeableTabBar extends StatelessWidget {
  final List<BadgeableTabBarItem> tabs;
  final int activeIndex;
  final Function(int) onTabSelected;
  final Color color;

  const BadgeableTabBar({
    Key key,
    @required this.tabs,
    @required this.activeIndex,
    @required this.onTabSelected,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    final size = MediaQuery.of(context).size;
    final kWidth = size.width;

    return Container(
      width: kWidth,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ...tabs
              .map(
                (tabItem) => InkWell(
                  splashColor: themeData.splashColor,
                  onTap: () => onTabSelected(tabs.indexOf(tabItem)),
                  child: tabItem
                    ..tabIndicatorWidth = tabs.indexOf(tabItem) == activeIndex
                        ? kSpacingX12
                        : kSpacingNone
                    ..color = tabs.indexOf(tabItem) == activeIndex
                        ? color
                        : themeData.disabledColor,
                ),
              )
              .toList(),
        ],
      ),
    );
  }
}

// ignore: must_be_immutable
class BadgeableTabBarItem extends StatelessWidget {
  final String title;
  final int badgeCount;
  Color color;
  double tabIndicatorWidth;

  BadgeableTabBarItem({
    Key key,
    @required this.title,
    this.badgeCount = 0,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    return AnimatedContainer(
      duration: kScaleDuration,
      margin: EdgeInsets.only(right: getProportionateScreenWidth(kSpacingX24)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Text(
                title,
                style: themeData.textTheme.bodyText1.copyWith(
                  color: color ?? themeData.disabledColor,
                ),
              ),
              SizedBox(width: getProportionateScreenWidth(kSpacingX8)),
              badgeCount == 0
                  ? SizedBox.shrink()
                  : Container(
                      alignment: Alignment.center,
                      height: getProportionateScreenHeight(kSpacingX24),
                      width: getProportionateScreenWidth(kSpacingX24),
                      decoration: BoxDecoration(
                        color: color ?? themeData.disabledColor,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        badgeCount.toString(),
                        style: themeData.textTheme.caption.copyWith(
                          color: kWhiteColor,
                        ),
                      ),
                    ),
            ],
          ),
          SizedBox(height: getProportionateScreenHeight(kSpacingX4)),
          Container(
            width: getProportionateScreenWidth(tabIndicatorWidth),
            height: getProportionateScreenHeight(kSpacingX4),
            decoration: BoxDecoration(
              color: color ?? themeData.disabledColor,
              borderRadius: BorderRadius.all(
                Radius.circular(getProportionateScreenWidth(kSpacingX12)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

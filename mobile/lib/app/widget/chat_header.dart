import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:handyman/core/constants.dart';
import 'package:handyman/core/size_config.dart';
import 'package:handyman/domain/models/user.dart';
import 'package:meta/meta.dart';

class ChatHeader extends StatelessWidget {
  final BaseUser user;

  const ChatHeader({Key key, @required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);

    return Container(
      alignment: Alignment.bottomCenter,
      height: kSpacingX64,
      width: double.infinity,
      decoration: BoxDecoration(
        color: themeData.scaffoldBackgroundColor.withOpacity(kOpacityX90),
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Feather.x),
            onPressed: () => context.navigator.pop(),
          ),
          Expanded(
            child: Container(
              margin: EdgeInsets.symmetric(
                  horizontal: getProportionateScreenWidth(kSpacingX8)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    user?.user?.name ?? "No name",
                    style: themeData.textTheme.headline6,
                  ),
                  SizedBox(height: getProportionateScreenHeight(kSpacingX4)),
                  Text(
                    user?.user?.business ??
                        user?.user?.email ??
                        "#unregistered",
                    style: themeData.textTheme.caption,
                  ),
                ],
              ),
            ),
          ),
          IconButton(
            icon: Icon(Entypo.dots_three_horizontal),
            onPressed: () => showNotAvailableDialog(context),
          ),
        ],
      ),
    );
  }
}

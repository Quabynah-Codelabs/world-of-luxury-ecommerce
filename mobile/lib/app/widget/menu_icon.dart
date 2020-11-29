import 'package:flutter/material.dart';
import 'package:handyman/core/constants.dart';
import 'package:handyman/core/size_config.dart';

class MenuIcon extends StatelessWidget {
  final Function onTap;

  const MenuIcon({
    Key key,
    @required this.onTap,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).iconTheme.color;
    return InkWell(
      borderRadius: BorderRadius.circular(kSpacingX4),
      onTap: onTap,
      child: Container(
        height: getProportionateScreenHeight(kSpacingX24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: getProportionateScreenHeight(kSpacingX4),
              width: getProportionateScreenWidth(kSpacingX16),
              decoration: BoxDecoration(
                shape: BoxShape.rectangle,
                color: color,
                borderRadius: BorderRadius.circular(kSpacingX4),
              ),
            ),
            Container(
              alignment: Alignment.centerLeft,
              height: getProportionateScreenHeight(kSpacingX4),
              width: getProportionateScreenWidth(kSpacingX12),
              decoration: BoxDecoration(
                shape: BoxShape.rectangle,
                color: color,
                borderRadius: BorderRadius.circular(kSpacingX4),
              ),
            ),
            Container(
              height: getProportionateScreenHeight(kSpacingX4),
              width: getProportionateScreenWidth(kSpacingX16),
              decoration: BoxDecoration(
                shape: BoxShape.rectangle,
                color: color,
                borderRadius: BorderRadius.circular(kSpacingX4),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

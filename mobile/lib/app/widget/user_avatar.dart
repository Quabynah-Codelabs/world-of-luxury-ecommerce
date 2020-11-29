import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:handyman/core/constants.dart';
import 'package:meta/meta.dart';
import 'package:uuid/uuid.dart';

/// User avatar widget.
/// Use the widget below as a placeholder to show a progress indicator
/// while images load.
/// Center(child: CircularProgressIndicator(value: downloadProgress.progress));
class UserAvatar extends StatelessWidget {
  final String url;
  final Function onTap;
  final double radius;
  final Color ringColor;
  final bool isCircular;
  final IconData errorIcon;

  const UserAvatar({
    Key key,
    @required this.url,
    @required this.ringColor,
    this.onTap,
    this.radius = kSpacingX48,
    this.isCircular = true,
    this.errorIcon = Feather.user,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);

    return GestureDetector(
      onTap: onTap ?? null,
      child: Hero(
        tag: Uuid().v4(),
        child: Container(
          height: radius,
          width: radius,
          clipBehavior: Clip.hardEdge,
          decoration: BoxDecoration(
            shape: isCircular ? BoxShape.circle : BoxShape.rectangle,
            color: themeData.scaffoldBackgroundColor,
            border: Border.all(color: ringColor, width: isCircular ? kSpacingX4 : kSpacingX2),
            borderRadius: isCircular ? null : BorderRadius.circular(radius / 8),
          ),
          child: url != null && url.isNotEmpty
              ? Container(
                  clipBehavior: Clip.hardEdge,
                  decoration: BoxDecoration(
                    shape: isCircular ? BoxShape.circle : BoxShape.rectangle,
                    borderRadius:
                        isCircular ? null : BorderRadius.circular(radius / 8),
                  ),
                  child: CachedNetworkImage(
                    imageUrl: url ?? "",
                    progressIndicatorBuilder: (_, url, downloadProgress) =>
                        Container(
                      clipBehavior: Clip.hardEdge,
                      decoration: BoxDecoration(
                        shape:
                            isCircular ? BoxShape.circle : BoxShape.rectangle,
                        borderRadius: isCircular
                            ? null
                            : BorderRadius.circular(radius / 8),
                      ),
                    ),
                    fit: BoxFit.cover,
                    width: radius,
                    height: radius,
                    alignment: Alignment.center,
                    errorWidget: (_, __, chunk) => Container(
                      alignment: Alignment.center,
                      height: radius,
                      width: radius,
                      clipBehavior: Clip.hardEdge,
                      decoration: BoxDecoration(
                        color: themeData.colorScheme.onBackground
                            .withOpacity(kOpacityX14),
                        borderRadius: isCircular
                            ? null
                            : BorderRadius.circular(radius / 8),
                        shape:
                            isCircular ? BoxShape.circle : BoxShape.rectangle,
                      ),
                      child: Icon(Feather.user,
                          size: radius / 2.5, color: ringColor),
                    ),
                  ),
                )
              : Container(
                  clipBehavior: Clip.hardEdge,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: themeData.colorScheme.onBackground
                        .withOpacity(kOpacityX14),
                    borderRadius:
                        isCircular ? null : BorderRadius.circular(radius / 8),
                    shape: isCircular ? BoxShape.circle : BoxShape.rectangle,
                  ),
                  child: Icon(
                    errorIcon,
                    size: radius / 3,
                    color: themeData.colorScheme.onBackground
                        .withOpacity(kOpacityX35),
                  ),
                ),
        ),
      ),
    );
  }
}

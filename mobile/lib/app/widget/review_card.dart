import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:handyman/app/widget/buttons.dart';
import 'package:handyman/app/widget/user_avatar.dart';
import 'package:handyman/core/constants.dart';
import 'package:handyman/core/size_config.dart';
import 'package:handyman/data/local_database.dart';
import 'package:handyman/domain/models/user.dart';
import 'package:handyman/domain/services/data.dart';
import 'package:meta/meta.dart';
import 'package:random_color/random_color.dart';
import 'package:share/share.dart';

class CustomerReviewCard extends StatefulWidget {
  final CustomerReview review;
  final DataService apiService;
  final String userId;

  const CustomerReviewCard({
    Key key,
    @required this.review,
    @required this.apiService,
    @required this.userId,
  }) : super(key: key);

  @override
  _CustomerReviewCardState createState() => _CustomerReviewCardState();
}

class _CustomerReviewCardState extends State<CustomerReviewCard> {
  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    final kWidth = MediaQuery.of(context).size.width;

    return StreamBuilder<BaseUser>(
        stream: widget.apiService.getCustomerById(id: widget.userId),
        builder: (context, snapshot) {
          final customer = snapshot.data?.user;
          return Container(
            width: kWidth,
            clipBehavior: Clip.hardEdge,
            decoration: BoxDecoration(
              color: themeData.cardColor,
              borderRadius: BorderRadius.circular(kSpacingX16),
            ),
            padding: EdgeInsets.symmetric(
              vertical: getProportionateScreenHeight(kSpacingX8),
              horizontal: getProportionateScreenWidth(kSpacingX12),
            ),
            margin: EdgeInsets.symmetric(
              horizontal: getProportionateScreenWidth(kSpacingX8),
              vertical: getProportionateScreenHeight(kSpacingX4),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    UserAvatar(
                      url: customer?.avatar ?? "",
                      ringColor: RandomColor()
                          .randomColor(colorBrightness: ColorBrightness.dark),
                    ),
                    SizedBox(width: getProportionateScreenWidth(kSpacingX16)),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          customer?.name ?? "",
                          style: themeData.textTheme.headline6,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          "@${customer?.name?.toString()?.toLowerCase()?.replaceAll(" ", "_")}",
                          style: themeData.textTheme.caption,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(
                            height: getProportionateScreenHeight(kSpacingX8)),
                        ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: kWidth * 0.7,
                          ),
                          child: Text(
                            widget.review.review ?? "",
                            style: themeData.textTheme.bodyText2,
                            textAlign: TextAlign.start,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(
                  height: getProportionateScreenHeight(kSpacingX12),
                ),
                Container(
                  width: kWidth,
                  margin: EdgeInsets.only(
                    right: getProportionateScreenWidth(kSpacingX8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      IconButton(
                        icon: Icon(Feather.thumbs_up),
                        onPressed: () => showNotAvailableDialog(context),
                      ),
                      IconButton(
                        icon: Icon(Feather.share_2),
                        onPressed: () => Share.share(widget.review.review),
                      ),
                      IconButton(
                        icon: Icon(Icons.reply_outlined),
                        onPressed: () => showNotAvailableDialog(context),
                      ),
                      widget.review.customerId == widget.userId
                          ? IconButton(
                              icon: Icon(Feather.trash_2),
                              onPressed: () => showDialog(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  content: Text(
                                      "Do you wish to delete this review?"),
                                  actions: [
                                    ButtonClear(
                                      text: "No",
                                      onPressed: () => ctx.navigator.pop(),
                                      themeData: themeData,
                                    ),
                                    ButtonClear(
                                      text: "Yes",
                                      onPressed: () {
                                        widget.apiService.deleteReviewById(
                                            id: widget.review.id,
                                            customerId: widget.userId);
                                        ctx.navigator.pop();
                                      },
                                      themeData: themeData,
                                    ),
                                  ],
                                ),
                              ),
                            )
                          : SizedBox.shrink(),
                    ],
                  ),
                ),
              ],
            ),
          );
        });
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:handyman/app/model/prefs_provider.dart';
import 'package:handyman/core/constants.dart';
import 'package:handyman/core/size_config.dart';
import 'package:handyman/data/local_database.dart';
import 'package:handyman/domain/models/user.dart';
import 'package:handyman/domain/services/data.dart';
import 'package:intl/intl.dart';
import 'package:meta/meta.dart';
import 'package:provider/provider.dart';

class ArtisanProfileInfo extends StatelessWidget {
  final Artisan artisan;
  final DataService apiService;

  const ArtisanProfileInfo(
      {Key key, @required this.artisan, @required this.apiService})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _themeData = Theme.of(context);

    return Consumer<PrefsProvider>(
      builder: (_, prefs, __) => StreamBuilder<BaseUser>(
          stream: apiService.getArtisanById(id: artisan?.id),
          builder: (context, snapshot) {
            return Material(
              type: MaterialType.card,
              elevation: 2,
              clipBehavior: Clip.hardEdge,
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: getProportionateScreenWidth(kSpacingX16),
                        vertical: getProportionateScreenHeight(kSpacingX12)),
                    decoration: BoxDecoration(color: _themeData.cardColor),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  artisan?.name ?? "",
                                  style: _themeData.textTheme.headline4,
                                ),
                                SizedBox(
                                  height:
                                      getProportionateScreenHeight(kSpacingX4),
                                ),
                                Text(
                                  artisan?.business ?? "",
                                  style: _themeData.textTheme.bodyText2,
                                ),
                                SizedBox(
                                  height:
                                      getProportionateScreenHeight(kSpacingX8),
                                ),
                                RichText(
                                  textAlign: TextAlign.start,
                                  text: TextSpan(
                                    children: <TextSpan>[
                                      TextSpan(
                                        text: "Available: ",
                                        style: _themeData.textTheme.bodyText1
                                            .copyWith(
                                          color: _themeData.primaryColor,
                                        ),
                                      ),
                                      TextSpan(
                                        text:
                                            "${DateFormat.jm().format(DateTime.fromMillisecondsSinceEpoch(artisan?.startWorkingHours ?? 0))} - ",
                                        style: _themeData.textTheme.bodyText2,
                                      ),
                                      TextSpan(
                                        text: DateFormat.jm().format(
                                            DateTime.fromMillisecondsSinceEpoch(
                                                artisan?.endWorkingHours ?? 0)),
                                        style: _themeData.textTheme.bodyText2,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(kSpacingX8),
                                  decoration: BoxDecoration(
                                    color: _themeData.primaryColor
                                        .withOpacity(kOpacityX90),
                                    borderRadius:
                                        BorderRadius.circular(kSpacingX8),
                                  ),
                                  child: Text(
                                    artisan?.rating?.toString() ?? "",
                                    style:
                                        _themeData.textTheme.bodyText1.copyWith(
                                      color: _themeData.colorScheme.onPrimary,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height:
                                      getProportionateScreenHeight(kSpacingX4),
                                ),
                                RatingBarIndicator(
                                  rating: artisan?.rating ?? 0,
                                  itemBuilder: (_, index) => Icon(
                                    kRatingStar,
                                    color: kAmberColor,
                                  ),
                                  itemCount: 5,
                                  itemSize: kSpacingX16,
                                  direction: Axis.horizontal,
                                ),
                              ],
                            ),
                          ],
                        ),
                        SizedBox(
                            height: getProportionateScreenHeight(kSpacingX8)),
                        Divider(height: kSpacingX12, endIndent: kSpacingX24),
                        SizedBox(
                            height: getProportionateScreenHeight(kSpacingX8)),
                        // SizedBox(height: getProportionateScreenHeight(kSpacingX16)),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  artisan?.completedBookingsCount?.toString() ??
                                      "",
                                  style:
                                      _themeData.textTheme.headline5.copyWith(
                                    color: _themeData.primaryColor,
                                  ),
                                ),
                                SizedBox(
                                  height:
                                      getProportionateScreenHeight(kSpacingX4),
                                ),
                                Text(
                                  "Ongoing",
                                  style: _themeData.textTheme.bodyText2,
                                ),
                              ],
                            ),
                            Container(
                              height: getProportionateScreenHeight(kSpacingX8),
                              width: getProportionateScreenWidth(kSpacingX8),
                              decoration: BoxDecoration(
                                color: _themeData.primaryColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  artisan?.ongoingBookingsCount?.toString() ??
                                      "",
                                  style: _themeData.textTheme.headline5
                                      .copyWith(color: kGreenColor),
                                ),
                                SizedBox(
                                  height:
                                      getProportionateScreenHeight(kSpacingX4),
                                ),
                                Text(
                                  "Completed",
                                  style: _themeData.textTheme.bodyText2,
                                ),
                              ],
                            ),
                            Container(
                              height: getProportionateScreenHeight(kSpacingX8),
                              width: getProportionateScreenWidth(kSpacingX8),
                              decoration: BoxDecoration(
                                color: _themeData.primaryColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  artisan?.cancelledBookingsCount?.toString() ??
                                      "",
                                  style:
                                      _themeData.textTheme.headline5.copyWith(
                                    color: _themeData.errorColor
                                        .withOpacity(kOpacityX70),
                                  ),
                                ),
                                SizedBox(
                                  height:
                                      getProportionateScreenHeight(kSpacingX4),
                                ),
                                Text(
                                  "Cancelled",
                                  style: _themeData.textTheme.bodyText2,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  artisan?.aboutMe?.isNotEmpty ?? false
                      ? Container(
                          padding: EdgeInsets.symmetric(
                            vertical: getProportionateScreenHeight(kSpacingX16),
                            horizontal:
                                getProportionateScreenWidth(kSpacingX24),
                          ),
                          decoration: BoxDecoration(
                            color: _themeData.colorScheme.primary
                                .withOpacity(kEmphasisHigh),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              RotatedBox(
                                quarterTurns: 2,
                                child: Container(
                                  alignment: Alignment.topCenter,
                                  child: Icon(
                                    Icons.format_quote_outlined,
                                    size:
                                        _themeData.textTheme.headline4.fontSize,
                                    color: _themeData.colorScheme.onPrimary,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  artisan?.aboutMe ?? "",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: _themeData.colorScheme.onPrimary,
                                  ),
                                ),
                              ),
                              Container(
                                alignment: Alignment.topCenter,
                                child: Icon(
                                  Icons.format_quote_outlined,
                                  size: _themeData.textTheme.headline4.fontSize,
                                  color: _themeData.colorScheme.onPrimary,
                                ),
                              ),
                            ],
                          ),
                        )
                      : SizedBox.shrink(),
                ],
              ),
            );
          }),
    );
  }
}

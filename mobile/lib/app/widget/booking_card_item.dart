import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:geolocator/geolocator.dart';
import 'package:handyman/core/constants.dart';
import 'package:handyman/core/size_config.dart';
import 'package:handyman/data/entities/booking.dart';
import 'package:handyman/data/local_database.dart';
import 'package:jiffy/jiffy.dart';
import 'package:meta/meta.dart';

/// [Booking] card item
class BookingCardItem extends StatefulWidget {
  final Booking booking;
  final Function onTap;
  final BookingType bookingType;

  const BookingCardItem({
    Key key,
    @required this.booking,
    @required this.onTap,
    this.bookingType = BookingType.NEW,
  }) : super(key: key);

  @override
  _BookingCardItemState createState() => _BookingCardItemState();
}

class _BookingCardItemState extends State<BookingCardItem> {
  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    final kDecoration = BoxDecoration(
      borderRadius: BorderRadius.circular(kSpacingX16),
      color: themeData.cardColor,
      border:
          Border.all(color: themeData.disabledColor.withOpacity(kEmphasisLow)),
    );

    return Padding(
      padding: EdgeInsets.only(
        bottom: getProportionateScreenHeight(kSpacingX12),
      ),
      child: Material(
        elevation: kSpacingX2,
        type: MaterialType.card,
        clipBehavior: Clip.hardEdge,
        shape: RoundedRectangleBorder(
          borderRadius: kDecoration.borderRadius,
          side: BorderSide(
            color: themeData.disabledColor.withOpacity(kEmphasisLow),
          ),
        ),
        child: Container(
          clipBehavior: Clip.hardEdge,
          width: double.infinity,
          decoration: kDecoration,
          padding: EdgeInsets.all(kSpacingX16),
          child: InkWell(
            borderRadius: kDecoration.borderRadius,
            onTap: () => widget.onTap(),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.booking.reason,
                          style: themeData.textTheme.headline6.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(
                          height: getProportionateScreenHeight(kSpacingX8),
                        ),
                        Row(
                          children: [
                            Icon(
                              Entypo.stopwatch,
                              size: themeData.textTheme.caption.fontSize,
                              color: themeData.colorScheme.primary,
                            ),
                            SizedBox(
                              width: getProportionateScreenWidth(kSpacingX4),
                            ),
                            RichText(
                              text: TextSpan(
                                children: <TextSpan>[
                                  TextSpan(
                                      style:
                                          themeData.textTheme.caption.copyWith(
                                        color: themeData.colorScheme.primary,
                                      ),
                                      text:
                                          "Due date - ${Jiffy.unix(widget.booking.dueDate).yMMMMd}"),
                                ],
                              ),
                              textAlign: TextAlign.start,
                            ),
                          ],
                        ),
                      ],
                    ),
                    Container(
                      height: getProportionateScreenHeight(kSpacingX42),
                      width: getProportionateScreenHeight(kSpacingX42),
                      decoration: BoxDecoration(
                        color: themeData.scaffoldBackgroundColor,
                        shape: BoxShape.circle,
                      ),
                      child: Stack(
                        fit: StackFit.loose,
                        children: [
                          Positioned.fill(
                            child: CircularProgressIndicator(
                              value: widget.booking.progress,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                themeData.colorScheme.primary,
                              ),
                              backgroundColor: themeData.disabledColor
                                  .withOpacity(kEmphasisLow),
                              strokeWidth: kSpacingX4,
                            ),
                          ),
                          Positioned(
                            top: kSpacingNone,
                            left: kSpacingNone,
                            right: kSpacingNone,
                            bottom: kSpacingNone,
                            child: Center(
                              child: widget.booking.progress == 1.0
                                  ? Icon(
                                      Feather.check,
                                      color: themeData.colorScheme.primary,
                                    )
                                  : Text(
                                      "${(widget.booking.progress * 100).round()}%",
                                      style:
                                          themeData.textTheme.overline.copyWith(
                                        color: themeData.colorScheme.primary,
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: getProportionateScreenHeight(kSpacingX16),
                ),
                // Location & Value
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Location",
                        ),
                        SizedBox(
                          height: getProportionateScreenHeight(kSpacingX4),
                        ),
                        FutureBuilder<String>(
                          future: getLocationName(
                            Position(
                                latitude: widget.booking.locationLat,
                                longitude: widget.booking.locationLng),
                          ),
                          builder: (_, locationSnapshot) {
                            debugPrint("Address -> ${locationSnapshot.data}");
                            return AnimatedOpacity(
                              opacity: locationSnapshot.hasData ? 1.0 : 0.0,
                              duration: kScaleDuration,
                              child: Row(
                                children: [
                                  Icon(
                                    Feather.map_pin,
                                    size:
                                        themeData.textTheme.bodyText1.fontSize,
                                    color: themeData.textTheme.bodyText1.color,
                                  ),
                                  SizedBox(
                                    width:
                                        getProportionateScreenWidth(kSpacingX4),
                                  ),
                                  Text(
                                    "Address - ${locationSnapshot.data}",
                                    style: themeData.textTheme.bodyText1,
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          "Value",
                        ),
                        SizedBox(
                          height: getProportionateScreenHeight(kSpacingX4),
                        ),
                        Text(
                          "GHC ${widget.booking.value}",
                          style: themeData.textTheme.bodyText1,
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

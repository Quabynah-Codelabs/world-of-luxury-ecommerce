import 'package:auto_route/auto_route.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:handyman/app/routes/route.gr.dart';
import 'package:handyman/app/widget/booking_card_item.dart';
import 'package:handyman/core/constants.dart';
import 'package:handyman/core/service_locator.dart';
import 'package:handyman/core/size_config.dart';
import 'package:handyman/data/local_database.dart';
import 'package:handyman/domain/services/data.dart';
import 'package:intl/intl.dart';
import 'package:jiffy/jiffy.dart';
import 'package:meta/meta.dart';
import 'package:sliding_sheet/sliding_sheet.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:uuid/uuid.dart';

final _kDefaultMargin = EdgeInsets.only(
  left: getProportionateScreenWidth(kSpacingX24),
  right: getProportionateScreenWidth(kSpacingX24),
  bottom: getProportionateScreenHeight(kSpacingX16),
);

Widget buildMapPreviewForBusinessLocation(
        {@required Position position, bool isLightTheme}) =>
    position == null
        ? SizedBox.shrink()
        : Column(
            children: [
              FutureBuilder<String>(
                  future: getLocationName(position),
                  builder: (context, snapshot) {
                    return Stack(
                      children: [
                        Padding(
                          padding: EdgeInsets.only(
                            left: getProportionateScreenWidth(kSpacingX16),
                            right: getProportionateScreenWidth(kSpacingX16),
                            bottom: getProportionateScreenHeight(kSpacingNone),
                          ),
                          child: Material(
                            clipBehavior: Clip.hardEdge,
                            borderRadius: BorderRadius.circular(kSpacingX16),
                            child: Container(
                              clipBehavior: Clip.hardEdge,
                              height:
                                  getProportionateScreenHeight(kSpacingX160),
                              width: double.infinity,
                              decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.circular(kSpacingX16),
                                border: Border.all(
                                    color: Theme.of(context)
                                        .disabledColor
                                        .withOpacity(kEmphasisLow)),
                              ),
                              child: Stack(
                                fit: StackFit.loose,
                                children: [
                                  GoogleMap(
                                    markers: [
                                      Marker(
                                        markerId: MarkerId(Uuid().v4()),
                                        position: LatLng(
                                            position?.latitude ?? 0,
                                            position?.longitude ?? 0),
                                        infoWindow: InfoWindow(
                                          title: "Your current location",
                                          snippet: snapshot.data ?? "",
                                        ),
                                      ),
                                    ].toSet(),
                                    initialCameraPosition: CameraPosition(
                                      target: LatLng(position.latitude,
                                          position.longitude),
                                      zoom: 18.0,
                                    ),
                                    zoomControlsEnabled: false,
                                    liteModeEnabled: defaultTargetPlatform ==
                                        TargetPlatform.android,
                                    mapToolbarEnabled: false,
                                    compassEnabled: false,
                                    indoorViewEnabled: false,
                                    myLocationButtonEnabled: false,
                                    myLocationEnabled: false,
                                    rotateGesturesEnabled: false,
                                    scrollGesturesEnabled: false,
                                    tiltGesturesEnabled: false,
                                    zoomGesturesEnabled: false,
                                    onMapCreated: (controller) async {
                                      final mapStyle = await getMapStyle(
                                          isLightTheme: isLightTheme ?? false);
                                      controller.setMapStyle(mapStyle);
                                    },
                                  ),
                                  snapshot.hasData
                                      ? Positioned(
                                          bottom: kSpacingNone,
                                          left: kSpacingNone,
                                          right: kSpacingNone,
                                          child: Container(
                                            color: Theme.of(context)
                                                .scaffoldBackgroundColor
                                                .withOpacity(kOpacityX50),
                                            height: kToolbarHeight,
                                            alignment: Alignment.center,
                                            child: Text(
                                              snapshot.data,
                                              textAlign: TextAlign.center,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .headline6
                                                  .copyWith(
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .onBackground,
                                                  ),
                                            ),
                                          ),
                                        )
                                      : SizedBox.shrink(),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          top: kSpacingNone,
                          right: getProportionateScreenWidth(kSpacingX16),
                          child: InkWell(
                            onTap: () => showNotAvailableDialog(context),
                            borderRadius: BorderRadius.only(
                              topRight: Radius.circular(kSpacingX16),
                              bottomLeft: Radius.circular(kSpacingX16),
                            ),
                            splashColor: Theme.of(context).splashColor,
                            child: Container(
                              alignment: Alignment.center,
                              height: getProportionateScreenHeight(kSpacingX42),
                              width: getProportionateScreenWidth(kSpacingX42),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.only(
                                  topRight: Radius.circular(kSpacingX16),
                                  bottomLeft: Radius.circular(kSpacingX16),
                                ),
                                color: Theme.of(context).primaryColor,
                              ),
                              child: Icon(
                                Feather.map_pin,
                                color: Theme.of(context).colorScheme.onPrimary,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  }),
              SizedBox(height: getProportionateScreenHeight(kSpacingX36)),
            ],
          );

Widget buildArtisanMetadataBar(BuildContext context, ThemeData themeData,
        {@required Artisan artisan}) =>
    Container(
      margin: _kDefaultMargin,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.symmetric(
              vertical: getProportionateScreenHeight(kSpacingX12),
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(kSpacingX16),
              color: themeData.cardColor.withOpacity(kEmphasisMedium),
              border: Border.all(
                  color: themeData.disabledColor.withOpacity(kEmphasisLow)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text("Joined".toUpperCase(),
                        style: themeData.textTheme.subtitle2),
                    SizedBox(height: getProportionateScreenHeight(kSpacingX4)),
                    Text(_parseDateInYears(artisan?.createdAt),
                        style: themeData.textTheme.bodyText1),
                  ],
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text("Bookings".toUpperCase(),
                        style: themeData.textTheme.subtitle2),
                    SizedBox(height: getProportionateScreenHeight(kSpacingX4)),
                    Text(
                      artisan?.requestsCount == 0
                          ? "None recently"
                          : "${artisan?.requestsCount ?? 0} bookings",
                      style: themeData.textTheme.bodyText1,
                    ),
                  ],
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text("Reports".toUpperCase(),
                        style: themeData.textTheme.subtitle2),
                    SizedBox(height: getProportionateScreenHeight(kSpacingX4)),
                    Text("${artisan?.reportsCount ?? 0}",
                        style: themeData.textTheme.bodyText1),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: getProportionateScreenHeight(kSpacingX12)),
          Container(
            padding: EdgeInsets.symmetric(
              vertical: getProportionateScreenHeight(kSpacingX12),
              horizontal: getProportionateScreenWidth(kSpacingX16),
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(kSpacingX16),
              color: themeData.cardColor.withOpacity(kEmphasisMedium),
              border: Border.all(
                  color: themeData.disabledColor.withOpacity(kEmphasisLow)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text("Time management:"),
                        SizedBox(
                            width: getProportionateScreenWidth(kSpacingX8)),
                        RatingBarIndicator(
                          rating: 4.50,
                          direction: Axis.horizontal,
                          itemCount: 5,
                          itemSize: kSpacingX12,
                          itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                          itemBuilder: (context, _) =>
                              Icon(kRatingStar, color: kAmberColor),
                        ),
                      ],
                    ),
                    SizedBox(height: getProportionateScreenHeight(kSpacingX12)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text("Professionalism:"),
                        SizedBox(
                            width: getProportionateScreenWidth(kSpacingX8)),
                        RatingBarIndicator(
                          rating: 5.00,
                          direction: Axis.horizontal,
                          itemCount: 5,
                          itemSize: kSpacingX12,
                          itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                          itemBuilder: (context, _) =>
                              Icon(kRatingStar, color: kAmberColor),
                        ),
                      ],
                    ),
                    SizedBox(height: getProportionateScreenHeight(kSpacingX12)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text("Quality of work:"),
                        SizedBox(
                            width: getProportionateScreenWidth(kSpacingX8)),
                        RatingBarIndicator(
                          rating: 3.50,
                          direction: Axis.horizontal,
                          itemCount: 5,
                          itemSize: kSpacingX12,
                          itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                          itemBuilder: (context, _) =>
                              Icon(kRatingStar, color: kAmberColor),
                        ),
                      ],
                    ),
                  ],
                ),
                IconButton(
                  icon: Icon(Feather.help_circle),
                  onPressed: () => showNotAvailableDialog(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );

String _parseDateInYears(int createdAt) => Jiffy(
        DateFormat("yyyy-MM-dd", "en_US").format(
          DateTime.fromMillisecondsSinceEpoch(createdAt ?? 0),
        ),
        "yyyy-MM-dd")
    .fromNow();

/*color: themeData.scaffoldBackgroundColor.withOpacity(kEmphasisLow),
        borderRadius: BorderRadius.circular(kSpacingX16),
        border: Border.all(
            color: themeData.disabledColor.withOpacity(kEmphasisLow)),*/

Widget buildProfileDescriptor(
  BuildContext context, {
  String title,
  String content,
  ThemeData themeData,
  FocusNode focusNode,
  void Function() onTap,
  void Function(String) onEditComplete,
  TextEditingController controller,
  bool isEditable = true,
  String hint = "Say something...",
  bool isEditing = false,
  TextInputAction inputAction = TextInputAction.done,
  IconData iconData = Feather.edit_2,
}) =>
    AnimatedContainer(
      duration: kScaleDuration,
      padding: EdgeInsets.fromLTRB(
        getProportionateScreenWidth(kSpacingX16),
        getProportionateScreenHeight(kSpacingX4),
        getProportionateScreenWidth(kSpacingX16),
        getProportionateScreenHeight(kSpacingX16),
      ),
      decoration: BoxDecoration(
        color: themeData.scaffoldBackgroundColor.withOpacity(kEmphasisLow),
        borderRadius: BorderRadius.circular(kSpacingX16),
        border: Border.all(
            color: themeData.disabledColor.withOpacity(kEmphasisLow)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(title, style: themeData.textTheme.headline6),
              isEditable
                  ? IconButton(
                      icon: Icon(iconData),
                      onPressed: isEditing
                          ? () => onEditComplete(controller.text)
                          : onTap,
                    )
                  : SizedBox(height: getProportionateScreenHeight(kSpacingX36)),
            ],
          ),
          SizedBox(
            height: getProportionateScreenHeight(kSpacingX8),
          ),
          isEditing
              ? Container(
                  child: TextFormField(
                    focusNode: focusNode ??= FocusNode(),
                    autofocus: false,
                    minLines: 5,
                    maxLines: 8,
                    enableSuggestions: true,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: hint,
                      hintStyle: TextStyle(color: themeData.disabledColor),
                    ),
                    textAlign: TextAlign.start,
                    // keyboardType: ,
                    onFieldSubmitted: (input) => onEditComplete(input),
                    controller: controller,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    autocorrect: true,
                    textInputAction: inputAction,
                    onTap: () {},
                  ),
                )
              : Text(content, style: themeData.textTheme.bodyText2),
        ],
      ),
    );

Widget buildCalendarTable(
  ThemeData themeData,
  BuildContext context,
  Artisan artisan,
  CalendarController controller,
) =>
    Container(
      child: TableCalendar(
        calendarController: controller,
        onDaySelected: (day, _, __) async {
          await _showBottomSheetForDay(
              context, themeData, artisan, day.millisecondsSinceEpoch);
        },
      ),
    );

Future<void> _showBottomSheetForDay(
    BuildContext context, ThemeData themeData, Artisan artisan, day) async {
  await showSlidingBottomSheet(context, builder: (context) {
    return SlidingSheetDialog(
      elevation: kSpacingX8,
      dismissOnBackdropTap: false,
      addTopViewPaddingOnFullscreen: true,
      headerBuilder: (_, __) => Material(
        type: MaterialType.card,
        clipBehavior: Clip.hardEdge,
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: getProportionateScreenWidth(kSpacingX16),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "Showing bookings for ${Jiffy.unix(day).yMd}",
                style: themeData.textTheme.headline6,
              ),
              IconButton(
                icon: Icon(
                  Feather.chevron_down,
                ),
                color: themeData.colorScheme.onBackground,
                onPressed: () => context.navigator.pop(),
              ),
            ],
          ),
        ),
      ),
      color: themeData.scaffoldBackgroundColor.withOpacity(kOpacityX50),
      duration: kScaleDuration,
      cornerRadius: kSpacingX16,
      snapSpec: const SnapSpec(
        snap: true,
        snappings: [0.4, 0.75],
        positioning: SnapPositioning.relativeToAvailableSpace,
      ),
      padding: EdgeInsets.symmetric(
        vertical: getProportionateScreenHeight(kSpacingX8),
      ),
      // addTopViewPaddingOnFullscreen: true,
      builder: (context, state) {
        return Material(
          type: MaterialType.card,
          clipBehavior: Clip.hardEdge,
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
                // color: themeData.scaffoldBackgroundColor,
                ),
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                vertical: getProportionateScreenHeight(kSpacingX16),
                horizontal: getProportionateScreenWidth(kSpacingX16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  StreamBuilder<List<Booking>>(
                      stream: sl
                          .get<DataService>()
                          .getBookingsForArtisan(artisan.id),
                      initialData: [],
                      builder: (context, snapshot) {
                        return snapshot.hasError ||
                                snapshot.hasData && snapshot.data.isEmpty
                            ? Container(
                                height: kSpacingX320,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Entypo.bucket,
                                      size: getProportionateScreenHeight(
                                          kSpacingX96),
                                      color: themeData.colorScheme.onBackground,
                                    ),
                                    SizedBox(
                                      height: getProportionateScreenHeight(
                                          kSpacingX16),
                                    ),
                                    Text(
                                      "You have no bookings for today",
                                      style: themeData.textTheme.bodyText2
                                          .copyWith(
                                        color: themeData.disabledColor,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              )
                            : AnimationLimiter(
                                child: AnimationConfiguration.synchronized(
                                  duration: kScaleDuration,
                                  child: Column(
                                    children: [
                                      ...snapshot.data
                                          .where((element) =>
                                              element.dueDate <= day)
                                          .map(
                                            (item) => BookingCardItem(
                                              booking: item,
                                              onTap: () =>
                                                  context.navigator.push(
                                                Routes.bookingsDetailsPage,
                                                arguments:
                                                    BookingsDetailsPageArguments(
                                                        booking: item),
                                              ),
                                            ),
                                          )
                                          .toList(),
                                    ],
                                  ),
                                ),
                              );
                      }),
                  // SizedBox(
                  //   height: getProportionateScreenHeight(kSpacingX16),
                  // ),
                  // ButtonOutlined(
                  //   label: "Save",
                  //   onTap: () {},
                  //   width: MediaQuery.of(context).size.width * 0.4,
                  //   themeData: themeData,
                  // ),
                ],
              ),
            ),
          ),
        );
      },
    );
  });
}

import 'package:auto_route/auto_route.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:handyman/app/model/prefs_provider.dart';
import 'package:handyman/app/widget/artisan_settings_widgets.dart';
import 'package:handyman/app/widget/badgeable_tab_bar.dart';
import 'package:handyman/app/widget/marker_generator.dart';
import 'package:handyman/core/constants.dart';
import 'package:handyman/core/service_locator.dart';
import 'package:handyman/core/size_config.dart';
import 'package:handyman/data/local_database.dart';
import 'package:handyman/domain/services/auth.dart';
import 'package:handyman/domain/services/data.dart';
import 'package:meta/meta.dart';
import 'package:provider/provider.dart';

class BookingsDetailsPage extends StatefulWidget {
  final Booking booking;

  const BookingsDetailsPage({Key key, @required this.booking})
      : super(key: key);

  @override
  _BookingsDetailsPageState createState() => _BookingsDetailsPageState();
}

class _BookingsDetailsPageState extends State<BookingsDetailsPage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  DataService _dataService = sl.get<DataService>();
  double _kWidth, _kHeight;
  ThemeData _themeData;
  var markers = <Marker>[];
  int _currentTabIndex = 0;
  final _pageController = PageController(initialPage: 0, keepPage: true);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _themeData = Theme.of(context);
    final size = MediaQuery.of(context).size;
    _kWidth = size.width;
    _kHeight = size.height;
  }

  @override
  void initState() {
    super.initState();
    MarkerGenerator([
      Text("Hello"),
    ], (bitmaps) {
      setState(() {
        // markers = mapBitmapsToMarkers(bitmaps);
      });
    }).generate(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      extendBody: true,
      body: Consumer<AuthService>(
        builder: (_, service, __) => Consumer<PrefsProvider>(
          builder: (_, provider, __) => StreamBuilder<Booking>(
              initialData: widget.booking,
              stream: _dataService.getBookingById(id: widget.booking.id),
              builder: (_, bs) {
                final booking = bs.data;
                return Stack(
                  fit: StackFit.expand,
                  children: [
                    provider.isLightTheme
                        ? Container(
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: AssetImage(kBackgroundAsset),
                                fit: BoxFit.cover,
                              ),
                            ),
                          )
                        : SizedBox.shrink(),
                    Positioned(
                      height: getProportionateScreenHeight(kSpacingX360),
                      width: _kWidth,
                      child: Container(
                        height: getProportionateScreenHeight(kSpacingX360),
                        width: _kWidth,
                        child: GoogleMap(
                          initialCameraPosition: CameraPosition(
                            target: LatLng(
                              booking.locationLat,
                              booking.locationLng,
                            ),
                            zoom: 16.0,
                          ),
                          markers: (markers
                                ..add(
                                  Marker(
                                    markerId: MarkerId(booking.id),
                                    position: LatLng(
                                      booking.locationLat,
                                      booking.locationLng,
                                    ),
                                    draggable: false,
                                    // icon: ,
                                  ),
                                ))
                              .toSet(),
                          liteModeEnabled:
                              defaultTargetPlatform == TargetPlatform.android,
                          myLocationButtonEnabled: true,
                          myLocationEnabled: true,
                          rotateGesturesEnabled: true,
                          trafficEnabled: true,
                          zoomControlsEnabled: false,
                          zoomGesturesEnabled: true,
                          onMapCreated: (controller) async {
                            debugPrint(
                                "Light mode for map => ${provider.isLightTheme}");
                            final mapStyle = await getMapStyle(
                                isLightTheme: provider.isLightTheme ?? false);
                            controller.setMapStyle(mapStyle);
                            setState(() {});
                          },
                        ),
                      ),
                    ),
                    Positioned(
                      width: _kWidth,
                      top: getProportionateScreenHeight(kSpacingX320),
                      bottom: kSpacingNone,
                      child: Container(
                        clipBehavior: Clip.hardEdge,
                        decoration: BoxDecoration(
                          color: _themeData.cardColor,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(kSpacingX24),
                            topRight: Radius.circular(kSpacingX24),
                          ),
                        ),
                        padding: EdgeInsets.only(
                          top: getProportionateScreenHeight(kSpacingX16),
                        ),
                        height: _kHeight,
                        width: _kWidth,
                        child: ListView(
                          padding: EdgeInsets.symmetric(
                            horizontal:
                                getProportionateScreenWidth(kSpacingX24),
                            vertical: getProportionateScreenHeight(kSpacingX16),
                          ),
                          children: [
                            Text(
                              widget.booking.reason,
                              style: _themeData.textTheme.headline5.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(
                                height:
                                    getProportionateScreenHeight(kSpacingX16)),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Overall progress",
                                  style: _themeData.textTheme.caption.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  "${(widget.booking.progress * 100).round()}%",
                                  style: _themeData.textTheme.caption.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                                height:
                                    getProportionateScreenHeight(kSpacingX8)),
                            LinearProgressIndicator(
                              minHeight: 6,
                              value: widget.booking.progress,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                _themeData.colorScheme.primary,
                              ),
                              backgroundColor: _themeData.disabledColor
                                  .withOpacity(kEmphasisLow),
                            ),
                            SizedBox(
                                height:
                                    getProportionateScreenHeight(kSpacingX16)),
                            buildProfileDescriptor(
                              context,
                              themeData: _themeData,
                              title: "Description",
                              isEditable: false,
                              content: widget.booking.description,
                              onTap: () => showNotAvailableDialog(context),
                            ),
                            SizedBox(
                                height:
                                    getProportionateScreenHeight(kSpacingX16)),
                            Container(
                              margin: EdgeInsets.symmetric(
                                horizontal:
                                    getProportionateScreenWidth(kSpacingNone),
                              ),
                              child: BadgeableTabBar(
                                tabs: <BadgeableTabBarItem>[
                                  BadgeableTabBarItem(title: "Tasks"),
                                  BadgeableTabBarItem(title: "Overview"),
                                  BadgeableTabBarItem(title: "Notes"),
                                ],
                                onTabSelected: (index) {
                                  _currentTabIndex = index;
                                  _pageController.animateToPage(
                                    index,
                                    curve: Curves.fastOutSlowIn,
                                    duration: kSheetDuration,
                                  );
                                  setState(() {});
                                },
                                color: _themeData.colorScheme.primary,
                                activeIndex: _currentTabIndex,
                              ),
                            ),
                            SizedBox(
                                height:
                                    getProportionateScreenHeight(kSpacingX16)),
                            Container(
                              height:
                                  getProportionateScreenHeight(kSpacingX320),
                              child: PageView.builder(
                                controller: _pageController,
                                clipBehavior: Clip.hardEdge,
                                pageSnapping: true,
                                onPageChanged: (index) {
                                  setState(() {
                                    _currentTabIndex = index;
                                  });
                                },
                                itemCount: 3,
                                itemBuilder: (_, index) {
                                  return buildFunctionalityNotAvailablePanel(
                                      context);
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      top: kSpacingNone,
                      width: _kWidth,
                      child: _buildAppBar(provider),
                    ),
                  ],
                );
              }),
        ),
      ),
    );
  }

  Widget _buildAppBar(PrefsProvider provider) => SafeArea(
        child: Container(
          padding: EdgeInsets.symmetric(
            vertical: getProportionateScreenHeight(kSpacingX8),
          ),
          color: _themeData.scaffoldBackgroundColor.withOpacity(kOpacityX50),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: _kWidth,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      tooltip: "Go back",
                      icon: Icon(Feather.x),
                      onPressed: () => context.navigator.pop(),
                    ),
                    IconButton(
                      tooltip: "Toggle theme",
                      icon: Icon(
                        provider.isLightTheme ? Feather.moon : Feather.sun,
                      ),
                      onPressed: () => provider.toggleTheme(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
}

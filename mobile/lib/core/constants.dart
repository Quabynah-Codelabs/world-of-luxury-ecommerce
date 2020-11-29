import 'package:algolia/algolia.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:geocoder/geocoder.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:handyman/app/widget/buttons.dart';

import 'size_config.dart';

/// Defaults
const kGeneralCategory = "bbe8a179-7797-4d87-b388-cf93125f490e";
const _kGoogleApiKey = "AIzaSyByvL9jc4UvlhILkhAZs7ZrQP68LwWDgFg";
const kRatingStar = Entypo.star;

/// Predicts location address info using Google Places API
Future<Prediction> getLocationPrediction(context) async =>
    await PlacesAutocomplete.show(
      context: context,
      apiKey: _kGoogleApiKey,
      mode: Mode.overlay,
      // Mode.fullscreen
      language: "en",
    );

Future<String> getLocationName(Position position) async {
  final addresses = await Geocoder.local.findAddressesFromCoordinates(
      Coordinates(position.latitude, position.longitude));
  return addresses.first?.addressLine ?? "Unknown location";
}

void showNotAvailableDialog(BuildContext context) => showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Oops..."),
        content: Text(kFunctionalityUnavailable),
        actions: [
          ButtonClear(
            text: "Dismiss",
            onPressed: () => ctx.navigator.pop(),
            themeData: Theme.of(context),
          ),
        ],
      ),
    );

Widget buildFunctionalityNotAvailablePanel(BuildContext context) => Container(
      height: getProportionateScreenHeight(kSpacingX320),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            Entypo.feather,
            size: getProportionateScreenHeight(kSpacingX96),
            color: Theme.of(context).colorScheme.onBackground,
          ),
          SizedBox(height: getProportionateScreenHeight(kSpacingX24)),
          Text(
            "Functionality currently not available",
            style: Theme.of(context).textTheme.subtitle1,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: getProportionateScreenHeight(kSpacingX8)),
          Text(
            "Grab a beverage and check back later!",
            style: Theme.of(context).textTheme.bodyText2.copyWith(
                  color: Theme.of(context).disabledColor,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );

Future getMapStyle({bool isLightTheme = false}) async =>
    await rootBundle.loadString(
        isLightTheme ? "assets/map_style.json" : "assets/dark_map_style.json");

/// Dimensions
const double kSpacingNone = 0.0;
const double kSpacingX2 = 2.0;
const double kSpacingX4 = 4.0;
const double kSpacingX8 = 8.0;
const double kSpacingX12 = 12.0;
const double kSpacingX16 = 16.0;
const double kSpacingX20 = 20.0;
const double kSpacingX24 = 24.0;
const double kSpacingX36 = 36.0;
const double kSpacingX42 = 42.0;
const double kSpacingX48 = 48.0;
const double kSpacingX56 = 56.0;
const double kSpacingX64 = 64.0;
const double kSpacingX72 = 72.0;
const double kSpacingX84 = 84.0;
const double kSpacingX96 = 96.0;
const double kSpacingX100 = 100.0;
const double kSpacingX120 = 120.0;
const double kSpacingX140 = 120.0;
const double kSpacingX160 = 160.0;
const double kSpacingX200 = 200.0;
const double kSpacingX230 = 230.0;
const double kSpacingX250 = 250.0;
const double kSpacingX300 = 300.0;
const double kSpacingX320 = 320.0;
const double kSpacingX360 = 360.0;
const double kOpacityX14 = 0.14;
const double kOpacityX35 = 0.35;
const double kOpacityX50 = 0.5;
const double kOpacityX70 = 0.7;
const double kOpacityX90 = 0.9;
const double kEmphasisLow = 0.38;
const double kEmphasisMedium = 0.67;
const double kEmphasisHigh = 0.9;

/// App
const kAppName = "HandyMan";
const kAppSlogan = "Get some real work done";
const kAppVersion = "v0.0.1";
const kAppSloganDesc = "Find your service & book easily with $kAppName";
const kArtisanReviewHelpDialogContent =
    "Sensitive data (like email addresses, phone numbers, user ids etc) will not be made public to customers on this platform.\nYour ratings are also based on the accumulated reviews by customers you have served over the last 6 months";
const kPasswordHint =
    "Your password must be 8 or more characters long & must contain a mix of upper & lower case letters,a number & a symbol";
const kSignOutText =
    "Signing out will set you offline until you sign in again. You may not be able to send/receive requests. Do you wish to continue?";
const kAccountCompletionHelperText =
    "In order to complete your mobile registration process, kindly setup your profile information and upload a business document. You will be notified within the next 72 hours. Thank you!";
const kArtisanString = "Artisan";
const kFunctionalityUnavailable =
    "Functionality is currently unavailable. Try again after the next update. Thank you";
const kCustomerString = "Customer";
const kLogoAsset = "assets/logo/logo_colored.svg";
const kLogoDarkAsset = "assets/logo/logo_dark.svg";
const kTimeSvgAsset = "assets/svg/time.svg";
const kPeopleSvgAsset = "assets/svg/people.svg";
const kBookingSvgAsset = "assets/svg/booking.svg";
const kBackgroundAsset = "assets/bg/bg.webp";
const kLoremText =
    "Ipsum suspendisse ultrices gravida dictum fusce ut placerat. Cursus sit amet dictum sit amet. Vel elit scelerisque mauris pellentesque pulvinar pellentesque habitant morbi tristique";

/// [Algolia]
const kAlgoliaAppId = "AIBRVBFA4W";
const kAlgoliaKey = "604022a17d65f30d23e80a38f285be57";

/// Durations
const kScaleDuration = const Duration(milliseconds: 350);
const kTestDuration = const Duration(milliseconds: 2500);
const kSheetDuration = const Duration(milliseconds: 850);

/// Others
const kScrollPhysics = const BouncingScrollPhysics();
const kSlideOffset = 50.0;

/// Colors
const kGreenColor = Color(0xFF009688);
const kWhiteColor = Colors.white;
const kBlackColor = Colors.black87;
const kAmberColor = Colors.amber;
const kChatBackgroundLight = Color(0xFFF5F5F5);
const kChatBackgroundDark = Color(0xFF222222);
const kTransparent = Colors.transparent;
const kPlaceholderColor = Color(0x70000000);
const kDisabledColor = Color(0xFF666666);
// const kDisabledColorDark = Color(0x1f000000);

// const kPrimaryColor = Color(0xFF5d1049);
// const kSecondaryLightColor = Color(0xFFe30425);
const kPrimaryColor = Color(0xFF0E37EA);
const kSecondaryLightColor = Color(0xFFEBB609);
const kErrorLightColor = Color(0xffE91E63);
const kAccentLightColor = kSecondaryLightColor;
const kBackgroundLightColor = kWhiteColor;
const kCardLightColor = kWhiteColor;

const kPrimaryColorDark = Color(0xFF9BA1F6);
// const kPrimaryColorDark = Color(0xFFFF7597);
const kSecondaryDarkColor = Color(0xFF9BA1F6);
const kErrorDarkColor = Color(0xffEC407A);
const kAccentDarkColor = kWhiteColor;
const kBackgroundDarkColor = Color(0xFF151515);
// const kBackgroundDarkColor = Color(0xFF202124);
// const kBackgroundDarkColor = Color(0xFF24191C);
const kCardDarkColor = Color(0xFF272727);
// const kCardDarkColor = Color(0xFF3C4043);
const kSurfaceDarkColor = Color(0xFF222225);

/// Icon Colors
const kAccentIconLightColor = kPrimaryColor;
const kPrimaryIconLightColor = kPrimaryColor;

const kAccentIconDarkColor = kWhiteColor;
const kPrimaryIconDarkColor = kWhiteColor;

/// Text Colors
const kBodyTextColorLight = Color(0xFF232323);
const kTitleTextColorLight = Color(0xFF131313);
const kUnselectedLabelColorLight = Color(0xFF7C7C7C);

// const kBodyTextColorDark = Color(0xFF7C7C7C);
// const kUnselectedLabelColorDark = Color(0xFF5F6368);
const kBodyTextColorDark = Color(0xFFDEDEDE);
const kUnselectedLabelColorDark = Color(0xFFDEDEDE);
const kTitleTextColorDark = Color(0xFFDEDEDE);

const kShadowColor = Color(0xFFDEDEDE);
const kShadowDarkColor = Color(0xFF7C7C7C);

import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:handyman/app/model/prefs_provider.dart';
import 'package:handyman/app/pages/login.dart';
import 'package:handyman/app/routes/route.gr.dart';
import 'package:handyman/app/widget/artisan_settings_widgets.dart';
import 'package:handyman/app/widget/badgeable_tab_bar.dart';
import 'package:handyman/app/widget/buttons.dart';
import 'package:handyman/app/widget/fields.dart';
import 'package:handyman/app/widget/loaders.dart';
import 'package:handyman/app/widget/user_avatar.dart';
import 'package:handyman/core/constants.dart';
import 'package:handyman/core/service_locator.dart';
import 'package:handyman/core/size_config.dart';
import 'package:handyman/data/entities/artisan_model.dart';
import 'package:handyman/data/local_database.dart';
import 'package:handyman/data/services/data.dart';
import 'package:handyman/data/services/storage.dart';
import 'package:handyman/domain/models/user.dart';
import 'package:handyman/domain/services/auth.dart';
import 'package:handyman/domain/services/data.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

/// activeTabIndex legend:
/// 0 => calendar
/// 1 => profile
/// 2 => history
class ProviderSettingsPage extends StatefulWidget {
  final int activeTabIndex;

  const ProviderSettingsPage({
    Key key,
    this.activeTabIndex = 1,
  }) : super(key: key);

  @override
  _ProviderSettingsPageState createState() => _ProviderSettingsPageState();
}

class _ProviderSettingsPageState extends State<ProviderSettingsPage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  double _kWidth;
  ThemeData _themeData;
  bool _isLoading = false;

  // Artisan _currentUser;
  bool _shouldDismissEarnPointsSheet = true,
      _isEditingAboutMe = false,
      _isEditingPhone = false,
      _isEditingBusinessName = false;
  int _activeTabIndex;
  TextEditingController _businessNameController = TextEditingController(),
      _nameController = TextEditingController(),
      _aboutController = TextEditingController(),
      _phoneController = TextEditingController();

  CalendarController _calendarController;
  DataService _dataService = DataServiceImpl.instance;
  final _storageService = StorageServiceImpl.instance;

  File _avatar;
  String _userId;
  final picker = ImagePicker();

  _showPickerDialog(BuildContext ctx) => AlertDialog(
        title: Text("Select an option"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text("View"),
              leading: Icon(Feather.eye),
              onTap: () {
                ctx.navigator.pop();
                showNotAvailableDialog(ctx);
              },
            ),
            ListTile(
              title: Text("Change avatar"),
              leading: Icon(Feather.user),
              onTap: () async {
                ctx.navigator.pop();
                await _getImage();
              },
            ),
          ],
        ),
        actions: [
          ButtonClear(
            text: "Dismiss",
            onPressed: () => ctx.navigator.pop(),
            themeData: Theme.of(context),
          )
        ],
      );

  Future<void> _getImage() async {
    final pickedFile = await picker.getImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      _avatar = File(pickedFile.path);
      await _storageService.uploadFile(_avatar, path: _userId);
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    _calendarController = CalendarController();
    if (mounted) {
      _storageService.onStorageUploadResponse.listen((event) {
        debugPrint(event.state.toString());
      });
      _activeTabIndex = widget.activeTabIndex;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _themeData = Theme.of(context);
    final size = MediaQuery.of(context).size;
    _kWidth = size.width;
  }

  @override
  void dispose() {
    // Focus.of(context).unfocus();
    _calendarController?.dispose();
    // _dataService.updateUser(ArtisanModel(artisan: _currentUser), sync: true);
    _businessNameController.dispose();
    _aboutController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthService>(
      builder: (_, service, __) {
        return StreamBuilder<BaseUser>(
            stream: service.currentUser(),
            builder: (context, snapshot) {
              final user = snapshot.data?.user;

              return Scaffold(
                key: _scaffoldKey,
                extendBody: true,
                body: Consumer<PrefsProvider>(
                  builder: (_, provider, __) => SafeArea(
                    child: Stack(
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
                          top: kSpacingNone,
                          width: _kWidth,
                          child: _buildAppBar(provider),
                        ),
                        Positioned(
                          width: _kWidth,
                          top: getProportionateScreenHeight(kSpacingX64),
                          bottom: kSpacingNone,
                          child: Column(
                            children: [
                              Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal:
                                      getProportionateScreenWidth(kSpacingX24),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Row(
                                      children: [
                                        _avatar == null
                                            ? UserAvatar(
                                                onTap: () => showDialog(
                                                  context: context,
                                                  builder: (ctx) =>
                                                      _showPickerDialog(ctx),
                                                ),
                                                url: user?.avatar,
                                                radius: kSpacingX72,
                                                isCircular: true,
                                                ringColor:
                                                    user?.isAvailable ?? false
                                                        ? kGreenColor
                                                        : _themeData
                                                            .colorScheme.error,
                                              )
                                            : InkWell(
                                                onTap: () => showDialog(
                                                  context: context,
                                                  builder: (ctx) =>
                                                      _showPickerDialog(ctx),
                                                ),
                                                child: Container(
                                                  height:
                                                      getProportionateScreenHeight(
                                                          kSpacingX72),
                                                  width:
                                                      getProportionateScreenHeight(
                                                          kSpacingX72),
                                                  child: Stack(
                                                    children: [
                                                      Container(
                                                        clipBehavior:
                                                            Clip.hardEdge,
                                                        decoration:
                                                            BoxDecoration(
                                                          shape:
                                                              BoxShape.circle,
                                                        ),
                                                        child: Image.file(
                                                          _avatar,
                                                          fit: BoxFit.cover,
                                                          height:
                                                              getProportionateScreenHeight(
                                                                  kSpacingX72),
                                                          width:
                                                              getProportionateScreenHeight(
                                                                  kSpacingX72),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                        SizedBox(
                                          width: getProportionateScreenWidth(
                                              kSpacingX12),
                                        ),
                                        Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            GestureDetector(
                                              onTap: () =>
                                                  _showEditUsernameDialog(user),
                                              child: ConstrainedBox(
                                                constraints:
                                                    BoxConstraints.tightFor(
                                                  width: _kWidth * 0.4,
                                                ),
                                                child: Text(
                                                  user?.name ?? "No name set",
                                                  maxLines: 2,
                                                  overflow: TextOverflow.fade,
                                                  style: _themeData
                                                      .textTheme.headline6,
                                                ),
                                              ),
                                            ),
                                            SizedBox(
                                              height:
                                                  getProportionateScreenHeight(
                                                      kSpacingX8),
                                            ),
                                            user?.business == null
                                                ? SizedBox.shrink()
                                                : Text(
                                                    user?.business ??
                                                        "None available",
                                                    style: _themeData
                                                        .textTheme.bodyText2,
                                                  ),
                                            SizedBox(
                                                height:
                                                    getProportionateScreenHeight(
                                                        kSpacingX4)),
                                            RatingBarIndicator(
                                              rating: user?.rating ?? 2.00,
                                              direction: Axis.horizontal,
                                              itemCount: 5,
                                              itemSize: kSpacingX12,
                                              itemPadding: EdgeInsets.symmetric(
                                                  horizontal: 4.0),
                                              itemBuilder: (context, _) => Icon(
                                                  kRatingStar,
                                                  color: kAmberColor),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    ButtonPrimary(
                                      width: _kWidth * 0.25,
                                      themeData: _themeData,
                                      color: _themeData.colorScheme.error,
                                      enabled: user != null,
                                      textColor: _themeData.colorScheme.onError,
                                      onTap: () => showDialog(
                                        context: context,
                                        builder: (ctx) => AlertDialog(
                                          title: Text("Leaving already?"),
                                          content: Text(
                                            kSignOutText,
                                          ),
                                          actions: [
                                            ButtonClear(
                                              text: "No",
                                              onPressed: () =>
                                                  ctx.navigator.pop(),
                                              themeData: _themeData,
                                            ),
                                            ButtonClear(
                                              text: "Yes",
                                              onPressed: () async {
                                                ctx.navigator.pop();
                                                await sl
                                                    .get<AuthService>()
                                                    .signOut();
                                                context.navigator
                                                    .pushAndRemoveUntil(
                                                  Routes.loginPage,
                                                  (route) => route is LoginPage,
                                                );
                                              },
                                              themeData: _themeData,
                                            ),
                                          ],
                                        ),
                                      ),
                                      label: "Sign out",
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                height:
                                    getProportionateScreenHeight(kSpacingX24),
                              ),
                              _buildTabBar(),
                              SizedBox(
                                height:
                                    getProportionateScreenHeight(kSpacingX16),
                              ),
                              Expanded(
                                child: _activeTabIndex == 0
                                    ? _buildCalendarSection(user)
                                    : _activeTabIndex == 1
                                        ? _buildProfileSection(user)
                                        : _buildHistorySection(user),
                              ),
                            ],
                          ),
                        ),
                        Positioned(
                          width: _kWidth,
                          bottom: kSpacingNone,
                          child: _buildBottomBar(user),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            });
      },
    );
  }

  Widget _buildAppBar(PrefsProvider provider) => Container(
        padding: EdgeInsets.symmetric(
          vertical: getProportionateScreenHeight(kSpacingX8),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: _kWidth,
              padding: EdgeInsets.only(
                right: getProportionateScreenWidth(kSpacingX12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    tooltip: "Go back",
                    icon: Icon(Feather.x),
                    onPressed: () => context.navigator.pop(),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        tooltip: "Toggle theme",
                        icon: Icon(
                          provider.isLightTheme ? Feather.moon : Feather.sun,
                        ),
                        onPressed: () => provider.toggleTheme(),
                      ),
                      IconButton(
                        icon: Icon(Feather.help_circle),
                        onPressed: () => showDialog(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: Text("Help"),
                            content: Text(kArtisanReviewHelpDialogContent),
                            actions: [
                              ButtonClear(
                                text: "Dismiss",
                                onPressed: () => ctx.navigator.pop(),
                                themeData: _themeData,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      );

  Widget _buildBottomBar(Artisan user) => _isEditingBusinessName ||
          _isEditingAboutMe ||
          _isEditingPhone
      ? SizedBox.shrink()
      : AnimatedContainer(
          duration: kScaleDuration,
          width: _kWidth,
          height: getProportionateScreenHeight(
              _shouldDismissEarnPointsSheet ? kSpacingX160 : kSpacingX250),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(kSpacingX24),
              topRight: Radius.circular(kSpacingX24),
            ),
            border: Border.all(
              color: _themeData.disabledColor,
              style: BorderStyle.none,
            ),
          ),
          child: Material(
            clipBehavior: Clip.hardEdge,
            type: MaterialType.card,
            elevation: kSpacingX4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(kSpacingX24),
                topRight: Radius.circular(kSpacingX24),
              ),
            ),
            child: Stack(
              fit: StackFit.passthrough,
              children: [
                _shouldDismissEarnPointsSheet
                    ? Container(
                        alignment: Alignment.topRight,
                        height: getProportionateScreenHeight(
                            kSpacingX250 - kSpacingX160),
                        clipBehavior: Clip.hardEdge,
                        decoration: BoxDecoration(
                          color: _themeData.colorScheme.secondary,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(kSpacingX24),
                            topRight: Radius.circular(kSpacingX24),
                          ),
                        ),
                        padding: EdgeInsets.only(
                          left: getProportionateScreenWidth(kSpacingX16),
                          right: getProportionateScreenWidth(kSpacingX16),
                        ),
                        child: AnimatedOpacity(
                          opacity: _shouldDismissEarnPointsSheet ? 1.0 : 0.0,
                          duration: kSheetDuration,
                          child: IconButton(
                            icon: Icon(Feather.chevron_up),
                            onPressed: () {
                              setState(() {
                                _shouldDismissEarnPointsSheet =
                                    !_shouldDismissEarnPointsSheet;
                              });
                            },
                            color: _themeData.colorScheme.onSecondary,
                          ),
                        ),
                      )
                    : Positioned(
                        bottom: kSpacingNone,
                        width: _kWidth,
                        child: Container(
                          alignment: Alignment.center,
                          padding: EdgeInsets.only(
                            left: getProportionateScreenWidth(kSpacingX16),
                            right: getProportionateScreenWidth(kSpacingX16),
                            bottom: kSpacingNone,
                          ),
                          height: getProportionateScreenHeight(kSpacingX360),
                          width: _kWidth,
                          clipBehavior: Clip.hardEdge,
                          decoration: BoxDecoration(
                            color: _themeData.colorScheme.secondary,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(kSpacingX24),
                              topRight: Radius.circular(kSpacingX24),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Earn Skills Badge",
                                    style:
                                        _themeData.textTheme.headline6.copyWith(
                                      color: _themeData.colorScheme.onSecondary,
                                    ),
                                  ),
                                  SizedBox(
                                      height: getProportionateScreenHeight(
                                          kSpacingX8)),
                                  // Allow prospective customers to book your services. Turning this off will make you invisible
                                  ConstrainedBox(
                                    constraints: BoxConstraints.tightFor(
                                      width: _kWidth * 0.6,
                                    ),
                                    child: RichText(
                                      textAlign: TextAlign.left,
                                      text: TextSpan(
                                        text:
                                            "Skills assessment helps you to stand out to customers",
                                        style: _themeData.textTheme.bodyText2
                                            .copyWith(
                                          color: _themeData
                                              .colorScheme.onSecondary,
                                        ),
                                      ),
                                      softWrap: true,
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  ButtonIconOnly(
                                    icon: Icons.arrow_right_alt_outlined,
                                    color: _themeData.colorScheme.onSecondary,
                                    iconColor:
                                        _themeData.colorScheme.onSecondary,
                                    onPressed: () =>
                                        showNotAvailableDialog(context),
                                  ),
                                  IconButton(
                                    icon: Icon(
                                      Feather.chevron_down,
                                    ),
                                    color: _themeData.colorScheme.onSecondary,
                                    onPressed: () {
                                      setState(() {
                                        _shouldDismissEarnPointsSheet =
                                            !_shouldDismissEarnPointsSheet;
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                Positioned(
                  bottom: kSpacingNone,
                  width: _kWidth,
                  child: Container(
                    alignment: Alignment.center,
                    padding: EdgeInsets.symmetric(
                      horizontal: getProportionateScreenWidth(kSpacingX16),
                    ),
                    height: getProportionateScreenHeight(kSpacingX120),
                    width: _kWidth,
                    clipBehavior: Clip.hardEdge,
                    decoration: BoxDecoration(
                        color: _themeData.cardColor,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(kSpacingX24),
                          topRight: Radius.circular(kSpacingX24),
                        )),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Receive Job Alerts",
                              style: _themeData.textTheme.headline6,
                            ),
                            SizedBox(
                                height:
                                    getProportionateScreenHeight(kSpacingX8)),
                            // Allow prospective customers to book your services. Turning this off will make you invisible
                            ConstrainedBox(
                              constraints: BoxConstraints.tightFor(
                                width: _kWidth * 0.7,
                              ),
                              child: RichText(
                                textAlign: TextAlign.left,
                                text: TextSpan(
                                  text:
                                      "Allow prospective customers to book your services. Turning this off will make you invisible",
                                  style: _themeData.textTheme.bodyText2,
                                ),
                                softWrap: true,
                              ),
                            ),
                          ],
                        ),
                        _isLoading
                            ? Loading()
                            : Switch.adaptive(
                                activeColor: _themeData.colorScheme.primary,
                                value: user?.isAvailable ?? false,
                                onChanged: (visibility) async {
                                  setState(() {
                                    _isLoading = !_isLoading;
                                  });
                                  await _dataService.updateUser(ArtisanModel(
                                    artisan:
                                        user.copyWith(isAvailable: visibility),
                                  ));
                                  setState(() {
                                    _isLoading = !_isLoading;
                                  });
                                },
                              ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );

  // Gets user's current location and finds the name of that address
  Stream<geo.Position> _getUserLocation() => geo.Geolocator.getCurrentPosition(
          desiredAccuracy: geo.LocationAccuracy.high)
      .asStream();

  Widget _buildTabBar() => Container(
        margin: EdgeInsets.symmetric(
            horizontal: getProportionateScreenWidth(kSpacingX24)),
        child: BadgeableTabBar(
          tabs: <BadgeableTabBarItem>[
            BadgeableTabBarItem(
              title: "Calendar",
              badgeCount: 0,
            ),
            BadgeableTabBarItem(
              title: "Profile",
              badgeCount: 0,
            ),
            BadgeableTabBarItem(
              title: "History",
              badgeCount: 0,
            ),
          ],
          onTabSelected: (index) {
            _activeTabIndex = index;
            setState(() {});
          },
          color: _themeData.primaryColor,
          activeIndex: _activeTabIndex,
        ),
      );

  Widget _buildHistorySection(Artisan user) => ListView(
        children: [
          // buildFunctionalityNotAvailablePanel(context),
          Container(
            height: kSpacingX320,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  Entypo.bucket,
                  size: getProportionateScreenHeight(kSpacingX96),
                  color: _themeData.colorScheme.onBackground,
                ),
                SizedBox(
                  height: getProportionateScreenHeight(kSpacingX16),
                ),
                Text(
                  "Your recent activities will appear here",
                  style: _themeData.textTheme.bodyText2.copyWith(
                    color: _themeData.colorScheme.onBackground,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(
                  height: getProportionateScreenHeight(kSpacingX24),
                ),
                ButtonOutlined(
                  width: _kWidth * 0.6,
                  themeData: _themeData,
                  gravity: ButtonIconGravity.END,
                  icon: Icons.arrow_right_alt_outlined,
                  onTap: () => showNotAvailableDialog(context),
                  label: "Earn Skills Badge",
                ),
              ],
            ),
          ),
        ],
      );

  Widget _buildCalendarSection(Artisan user) => ListView(
        children: [
          buildCalendarTable(_themeData, context, user, _calendarController),
        ],
      );

  Widget _buildProfileSection(Artisan user) => ListView(
        padding: EdgeInsets.only(
          bottom: getProportionateScreenHeight(
              _shouldDismissEarnPointsSheet ? kSpacingX160 : kSpacingX250),
        ),
        children: [
          buildArtisanMetadataBar(
            context,
            _themeData,
            artisan: user,
          ),
          Container(
            margin: EdgeInsets.only(
              left: getProportionateScreenWidth(kSpacingX24),
              right: getProportionateScreenWidth(kSpacingX24),
              bottom: getProportionateScreenHeight(kSpacingX16),
            ),
            child: buildProfileDescriptor(
              context,
              themeData: _themeData,
              isEditing: _isEditingAboutMe,
              iconData: _isEditingAboutMe ? Feather.check : Feather.edit_2,
              title: "About Me",
              content: user?.aboutMe ??
                  "Brand yourself to your prospective customers",
              onTap: () async {
                _isEditingAboutMe = !_isEditingAboutMe;
                setState(() {});
              },
              inputAction: TextInputAction.done,
              controller: _aboutController,
              hint: "Tell us about yourself...",
              onEditComplete: (content) {
                if (content.isEmpty) return;
                _isEditingAboutMe = !_isEditingAboutMe;
                _aboutController.text = content;
                setState(() {});
                _dataService.updateUser(ArtisanModel(
                    artisan: user.copyWith(aboutMe: _aboutController.text)));
              },
            ),
          ),
          Container(
            margin: EdgeInsets.only(
              left: getProportionateScreenWidth(kSpacingX24),
              right: getProportionateScreenWidth(kSpacingX24),
              bottom: getProportionateScreenHeight(kSpacingX16),
            ),
            child: buildProfileDescriptor(
              context,
              themeData: _themeData,
              title: "Phone Number",
              content: user?.phone ?? "Create one...",
              isEditing: _isEditingPhone,
              iconData: _isEditingPhone ? Feather.check : Feather.edit_2,
              onTap: () {
                _isEditingPhone = !_isEditingPhone;
                setState(() {});
              },
              inputAction: TextInputAction.done,
              controller: _phoneController,
              hint: "Create one...",
              onEditComplete: (content) {
                if (content.isEmpty) return;
                _isEditingPhone = !_isEditingPhone;
                _phoneController.text = content;
                setState(() {});
                _dataService.updateUser(ArtisanModel(
                    artisan: user.copyWith(phone: _phoneController.text)));
              },
            ),
          ),
          Container(
            margin: EdgeInsets.only(
              left: getProportionateScreenWidth(kSpacingX24),
              right: getProportionateScreenWidth(kSpacingX24),
              bottom: getProportionateScreenHeight(kSpacingX16),
            ),
            child: buildProfileDescriptor(
              context,
              themeData: _themeData,
              title: "Business Name",
              content: user?.business ?? "Create one...",
              isEditing: _isEditingBusinessName,
              iconData: _isEditingBusinessName ? Feather.check : Feather.edit_2,
              onTap: () {
                _isEditingBusinessName = !_isEditingBusinessName;
                setState(() {});
              },
              inputAction: TextInputAction.done,
              controller: _businessNameController,
              hint: "What\'s your business name?",
              onEditComplete: (content) {
                if (content.isEmpty) return;
                _isEditingBusinessName = !_isEditingBusinessName;
                _businessNameController.text = content;
                setState(() {});
                _dataService.updateUser(ArtisanModel(
                    artisan:
                        user.copyWith(business: _businessNameController.text)));
              },
            ),
          ),
          _buildPriceRange(user),
          StreamBuilder<geo.Position>(
            stream: _getUserLocation(),
            builder: (_, locationSnapshot) {
              return AnimatedContainer(
                duration: kSheetDuration,
                padding: EdgeInsets.symmetric(
                  vertical: locationSnapshot.hasError ||
                          locationSnapshot.connectionState ==
                              ConnectionState.waiting
                      ? getProportionateScreenHeight(kSpacingX24)
                      : kSpacingNone,
                ),
                child: locationSnapshot.hasError ||
                        locationSnapshot.connectionState ==
                            ConnectionState.waiting
                    ? Loading()
                    : buildMapPreviewForBusinessLocation(
                        position: locationSnapshot.data,
                      ),
              );
            },
          ),
        ],
      );

  Widget _buildPriceRange(Artisan user) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        getProportionateScreenWidth(kSpacingX16),
        getProportionateScreenHeight(kSpacingX8),
        getProportionateScreenWidth(kSpacingX16),
        getProportionateScreenHeight(kSpacingX16),
      ),
      margin: EdgeInsets.only(
        left: getProportionateScreenWidth(kSpacingX24),
        right: getProportionateScreenWidth(kSpacingX24),
        bottom: getProportionateScreenHeight(kSpacingX16),
      ),
      decoration: BoxDecoration(
        color: _themeData.scaffoldBackgroundColor.withOpacity(kEmphasisLow),
        borderRadius: BorderRadius.circular(kSpacingX16),
        border: Border.all(
            color: _themeData.disabledColor.withOpacity(kEmphasisLow)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              children: [
                TextSpan(text: "Service price range"),
                TextSpan(
                    text: " (in GHC)", style: _themeData.textTheme.bodyText1),
              ],
              style: _themeData.textTheme.headline6,
            ),
          ),
          SizedBox(
            height: getProportionateScreenHeight(kSpacingX12),
          ),
          Row(
            children: [
              // ₵
              Text("GHC10"),
              Expanded(
                child: RangeSlider(
                  labels: RangeLabels(
                      user?.startPrice.toString(), user?.endPrice.toString()),
                  divisions: 10,
                  min: 9.99,
                  max: 199.99,
                  values: RangeValues(user?.startPrice?.roundToDouble() ?? 10,
                      user?.endPrice?.roundToDouble() ?? 20),
                  onChanged: (newValue) {
                    print("New value => $newValue");
                    _dataService.updateUser(
                      ArtisanModel(
                        artisan: user.copyWith(
                          startPrice: newValue.start,
                          endPrice: newValue.end,
                        ),
                      ),
                    );
                  },
                ),
              ),
              Text("GHC200"),
            ],
          ),
        ],
      ),
    );
  }

  void _showEditUsernameDialog(Artisan user) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Edit username"),
        content: Form(
          child: TextFormInput(
            labelText: "What's your name?",
            controller: _nameController..text = user?.name,
            validator: (_) => _.isEmpty ? "Enter a username" : null,
            onFieldSubmitted: (_) async {
              var artisan = user.copyWith(name: _nameController.text);
              ctx.navigator.pop();
              await _dataService.updateUser(ArtisanModel(artisan: artisan));
            },
          ),
        ),
        actions: [
          ButtonClear(
            text: "Cancel",
            onPressed: () {
              ctx.navigator.pop();
            },
            themeData: _themeData,
          ),
          ButtonClear(
            text: "Save",
            onPressed: () {
              ctx.navigator.pop();
            },
            themeData: _themeData,
          ),
        ],
      ),
    );
  }
}

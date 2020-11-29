import 'dart:io';
import 'dart:math';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_svg_provider/flutter_svg_provider.dart';
import 'package:handyman/app/model/prefs_provider.dart';
import 'package:handyman/app/pages/login.dart';
import 'package:handyman/app/routes/route.gr.dart';
import 'package:handyman/app/widget/buttons.dart';
import 'package:handyman/app/widget/fields.dart';
import 'package:handyman/app/widget/user_avatar.dart';
import 'package:handyman/core/constants.dart';
import 'package:handyman/core/size_config.dart';
import 'package:handyman/data/entities/customer_model.dart';
import 'package:handyman/data/local_database.dart';
import 'package:handyman/data/services/data.dart';
import 'package:handyman/data/services/storage.dart';
import 'package:handyman/domain/models/user.dart';
import 'package:handyman/domain/services/auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:contact_picker/contact_picker.dart';
import 'package:provider/provider.dart';
import 'package:sliding_sheet/sliding_sheet.dart';

enum EditType { PHONE, NAME }

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final ContactPicker _contactPicker = ContactPicker();
  final _formKey = GlobalKey<FormState>();
  final _fieldController = TextEditingController();
  double _kWidth, _kHeight;
  ThemeData _themeData;
  final _dataService = DataServiceImpl.instance;
  final _storageService = StorageServiceImpl.instance;
  bool _isSaving = false;
  SheetController _sheetController = SheetController();

  File _avatar;
  String _userId;
  final picker = ImagePicker();

  Future<void> _getImage() async {
    final pickedFile = await picker.getImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      debugPrint("Image picked as -> ${pickedFile.path}");
      _avatar = File(pickedFile.path);
      await _storageService.uploadFile(_avatar, path: _userId);
    } else {
      debugPrint('No image selected.');
    }
    setState(() {});
  }

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
    if (mounted) {
      /// FIXME: User data not loaded when page is first viewed
      if (mounted)
        Future.delayed(kScaleDuration).then((value) => setState(() => {}));
      _storageService.onStorageUploadResponse.listen((event) {
        debugPrint(event.state.toString());
      });
    }
  }

  @override
  Widget build(BuildContext context) => Consumer<PrefsProvider>(
        builder: (_, provider, __) {
          _userId = provider.userId;
          return Scaffold(
            extendBody: true,
            body: SafeArea(
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
                    top: getProportionateScreenHeight(kToolbarHeight),
                    child: Consumer<AuthService>(
                      builder: (_, authService, __) => StreamBuilder<BaseUser>(
                          stream: authService.currentUser(),
                          builder: (context, snapshot) {
                            final Customer user = snapshot.data?.user;
                            return AnimatedContainer(
                              duration: kSheetDuration,
                              height: _kHeight,
                              width: _kWidth,
                              child: Stack(
                                children: [
                                  Positioned(
                                    top: getProportionateScreenHeight(
                                        kToolbarHeight * 2),
                                    bottom: kSpacingNone,
                                    width: _kWidth,
                                    child: Container(
                                      decoration: BoxDecoration(
                                          color: _themeData.cardColor,
                                          borderRadius: BorderRadius.only(
                                            topLeft:
                                                Radius.circular(kSpacingX16),
                                            topRight:
                                                Radius.circular(kSpacingX16),
                                          )),
                                      padding: EdgeInsets.only(
                                          left: getProportionateScreenWidth(
                                              kSpacingX16),
                                          right: getProportionateScreenWidth(
                                              kSpacingX16),
                                          top: getProportionateScreenHeight(
                                              kSpacingX96),
                                          bottom: getProportionateScreenHeight(
                                              kSpacingX36)),
                                      child: Column(
                                        children: [
                                          ListTile(
                                            title: Text("Email"),
                                            subtitle: Text(user?.email ?? "Syncing..."),
                                            leading: Icon(Feather.mail),
                                            enabled: false,
                                          ),
                                          ListTile(
                                            title: Text("Username"),
                                            subtitle: Text(user?.name ?? "Syncing..."),
                                            leading: Icon(Feather.user),
                                            trailing: IconButton(
                                              icon: Icon(
                                                Feather.edit_2,
                                                size: kSpacingX16,
                                              ),
                                              onPressed: () =>
                                                  _editProfileInfo(user),
                                            ),
                                          ),
                                          ListTile(
                                            title: Text("Phone"),
                                            subtitle: Text(user?.phone ??
                                                "Add your phone number"),
                                            leading: Icon(Feather.phone),
                                            trailing: IconButton(
                                              icon: Icon(
                                                Feather.edit_2,
                                                size: kSpacingX16,
                                              ),
                                              onPressed: () => _editProfileInfo(
                                                user,
                                                "Phone number",
                                                EditType.PHONE,
                                              ),
                                            ),
                                          ),
                                          Divider(),
                                          ListTile(
                                            onTap: () => null,
                                            title: Text("Emergency Contact"),
                                            subtitle: Text(provider
                                                    .emergencyContactNumber ??
                                                "Select an emergency contact"),
                                            leading: Icon(Feather.users),
                                            trailing: IconButton(
                                              icon: Icon(
                                                Feather.user_plus,
                                                size: kSpacingX16,
                                              ),
                                              onPressed: () async {
                                                Contact contact = await _contactPicker.selectContact();
                                                provider.updateEmergencyContact(contact.phoneNumber.number);
                                                setState(() {});
                                              },
                                            ),
                                          ),
                                          Divider(),
                                          SizedBox(
                                            height:
                                                getProportionateScreenHeight(
                                                    kSpacingX8),
                                          ),
                                          _buildLogoutButton(authService),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    top: getProportionateScreenHeight(
                                        kToolbarHeight),
                                    width: _kWidth,
                                    child: Container(
                                      alignment: Alignment.center,
                                      child: _buildProfileImage(user),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                    ),
                  ),
                  Positioned(
                    top: kSpacingNone,
                    child: _buildAppbar(provider),
                  ),
                ],
              ),
            ),
          );
        },
      );

  Widget _buildAppbar(PrefsProvider provider) => Container(
        width: _kWidth,
        height: getProportionateScreenHeight(kToolbarHeight),
        decoration: BoxDecoration(
          color: _themeData.scaffoldBackgroundColor.withOpacity(kOpacityX14),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
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
                  icon: Icon(Entypo.info),
                  onPressed: () => showAboutDialog(
                    context: context,
                    applicationVersion: kAppVersion,
                    applicationName: kAppName,
                    applicationLegalese: kAppSloganDesc,
                    applicationIcon: Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: getProportionateScreenHeight(kSpacingX16),
                      ),
                      child: Image(
                        image: Svg(kLogoAsset),
                        height: getProportionateScreenHeight(kSpacingX48),
                        width: getProportionateScreenHeight(kSpacingX48),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );

  Future<void> _editProfileInfo(
    Customer user, [
    String label = "Full Name",
    EditType editType = EditType.NAME,
  ]) async =>
      await showSlidingBottomSheet(context,
          builder: (context) => SlidingSheetDialog(
                elevation: kSpacingX8,
                controller: _sheetController,
                dismissOnBackdropTap: false,
                addTopViewPaddingOnFullscreen: true,
                headerBuilder: (ctx, __) => Material(
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
                          "Update profile information",
                          style: _themeData.textTheme.headline6,
                        ),
                        IconButton(
                          icon: Icon(
                            Feather.chevron_down,
                          ),
                          color: _themeData.colorScheme.onBackground,
                          onPressed: () => ctx.navigator.pop(),
                        ),
                      ],
                    ),
                  ),
                ),
                footerBuilder: (ctx, __) => Material(
                  type: MaterialType.card,
                  clipBehavior: Clip.hardEdge,
                  child: InkWell(
                    onTap: () {
                      _saveUserInfo(user, editType);
                      ctx.navigator.pop();
                    },
                    child: Container(
                      alignment: Alignment.center,
                      height: getProportionateScreenHeight(kToolbarHeight),
                      width: _kWidth,
                      decoration: BoxDecoration(
                        color: _themeData.colorScheme.secondary,
                      ),
                      child: _isSaving
                          ? CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation(
                                  _themeData.colorScheme.onSecondary),
                            )
                          : Text(
                              "Save & continue".toUpperCase(),
                              style: _themeData.textTheme.button.copyWith(
                                color: _themeData.colorScheme.onSecondary,
                              ),
                            ),
                    ),
                  ),
                ),
                color:
                    _themeData.scaffoldBackgroundColor.withOpacity(kOpacityX50),
                duration: kScaleDuration,
                cornerRadius: kSpacingX16,
                snapSpec: const SnapSpec(
                  snap: true,
                  snappings: [0.4, 0.75, 1.0],
                  positioning: SnapPositioning.relativeToAvailableSpace,
                ),
                padding: EdgeInsets.symmetric(
                  vertical: getProportionateScreenHeight(kSpacingX8),
                ),
                builder: (context, state) {
                  return Material(
                    type: MaterialType.card,
                    clipBehavior: Clip.hardEdge,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: getProportionateScreenWidth(kSpacingX24),
                        vertical: getProportionateScreenHeight(kSpacingX36),
                      ),
                      decoration: BoxDecoration(),
                      child: Column(
                        children: [
                          Form(
                            key: _formKey,
                            child: TextFormInput(
                              labelText: label,
                              keyboardType: editType == EditType.PHONE
                                  ? TextInputType.phone
                                  : TextInputType.text,
                              controller: _fieldController
                                ..text = editType == EditType.PHONE
                                    ? user.phone
                                    : user.name,
                              onFieldSubmitted: (username) {
                                _saveUserInfo(user, editType);
                                context.navigator.pop();
                              },
                              validator: (input) => input.isNotEmpty
                                  ? null
                                  : "Enter your full name",
                              color: _themeData.colorScheme.onBackground,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ));

  // Build user image
  Widget _buildProfileImage(user) => _avatar == null
      ? UserAvatar(
          url: user?.avatar ?? "",
          radius: kSpacingX140,
          isCircular: true,
          ringColor:
              _themeData.colorScheme.onBackground.withOpacity(kEmphasisLow),
          onTap: () => showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              title: Text("Select an option"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    title: Text("View"),
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(Feather.eye),
                    onTap: () {
                      ctx.navigator.pop();
                      showNotAvailableDialog(ctx);
                    },
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
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
                  themeData: _themeData,
                )
              ],
            ),
          ),
        )
      : InkWell(
          onTap: () async => await _getImage(),
          child: Container(
            clipBehavior: Clip.hardEdge,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
            ),
            child: Image.file(
              _avatar,
              fit: BoxFit.cover,
              height: getProportionateScreenHeight(kSpacingX120),
              width: getProportionateScreenHeight(kSpacingX120),
            ),
          ),
        );

  void _saveUserInfo(Customer user, EditType type) async {
    if (_formKey.currentState.validate()) {
      /// Fix for setState in a non-stateful widget child
      /// https://stackoverflow.com/questions/52414629/how-to-update-state-of-a-modalbottomsheet-in-flutter
      _sheetController.rebuild();
      setState(() {
        _isSaving = true;
      });
      switch (type) {
        case EditType.NAME:
          user = user.copyWith(
            name: _fieldController.text.trim(),
          );
          break;
        case EditType.PHONE:
          user = user.copyWith(
            phone: _fieldController.text.trim(),
          );
          break;
      }
      await _dataService.updateUser(CustomerModel(customer: user));
      setState(() {
        _isSaving = false;
      });
    }
  }

  // Sign out button
  Widget _buildLogoutButton(AuthService authService) => InkWell(
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
                onPressed: () => ctx.navigator.pop(),
                themeData: _themeData,
              ),
              Consumer<AuthService>(
                builder: (_, authService, __) => ButtonClear(
                  text: "Yes",
                  onPressed: () {
                    ctx.navigator.pop();
                    authService.signOut();
                    context.navigator.pushAndRemoveUntil(
                      Routes.loginPage,
                      (route) => route is LoginPage,
                    );
                  },
                  themeData: _themeData,
                ),
              ),
            ],
          ),
        ),
        splashColor: _themeData.splashColor,
        child: Container(
          alignment: Alignment.center,
          height: getProportionateScreenHeight(kToolbarHeight),
          width: _kWidth * 0.5,
          decoration: BoxDecoration(
            color: _themeData.colorScheme.error,
            borderRadius: BorderRadius.circular(kSpacingX36),
          ),
          child: _isSaving
              ? CircularProgressIndicator(
                  valueColor:
                      AlwaysStoppedAnimation(_themeData.colorScheme.onError),
                )
              : Text(
                  "Sign out".toUpperCase(),
                  style: _themeData.textTheme.button.copyWith(
                    color: _themeData.colorScheme.onError,
                  ),
                ),
        ),
      );
}



import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:handyman/app/model/prefs_provider.dart';
import 'package:handyman/app/routes/route.gr.dart';
import 'package:handyman/app/widget/buttons.dart';
import 'package:handyman/app/widget/fields.dart';
import 'package:handyman/core/constants.dart';
import 'package:handyman/core/size_config.dart';
import 'package:handyman/data/entities/artisan_model.dart';
import 'package:handyman/data/services/storage.dart';
import 'package:handyman/domain/models/user.dart';
import 'package:handyman/domain/services/auth.dart';
import 'package:handyman/domain/services/data.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

/// Account completion page for new artisans
/// 1. Provide full details
/// 2. Upload business document
/// 3. Select business category and provide additional business details
/// 4. Add phone number
class AccountCompletionPage extends StatefulWidget {
  @override
  _AccountCompletionPageState createState() => _AccountCompletionPageState();
}

class _AccountCompletionPageState extends State<AccountCompletionPage> {
  final _storageService = StorageServiceImpl.instance;

  // region Form
  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _businessNameController = TextEditingController(),
      _phoneController = TextEditingController();
  bool _isLoading = false;

  // endregion

  // region Image Picker
  File _avatar;
  File _businessDoc;
  final _currentTimestamp = DateTime.now().millisecondsSinceEpoch;
  String _userId;
  final picker = ImagePicker();

  // endregion

  ThemeData _themeData;

  Future<void> _getImage() async {
    final pickedFile = await picker.getImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      debugPrint("Image picked as -> ${pickedFile.path}");
      _avatar = File(pickedFile.path);
    } else {
      debugPrint('No image selected.');
    }
    setState(() {});
    await _storageService.uploadFile(_avatar, path: _userId);
  }

  // Pick business document from device storage
  Future<void> _pickBusinessDocument() async {
    try {
      FilePickerResult result = await FilePicker.platform.pickFiles(
        allowedExtensions: ["pdf"],
        type: FileType.custom,
      );
      if (result != null) {
        PlatformFile file = result.files.single;
        _businessDoc = File(file.path);
        setState(() {});
        await _storageService.uploadFile(_businessDoc,
            isImageFile: false,
            path: "$_userId$_currentTimestamp",
            extension: file.extension);
      } else {
        // User canceled the picker
        debugPrint("User canceled file picking action");
      }
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context)
        ..removeCurrentSnackBar()
        ..showSnackBar(SnackBar(
          content: Text("Unable to pick document at this time"),
          behavior: SnackBarBehavior.floating,
        ));
    }
  }

  @override
  void initState() {
    super.initState();
    _storageService.onStorageUploadResponse.listen((event) {
      debugPrint(event.state.toString());
    });
  }

  @override
  void dispose() {
    _storageService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _themeData = Theme.of(context);
    final size = MediaQuery.of(context).size;
    final kWidth = size.width;
    final kHeight = size.height;

    return Consumer<AuthService>(
      builder: (_, authService, __) => StreamBuilder<BaseUser>(
        stream: authService.currentUser(),
        builder: (context, userSnapshot) => Consumer<PrefsProvider>(
          builder: (_, prefs, __) {
            _userId = prefs.userId;
            return Scaffold(
              key: _scaffoldKey,
              extendBodyBehindAppBar: true,
              extendBody: true,
              body: Container(
                height: kHeight,
                width: kWidth,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    prefs.isLightTheme
                        ? Container(
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: AssetImage(kBackgroundAsset),
                                fit: BoxFit.cover,
                              ),
                            ),
                          )
                        : SizedBox.shrink(),
                    Positioned.fill(
                      child: SafeArea(
                        child: SingleChildScrollView(
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal:
                                  getProportionateScreenWidth(kSpacingX12),
                              vertical:
                                  getProportionateScreenHeight(kSpacingX24),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        "Almost there...",
                                        style: _themeData.textTheme.headline4,
                                      ),
                                      SizedBox(
                                          height: getProportionateScreenHeight(
                                              kSpacingX8)),
                                      Text(
                                        kAccountCompletionHelperText,
                                        style: _themeData.textTheme.caption,
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(
                                    height: getProportionateScreenHeight(
                                        kSpacingX24)),
                                _avatar == null
                                    ? _buildImagePickerWidget()
                                    : _buildAvatarWidget(),
                                SizedBox(
                                    height: getProportionateScreenHeight(
                                        kSpacingX24)),
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: getProportionateScreenWidth(
                                          kSpacingX24)),
                                  child: Form(
                                    key: _formKey,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        TextFormInput(
                                          labelText: "Business name",
                                          enabled: true,
                                          controller: _businessNameController,
                                          validator: (value) => value == null ||
                                                  value.isEmpty ||
                                                  value.length < 6
                                              ? "Provide your business name"
                                              : null,
                                          color: _themeData
                                              .textTheme.bodyText1.color,
                                        ),
                                        TextFormInput(
                                          labelText: "Phone number",
                                          enabled: !_isLoading,
                                          keyboardType: TextInputType.phone,
                                          textInputAction: TextInputAction.done,
                                          validator: (value) => null,
                                          color: _themeData
                                              .textTheme.bodyText1.color,
                                          controller: _phoneController
                                            ..text =
                                                userSnapshot.data?.user?.phone,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(
                                    height: getProportionateScreenHeight(
                                        kSpacingX24)),
                                GestureDetector(
                                  onTap: () async =>
                                      await _pickBusinessDocument(),
                                  child: AnimatedContainer(
                                      duration: kSheetDuration,
                                      alignment: Alignment.center,
                                      clipBehavior: Clip.hardEdge,
                                      width: kWidth,
                                      height: getProportionateScreenHeight(
                                          kSpacingX120),
                                      decoration: BoxDecoration(
                                        color: _themeData.disabledColor
                                            .withOpacity(kEmphasisLow),
                                        borderRadius:
                                            BorderRadius.circular(kSpacingX8),
                                      ),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          _businessDoc == null
                                              ? Icon(
                                                  Feather.file,
                                                  size: kSpacingX48,
                                                  color: _themeData
                                                      .colorScheme.primary,
                                                )
                                              : Icon(
                                                  Feather.check_circle,
                                                  size: kSpacingX48,
                                                  color: _themeData
                                                      .colorScheme.primary,
                                                ),
                                          SizedBox(
                                            height:
                                                getProportionateScreenHeight(
                                                    kSpacingX16),
                                          ),
                                          Text(
                                            _businessDoc == null
                                                ? "Add business document"
                                                : "Document added",
                                          ),
                                        ],
                                      )),
                                ),
                                SizedBox(
                                    height: getProportionateScreenHeight(
                                        kSpacingX24)),
                                Consumer<DataService>(
                                  builder: (_, dataService, __) =>
                                      ButtonOutlined(
                                    width: getProportionateScreenWidth(
                                        kSpacingX200),
                                    themeData: _themeData,
                                    onTap: () {
                                      _formKey.currentState.save();
                                      if (_formKey.currentState.validate()) {
                                        debugPrint(
                                            "Validated form successfully");
                                        dataService.updateUser(
                                          ArtisanModel(
                                            artisan:
                                                userSnapshot.data.user.copyWith(
                                              business: _businessNameController
                                                  .text
                                                  .toString(),
                                              phone: _phoneController.text
                                                  .toString(),
                                            ),
                                          ),
                                        );
                                        context.navigator.popAndPush(
                                          userSnapshot.data?.isCustomer ?? false
                                              ? Routes.homePage
                                              : Routes.dashboardPage,
                                        );
                                      }
                                    },
                                    enabled: _businessDoc != null &&
                                        _avatar != null &&
                                        _businessNameController.text.isNotEmpty,
                                    label: "Save",
                                  ),
                                ),
                                // SizedBox(height: getProportionateScreenHeight(kSpacingX24)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    prefs.userType == kArtisanString
                        ? SizedBox.shrink()
                        : Positioned(
                            top: getProportionateScreenHeight(kSpacingX56),
                            right: kSpacingNone,
                            child: InkWell(
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(
                                    getProportionateScreenWidth(kSpacingX24)),
                                bottomLeft: Radius.circular(
                                    getProportionateScreenWidth(kSpacingX24)),
                              ),
                              onTap: () => context.navigator.popAndPush(
                                prefs.userType == kCustomerString
                                    ? Routes.homePage
                                    : Routes.dashboardPage,
                              ),
                              child: Container(
                                height: kToolbarHeight,
                                width: kWidth * 0.3,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: _themeData.colorScheme.primary,
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(
                                        getProportionateScreenWidth(
                                            kSpacingX24)),
                                    bottomLeft: Radius.circular(
                                        getProportionateScreenWidth(
                                            kSpacingX24)),
                                  ),
                                ),
                                child: Text(
                                  "Skip".toUpperCase(),
                                  style: _themeData.textTheme.button.copyWith(
                                    color: _themeData.colorScheme.onPrimary,
                                  ),
                                ),
                              ),
                            ),
                          ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildImagePickerWidget() => GestureDetector(
        onTap: () async => await _getImage(),
        child: Container(
          clipBehavior: Clip.hardEdge,
          alignment: Alignment.center,
          height: getProportionateScreenHeight(kSpacingX200),
          width: getProportionateScreenWidth(kSpacingX200),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _themeData.disabledColor.withOpacity(kEmphasisLow),
            border: Border.all(
              color:
                  _themeData.colorScheme.onBackground.withOpacity(kOpacityX70),
              width: kSpacingX2,
            ),
          ),
          child: Icon(
            Feather.image,
            size: kSpacingX64,
            color: _themeData.colorScheme.onBackground.withOpacity(kOpacityX70),
          ),
        ),
      );

  Widget _buildAvatarWidget() => Container(
        child: Stack(
          children: [
            Container(
              clipBehavior: Clip.hardEdge,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
              ),
              child: Image.file(
                _avatar,
                fit: BoxFit.cover,
                height: getProportionateScreenHeight(kSpacingX200),
                width: getProportionateScreenWidth(kSpacingX200),
              ),
            ),
            Positioned(
              bottom: getProportionateScreenHeight(kSpacingX16),
              right: getProportionateScreenWidth(kSpacingNone),
              child: InkWell(
                borderRadius: BorderRadius.all(Radius.circular(kSpacingX56)),
                onTap: () async => await _getImage(),
                child: Container(
                  alignment: Alignment.center,
                  height: getProportionateScreenHeight(kSpacingX56),
                  width: getProportionateScreenWidth(kSpacingX56),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _themeData.colorScheme.primary,
                  ),
                  child: Icon(
                    Feather.image,
                    size: kSpacingX24,
                    color: _themeData.colorScheme.onPrimary,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
}

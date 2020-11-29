import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:handyman/app/model/prefs_provider.dart';
import 'package:handyman/app/routes/route.gr.dart';
import 'package:handyman/app/widget/artisan_hours.dart';
import 'package:handyman/app/widget/buttons.dart';
import 'package:handyman/app/widget/fields.dart';
import 'package:handyman/app/widget/user_avatar.dart';
import 'package:handyman/core/constants.dart';
import 'package:handyman/core/service_locator.dart';
import 'package:handyman/core/size_config.dart';
import 'package:handyman/data/local_database.dart';
import 'package:handyman/domain/models/user.dart';
import 'package:handyman/domain/services/auth.dart';
import 'package:handyman/domain/services/data.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class RequestBookingPage extends StatefulWidget {
  final Artisan artisan;

  const RequestBookingPage({Key key, this.artisan}) : super(key: key);

  @override
  _RequestBookingPageState createState() => _RequestBookingPageState();
}

class _RequestBookingPageState extends State<RequestBookingPage> {
  DataService _dataService;
  double _kWidth, _kHeight;
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController(),
      _mailController = TextEditingController(),
      _descriptionController = TextEditingController(),
      _phoneController = TextEditingController();
  ThemeData _themeData;
  int _currentHour = 0;
  File _imageFile;
  ServiceCategory _category;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _themeData = Theme.of(context);
    final size = MediaQuery.of(context).size;
    _kWidth = size.width;
    _kHeight = size.height;
  }

  @override
  Widget build(BuildContext context) => Consumer<DataService>(
        builder: (_, service, __) {
          _dataService = service;
          return Consumer<PrefsProvider>(
            builder: (_, provider, __) => Consumer<AuthService>(
              builder: (_, authService, __) => Scaffold(
                key: _scaffoldKey,
                body: SafeArea(
                  child: Container(
                    height: _kHeight,
                    width: _kWidth,
                    child: StreamBuilder<BaseUser>(
                        stream: authService.currentUser(),
                        builder: (context, snapshot) {
                          return Stack(
                            fit: StackFit.expand,
                            children: [
                              Positioned(
                                left: getProportionateScreenWidth(kSpacingNone),
                                right: getProportionateScreenWidth(kSpacingNone),
                                bottom: kSpacingNone,
                                top: getProportionateScreenHeight(
                                    kToolbarHeight),
                                child: ListView(
                                  padding: EdgeInsets.only(
                                    left: getProportionateScreenWidth(kSpacingX24),
                                    right: getProportionateScreenWidth(kSpacingX24),
                                    bottom: getProportionateScreenHeight(
                                        kSpacingX24),
                                  ),
                                  children: [
                                    _buildArtisanInfoSection(),
                                    _buildRequestSection(snapshot.data?.user),
                                    _buildDatePickerSection(
                                        snapshot.data?.user),
                                  ],
                                ),
                              ),
                              Positioned(
                                top: 0,
                                width: _kWidth,
                                child: Container(
                                  width: _kWidth,
                                  height: getProportionateScreenHeight(
                                      kToolbarHeight),
                                  color: _themeData.scaffoldBackgroundColor
                                      .withOpacity(kOpacityX90),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      IconButton(
                                        icon: Icon(Feather.x),
                                        onPressed: () =>
                                            context.navigator.pop(),
                                      ),
                                      IconButton(
                                        tooltip: "Toggle theme",
                                        icon: Icon(provider.isLightTheme
                                            ? Feather.moon
                                            : Feather.sun),
                                        onPressed: () =>
                                            provider.toggleTheme(),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          );
                        }),
                  ),
                ),
              ),
            ),
          );
        },
      );

  Widget _buildDatePickerSection(Customer user) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: getProportionateScreenHeight(kSpacingX24)),
          Text(
            "Available working hours",
            style: _themeData.textTheme.button.copyWith(
              color: _themeData.colorScheme.onBackground,
            ),
          ),
          SizedBox(height: getProportionateScreenHeight(kSpacingX16)),
          ArtisanHoursPicker(
            artisan: widget.artisan,
            currentSelection: _currentHour,
            onSelectionChanged: (newSelection) {
              setState(() {
                _currentHour = newSelection;
              });
            },
          ),
          SizedBox(height: getProportionateScreenHeight(kSpacingX24)),
          GestureDetector(
            onTap: () async {
              var picker = ImagePicker();
              var pickedFile = await picker.getImage(
                source: kReleaseMode ? ImageSource.camera : ImageSource.gallery,
              );
              _imageFile = File(pickedFile.path);
              setState(() {});
            },
            child: Container(
              alignment: Alignment.center,
              clipBehavior: Clip.hardEdge,
              width: _kWidth,
              height: getProportionateScreenHeight(kSpacingX230),
              decoration: BoxDecoration(
                color: _themeData.disabledColor.withOpacity(kEmphasisLow),
                borderRadius: BorderRadius.circular(kSpacingX8),
              ),
              child: _imageFile == null
                  ? Icon(
                      Entypo.image,
                      size: kSpacingX48,
                      color: _themeData.colorScheme.primary,
                    )
                  : Image.file(
                      _imageFile,
                      width: _kWidth,
                      fit: BoxFit.cover,
                      height: getProportionateScreenHeight(kSpacingX230),
                    ),
            ),
          ),
          SizedBox(height: getProportionateScreenHeight(kSpacingX24)),
          Container(
            alignment: Alignment.center,
            child: ButtonOutlined(
              width: _kWidth * 0.7,
              themeData: _themeData,
              enabled: widget.artisan.isAvailable,
              onTap: () {
                context.navigator.pop();
                _dataService.requestBooking(
                  artisan: widget.artisan,
                  customer: user?.id,
                  hourOfDay: _currentHour,
                  category: _category?.id,
                  description: _descriptionController.text?.trim(),
                  image: _imageFile,
                );
              },
              label: widget.artisan.isAvailable
                  ? "Book service"
                  : "Artisan is unavailable",
            ),
          ),
        ],
      );

  Widget _buildRequestSection(Customer user) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: getProportionateScreenHeight(kSpacingX36)),
          Text(
            "Personal details",
            style: _themeData.textTheme.button.copyWith(
              color: _themeData.colorScheme.onBackground,
            ),
          ),
          SizedBox(height: getProportionateScreenHeight(kSpacingX16)),
          Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormInput(
                  labelText: "Your email",
                  enabled: false,
                  color: _themeData.colorScheme.onBackground,
                  controller: _mailController..text = user?.email,
                ),
                TextFormInput(
                  labelText: "Your name",
                  controller: _nameController..text = user?.name,
                  color: _themeData.colorScheme.onBackground,
                  textInputAction: TextInputAction.next,
                ),
                TextFormInput(
                  labelText: "Phone number (optional)",
                  color: _themeData.colorScheme.onBackground,
                  controller: _phoneController..text = user?.phone,
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.done,
                ),
              ],
            ),
          ),
        ],
      );

  Widget _buildArtisanInfoSection() => StreamBuilder<ServiceCategory>(
        stream: _dataService.getCategoryById(id: widget.artisan.category),
        builder: (context, snapshot) {
          _category = snapshot.data;
          return _category == null
              ? SizedBox.shrink()
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Request a service...",
                      style: _themeData.textTheme.headline5,
                    ),
                    SizedBox(
                      height: getProportionateScreenHeight(kSpacingX36),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            IconButton(
                              icon: Icon(Feather.phone),
                              onPressed: () => widget.artisan.phone == null ||
                                      widget.artisan.phone.isEmpty
                                  ? showNotAvailableDialog(context)
                                  : launchUrl(
                                      url: "tel:${widget.artisan.phone}"),
                            ),
                            UserAvatar(
                              url: widget.artisan.avatar,
                              ringColor: _themeData.iconTheme.color,
                              radius: kSpacingX120,
                            ),
                            IconButton(
                              icon: Icon(Feather.at_sign),
                              onPressed: () => widget.artisan.email == null ||
                                      widget.artisan.email.isEmpty
                                  ? showNotAvailableDialog(context)
                                  : launchUrl(
                                      url:
                                          "mailto:${widget.artisan.email}?subject=Request%20your%20service"),
                            ),
                          ],
                        ),
                        SizedBox(
                            height: getProportionateScreenHeight(kSpacingX12)),
                        Text(
                          widget.artisan.name,
                          style: _themeData.textTheme.headline6,
                        ),
                        SizedBox(
                          height: getProportionateScreenHeight(kSpacingX4),
                        ),
                        Text(
                          widget.artisan.business,
                          style: _themeData.textTheme.caption,
                        ),
                        SizedBox(
                          height: getProportionateScreenHeight(kSpacingX8),
                        ),
                        Container(
                          alignment: Alignment.center,
                          width: _kWidth * 0.45,
                          decoration: BoxDecoration(
                            color: _themeData.scaffoldBackgroundColor.withOpacity(kEmphasisMedium),
                            borderRadius: BorderRadius.circular(kSpacingX8),
                          ),
                          padding: EdgeInsets.symmetric(
                            vertical: getProportionateScreenHeight(kSpacingX8),
                            horizontal:
                                getProportionateScreenWidth(kSpacingX24),
                          ),
                          child: Text(
                            _category?.name ?? "",
                            style: _themeData.textTheme.button.copyWith(
                              color: _themeData.colorScheme.onBackground,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                );
        },
      );
}

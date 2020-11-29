import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:handyman/app/model/prefs_provider.dart';
import 'package:handyman/app/routes/route.gr.dart';
import 'package:handyman/app/widget/artisan_profile_info.dart';
import 'package:handyman/app/widget/buttons.dart';
import 'package:handyman/app/widget/chat_input_entry.dart';
import 'package:handyman/app/widget/review_card.dart';
import 'package:handyman/core/constants.dart';
import 'package:handyman/core/size_config.dart';
import 'package:handyman/data/entities/artisan_model.dart';
import 'package:handyman/data/local_database.dart';
import 'package:handyman/domain/models/user.dart';
import 'package:handyman/domain/services/data.dart';
import 'package:provider/provider.dart';

class ServiceProviderDetails extends StatefulWidget {
  final Artisan artisan;

  const ServiceProviderDetails({Key key, this.artisan}) : super(key: key);

  @override
  _ServiceProviderDetailsState createState() => _ServiceProviderDetailsState();
}

class _ServiceProviderDetailsState extends State<ServiceProviderDetails> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  ThemeData _themeData;
  DataService _apiService;
  final _textController = TextEditingController();
  final _focusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    _themeData = Theme.of(context);
    final kHeight = MediaQuery.of(context).size.height;
    final kWidth = MediaQuery.of(context).size.width;

    return Consumer<DataService>(
      builder: (_, service, __) {
        _apiService = service;
        return Consumer<PrefsProvider>(
          builder: (_, provider, __) => StreamBuilder<BaseUser>(
              stream: _apiService.getArtisanById(id: widget.artisan.id),
              initialData: ArtisanModel(artisan: widget.artisan),
              builder: (context, snapshot) {
                final artisan = snapshot.data.user;

                return Scaffold(
                  key: _scaffoldKey,
                  body: artisan == null
                      ? Container(
                    width: double.infinity,
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Icon(
                                Entypo.users,
                                size: getProportionateScreenHeight(kSpacingX96),
                                color: _themeData.colorScheme.onBackground,
                              ),
                              SizedBox(
                                height: getProportionateScreenHeight(kSpacingX16),
                              ),
                              Text(
                                "No artisans found matching this information",
                                style: _themeData.textTheme.bodyText2.copyWith(
                                  color: _themeData.colorScheme.onBackground,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(
                                height: getProportionateScreenHeight(kSpacingX64),
                              ),
                              ButtonPrimary(
                                width: getProportionateScreenWidth(kSpacingX120),
                                label: "Go back",
                                onTap: () => context.navigator.pop(),
                                themeData: _themeData,
                              ),
                            ],
                          ),
                      )
                      : Stack(
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
                            SafeArea(
                              child: AnimatedContainer(
                                duration: kScaleDuration,
                                height: kHeight,
                                width: kWidth,
                                child: ListView(
                                  //physics: kScrollPhysics,
                                  padding: EdgeInsets.only(
                                      bottom: getProportionateScreenHeight(
                                          kToolbarHeight)),
                                  children: [
                                    Stack(
                                      children: [
                                        Container(
                                          height: kHeight * 0.4,
                                          width: kWidth,
                                          child: CachedNetworkImage(
                                            imageUrl: artisan?.avatar ?? "",
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                        Positioned(
                                          right: getProportionateScreenWidth(
                                              kSpacingNone),
                                          top: kHeight * 0.3,
                                          child: InkWell(
                                            onTap: () =>
                                                context.navigator.push(
                                              Routes.requestBookingPage,
                                              arguments:
                                                  RequestBookingPageArguments(
                                                artisan: artisan,
                                              ),
                                            ),
                                            child: Container(
                                              alignment: Alignment.center,
                                              height: kToolbarHeight,
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.only(
                                                  topLeft: Radius.circular(
                                                      kSpacingX16),
                                                  bottomLeft:
                                                      Radius.circular(
                                                          kSpacingX16),
                                                ),
                                                color:
                                                    _themeData.colorScheme.primary,
                                              ),
                                              width: kWidth * 0.25,
                                              child: Text(
                                                "Book now".toUpperCase(),
                                                style: _themeData
                                                    .textTheme.button,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    _buildProfileTab(artisan),
                                    _buildPhotoTab(artisan?.id),
                                    _buildReviewTab(artisan, provider.userId),
                                  ],
                                ),
                              ),
                            ),
                            Positioned(
                              top: kSpacingNone,
                              width: kWidth,
                              child: SafeArea(
                                child: Container(
                                  width: kWidth,
                                  height: kToolbarHeight,
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
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            tooltip: "Search",
                                            icon: Icon(Feather.search),
                                            onPressed: () => context.navigator
                                                .push(Routes.searchPage),
                                          ),
                                          IconButton(
                                            tooltip: "Toggle theme",
                                            icon: Icon(provider.isLightTheme
                                                ? Feather.moon
                                                : Feather.sun),
                                            onPressed: () =>
                                                provider.toggleTheme(),
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              width: kWidth,
                              bottom: kSpacingNone,
                              child: Container(
                                color: _themeData.scaffoldBackgroundColor,
                                child: Column(
                                  children: [
                                    Divider(height: kSpacingNone),
                                    UserInputText(
                                      textController: _textController,
                                      keyboardShown: false,
                                      focusNode: _focusNode,
                                      onSubmit: (text) {
                                        _textController.clear();
                                        _apiService.sendReview(
                                          message: text,
                                          reviewer: provider.userId,
                                          artisan: artisan?.id,
                                        );
                                      },
                                      onTextFieldFocused: (focused) {
                                        if (focused)
                                          FocusScope.of(context)
                                              .requestFocus(_focusNode);
                                        else
                                          FocusScope.of(context).unfocus();
                                        setState(() {});
                                      },
                                      focusState: false,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                );
              }),
        );
      },
    );
  }

  Widget _buildPhotoTab(userId) => Container(
        clipBehavior: Clip.hardEdge,
        width: MediaQuery.of(context).size.width,
        height: getProportionateScreenHeight(kSpacingX320),
        padding: EdgeInsets.symmetric(
          vertical: getProportionateScreenHeight(kSpacingX24),
          horizontal: getProportionateScreenWidth(kSpacingX8),
        ),
        decoration: BoxDecoration(
          color: _themeData.cardColor,
        ),
        child: StreamBuilder<List<Gallery>>(
            stream: _apiService.getPhotosForArtisan(userId),
            initialData: [],
            builder: (context, snapshot) {
              if (snapshot.hasError || snapshot.data.isEmpty)
                return Container(
                  width: double.infinity,
                  height: getProportionateScreenHeight(kSpacingX320),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Entypo.images,
                        size: getProportionateScreenHeight(kSpacingX72),
                      ),
                      SizedBox(
                          height: getProportionateScreenHeight(kSpacingX16)),
                      Text(
                        "No photos found",
                        style: _themeData.textTheme.bodyText2.copyWith(),
                      ),
                    ],
                  ),
                );
              else
                return GridView.builder(
                  scrollDirection: Axis.horizontal,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 1,
                    mainAxisSpacing: getProportionateScreenHeight(kSpacingX12),
                    crossAxisSpacing: getProportionateScreenWidth(kSpacingX8),
                  ),
                  itemBuilder: (_, index) {
                    final photo = snapshot.data[index];

                    return Container(
                      clipBehavior: Clip.hardEdge,
                      width: MediaQuery.of(context).size.width * 0.25,
                      height: getProportionateScreenHeight(kSpacingX160),
                      decoration: BoxDecoration(
                        color: _themeData.errorColor,
                        borderRadius: BorderRadius.circular(kSpacingX16),
                      ),
                      child: CachedNetworkImage(
                        imageUrl: photo.imageUrl,
                        fit: BoxFit.cover,
                      ),
                    );
                  },
                  itemCount: snapshot.data.length,
                );
            }),
      );

  Widget _buildReviewTab(Artisan artisan, String userId) =>
      Consumer<PrefsProvider>(
        builder: (_, prefs, __) => StreamBuilder<List<CustomerReview>>(
            stream: _apiService.getReviewsForArtisan(artisan?.id),
            initialData: [],
            builder: (context, snapshot) {
              return snapshot.hasError || snapshot.data.isEmpty
                  ? SizedBox.shrink()
                  : AnimationLimiter(
                      child: AnimationConfiguration.synchronized(
                        duration: kScaleDuration,
                        child: Column(
                          children: [
                            Container(
                              width: double.infinity,
                              color: _themeData.scaffoldBackgroundColor
                                  .withOpacity(kOpacityX35),
                              padding: EdgeInsets.symmetric(
                                vertical:
                                    getProportionateScreenHeight(kSpacingX16),
                                horizontal:
                                    getProportionateScreenWidth(kSpacingX24),
                              ),
                              child: Text(
                                "Reviews",
                                style: _themeData.textTheme.headline5,
                                textAlign: TextAlign.start,
                              ),
                            ),
                            ...snapshot.data.map(
                              (data) => SlideAnimation(
                                verticalOffset: kSlideOffset,
                                child: FadeInAnimation(
                                  child: CustomerReviewCard(
                                    review: data,
                                    apiService: _apiService,
                                    userId: userId,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
            }),
      );

  Widget _buildProfileTab(Artisan artisan) =>
      ArtisanProfileInfo(artisan: artisan, apiService: _apiService);
}

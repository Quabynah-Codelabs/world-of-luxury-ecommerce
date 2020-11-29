import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:handyman/app/model/prefs_provider.dart';
import 'package:handyman/app/routes/route.gr.dart';
import 'package:handyman/app/widget/buttons.dart';
import 'package:handyman/core/constants.dart';
import 'package:handyman/core/size_config.dart';
import 'package:handyman/data/entities/customer_model.dart';
import 'package:handyman/data/local_database.dart';
import 'package:handyman/domain/models/user.dart';
import 'package:handyman/domain/services/data.dart';
import 'package:meta/meta.dart';
import 'package:provider/provider.dart';

class UserInfoPage extends StatefulWidget {
  final Customer customer;

  const UserInfoPage({
    Key key,
    @required this.customer,
  }) : super(key: key);

  @override
  _UserInfoPageState createState() => _UserInfoPageState();
}

class _UserInfoPageState extends State<UserInfoPage> {
  double _kWidth, _kHeight;
  ThemeData _themeData;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _themeData = Theme.of(context);
    final size = MediaQuery.of(context).size;
    _kWidth = size.width;
    _kHeight = size.height;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PrefsProvider>(
      builder: (_, provider, __) => Scaffold(
        extendBody: true,
        body: Stack(
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
            Consumer<DataService>(
              builder: (_, dataService, __) => StreamBuilder<BaseUser>(
                  stream: dataService.getCustomerById(id: widget.customer.id),
                  initialData: CustomerModel(customer: widget.customer),
                  builder: (context, snapshot) {
                    final Customer user = snapshot.data.user;
                    return Column(
                      children: [
                        Expanded(
                          child: Stack(
                            children: [
                              user.avatar == null || user.avatar.isEmpty
                                  ? SizedBox.shrink()
                                  : Container(
                                      height: _kHeight * 0.75,
                                      width: _kWidth,
                                      child: CachedNetworkImage(
                                        imageUrl: user.avatar,
                                        fit: BoxFit.cover,
                                        placeholder: (_, __) => Container(
                                          alignment: Alignment.center,
                                          decoration: BoxDecoration(
                                            color: _themeData
                                                .scaffoldBackgroundColor
                                                .withOpacity(kOpacityX14),
                                          ),
                                          child: Icon(
                                            Feather.user,
                                            size: _kHeight * 0.15,
                                            color: _themeData
                                                .colorScheme.onBackground
                                                .withOpacity(kOpacityX50),
                                          ),
                                        ),
                                      ),
                                    ),
                              Positioned(
                                bottom: kSpacingNone,
                                width: _kWidth,
                                top: _kHeight * 0.68,
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.only(
                                      topRight: Radius.circular(kSpacingX12),
                                      topLeft: Radius.circular(kSpacingX12),
                                    ),
                                    color: _themeData.scaffoldBackgroundColor,
                                  ),
                                  padding: EdgeInsets.symmetric(
                                    vertical: getProportionateScreenHeight(
                                        kSpacingX24),
                                    horizontal: getProportionateScreenWidth(
                                        kSpacingX16),
                                  ),
                                  clipBehavior: Clip.hardEdge,
                                  child: ConstrainedBox(
                                    constraints: BoxConstraints.tightFor(
                                      width: _kWidth * 0.85,
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Text(
                                          user.name,
                                          style: _themeData.textTheme.headline5,
                                        ),
                                        SizedBox(
                                          height: getProportionateScreenHeight(
                                              kSpacingX24),
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          children: [
                                            // Bookings
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Text(
                                                  "Requests",
                                                  style: _themeData
                                                      .textTheme.headline6,
                                                ),
                                                SizedBox(
                                                  height:
                                                      getProportionateScreenHeight(
                                                          kSpacingX8),
                                                ),
                                                StreamBuilder<List<Booking>>(
                                                    stream: dataService
                                                        .getBookingsForCustomer(
                                                            user?.id),
                                                    initialData: [],
                                                    builder:
                                                        (context, snapshot) {
                                                      return Text(
                                                        snapshot.data.length
                                                            .toString(),
                                                        style: _themeData
                                                            .textTheme
                                                            .headline5,
                                                      );
                                                    }),
                                              ],
                                            ),
                                            _buildDotSeparator(),
                                            // Reviews
                                            Column(
                                              crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Text(
                                                  "Reviews",
                                                  style: _themeData
                                                      .textTheme.headline6,
                                                ),
                                                SizedBox(
                                                  height:
                                                  getProportionateScreenHeight(
                                                      kSpacingX8),
                                                ),
                                                StreamBuilder<List<CustomerReview>>(
                                                    stream: dataService
                                                        .getReviewsByCustomer(
                                                        user?.id),
                                                    initialData: [],
                                                    builder:
                                                        (context, snapshot) {
                                                      return Text(
                                                        snapshot.data.length
                                                            .toString(),
                                                        style: _themeData
                                                            .textTheme
                                                            .headline5,
                                                      );
                                                    }),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        provider.userId == widget.customer.id
                            ? _buildCompleteProfileBar(provider)
                            : SizedBox.shrink(),
                      ],
                    );
                  }),
            ),
            Positioned(
              top: kSpacingNone,
              width: _kWidth,
              child: _buildAppbar(provider),
            ),
          ],
        ),
      ),
    );
  }

  // Builds top appbar
  Widget _buildAppbar(PrefsProvider provider) => SafeArea(
        child: Container(
          width: _kWidth,
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
      );

  // Complete profile bar
  Widget _buildCompleteProfileBar(PrefsProvider provider) => Container(
        width: _kWidth,
        decoration: BoxDecoration(
          color: _themeData.colorScheme.secondary,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(kSpacingX16),
            topRight: Radius.circular(kSpacingX16),
          ),
        ),
        padding: EdgeInsets.symmetric(
          horizontal: getProportionateScreenWidth(kSpacingX36),
          vertical: getProportionateScreenHeight(kSpacingX24),
        ),
        clipBehavior: Clip.hardEdge,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ConstrainedBox(
              constraints: BoxConstraints.tightFor(
                width: _kWidth * 0.6,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Complete Your Profile",
                    style: _themeData.textTheme.headline5.copyWith(
                      color: _themeData.colorScheme.onSecondary,
                    ),
                  ),
                  SizedBox(
                    height: getProportionateScreenHeight(kSpacingX8),
                  ),
                  Text(
                    "Personal | Preferred Service Type | Emergency Contacts",
                    maxLines: 2,
                    style: _themeData.textTheme.subtitle2.copyWith(
                      color: _themeData.colorScheme.onSecondary
                          .withOpacity(kOpacityX50),
                    ),
                  ),
                ],
              ),
            ),
            ButtonIconOnly(
              icon: Icons.arrow_right_alt_outlined,
              color: _themeData.colorScheme.onSecondary,
              iconColor: _themeData.colorScheme.onSecondary,
              onPressed: () => context.navigator.popAndPush(
                Routes.profilePage,
              ),
            ),
          ],
        ),
      );

  // Dot icon
  Widget _buildDotSeparator() => Container(
    height: getProportionateScreenHeight(kSpacingX8),
    width: getProportionateScreenWidth(kSpacingX8),
    decoration: BoxDecoration(
      color: _themeData.primaryColor,
      shape: BoxShape.circle,
    ),
  );
}

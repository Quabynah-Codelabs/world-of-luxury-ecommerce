import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:handyman/app/model/prefs_provider.dart';
import 'package:handyman/app/routes/route.gr.dart';
import 'package:handyman/app/widget/artisan_card.dart';
import 'package:handyman/app/widget/booking_card_item.dart';
import 'package:handyman/core/constants.dart';
import 'package:handyman/core/size_config.dart';
import 'package:handyman/data/local_database.dart';
import 'package:handyman/data/services/data.dart';
import 'package:provider/provider.dart';

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final _dataService = DataServiceImpl.instance;
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  double _kWidth, _kHeight;
  ThemeData _themeData;
  bool _isSearching = false;
  List<dynamic> _searchResults = [];
  TextEditingController _searchController = TextEditingController();

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
              Positioned.fill(
                  top: getProportionateScreenHeight(
                      provider.userType == kCustomerString
                          ? _kHeight * 0.25
                          : kSpacingX160),
                  left: kSpacingNone,
                  right: kSpacingNone,
                  bottom: kSpacingNone,
                  child: _buildSearchContent(provider)),
              Positioned(
                  top: getProportionateScreenHeight(kSpacingX64),
                  width: _kWidth,
                  child: _buildSearchBar()),
              Positioned(
                  height: getProportionateScreenHeight(kToolbarHeight),
                  width: _kWidth,
                  child: _buildAppbar(provider)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppbar(PrefsProvider provider) => Container(
        height: double.infinity,
        width: _kWidth,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            IconButton(
              tooltip: "Go back",
              icon: Icon(Feather.x),
              onPressed: () => context.navigator.pop(),
            ),
          ],
        ),
      );

  Widget _buildSearchBar() => Consumer<PrefsProvider>(
        builder: (_, provider, __) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              height: provider.userType == kCustomerString
                  ? getProportionateScreenHeight(_kHeight * 0.15)
                  : getProportionateScreenHeight(kSpacingX56),
              padding: EdgeInsets.symmetric(
                horizontal: getProportionateScreenWidth(kSpacingX16),
              ),
              margin: EdgeInsets.symmetric(
                horizontal: getProportionateScreenWidth(kSpacingX24),
              ),
              clipBehavior: Clip.hardEdge,
              decoration: BoxDecoration(
                color: _themeData.cardColor,
                borderRadius: BorderRadius.circular(kSpacingX16),
              ),
              child: Column(
                children: [
                  Container(
                    height: getProportionateScreenHeight(kToolbarHeight),
                    child: Row(
                      children: [
                        Icon(
                          Feather.search,
                          color: _themeData.disabledColor
                              .withOpacity(kEmphasisHigh),
                        ),
                        SizedBox(
                          width: getProportionateScreenWidth(kSpacingX8),
                        ),
                        Expanded(
                          child: TextFormField(
                            controller: _searchController,
                            textInputAction: TextInputAction.search,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: provider.userType == kCustomerString
                                  ? "Search for artisans..."
                                  : "Search for bookings & notes...",
                              hintStyle: TextStyle(
                                color: _themeData.disabledColor
                                    .withOpacity(kEmphasisHigh),
                              ),
                            ),
                            onFieldSubmitted: (_) =>
                                setState(() => _isSearching = true),
                            textAlign: TextAlign.start,
                            autocorrect: true,
                          ),
                        ),
                        Row(
                          children: [
                            SizedBox(
                              width: getProportionateScreenWidth(kSpacingX8),
                            ),
                            GestureDetector(
                              onTap: () {
                                _searchController.clear();
                                _searchResults.clear();
                                _isSearching = false;
                                setState(() {});
                              },
                              child: Icon(
                                Feather.x,
                                color: _themeData.disabledColor
                                    .withOpacity(kEmphasisHigh),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  provider.userType == kCustomerString
                      ? Column(
                          children: [
                            SizedBox(
                              height: getProportionateScreenHeight(kSpacingX8),
                            ),
                            StreamBuilder<List<ServiceCategory>>(
                                stream: _dataService.getCategories(),
                                initialData: [],
                                builder: (context, snapshot) {
                                  return Container(
                                    width: double.infinity,
                                    height: getProportionateScreenHeight(
                                        kSpacingX48),
                                    child: ListView.separated(
                                      scrollDirection: Axis.horizontal,
                                      itemBuilder: (_, index) {
                                        final category = snapshot.data[index];
                                        return InkWell(
                                          onTap: () async {
                                            _isSearching = true;
                                            _searchController.text = category.name;
                                            setState(() {});
                                          },
                                          child: Chip(
                                            label: Text(category.name),
                                            padding: EdgeInsets.symmetric(
                                              horizontal:
                                                  getProportionateScreenWidth(
                                                      kSpacingX8),
                                            ),
                                          ),
                                        );
                                      },
                                      separatorBuilder: (_, __) => SizedBox(
                                        width: getProportionateScreenWidth(
                                            kSpacingX8),
                                      ),
                                      itemCount: snapshot.data.length,
                                    ),
                                  );
                                }),
                          ],
                        )
                      : SizedBox.shrink(),
                ],
              ),
            ),
            _isSearching
                ? SizedBox.shrink()
                : Padding(
                    padding: EdgeInsets.symmetric(
                      vertical: getProportionateScreenHeight(kSpacingX8),
                      horizontal: getProportionateScreenWidth(kSpacingX24),
                    ),
                    child: Text(
                      "${_searchResults.length} results found in your area",
                      style: TextStyle(
                        color: _themeData.disabledColor
                            .withOpacity(kEmphasisMedium),
                      ),
                    ),
                  )
          ],
        ),
      );

  Widget _buildSearchContent(PrefsProvider provider) => _isSearching
      ? FutureBuilder<List<dynamic>>(
          initialData: [],
          future: provider.userType == kCustomerString
              ? _dataService.searchFor(
                  value: _searchController.text.toLowerCase().trim())
              : _dataService.getBookingsForArtisan(provider.userId).single,
          builder: (ctx, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(),
              );
            } else {
              _isSearching = false;
              if (snapshot.hasError || snapshot.data.isEmpty) {
                return Container(
                  height: getProportionateScreenHeight(kSpacingX320),
                  width: _kWidth,
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
                        "No results found for\n\`${_searchController.text?.trim()}\`",
                        style: _themeData.textTheme.bodyText2.copyWith(
                          color: _themeData.colorScheme.onBackground,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              } else {
                _searchResults = snapshot.data;
                return Container(
                  height: _kHeight,
                  width: _kWidth,
                  margin: EdgeInsets.symmetric(
                    horizontal: getProportionateScreenWidth(kSpacingX24),
                  ),
                  decoration: BoxDecoration(),
                  child: AnimationLimiter(
                    child: provider.userType == kCustomerString
                        ? GridView.builder(
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing:
                                  getProportionateScreenWidth(kSpacingX8),
                              mainAxisSpacing:
                                  getProportionateScreenHeight(kSpacingX4),
                            ),
                            itemBuilder: (_, index) {
                              final item = snapshot.data[index];
                              return AnimationConfiguration.staggeredList(
                                position: index,
                                duration: kScaleDuration,
                                child: ScaleAnimation(
                                  duration: kScaleDuration,
                                  child: FadeInAnimation(
                                    child: GridArtisanCardItem(artisan: item),
                                  ),
                                ),
                              );
                            },
                            itemCount: snapshot.data.length,
                          )
                        : ListView.separated(
                            itemBuilder: (_, index) {
                              final item = snapshot.data[index];
                              return AnimationConfiguration.staggeredList(
                                position: index,
                                duration: kScaleDuration,
                                child: ScaleAnimation(
                                  duration: kScaleDuration,
                                  child: FadeInAnimation(
                                    child: BookingCardItem(
                                      booking: item,
                                      onTap: () => context.navigator.push(
                                        Routes.bookingsDetailsPage,
                                        arguments: BookingsDetailsPageArguments(
                                          booking: item,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                            separatorBuilder: (_, __) => SizedBox(
                              height: getProportionateScreenHeight(kSpacingX8),
                            ),
                            itemCount: snapshot.data.length,
                          ),
                  ),
                );
              }
            }
          },
        )
      : SizedBox.shrink();
}

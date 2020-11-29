import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:handyman/app/widget/buttons.dart';
import 'package:handyman/core/constants.dart';
import 'package:handyman/core/service_locator.dart';
import 'package:handyman/core/size_config.dart';
import 'package:handyman/core/utils.dart';
import 'package:handyman/domain/models/user.dart';
import 'package:meta/meta.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum InputSelector { NONE, KEYBOARD, MAP, DM, EMOJI, PHONE, PICTURE }

enum EmojiStickerSelector { EMOJI, STICKER }

/// User message input area with options
class UserInput extends StatefulWidget {
  final Function(String) onMessageSent;
  final BaseUser user;

  const UserInput({Key key, @required this.onMessageSent, @required this.user})
      : super(key: key);

  @override
  _UserInputState createState() => _UserInputState();
}

class _UserInputState extends State<UserInput> {
  var currentInputSelector = InputSelector.NONE;
  final textController = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        child: Column(
          children: [
            Divider(),
            UserInputText(
              textController: textController,
              keyboardShown: currentInputSelector == InputSelector.KEYBOARD,
              focusNode: _focusNode,
              onTextFieldFocused: (focused) {
                currentInputSelector = InputSelector.KEYBOARD;
                if (focused)
                  FocusScope.of(context).requestFocus(_focusNode);
                else
                  FocusScope.of(context).unfocus();
                setState(() {});
              },
              focusState: currentInputSelector == InputSelector.KEYBOARD,
            ),
            _UserInputSelector(
              onSelectorChange: (selector) {
                currentInputSelector = selector;
                if (selector == InputSelector.KEYBOARD)
                  FocusScope.of(context).requestFocus(_focusNode);
                else if (selector == InputSelector.PHONE)
                  widget.user.user.phone.isNotEmpty
                      ? showNotAvailableDialog(context)
                      : launchUrl(url: "tel:${widget.user.user.phone}");
                else if (selector == InputSelector.DM)
                  widget.user.user.email.isEmpty
                      ? showNotAvailableDialog(context)
                      : launchUrl(
                          url:
                              "mailto:${widget.user.user.email}?subject=Request%20your%20service");
                else {
                  FocusScope.of(context).unfocus();
                  setState(() {});
                }
              },
              sendMessageEnabled: textController.text.isNotEmpty,
              onMessageSent: () {
                widget.onMessageSent(textController.text.trim());
                textController.clear();
                setState(() {});
              },
              currentInputSelector: currentInputSelector,
            ),
            _SelectorExpanded(
              onCloseRequested: (requestClose) {
                if (requestClose) currentInputSelector = InputSelector.NONE;
                FocusScope.of(context).unfocus();
                setState(() {});
              },
              onTextAdded: (text) {
                textController.text += text;
                setState(() {});
              },
              currentSelector: currentInputSelector,
            ),
          ],
        ),
      );
}

/// Input box for user messages
class UserInputText extends StatefulWidget {
  final TextInputType keyboardType;
  final FocusNode focusNode;
  final bool keyboardShown;
  final Function(bool) onTextFieldFocused;
  final bool focusState;
  final TextEditingController textController;
  final Function(String) onSubmit;

  const UserInputText({
    Key key,
    @required this.keyboardShown,
    @required this.onTextFieldFocused,
    @required this.focusState,
    @required this.focusNode,
    this.keyboardType = TextInputType.text,
    this.textController,
    this.onSubmit,
  }) : super(key: key);

  @override
  _UserInputTextState createState() => _UserInputTextState();
}

class _UserInputTextState extends State<UserInputText> {
  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);

    return Container(
      width: double.infinity,
      alignment: Alignment.center,
      padding: EdgeInsets.only(left: getProportionateScreenWidth(kSpacingX16)),
      // height: getProportionateScreenHeight(kSpacingX48),
      child: TextFormField(
        focusNode: widget.focusNode,
        autofocus: widget.focusState,
        minLines: 2,
        maxLines: 5,
        enableSuggestions: true,
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: "Say something...",
          hintStyle: TextStyle(color: themeData.disabledColor),
        ),
        textAlign: TextAlign.start,
        keyboardType: widget.keyboardType,
        onFieldSubmitted: widget.onSubmit ?? (_) {},
        controller: widget.textController,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        autocorrect: true,
        textInputAction: TextInputAction.send,
        onTap: () => widget.onTextFieldFocused(true),
      ),
    );
  }
}

/// User [InputSelector] (Emoji, Map, Image, Direct Message (email), Phone)
class _UserInputSelector extends StatelessWidget {
  final Function(InputSelector) onSelectorChange;
  final bool sendMessageEnabled;
  final Function onMessageSent;
  final InputSelector currentInputSelector;

  const _UserInputSelector(
      {Key key,
      @required this.onSelectorChange,
      @required this.sendMessageEnabled,
      @required this.onMessageSent,
      @required this.currentInputSelector})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    return Container(
      height: kToolbarHeight,
      padding: EdgeInsets.symmetric(
          horizontal: getProportionateScreenWidth(kSpacingX4)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _InputSelectorButton(
            onClick: () => onSelectorChange(InputSelector.EMOJI),
            icon: Icons.mood_outlined,
            selected: currentInputSelector == InputSelector.EMOJI,
          ),
          _InputSelectorButton(
            onClick: () => onSelectorChange(InputSelector.DM),
            icon: Feather.at_sign,
            selected: currentInputSelector == InputSelector.DM,
          ),
          _InputSelectorButton(
            onClick: () => onSelectorChange(InputSelector.PICTURE),
            icon: Feather.image,
            selected: currentInputSelector == InputSelector.PICTURE,
          ),
          _InputSelectorButton(
            onClick: () => onSelectorChange(InputSelector.MAP),
            icon: Icons.place_outlined,
            selected: currentInputSelector == InputSelector.MAP,
          ),
          _InputSelectorButton(
            onClick: () => onSelectorChange(InputSelector.PHONE),
            icon: Feather.phone,
            selected: currentInputSelector == InputSelector.PHONE,
          ),
          sendMessageEnabled ? SizedBox.shrink() : Divider(),
          Spacer(flex: 1),
          ButtonOutlined(
            width: getProportionateScreenWidth(kSpacingX96),
            themeData: themeData,
            onTap: onMessageSent,
            height: getProportionateScreenHeight(kSpacingX36),
            enabled: sendMessageEnabled,
            label: "Send",
          ),
        ],
      ),
    );
  }
}

class _InputSelectorButton extends StatelessWidget {
  final Function onClick;
  final IconData icon;
  final bool selected;
  final String tooltip;

  const _InputSelectorButton(
      {Key key,
      @required this.onClick,
      @required this.icon,
      @required this.selected,
      this.tooltip = "input button option"})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    return IconButton(
      icon: Icon(icon),
      onPressed: onClick,
      tooltip: tooltip,
      iconSize: kSpacingX20,
      color: selected ? themeData.primaryColor : themeData.disabledColor,
    );
  }
}

/// Area when [InputSelector] is picked
class _SelectorExpanded extends StatefulWidget {
  final Function(bool) onCloseRequested;
  final Function(String) onTextAdded;
  final InputSelector currentSelector;

  const _SelectorExpanded(
      {Key key,
      @required this.onCloseRequested,
      @required this.onTextAdded,
      @required this.currentSelector})
      : super(key: key);

  @override
  __SelectorExpandedState createState() => __SelectorExpandedState();
}

class __SelectorExpandedState extends State<_SelectorExpanded> {
  EmojiStickerSelector _emojiSelector = EmojiStickerSelector.EMOJI;
  LatLng _currentPosition;
  GoogleMapController _controller;

  @override
  void initState() {
    super.initState();
    _fetchCurrentLocation();
  }

  void _fetchCurrentLocation() async {
    if (await Geolocator.checkPermission() ==
        geo.LocationPermission.whileInUse) {
      bool isLocationServiceEnabled =
          await Geolocator.isLocationServiceEnabled();
      debugPrint("Location service enabled -> $isLocationServiceEnabled");
      geo.Position position = await Geolocator.getLastKnownPosition() ??
          await Geolocator.getCurrentPosition(
              desiredAccuracy: geo.LocationAccuracy.high);
      debugPrint("Lat -> ${position.latitude} : Lng -> ${position.longitude}");
      _currentPosition = LatLng(position.latitude, position.longitude);
    } else {
      var permission = await Geolocator.requestPermission();
      if (permission == geo.LocationPermission.whileInUse ||
          permission == geo.LocationPermission.always) _fetchCurrentLocation();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        widget.currentSelector == InputSelector.EMOJI
            ? _EmojiSelector(
                onTextAdded: widget.onTextAdded,
                selector: _emojiSelector,
                onSelected: (selector) {
                  setState(() {
                    _emojiSelector = selector;
                  });
                },
              )
            : widget.currentSelector == InputSelector.MAP
                ? _buildMapPanel()
                : widget.currentSelector == InputSelector.NONE ||
                        widget.currentSelector == InputSelector.KEYBOARD
                    ? SizedBox.shrink()
                    : buildFunctionalityNotAvailablePanel(context),
        _buildHideUIPanel(context),
      ],
    );
  }

  Widget _buildHideUIPanel(BuildContext context) => Container(
        alignment: Alignment.center,
        child: widget.currentSelector != InputSelector.NONE
            ? IconButton(
                icon: Icon(Feather.chevron_down),
                onPressed: () => widget.onCloseRequested(true))
            : SizedBox.shrink(),
      );

  Widget _buildMapPanel() => Container(
        height: kSpacingX320,
        child: GoogleMap(
          myLocationEnabled: true,
          zoomControlsEnabled: true,
          myLocationButtonEnabled: true,
          liteModeEnabled: defaultTargetPlatform == TargetPlatform.android,
          initialCameraPosition: CameraPosition(
            target: _currentPosition ??= LatLng(5.5329650, -0.2592160),
            zoom: 16.0,
          ),
          onMapCreated: (controller) async {
            _controller = controller;
            var preferences = await sl.getAsync<SharedPreferences>();
            var isLightTheme = preferences.getBool(PrefsUtils.THEME_MODE);
            final mapStyle = await getMapStyle(isLightTheme: isLightTheme ?? false);
            _controller.setMapStyle(mapStyle);
            setState(() {});
          },
          onTap: (address) {
            debugPrint("tapped on -> ${address.toString()}");
          },
        ),
      );
}

class _EmojiSelector extends StatelessWidget {
  final Function(String) onTextAdded;
  final EmojiStickerSelector selector;
  final Function(EmojiStickerSelector) onSelected;

  const _EmojiSelector(
      {Key key,
      @required this.onTextAdded,
      @required this.selector,
      @required this.onSelected})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    // final themeData = Theme.of(context);
    return Container(
      height: kSpacingX320,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _ExtendedSelectorInnerButton(
                text: "Emoji",
                onClick: () => onSelected(EmojiStickerSelector.EMOJI),
                selected: selector == EmojiStickerSelector.EMOJI,
              ),
              _ExtendedSelectorInnerButton(
                text: "Stickers",
                onClick: () => onSelected(EmojiStickerSelector.STICKER),
                selected: selector == EmojiStickerSelector.STICKER,
              ),
            ],
          ),
          selector == EmojiStickerSelector.EMOJI
              ? Expanded(child: _EmojiTable(onTextAdded: onTextAdded))
              : Expanded(
                  child: buildFunctionalityNotAvailablePanel(context),
                ),
        ],
      ),
    );
  }
}

/// Inner button for [EmojiStickerSelector]
class _ExtendedSelectorInnerButton extends StatelessWidget {
  final String text;
  final Function onClick;
  final bool selected;

  const _ExtendedSelectorInnerButton(
      {Key key,
      @required this.text,
      @required this.onClick,
      @required this.selected})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    final backgroundColor =
        selected ? themeData.colorScheme.primary : kTransparent;
    final color =
        selected ? themeData.colorScheme.onPrimary : themeData.disabledColor;

    return ButtonClear(
      text: text,
      onPressed: onClick,
      themeData: themeData,
      textColor: color,
      backgroundColor: backgroundColor,
    );
  }
}

class _EmojiTable extends StatelessWidget {
  final Function(String) onTextAdded;

  const _EmojiTable({Key key, @required this.onTextAdded}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(kSpacingX8),
      child: GridView.custom(
        scrollDirection: Axis.vertical,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: EMOJI_COLUMNS,
          crossAxisSpacing: getProportionateScreenWidth(kSpacingX4),
        ),
        childrenDelegate: SliverChildListDelegate.fixed(
          [
            ...emojis.map((emoji) => GestureDetector(
                  onTap: () => onTextAdded(emoji),
                  child: Container(
                    width: getProportionateScreenWidth(kSpacingX42),
                    height: getProportionateScreenHeight(kSpacingX42),
                    child: Text(
                      emoji,
                      style: TextStyle(
                        fontSize:
                            Theme.of(context).textTheme.headline5.fontSize,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                )),
          ],
        ),
      ),
    );
  }
}

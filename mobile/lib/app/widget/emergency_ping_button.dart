import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:handyman/app/model/prefs_provider.dart';
import 'package:handyman/app/routes/route.gr.dart';
import 'package:handyman/core/constants.dart';
import 'package:handyman/core/size_config.dart';
import "package:meta/meta.dart";
import 'package:provider/provider.dart';

class EmergencyPingButton extends StatefulWidget {
  final Widget child;

  const EmergencyPingButton({Key key, @required this.child}) : super(key: key);

  @override
  _EmergencyPingButtonState createState() => _EmergencyPingButtonState();
}

class _EmergencyPingButtonState extends State<EmergencyPingButton> {
  bool _isCalling = false, _isHidden = false;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Container(
      height: size.height,
      width: size.width,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Padding(
            padding: EdgeInsets.only(
              bottom: getProportionateScreenHeight(kSpacingX64),
            ),
            child: widget.child,
          ),
          Positioned(
            bottom: MediaQuery.of(context).padding.bottom,
            width: size.width,
            child: _isHidden ? SizedBox.shrink() : _buildEmergencyButton(),
          ),
        ],
      ),
    );
  }

  Widget _buildEmergencyButton() {
    final size = MediaQuery.of(context).size;
    final themeData = Theme.of(context);
    final backgroundColor = !_isCalling
        ? themeData.colorScheme.error
        : themeData.disabledColor.withOpacity(kOpacityX14);
    final onBackgroundColor =
        !_isCalling ? themeData.colorScheme.onError : themeData.disabledColor;

    return Consumer<PrefsProvider>(
      builder: (_, provider, __) => GestureDetector(
        onTap: () => _contactEmergencyService(provider),
        child: AnimatedContainer(
          duration: kScaleDuration,
          alignment: Alignment.center,
          height: getProportionateScreenHeight(kToolbarHeight),
          width: size.width,
          decoration: BoxDecoration(
            color: backgroundColor,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _isCalling ? Feather.phone_call : Feather.phone,
                color: onBackgroundColor,
              ),
              SizedBox(
                width: getProportionateScreenWidth(kSpacingX16),
              ),
              Text(
                _isCalling ? "Calling..." : "In trouble? Call for help now",
                style: themeData.textTheme.button.copyWith(
                  color: onBackgroundColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _contactEmergencyService(PrefsProvider provider) async {
    final themeData = Theme.of(context);

    if (provider.emergencyContactNumber == null ||
        provider.emergencyContactNumber.isEmpty) {
      ScaffoldMessenger.of(context)
        ..removeCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              "Add an emergency contact in your profile settings page",
              style: TextStyle(
                color: themeData.colorScheme.onError,
              ),
            ),
            backgroundColor: themeData.colorScheme.error,
            behavior: SnackBarBehavior.floating,
            onVisible: () {
              _isHidden = true;
              setState(() {});
            },
            action: SnackBarAction(
              label: "Change".toUpperCase(),
              onPressed: () => context.navigator.push(Routes.profilePage),
            ),
          ),
        );
    } else {
      setState(() {
        _isCalling = !_isCalling;
      });
      print("Emergency service...");
      await Future.delayed(kTestDuration);
      setState(() {
        _isCalling = !_isCalling;
      });
    }
  }
}

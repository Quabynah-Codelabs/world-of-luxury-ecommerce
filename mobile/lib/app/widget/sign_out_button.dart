import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:handyman/core/constants.dart';
import 'package:handyman/domain/services/auth.dart';
import 'package:meta/meta.dart';

import 'buttons.dart';

class SignOutButton extends StatelessWidget {
  final AuthService authService;
  final double preferredWidth;
  final String logoutRoute;
  final Function onConfirmSignOut;

  const SignOutButton({
    Key key,
    @required this.authService,
    @required this.logoutRoute,
    @required this.onConfirmSignOut,
    this.preferredWidth = double.infinity,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _themeData = Theme.of(context);
    return InkWell(
      onTap: () {
        context.navigator.pop();
        showDialog(
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
              ButtonClear(
                text: "Yes",
                onPressed: () {
                  ctx.navigator.pop();
                  onConfirmSignOut();
                },
                themeData: _themeData,
              ),
            ],
          ),
        );
      },
      child: Container(
        alignment: Alignment.center,
        width: double.infinity,
        height: kToolbarHeight,
        decoration: BoxDecoration(
          color: _themeData.errorColor,
        ),
        child: Text(
          "sign out".toUpperCase(),
          style: _themeData.textTheme.button,
        ),
      ),
    );
  }
}

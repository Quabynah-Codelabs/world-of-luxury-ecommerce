import 'package:flutter/material.dart';
import 'package:handyman/core/constants.dart';
import 'package:handyman/core/size_config.dart';
import 'package:meta/meta.dart';

enum UserAccountPicker { ARTISAN, CUSTOMER }

class UserAccountSelector extends StatefulWidget {
  final bool enabled;
  final UserAccountPicker accountPicker;
  final Function(UserAccountPicker) onAccountSelected;

  const UserAccountSelector({
    Key key,
    @required this.accountPicker,
    @required this.onAccountSelected,
    this.enabled = true,
  }) : super(key: key);

  @override
  _UserAccountSelectorState createState() => _UserAccountSelectorState();
}

class _UserAccountSelectorState extends State<UserAccountSelector> {
  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    final size = MediaQuery.of(context).size;
    final kWidth = size.width;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: kWidth * 0.85,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: widget.enabled
                ? themeData.cardColor
                : themeData.scaffoldBackgroundColor,
            borderRadius: BorderRadius.circular(kSpacingX16),
          ),
          padding: EdgeInsets.symmetric(
              vertical: getProportionateScreenHeight(kSpacingX4)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(kCustomerString),
                  SizedBox(width: getProportionateScreenWidth(kSpacingX4)),
                  Checkbox(
                    value: widget.accountPicker == UserAccountPicker.CUSTOMER,
                    onChanged: (_) =>
                        widget.onAccountSelected(UserAccountPicker.CUSTOMER),
                  ),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(kArtisanString),
                  SizedBox(width: getProportionateScreenWidth(kSpacingX4)),
                  Checkbox(
                    value: widget.accountPicker == UserAccountPicker.ARTISAN,
                    onChanged: (_) =>
                        widget.onAccountSelected(UserAccountPicker.ARTISAN),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

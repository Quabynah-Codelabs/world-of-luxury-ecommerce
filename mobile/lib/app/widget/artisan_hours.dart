import 'package:flutter/material.dart';
import 'package:handyman/core/constants.dart';
import 'package:handyman/core/size_config.dart';
import 'package:handyman/data/local_database.dart';
import 'package:meta/meta.dart';

class ArtisanHoursPicker extends StatelessWidget {
  final Artisan artisan;
  final int currentSelection;
  final Function(int) onSelectionChanged;
  final _workingHours = <String>[
    "9:30am",
    "11:30am",
    "1:30pm",
    "3:30pm",
    "5:30pm",
    "7:30pm",
  ];

  ArtisanHoursPicker({
    Key key,
    @required this.artisan,
    @required this.currentSelection,
    @required this.onSelectionChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => Container(
        child: Wrap(
          spacing: kSpacingX8,
          runSpacing: kSpacingX12,
          children: [
            ..._workingHours
                .map(
                  (e) => GestureDetector(
                    onTap: () {
                      onSelectionChanged(_workingHours.indexOf(e));
                    },
                    child: _HoursButton(
                      isSelected: _workingHours.indexOf(e) == currentSelection,
                      text: e,
                    ),
                  ),
                )
                .toList(),
          ],
        ),
      );
}

class _HoursButton extends StatelessWidget {
  final bool isSelected;
  final String text;
  final Color selectedColor;
  final Color unselectedColor;

  const _HoursButton({
    Key key,
    @required this.isSelected,
    @required this.text,
    this.selectedColor,
    this.unselectedColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: getProportionateScreenWidth(kSpacingX12),
        vertical: getProportionateScreenHeight(kSpacingX8),
      ),
      decoration: BoxDecoration(
        color: themeData.scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(kSpacingX8),
        border: Border.all(
          color: isSelected
              ? selectedColor ?? themeData.colorScheme.primary
              : unselectedColor ?? themeData.disabledColor,
          width: kSpacingX2,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            text,
            style: themeData.textTheme.button.copyWith(
              color: isSelected
                  ? selectedColor ?? themeData.colorScheme.primary
                  : unselectedColor ?? themeData.disabledColor,
            ),
          ),
          // SizedBox(width: getProportionateScreenWidth(kSpacingX4)),
          // Icon(
          //   Feather.lock,
          //   size: themeData.textTheme.button.fontSize,
          //   color: isSelected
          //       ? selectedColor ?? themeData.colorScheme.primary
          //       : unselectedColor ?? themeData.disabledColor,
          // ),
        ],
      ),
    );
  }
}

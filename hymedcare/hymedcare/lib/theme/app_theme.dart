import 'package:flutter/cupertino.dart';

class HymedCareTheme {
  // Primary Colors
  static const Color primaryColor = CupertinoColors.systemBlue;
  static const Color secondaryColor = CupertinoColors.systemIndigo;
  static const Color accentColor = CupertinoColors.systemTeal;

  // Background Colors
  static const Color scaffoldBackgroundColor = CupertinoColors.systemBackground;
  static const Color secondaryBackgroundColor = CupertinoColors.secondarySystemBackground;
  static const Color tertiaryBackgroundColor = CupertinoColors.tertiarySystemBackground;

  // Text Colors
  static const Color primaryTextColor = CupertinoColors.label;
  static const Color secondaryTextColor = CupertinoColors.secondaryLabel;
  static const Color tertiaryTextColor = CupertinoColors.tertiaryLabel;

  // Status Colors
  static const Color successColor = CupertinoColors.systemGreen;
  static const Color warningColor = CupertinoColors.systemYellow;
  static const Color errorColor = CupertinoColors.systemRed;
  static const Color infoColor = CupertinoColors.systemBlue;

  // Border and Divider Colors
  static const Color borderColor = CupertinoColors.separator;
  static const Color dividerColor = CupertinoColors.separator;

  // Custom Theme Data
  static CupertinoThemeData get lightTheme {
    return const CupertinoThemeData(
      brightness: Brightness.light,
      primaryColor: primaryColor,
      scaffoldBackgroundColor: scaffoldBackgroundColor,
      barBackgroundColor: secondaryBackgroundColor,
      textTheme: CupertinoTextThemeData(
        primaryColor: primaryColor,
        textStyle: TextStyle(
          color: primaryTextColor,
          fontSize: 16,
        ),
        actionTextStyle: TextStyle(
          color: primaryColor,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        tabLabelTextStyle: TextStyle(
          fontSize: 10,
        ),
        navTitleTextStyle: TextStyle(
          color: primaryTextColor,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        navLargeTitleTextStyle: TextStyle(
          color: primaryTextColor,
          fontSize: 32,
          fontWeight: FontWeight.bold,
        ),
        navActionTextStyle: TextStyle(
          color: primaryColor,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        pickerTextStyle: TextStyle(
          color: primaryTextColor,
          fontSize: 16,
        ),
        dateTimePickerTextStyle: TextStyle(
          color: primaryTextColor,
          fontSize: 16,
        ),
      ),
    );
  }

  static CupertinoThemeData get darkTheme {
    return const CupertinoThemeData(
      brightness: Brightness.dark,
      primaryColor: primaryColor,
      scaffoldBackgroundColor: CupertinoColors.black,
      barBackgroundColor: CupertinoColors.darkBackgroundGray,
      textTheme: CupertinoTextThemeData(
        primaryColor: primaryColor,
        textStyle: TextStyle(
          color: CupertinoColors.white,
          fontSize: 16,
        ),
        actionTextStyle: TextStyle(
          color: primaryColor,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        tabLabelTextStyle: TextStyle(
          fontSize: 10,
        ),
        navTitleTextStyle: TextStyle(
          color: CupertinoColors.white,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        navLargeTitleTextStyle: TextStyle(
          color: CupertinoColors.white,
          fontSize: 32,
          fontWeight: FontWeight.bold,
        ),
        navActionTextStyle: TextStyle(
          color: primaryColor,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        pickerTextStyle: TextStyle(
          color: CupertinoColors.white,
          fontSize: 16,
        ),
        dateTimePickerTextStyle: TextStyle(
          color: CupertinoColors.white,
          fontSize: 16,
        ),
      ),
    );
  }
}

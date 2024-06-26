import 'package:flutter/material.dart';

// MaterialColor kPrimaryColor = MaterialColor(
//   0xFF12344d,
//   <int, Color>{
//     50: Color(0xFFECEFF1),
//     100: Color(0xFFCFD8DC),
//     200: Color(0xFFB0BEC5),
//     300: Color(0xFF90A4AE),
//     400: Color(0xFF78909C),
//     500: Color(0xFF607D8B),
//     600: Color(0xFF546E7A),
//     700: Color(0xFF455A64),
//     800: Color(0xFF37474F),
//     900: Color(0xFF263238),
//   },
// );oct 31
MaterialColor kPrimaryColor = MaterialColor(
  0xFF22344d, // Made the color a bit lighter by increasing the second digit
  <int, Color>{
    50: Color(0xFFECEFF1),
    100: Color(0xFFCFD8DC),
    200: Color(0xFFB0BEC5),
    300: Color(0xFF90A4AE),
    400: Color(0xFF78909C),
    500: Color(0xFF607D8B),
    600: Color(0xFF546E7A),
    700: Color(0xFF455A64),
    800: Color(0xFF37474F),
    900: Color(0xFF263238),
  },
);

// MaterialColor kPrimaryColor = MaterialColor(
//   0xFF1F2937,
//   <int, Color>{
//     50: Color(0xFFECEFF1),
//     100: Color(0xFFCFD8DC),
//     200: Color(0xFFB0BEC5),
//     300: Color(0xFF90A4AE),
//     400: Color(0xFF78909C),
//     500: Color(0xFF607D8B),
//     600: Color(0xFF546E7A),
//     700: Color(0xFF455A64),
//     800: Color(0xFF37474F),
//     900: Color(0xFF263238),
//   },
// );  little dark

// MaterialColor kPrimaryColor = MaterialColor(
//   0xFF2F4F4F,
//   <int, Color>{
//     50: Color(0xFFE4E4E4),
//     100: Color(0xFFBDBDBD),
//     200: Color(0xFF8C8C8C),
//     300: Color(0xFF5C5C5C),
//     400: Color(0xFF3B3B3B),
//     500: Color(0xFF2F4F4F),
//     600: Color(0xFF292929),
//     700: Color(0xFF212121),
//     800: Color(0xFF1B1B1B),
//     900: Color(0xFF111111),
//   },
// );  little greenish
var buttonCOlor = MaterialStateProperty.all(Color(0xFF546E7A));
var buttonTextColor = Colors.white;
MaterialColor kLightTextColor = Colors.grey;
MaterialColor kLinkTextColor = Colors.blue;
MaterialColor kBlackColor = createMaterialColor(Colors.black);
MaterialColor kWhiteColor = createMaterialColor(Colors.white);

MaterialColor kDeliveredOrderColor = Colors.green;
MaterialColor kConfirmedOrderColor = Colors.orange;
MaterialColor kCancelledOrderColor = Colors.red;
MaterialColor kSubmittedOrderColor = Colors.yellow;
MaterialColor kAcceptedOrderColor = Colors.blue;

Color kBackgroundColor = Colors.black12;
Color kNavigationBarColor = kPrimaryColor;
Color kStatusBarColor = kPrimaryColor;

//Text Colors
Color kPrimaryTextColor = Colors.white;
Color kSecondayTextcolor = Color(0xFF535353);

MaterialColor createMaterialColor(Color color) {
  List strengths = <double>[.05];
  final swatch = <int, Color>{};
  final int r = color.red, g = color.green, b = color.blue;

  for (int i = 1; i < 10; i++) {
    strengths.add(0.1 * i);
  }
  strengths.forEach((strength) {
    final double ds = 0.5 - strength;
    swatch[(strength * 1000).round()] = Color.fromRGBO(
      r + ((ds < 0 ? r : (255 - r)) * ds).round(),
      g + ((ds < 0 ? g : (255 - g)) * ds).round(),
      b + ((ds < 0 ? b : (255 - b)) * ds).round(),
      1,
    );
  });
  return MaterialColor(color.value, swatch);
}

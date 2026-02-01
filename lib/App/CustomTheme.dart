import 'package:flutter/material.dart';

import 'AppColors.dart';

final ThemeData customTheme = ThemeData(
  scaffoldBackgroundColor: Colors.white,
  fontFamily: 'Montserrat',
  appBarTheme: AppBarTheme(
    backgroundColor: Colors.white,
    scrolledUnderElevation: 0,
    centerTitle: false,
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      minimumSize: const Size(double.infinity, 49),
      backgroundColor: Colors.deepPurple,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    enabledBorder: const OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(10)),
      borderSide: BorderSide(color: Colors.purple),
    ),
    focusedBorder: const OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(10)),
      borderSide: BorderSide(color: Colors.purple, width: 1),
    ),
    errorBorder: const OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(10)),
      borderSide: BorderSide(color: Colors.purple),
    ),
    focusedErrorBorder: const OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(10)),
      borderSide: BorderSide(color: Colors.purple, width: 1),
    ),
  ),

  // textTheme: const TextTheme(
  //   bodyLarge: TextStyle(color: Colors.white),
  //   bodyMedium: TextStyle(color: Colors.white),
  //   bodySmall: TextStyle(color: Colors.white),
  //
  //   titleLarge: TextStyle(color: Colors.white),
  //   titleMedium: TextStyle(color: Colors.white),
  //   titleSmall: TextStyle(color: Colors.white),
  //
  //   labelLarge: TextStyle(color: Colors.white),
  //   labelMedium: TextStyle(color: Colors.white),
  //   labelSmall: TextStyle(color: Colors.white),
  // ),
  //
);

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:glow_in_the_damp/utils/app_fonts.dart';
import 'package:glow_in_the_damp/utils/const.dart';

final appTheme = ThemeData(
  brightness: Brightness.dark,
  primaryColor: kAccent,
  scaffoldBackgroundColor: kBackground,
  colorScheme: const ColorScheme.dark(
    primary: kAccent,
    secondary: kViolet,
    surface: kPanelBg,
    onSurface: kPrimaryText,
    onPrimary: kBackground,
    error: kError,
    outline: kOutline,
  ),
  appBarTheme: AppBarTheme(
    backgroundColor: Colors.transparent,
    elevation: 0,
    scrolledUnderElevation: 0,
    systemOverlayStyle: const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
    titleTextStyle: AppFonts.archivo(
      fontSize: 18.sp,
      fontWeight: FontWeight.w700,
      color: kPrimaryText,
      letterSpacing: .8,
    ),
    iconTheme: const IconThemeData(color: kPrimaryText),
  ),
  textTheme: TextTheme(
    displayLarge: AppFonts.archivo(
      fontSize: 48.sp,
      fontWeight: FontWeight.w700,
      color: kPrimaryText,
      height: .9,
    ),
    displayMedium: AppFonts.archivo(
      fontSize: 36.sp,
      fontWeight: FontWeight.w700,
      color: kPrimaryText,
      height: 1,
    ),
    headlineMedium: AppFonts.archivo(
      fontSize: 24.sp,
      fontWeight: FontWeight.w700,
      color: kPrimaryText,
    ),
    titleLarge: AppFonts.ibmPlexSans(
      fontSize: 16.sp,
      fontWeight: FontWeight.w600,
      color: kPrimaryText,
    ),
    bodyMedium: AppFonts.ibmPlexSans(
      fontSize: 14.sp,
      fontWeight: FontWeight.w400,
      color: kPrimaryText,
      height: 1.5,
    ),
    bodySmall: AppFonts.ibmPlexSans(
      fontSize: 12.sp,
      fontWeight: FontWeight.w400,
      color: kSecondaryText,
    ),
    labelMedium: AppFonts.ibmPlexMono(
      fontSize: 11.sp,
      fontWeight: FontWeight.w600,
      color: kSecondaryText,
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: kPanelBg,
    contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(kRadiusSubtle),
      borderSide: const BorderSide(color: kOutline),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(kRadiusSubtle),
      borderSide: const BorderSide(color: kOutline),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(kRadiusSubtle),
      borderSide: const BorderSide(color: kAccent, width: kStrokeWeightMedium),
    ),
    hintStyle: AppFonts.ibmPlexSans(color: kSecondaryText, fontSize: 13.sp),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: kAccent,
      foregroundColor: kBackground,
      elevation: 0,
      padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 28.w),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(kRadiusPill)),
      ),
      textStyle: AppFonts.ibmPlexSans(
        fontWeight: FontWeight.w700,
        fontSize: 14.sp,
      ),
    ),
  ),
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: kPrimaryText,
      side: const BorderSide(color: kOutline),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(kRadiusPill)),
      ),
    ),
  ),
  chipTheme: ChipThemeData(
    backgroundColor: kPanelBg,
    selectedColor: kAccent,
    side: const BorderSide(color: kOutline),
    labelStyle: AppFonts.ibmPlexMono(color: kPrimaryText, fontSize: 10.sp),
  ),
  dividerTheme: const DividerThemeData(color: kOutline, thickness: 1),
  useMaterial3: true,
);

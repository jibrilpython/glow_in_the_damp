import 'package:flutter/material.dart';
import 'package:glow_in_the_damp/enum/my_enums.dart';

const Color kBackground = Color(0xFF070508);
const Color kPrimaryText = Color(0xFFEDE8DF);
const Color kPanelBg = Color(0xFF0F0C10);
const Color kSecondaryText = Color(0xFF5A5260);
const Color kAccent = Color(0xFFE8C020);
const Color kOutline = Color(0xFF140F18);
const Color kViolet = Color(0xFF7A3A9A);
const Color kError = Color(0xFFB02A1A);
const Color kGold = kAccent;
const Color kAccentSurface = Color(0x26E8C020);
const Color kVioletSurface = Color(0x267A3A9A);

const double kRadiusSubtle = 10.0;
const double kRadiusStandard = 16.0;
const double kRadiusMedium = 22.0;
const double kRadiusPill = 999.0;
const double kStrokeWeightMedium = 1.5;

const BoxShadow kShadowSubtle = BoxShadow(
  offset: Offset(0, 8),
  blurRadius: 22,
  spreadRadius: -18,
  color: Color(0xAA000000),
);
const BoxShadow kShadowFloat = BoxShadow(
  offset: Offset(0, 18),
  blurRadius: 44,
  spreadRadius: -24,
  color: Color(0xCC000000),
);
const BoxShadow kShadowSignal = BoxShadow(
  offset: Offset(0, 10),
  blurRadius: 30,
  spreadRadius: -16,
  color: Color(0x66E8C020),
);

Color alloyColor(GauzeAlloy alloy) {
  switch (alloy) {
    case GauzeAlloy.heavyIron:
      return kPrimaryText;
    case GauzeAlloy.drawnCopper:
      return const Color(0xFFD4803A);
    case GauzeAlloy.earlyBrass:
      return kAccent;
    case GauzeAlloy.monel:
      return const Color(0xFF8EA0A0);
    case GauzeAlloy.platinum:
      return const Color(0xFFD7D5C8);
  }
}

Color filterColor(GauzeFilter filter) {
  switch (filter) {
    case GauzeFilter.iron:
      return kPrimaryText;
    case GauzeFilter.copperZinc:
      return kAccent;
    case GauzeFilter.monel:
      return const Color(0xFF8EA0A0);
    case GauzeFilter.platinum:
      return const Color(0xFFD7D5C8);
    case GauzeFilter.doubleGauze:
      return kViolet;
    case GauzeFilter.glassCylinder:
      return const Color(0xFF9EB3C4);
  }
}

String alloyAbbrev(GauzeAlloy alloy) => alloy.code;

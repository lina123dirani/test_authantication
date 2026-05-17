import 'package:authantication/core/utils/build_context.dart';
import 'package:flutter/material.dart';

class FontManager {
  static const String fontFamily = 'MadaniArabic';
}

class FontWeightManager {
  static const FontWeight light = FontWeight.w300;
  static const FontWeight bold = FontWeight.w700;
  static const FontWeight semiBold = FontWeight.w600;
  static const FontWeight regular = FontWeight.w400;
  static const FontWeight medium = FontWeight.w500;
}

class FontSize {
  static double s22(BuildContext context) => context.screenWidth * 0.06;
  static double s20(BuildContext context) => context.screenWidth * 0.053;
  static double s18(BuildContext context) => context.screenWidth * 0.048;
  static double s16(BuildContext context) => context.screenWidth * 0.043;
  static double s32(BuildContext context) => context.screenWidth * 0.085;
  static double s14(BuildContext context) => context.screenWidth * 0.037;
  static double s12(BuildContext context) => context.screenWidth * 0.032;
  static double s10(BuildContext context) => context.screenWidth * 0.027;
}

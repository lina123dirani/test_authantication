import 'package:authantication/core/theme/colors.dart';
import 'package:flutter/material.dart';
import 'fonts.dart';

TextStyle _getTextStyle(
  BuildContext context,
  double fontSize,
  FontWeight fontWeight,
  Color? color,
  double height,
) {
  return TextStyle(
    fontFamily: FontManager.fontFamily,
    color: color ?? AppColors.black,
    fontSize: fontSize,
    fontWeight: fontWeight,
    height: height
  );
}

// regular style
TextStyle getRegularStyle(
  BuildContext context, {
  double? fontSize,
  Color? color,
  double? height,
}) {
  return _getTextStyle(
    context,
    fontSize ?? FontSize.s16(context),
    FontWeightManager.regular,
    color,
    height ?? 1.5,
  );
}

// light style
TextStyle getLightStyle(
  BuildContext context, {
  double? fontSize,
  Color? color,
  double? height,
}) {
  return _getTextStyle(
    context,
    fontSize ?? FontSize.s16(context),
    FontWeightManager.light,
    color,
    height ?? 1.5,
  );
}

// medium style
TextStyle getMediumStyle(
  BuildContext context, {
  double? fontSize,
  Color? color,
  double? height,
}) {
  return _getTextStyle(
    context,
    fontSize ?? FontSize.s16(context),
    FontWeightManager.medium,
    color,
    height ?? 1.5,
  );
}

// bold style
TextStyle getBoldStyle(
  BuildContext context, {
  double? fontSize,
  Color? color,
  double? height,
}) {
  return _getTextStyle(
    context,
    fontSize ?? FontSize.s16(context),
    FontWeightManager.bold,
    color,
    height ?? 1.5,
  );
}

// semiBold style
TextStyle getSemiBoldStyle(
  BuildContext context, {
  double? fontSize,
  Color? color,
  double? height,
}) {
  return _getTextStyle(
    context,
    fontSize ?? FontSize.s16(context),
    FontWeightManager.semiBold,
    color,
    height ?? 1.5,
  );
}

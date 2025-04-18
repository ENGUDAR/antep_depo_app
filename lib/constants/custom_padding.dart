import 'package:flutter/material.dart';

enum CustomPadding {
  xlow(9),
  low(12),
  medium(30),
  lmedium(50),
  high(150);

  final double value;
  const CustomPadding(this.value);

  ///all sides padding with[value]
  EdgeInsets get padding => EdgeInsets.all(value);

  ///vertical&horizontal sides padding with[value]
  EdgeInsets get paddingVertical => EdgeInsets.symmetric(vertical: value);
  EdgeInsets get paddingHorizontal => EdgeInsets.symmetric(horizontal: value);
}

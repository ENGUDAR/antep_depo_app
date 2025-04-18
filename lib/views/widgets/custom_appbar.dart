import 'package:antep_depo_app/constants/images_path.dart';
import 'package:flutter/material.dart';

AppBar CustomAppbar() {
  return AppBar(
    shadowColor: Colors.grey,
    backgroundColor: Colors.white,
    centerTitle: true,
    title: Image.asset(
      AssetImages.logo,
      height: 100,
      width: 250,
    ),
  );
}

import 'package:antep_depo_app/constants/images_path.dart';
import 'package:flutter/material.dart';

AppBar CustomAppbar() {
  return AppBar(
    shadowColor: Colors.grey,
    backgroundColor: Color.fromARGB(255, 242, 185, 29),
    centerTitle: true,
    title: Image.asset(
      AssetImages.logo2,
      height: 100,
      width: 250,
    ),
  );
}

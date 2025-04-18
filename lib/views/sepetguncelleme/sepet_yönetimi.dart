import 'package:antep_depo_app/constants/custom_padding.dart';
import 'package:antep_depo_app/viewmodel/screen_utils.dart';
import 'package:antep_depo_app/views/sepetguncelleme/sepet_cikar.dart';
import 'package:antep_depo_app/views/sepetguncelleme/sepet_ekle.dart';
import 'package:antep_depo_app/views/widgets/custom_appbar.dart';
import 'package:antep_depo_app/views/widgets/text_style.dart';
import 'package:flutter/material.dart';

class SepetYonetimi extends StatefulWidget {
  const SepetYonetimi({super.key});

  @override
  State<SepetYonetimi> createState() => _SepetYonetimiState();
}

class _SepetYonetimiState extends State<SepetYonetimi> {
  @override
  Widget build(BuildContext context) {
    // Ekran boyutlarını bir kez hesaplamak için init fonksiyonunu çağırıyoruz
    ScreenUtil().init(context);
    // Tek bir instance üzerinden en küçük boyuta erişim sağlanır
    final double smallestDimension = ScreenUtil().getSmallestDimension();
    return SafeArea(
      child: Scaffold(
        appBar: CustomAppbar(),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: CustomPadding.medium.paddingVertical,
                width: smallestDimension * 0.7,
                child: ElevatedButton(
                  onPressed: () {
                    _navigate(context, const SepetEkle());
                  },
                  style: buttonStyle(40, 50),
                  child: Text(
                    "Sepet Ekle",
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white),
                  ),
                ),
              ),
              Container(
                padding: CustomPadding.medium.paddingVertical,
                width: smallestDimension * 0.7,
                child: ElevatedButton(
                  onPressed: () {
                    _navigate(context, const SepetCikar());
                  },
                  style: buttonStyle(40, 50),
                  child: Text(
                    "Sepet Çıkar",
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<dynamic> _navigate(BuildContext context, Widget page) {
    return Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0); // Sağdan sola kayma
          const end = Offset.zero; // Son pozisyon
          const curve = Curves.ease;

          var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          var offsetAnimation = animation.drive(tween);

          return SlideTransition(
            position: offsetAnimation,
            child: child,
          );
        },
      ),
    );
  }
}

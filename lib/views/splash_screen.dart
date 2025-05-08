import 'package:antep_depo_app/constants/images_path.dart';
import 'package:antep_depo_app/viewmodel/opacity.notifier.dart';
import 'package:antep_depo_app/views/login_screen.dart';
import 'package:antep_depo_app/views/siparis_stok_home.dart';
import 'package:antep_depo_app/views/widgets/fade_page_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _startAnimation();
  }

  void _startAnimation() {
    // 500 ms sonra opacity değerini 1.0 yap
    Timer(const Duration(milliseconds: 500), () {
      ref.read(opacityProvider.notifier).show();
    }); // 5 saniye sonra login durumunu kontrol et ve yönlendir
    Timer(const Duration(seconds: 5), () async {
      final prefs = await SharedPreferences.getInstance();
      final bool isLoggedIn = prefs.getBool('isLoggedIn') ??
          false; // Eğer giriş yapılmışsa HomeScreen'e, yapılmamışsa LoginScreen'e yönlendir
      print('isLoggedIn: ${prefs.getBool('isLoggedIn')}');

      if (isLoggedIn) {
        Navigator.pushAndRemoveUntil(
          context, FadePageRoute(page: const MainScreen()), (_) => false, // Predicate: Tüm önceki sayfaları kaldır
        );
      } else {
        Navigator.pushAndRemoveUntil(
          context, FadePageRoute(page: const LoginScreen()), (_) => false, // Predicate: Tüm önceki sayfaları kaldır
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final opacity = ref.watch(opacityProvider); // Opacity değerini dinle

    return SafeArea(
      child: Scaffold(
        backgroundColor: Color.fromARGB(255, 242, 185, 29),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Center(
            child: AnimatedOpacity(
                duration: const Duration(seconds: 3), // Animasyon süresi
                opacity: opacity, // Riverpod'dan alınan opacity değeri
                child: Hero(
                  tag: 'hero-demo',
                  flightShuttleBuilder: (flightContext, animation, direction, fromHero, toHero) {
                    return AnimatedBuilder(
                      animation: animation,
                      builder: (context, child) {
                        // Yukarıdan aşağıya kayma animasyonu (geri dönüşte tersine)
                        final offset = Tween<Offset>(
                          begin: const Offset(0, -1.0), // Ortadan başlayacak
                          end: Offset.zero, // Ekranın üstünde bitecek
                        ).animate(animation).value;

                        return Transform.translate(
                          offset: Offset(0, offset.dy * MediaQuery.of(context).size.height),
                          child: child,
                        );
                      },
                      child: fromHero.widget,
                    );
                  },
                  child: Image.asset(
                    AssetImages.logo2,
                    width: MediaQuery.of(context).size.width,
                    height: 250,
                  ),
                )),
          ),
        ),
      ),
    );
  }
}

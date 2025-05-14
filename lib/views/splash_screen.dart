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

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseAnimationController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _setupPulseAnimation();
    _startAnimation();
  }

  void _setupPulseAnimation() {
    _pulseAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(
        parent: _pulseAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    _pulseAnimationController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseAnimationController.dispose();
    super.dispose();
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
          context, FadePageRoute(page: const MainScreen()),
          (_) => false, // Predicate: Tüm önceki sayfaları kaldır
        );
      } else {
        Navigator.pushAndRemoveUntil(
          context, FadePageRoute(page: const LoginScreen()),
          (_) => false, // Predicate: Tüm önceki sayfaları kaldır
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final opacity = ref.watch(opacityProvider); // Opacity değerini dinle
    final tema = Theme.of(context);
    final boyut = MediaQuery.of(context).size;

    // Renk tanımlamaları
    const sari = Color.fromARGB(255, 242, 185, 29);
    const beyaz = Colors.white;
    const siyah = Colors.black;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [beyaz, Color.fromARGB(255, 245, 245, 245)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: Center(
                  child: AnimatedOpacity(
                    duration: const Duration(seconds: 2),
                    opacity: opacity,
                    child: Hero(
                      tag: 'hero-demo',
                      flightShuttleBuilder: (flightContext, animation,
                          direction, fromHero, toHero) {
                        return AnimatedBuilder(
                          animation: animation,
                          builder: (context, child) {
                            final offset = Tween<Offset>(
                              begin: const Offset(0, -0.5),
                              end: Offset.zero,
                            ).animate(animation).value;

                            return Transform.translate(
                              offset: Offset(0, offset.dy * boyut.height),
                              child: child,
                            );
                          },
                          child: fromHero.widget,
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: const Color.fromARGB(255, 119, 119, 119)
                                  .withOpacity(0.1),
                              blurRadius: 15,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            AnimatedBuilder(
                              animation: _pulseAnimationController,
                              builder: (context, child) {
                                return Transform.scale(
                                  scale: _pulseAnimation.value,
                                  child: Container(
                                    width: boyut.width * 0.7,
                                    height: boyut.width * 0.7,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: sari.withOpacity(0.3),
                                          blurRadius: 20,
                                          spreadRadius: 5,
                                        ),
                                      ],
                                    ),
                                    child: ClipOval(
                                      child: Image.asset(
                                        AssetImages.logo2,
                                        width: boyut.width * 0.7,
                                        height: boyut.width * 0.7,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 24.0),
                child: AnimatedOpacity(
                  duration: const Duration(seconds: 2),
                  opacity: opacity,
                  child: Column(
                    children: [
                      const SizedBox(
                        width: 40,
                        height: 40,
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(sari),
                          strokeWidth: 3,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:antep_depo_app/constants/custom_padding.dart';
import 'package:antep_depo_app/service/order_services.dart'; // OrderServices import
import 'package:antep_depo_app/viewmodel/screen_utils.dart';
import 'package:antep_depo_app/views/bekleyensiparisler/bekleyen_siparisler.dart';
import 'package:antep_depo_app/views/login_screen.dart';
import 'package:antep_depo_app/views/sepetguncelleme/sepet_y%C3%B6netimi.dart';
import 'package:antep_depo_app/views/siparisyonetimi/siparis_management.dart';
import 'package:antep_depo_app/views/widgets/custom_appbar.dart';
import 'package:antep_depo_app/views/widgets/text_style.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// OrderServices provider
final orderServicesProvider = Provider<OrderServices>((ref) {
  return OrderServices(
      dio: Dio(BaseOptions(baseUrl: "https://www.kardamiyim.com/wms2/")));
});

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  final Color sari = const Color.fromARGB(255, 242, 185, 29);
  // Sepet sayısı örnek veri - gerçek uygulamada bir servisten gelecektir
  final String sepetSayisi = "9";

  @override
  Widget build(BuildContext context) {
    ScreenUtil().init(context);
    final double smallestDimension = ScreenUtil().getSmallestDimension();

    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xFFFDF7E4),
        appBar: CustomAppbar(
          showBackButton: false,
        ),
        body: Stack(
          children: [
            Center(
              child: Padding(
                padding: CustomPadding.medium.padding,
                child: Column(
                  children: [
                    const SizedBox(height: 100),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildMenuButton(
                              icon: Icons.shopping_basket,
                              title: "Sepet Güncelleme",
                              onPressed: () {
                                Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => const SepetYonetimi(),
                                ));
                              },
                              smallestDimension: smallestDimension,
                            ),
                            const SizedBox(height: 10),
                            _buildMenuButton(
                              icon: Icons.shopping_cart,
                              title: "Sipariş Yönetimi",
                              onPressed: () {
                                Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => const FilterScreen(),
                                ));
                              },
                              smallestDimension: smallestDimension,
                            ),
                            const SizedBox(height: 10),
                            _buildMenuButton(
                              icon: Icons.pending_actions,
                              title: "Bekleyen Siparişler",
                              onPressed: () {
                                Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) =>
                                      const BekleyenSiparisler(),
                                ));
                              },
                              smallestDimension: smallestDimension,
                            ),
                            const SizedBox(height: 10),
                            _buildMenuButton(
                              icon: Icons.account_tree_rounded,
                              title: "Ürün Sorgulama",
                              onPressed: () {
                                Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) =>
                                      const BekleyenSiparisler(),
                                ));
                              },
                              smallestDimension: smallestDimension,
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          final orderServices = ref.read(orderServicesProvider);
                          final prefs = await SharedPreferences.getInstance();
                          final userId = prefs.getString('userId');

                          if (userId == null || userId.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Kullanıcı ID bulunamadı."),
                                backgroundColor: Colors.red,
                              ),
                            );
                            return;
                          }

                          // Çıkış yapılırken yükleme göstergesi
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (context) => AlertDialog(
                              backgroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              content: Row(
                                children: [
                                  CircularProgressIndicator(
                                    valueColor:
                                        AlwaysStoppedAnimation<Color>(sari),
                                  ),
                                  const SizedBox(width: 16),
                                  const Text('Çıkış yapılıyor...'),
                                ],
                              ),
                            ),
                          );

                          final success = await orderServices.logout(userId);

                          // Yükleme göstergesini kapat
                          Navigator.of(context).pop();

                          if (success) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Çıkış işlemi başarılı."),
                                backgroundColor: Colors.green,
                              ),
                            );

                            await prefs.setBool('isLoggedIn', false);
                            await prefs.setString('userId', "");

                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const LoginScreen()),
                              (_) => false,
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Çıkış işlemi başarısız."),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.red,
                          elevation: 5,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0),
                            side:
                                const BorderSide(color: Colors.red, width: 1.5),
                          ),
                          padding: const EdgeInsets.symmetric(
                              vertical: 12.0, horizontal: 24.0),
                        ),
                        icon: const Icon(Icons.exit_to_app, color: Colors.red),
                        label: Text(
                          "Çıkış Yap",
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Sağ üst köşede sepet sayısı göstergesi
            Positioned(
              top: 20,
              right: 20,
              child: GestureDetector(
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => const SepetYonetimi(),
                  ));
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.3),
                        spreadRadius: 1,
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                    ],
                    border: Border.all(
                      color: const Color.fromARGB(255, 242, 185, 29),
                      width: 2,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        "Sepet Sayısı",
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 242, 185, 29),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          sepetSayisi,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuButton({
    required IconData icon,
    required String title,
    required VoidCallback onPressed,
    required double smallestDimension,
  }) {
    return Container(
      width: smallestDimension * 0.8,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: buttonStyle(40, 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: Colors.white,
              size: 26,
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w600,
                height: 1.50,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

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
  return OrderServices(dio: Dio(BaseOptions(baseUrl: "https://www.kardamiyim.com/wms2/")));
});

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  @override
  Widget build(BuildContext context) {
    ScreenUtil().init(context);
    final double smallestDimension = ScreenUtil().getSmallestDimension();

    return SafeArea(
      child: Scaffold(
        appBar: CustomAppbar(),
        body: Center(
          child: Padding(
            padding: CustomPadding.medium.padding,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),
                Container(
                  padding: CustomPadding.medium.paddingVertical,
                  width: smallestDimension * 0.7,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => const SepetYonetimi(),
                      ));
                    },
                    style: buttonStyle(40, 50),
                    child: Text(
                      "Sepet Güncelleme",
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white),
                    ),
                  ),
                ),
                SizedBox(
                  width: smallestDimension * 0.7,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => const FilterScreen(),
                      ));
                    },
                    style: buttonStyle(40, 50),
                    child: Text(
                      "Sipariş Yönetimi",
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white),
                    ),
                  ),
                ),
                Padding(
                  padding: CustomPadding.medium.paddingVertical,
                  child: SizedBox(
                    width: smallestDimension * 0.7,
                    child: ElevatedButton(
                      onPressed: () {
                        //bu kısım eklenecek
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => const BekleyenSiparisler(),
                        ));
                      },
                      style: buttonStyle(40, 50),
                      child: Text(
                        "Bekleyen Siparişler",
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white),
                      ),
                    ),
                  ),
                ),
                const Spacer(),
                TextButton(
                    onPressed: () async {
                      final orderServices = ref.read(orderServicesProvider); // OrderServices instance
// SharedPreferences'tan userId al
                      final prefs = await SharedPreferences.getInstance();
                      final userId = prefs.getString('userId');

                      if (userId == null || userId.isEmpty) {
                        // userId yoksa hata mesajı göster
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Kullanıcı ID bulunamadı."),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }
                      // API'ye çıkış isteği gönder
                      final success = await orderServices.logout(userId);

                      if (success) {
                        // Başarı durumunda Snackbar göster ve yönlendir
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Çıkış işlemi başarılı."),
                            backgroundColor: Colors.green,
                          ),
                        );

                        final prefs = await SharedPreferences.getInstance();
                        await prefs.setBool('isLoggedIn', false); // isLoggedIn değerini false yap
                        await prefs.setString('userId', ""); // userId'yi temizle

                        // LoginScreen'e yönlendir ve tüm önceki sayfaları kaldır
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (context) => const LoginScreen()),
                          (_) => false, // Predicate: Tüm önceki sayfaları kaldır
                        );
                      } else {
                        // Hata durumunda Snackbar göster
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Çıkış işlemi başarısız."),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
                    child: Text(
                      "Çıkış Yap",
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.red),
                    ))
              ],
            ),
          ),
        ),
      ),
    );
  }
}

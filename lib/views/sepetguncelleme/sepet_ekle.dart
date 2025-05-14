import 'dart:developer';
import 'package:antep_depo_app/service/order_services.dart'; // OrderServices import
import 'package:antep_depo_app/views/widgets/custom_appbar.dart';
import 'package:antep_depo_app/views/widgets/text_style.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pointmobile_scanner_advanced/pointmobile_scanner_advanced.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Barkod numarasını tutan bir StateProvider
final barcodeProvider = StateProvider<String?>((ref) => null);

// OrderServices provider
final orderServicesProvider = Provider<OrderServices>((ref) {
  return OrderServices(
      dio: Dio(BaseOptions(baseUrl: "https://www.kardamiyim.com/wms2/")));
});

class SepetEkle extends ConsumerStatefulWidget {
  const SepetEkle({super.key});

  @override
  ConsumerState<SepetEkle> createState() => _SepetEkleState();
}

class _SepetEkleState extends ConsumerState<SepetEkle> {
  @override
  void initState() {
    super.initState();
    _initializeScanner();
  }

  @override
  void dispose() {
    PMScanner.onDecode = null; // Dinleyiciyi kaldır
    inspect("PMScanner durdu");
    super.dispose();
  }

  // Barkod Okuyucuyu başlatıp verileri alır.
  Future<void> _initializeScanner() async {
    if (await PMScanner.isDevicePointMobile()) {
      await PMScanner.initScanner();
      await PMScanner.setBeepEnabled(beepEnabled: true);
      await PMScanner.setVibratorEnable(isEnabled: true);

      PMScanner.onDecode = (Symbology symbology, String barcode) {
        if (barcode.isNotEmpty) {
          // Barkod güncelleme işlemi
          ref.read(barcodeProvider.notifier).state = barcode;
        }
      };
    } else {
      showDialog(
        // ignore: use_build_context_synchronously
        context: context,
        builder: (context) => const AlertDialog(
          content: Text('Bu cihaz Point Mobile değil.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final barcodeNo = ref.watch(barcodeProvider); // Barkod değerini izliyoruz
    final orderServices =
        ref.read(orderServicesProvider); // OrderServices instance

    return SafeArea(
      child: Scaffold(
        appBar: CustomAppbar(
          showBackButton: true,
          onBackPressed: () => Navigator.of(context).pop(),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Okutulan Barkod",
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Container(
                width: MediaQuery.of(context).size.width * 0.8,
                height: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(color: Colors.grey),
                ),
                child: Center(
                  child: Text(
                    barcodeNo ?? "Henüz barkod taranmadı",
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 40, horizontal: 8),
                child: Container(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: buttonStyle(15, 150),
                    onPressed: () async {
                      if (barcodeNo != null && barcodeNo.isNotEmpty) {
                        // SharedPreferences'tan userId al
                        SharedPreferences prefs =
                            await SharedPreferences.getInstance();
                        final userId = prefs.getString('userId') ?? "1";

                        // API isteğini yap
                        final success =
                            await orderServices.addSepet(userId, barcodeNo);

                        if (success) {
                          // Snackbar ile başarı mesajı göster
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Sepet başarıyla eklendi."),
                              backgroundColor: Colors.green,
                            ),
                          );

                          // Barkod numarasını sıfırla
                          ref.read(barcodeProvider.notifier).state = null;
                        } else {
                          // Snackbar ile hata mesajı göster
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Sepet eklenemedi."),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      } else {
                        // Snackbar ile uyarı mesajı göster
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Lütfen barkod okutun."),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.add_circle_outline,
                          color: Colors.white,
                          size: 24,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "Ekle",
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: Colors.white,
                                  ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

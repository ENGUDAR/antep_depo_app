import 'dart:developer';
import 'package:antep_depo_app/constants/project_dio.dart';
import 'package:antep_depo_app/viewmodel/sepet_notifier.dart';
import 'package:antep_depo_app/views/siparis_stok_home.dart';
import 'package:antep_depo_app/views/widgets/custom_appbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pointmobile_scanner_advanced/pointmobile_scanner_advanced.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> with ProjectDioMixin {
  //String? _lastScannedBarcode;
  //int _scanCount = 0;
  final List<String> _matchedBarcodes = [];
  String? _userId; // userId'yi sınıf değişkeni olarak tanımla

  @override
  void initState() {
    super.initState();

    _initializeScanner();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      _userId = prefs.getString('userId'); // 'userId' anahtarını kullanarak değeri alın
      ref.read(sepetProvider.notifier).fetchSepetler();
    });
  }

  @override
  void dispose() {
    PMScanner.onDecode = null;
    inspect("PMScanner durdu");
    super.dispose();
  }

  Future<void> _initializeScanner() async {
    if (await PMScanner.isDevicePointMobile()) {
      await PMScanner.initScanner();
      await PMScanner.setBeepEnabled(beepEnabled: true);
      await PMScanner.setVibratorEnable(isEnabled: true);

      PMScanner.onDecode = (Symbology symbology, String barcode) {
        if (ref.read(sepetProvider.notifier).addBarkod(barcode)) {
          _matchedBarcodes.add(barcode);
        }
        inspect('Arka arkaya 2 kez aynı barkod tarandı: $barcode');
      };
    } else {
      showDialog(
        context: context,
        builder: (context) => const AlertDialog(
          content: Text('Bu cihaz Point Mobile değil.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final sepetListesi = ref.watch(sepetProvider);
    return SafeArea(
      child: Scaffold(
        appBar: CustomAppbar(),
        body: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          padding: const EdgeInsets.all(10),
          itemCount: sepetListesi.length,
          itemBuilder: (context, index) {
            final sepetItem = sepetListesi[index];
            return Card(
              elevation: 15,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      sepetItem.sepetAdi,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Barkod: ${sepetItem.sepetBarkodu}',
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.black,
          child: const Icon(
            Icons.done,
            color: Colors.green,
            size: 50,
          ),
          onPressed: () async {
            final userId = _userId;
            final sepetler = _matchedBarcodes;
            if (userId != null) {
              final result = await ref.read(sepetProvider.notifier).sendSepetData(userId, sepetler);

              if (result) {
                ref.read(sepetProvider.notifier).clear();
                _matchedBarcodes.clear();
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (context) => MainScreen(),
                  ),
                  (route) => false,
                );
              } else {
                showDialog(
                  context: context,
                  builder: (context) => const AlertDialog(
                    content: Text('Sepet verileri gönderilemedi.'),
                  ),
                );
              }
            } else {
              showDialog(
                context: context,
                builder: (context) => const AlertDialog(
                  content: Text('Kullanıcı ID\'si bulunamadı. Lütfen tekrar giriş yapın.'),
                ),
              );
            }
          },
        ),
      ),
    );
  }
}

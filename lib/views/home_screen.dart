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
  final Color sari = const Color.fromARGB(255, 242, 185, 29);

  @override
  void initState() {
    super.initState();

    _initializeScanner();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      _userId = prefs
          .getString('userId'); // 'userId' anahtarını kullanarak değeri alın
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
        builder: (context) => AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
            side: BorderSide(color: sari, width: 1.5),
          ),
          title: Text(
            'Uyarı',
            style: TextStyle(color: sari, fontWeight: FontWeight.bold),
          ),
          content: const Text('Bu cihaz Point Mobile değil.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Tamam',
                style: TextStyle(color: sari, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final sepetListesi = ref.watch(sepetProvider);
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xFFFDF7E4),
        appBar: CustomAppbar(
          showBackButton: false,
        ),
        body: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
              child: Text(
                'Sepet Listesi',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                  shadows: [
                    Shadow(
                      color: Colors.black.withOpacity(0.2),
                      offset: const Offset(1, 1),
                      blurRadius: 3,
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: sepetListesi.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.shopping_basket_outlined,
                            size: 80,
                            color: sari,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Henüz sepet bulunmamaktadır',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    )
                  : GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 1.1,
                      ),
                      padding: const EdgeInsets.all(16),
                      itemCount: sepetListesi.length,
                      itemBuilder: (context, index) {
                        final sepetItem = sepetListesi[index];
                        return Card(
                          elevation: 5,
                          shadowColor: Colors.black38,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                            side: BorderSide(
                              color: const Color(0xFFF2B91D).withOpacity(0.5),
                              width: 1,
                            ),
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Colors.white,
                                  Colors.grey.shade50,
                                ],
                              ),
                            ),
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.shopping_basket,
                                  color: sari,
                                  size: 30,
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  sepetItem.sepetAdi,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.06),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    'Barkod: ${sepetItem.sepetBarkodu}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.black87.withOpacity(0.7),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
        floatingActionButton: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                spreadRadius: 2,
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: FloatingActionButton(
            backgroundColor: Colors.black,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [sari, sari.withOpacity(0.7)],
                      radius: 0.8,
                    ),
                  ),
                ),
                const Icon(
                  Icons.done,
                  color: Colors.black,
                  size: 24,
                ),
              ],
            ),
            onPressed: () async {
              final userId = _userId;
              final sepetler = _matchedBarcodes;
              if (userId != null) {
                // Gönderm işlemi sırasında yükleme göstergesi görüntüle
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
                          valueColor: AlwaysStoppedAnimation<Color>(sari),
                        ),
                        const SizedBox(width: 16),
                        const Text('Gönderiliyor...'),
                      ],
                    ),
                  ),
                );

                final result = await ref
                    .read(sepetProvider.notifier)
                    .sendSepetData(userId, sepetler);

                // Yükleme göstergesini kapat
                Navigator.of(context).pop();

                if (result) {
                  ref.read(sepetProvider.notifier).clear();
                  _matchedBarcodes.clear();
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                      builder: (context) => const MainScreen(),
                    ),
                    (route) => false,
                  );
                } else {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                        side: BorderSide(color: sari, width: 1.5),
                      ),
                      title: const Text(
                        'Hata',
                        style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      content: const Text('Sepet verileri gönderilemedi.'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(
                            'Tamam',
                            style: TextStyle(
                              color: sari,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }
              } else {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                      side: BorderSide(color: sari, width: 1.5),
                    ),
                    title: const Text(
                      'Oturum Hatası',
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    content: const Text(
                      'Kullanıcı ID\'si bulunamadı. Lütfen tekrar giriş yapın.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(
                          'Tamam',
                          style: TextStyle(
                            color: sari,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }
            },
          ),
        ),
      ),
    );
  }
}

import 'package:antep_depo_app/constants/project_colors.dart';
import 'package:antep_depo_app/viewmodel/bekleyen_sepet_urunler_notifier.dart';
import 'package:antep_depo_app/views/siparis_stok_home.dart';
import 'package:antep_depo_app/views/widgets/custom_appbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pointmobile_scanner_advanced/pointmobile_scanner_advanced.dart';

class BekleyenSiparisList extends ConsumerStatefulWidget {
  const BekleyenSiparisList({
    super.key,
    required this.sepetIds,
    required this.siparisIds,
  });
  final String siparisIds;
  final List<String> sepetIds;
  @override
  ConsumerState<BekleyenSiparisList> createState() =>
      _BekleyenSiparisListState();
}

class _BekleyenSiparisListState extends ConsumerState<BekleyenSiparisList> {
  @override
  void initState() {
    List<String> result = [widget.siparisIds];

    ref
        .read(bekleyenSepetUrunlerProvider.notifier)
        .bekleyenSepetUrunFetch(result);
    _initializeScanner();
    super.initState();
  }

  Future<void> _initializeScanner() async {
    if (await PMScanner.isDevicePointMobile()) {
      await PMScanner.initScanner();
      await PMScanner.setBeepEnabled(beepEnabled: true);
      await PMScanner.setVibratorEnable(isEnabled: true);

      PMScanner.onDecode = (Symbology symbology, String barcode) {
        if (barcode.isNotEmpty) {
          ref
              .read(bekleyenSepetUrunlerProvider.notifier)
              .processBarkod(barcode, context);
        }
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
    final bekleyenSepetUrunler = ref.watch(bekleyenSepetUrunlerProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFFDF7E4),
      appBar: CustomAppbar(
        showBackButton: true,
        onBackPressed: () => Navigator.of(context).pop(),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        child: Column(
          children: [
            Expanded(
              child: bekleyenSepetUrunler.isEmpty
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Center(
                          child: Text(
                            "Gösterilecek ürün yok",
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () async {
                            final tamamla = await ref
                                .read(bekleyenSepetUrunlerProvider.notifier)
                                .bekleyenUrunlerTamamla(
                                    widget.sepetIds, context);

                            if (tamamla) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("İşlem tamamlandı."),
                                  backgroundColor: Colors.green,
                                ),
                              );

                              Navigator.of(context).pushAndRemoveUntil(
                                MaterialPageRoute(
                                  builder: (context) => const MainScreen(),
                                ),
                                (route) => false,
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("İşlem Tamamlanamadı."),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                            // Tamamla işlemi burada yapılabilir
                          },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                vertical: 15, horizontal: 30),
                            backgroundColor: loginColors,
                          ),
                          child: const Text(
                            "Tamamla",
                            style: TextStyle(fontSize: 18, color: Colors.white),
                          ),
                        ),
                      ],
                    )
                  : ListView.builder(
                      itemCount: bekleyenSepetUrunler.length,
                      itemBuilder: (context, index) {
                        final urun = bekleyenSepetUrunler[index];
                        return Card(
                          elevation: 5,
                          margin: const EdgeInsets.symmetric(
                              vertical: 8, horizontal: 4),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                            side: BorderSide(
                              color: const Color(0xFFF2B91D).withOpacity(0.5),
                              width: 1,
                            ),
                          ),
                          color: Colors.white,
                          child: ListTile(
                            title: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  "Ürün Adı",
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(
                                  width: 20,
                                ),
                                Expanded(
                                  // Text widget'ını kapsamak için kullanılır
                                  child: Text(
                                    urun.urunAdi,
                                    overflow: TextOverflow
                                        .ellipsis, // Uzun metni kesip '...' ekler
                                    maxLines: 2, // Maksimum 2 satır gösterir
                                    style: const TextStyle(fontSize: 17),
                                  ),
                                ),
                              ],
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Divider(),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      "Barkod",
                                      style: TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      urun.barkod,
                                      style: const TextStyle(fontSize: 17),
                                    )
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      "Adet",
                                      style: TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      urun.sepetler.isNotEmpty
                                          ? "${urun.sepetler[0].adet} Adet"
                                          : "0 Adet", // Eğer sepetler boşsa 0 göster
                                      style: const TextStyle(fontSize: 17),
                                    )
                                  ],
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
      ),
    );
  }
}

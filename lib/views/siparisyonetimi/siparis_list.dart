import 'package:antep_depo_app/constants/project_colors.dart';
import 'package:antep_depo_app/viewmodel/urun_state_notifier.dart';
import 'package:antep_depo_app/views/siparis_stok_home.dart';
import 'package:antep_depo_app/views/widgets/custom_appbar.dart';
import 'package:antep_depo_app/views/widgets/custom_row.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pointmobile_scanner_advanced/pointmobile_scanner_advanced.dart';

// Barkod sağlayıcı
final barcodeProvider = StateProvider<String?>((ref) => null);

class SiparisList extends ConsumerStatefulWidget {
  const SiparisList(this.siparisIdListesi, {super.key});
  final List<String> siparisIdListesi; // Sipariş ID'lerini alacak parametre

  @override
  _SiparisListState createState() => _SiparisListState();
}

class _SiparisListState extends ConsumerState<SiparisList> {
  @override
  void initState() {
    super.initState();
    // API'den veri çekme işlemi
    ref.read(urunStateProvider.notifier).fetchUrunler(widget.siparisIdListesi);
    _initializeScanner();
  }

  @override
  void dispose() {
    PMScanner.onDecode = null; // Dinleyiciyi kaldır
    super.dispose();
  }

  Future<void> _initializeScanner() async {
    if (await PMScanner.isDevicePointMobile()) {
      await PMScanner.initScanner();
      await PMScanner.setBeepEnabled(beepEnabled: true);
      await PMScanner.setVibratorEnable(isEnabled: true);

      PMScanner.onDecode = (Symbology symbology, String barcode) {
        if (barcode.isNotEmpty) {
          final success = ref
              .read(urunStateProvider.notifier)
              .processBarkod(barcode, ref, context);

          if (success) {
            // Başarılı işlemden sonra sepet barkodunu sıfırla
          }
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
    final urunler = ref.watch(urunStateProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFFDF7E4),
      appBar: CustomAppbar(
        showBackButton: true,
        onBackPressed: () => Navigator.of(context).pop(),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
        child: urunler.isEmpty
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Center(
                    child: Text(
                      "Gösterilecek ürün yok",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () async {
                      final tamam = await ref
                          .read(urunStateProvider.notifier)
                          .UrunlerveSepetlerTamamla(context);
                      // Tamamla işlemi burada yapılabilir
                      if (tamam) {
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
                            content: Text("İşlem tamamlanmadı."),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
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
                itemCount: urunler.length,
                itemBuilder: (context, index) {
                  final urun = urunler[index];
                  return Card(
                    elevation: 5,
                    margin:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                      side: BorderSide(
                        color: const Color(0xFFF2B91D).withOpacity(0.5),
                        width: 1,
                      ),
                    ),
                    color: Colors.white,
                    child: ListTile(
                      title: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 15),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text("Ürün Adı",
                                    style: TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold,
                                    )),
                                const SizedBox(
                                  width: 20,
                                ),
                                Expanded(
                                  child: Text(
                                    urun.urunAdi,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 2, // Maksimum 1 satır göster
                                    style: const TextStyle(fontSize: 17),
                                  ),
                                ),
                                PopupMenuButton<String>(
                                  onSelected: (value) async {
                                    if (value == "Beklemeye al") {
                                      // API'ye istek atarak siparişi beklemeye fial

                                      final success = await ref
                                          .read(urunStateProvider.notifier)
                                          .removeProductAndPostSepets(
                                              urun.barkod,
                                              context,
                                              urun.sepetler);

                                      if (success) {
                                        // Başarılı mesaj göster
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text(
                                                "Sipariş beklemeye alındı: ${urun.urunAdi}"),
                                            backgroundColor: Colors.green,
                                          ),
                                        );
                                      } else {
                                        // Başarısızlık mesajı göster
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                                "Sipariş beklemeye alınamadı."),
                                            backgroundColor: Colors.red,
                                          ),
                                        );
                                      }
                                    }
                                  },

                                  itemBuilder: (context) => [
                                    const PopupMenuItem(
                                      value: "Beklemeye al",
                                      child: Text("Beklemeye al"),
                                    ),
                                  ],
                                  icon: const Icon(
                                      Icons.more_vert), // 3 nokta ikonu
                                ),
                              ],
                            ),
                            const Divider(),
                            CustomRow(
                              message1: "Barkod",
                              message2: urun.barkod,
                            )
                          ],
                        ),
                      ),
                      subtitle: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 15),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: urun.sepetler.length,
                          itemBuilder: (context, index) {
                            final sepet = urun.sepetler[index];
                            return Column(
                              children: [
                                ListTile(
                                  title: Text(
                                    sepet.sepetAdi,
                                    style:
                                        Theme.of(context).textTheme.titleLarge,
                                  ),
                                  leading:
                                      const Icon(Icons.shopping_bag_outlined),
                                  subtitle: Text(
                                    "Barkod: ${sepet.sepetBarkodu}",
                                    style: const TextStyle(fontSize: 17),
                                  ),
                                  trailing: Text(
                                    "${sepet.adet} Adet",
                                    style: const TextStyle(fontSize: 17),
                                  ),
                                ),
                              ],
                            );
                          },
                          separatorBuilder: (context, index) => const Divider(),
                        ),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}

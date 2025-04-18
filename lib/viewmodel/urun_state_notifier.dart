import 'package:antep_depo_app/model/sepet_%C3%BCr%C3%BCn_model.dart';
import 'package:antep_depo_app/service/order_services.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UrunStateNotifier extends StateNotifier<List<Sepeturun>> {
  final OrderServices _orderServices;

  UrunStateNotifier(this._orderServices) : super([]);

  // Ek yapı: Ürünleri barkod bazında saklayacağımız map
  // Ek yapı: Gelen ürünlerin tutulduğu bir liste
  List<Sepeturun> tamamlaData = [];

  // API'den veri çekme ve state'i güncelleme
  Future<void> fetchUrunler(List<String> siparisIds) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId') ?? "1";
    //todo: Liste de ürün varsa temizle
    tamamlaData.clear();

    final urunResponse = await _orderServices.fetchUrunler(userId: userId, siparisIds: siparisIds);

    if (urunResponse != null && urunResponse.data.isNotEmpty) {
      state = urunResponse.data;
      tamamlaData = urunResponse.data; //Gelen ürünleri bir listede tutuyorum
    } else {
      state = [];
    }
  }

  // Barkod okutulduğunda ilgili ürünün adedini düşürme
  bool processBarkod(String barkod, WidgetRef ref, BuildContext context) {
    final selectedSepetBarkod = ref.read(selectedSepetBarkodProvider); // Mevcut seçili sepet barkodu

    if (selectedSepetBarkod == null) {
      // İlk okutulan barkod: Sepet barkodlarında ara
      final sepetBulundu = state.any((urun) => urun.sepetler.any((sepet) => sepet.sepetBarkodu == barkod));

      if (sepetBulundu) {
        // Barkod bir sepet barkodu ise seç ve kullanıcıya bildir
        ref.read(selectedSepetBarkodProvider.notifier).state = barkod;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Sepet barkodu alındı: $barkod"),
            backgroundColor: Colors.green,
          ),
        );
        return true;
      } else {
        // Barkod bir sepet barkodu değilse hata mesajı ver
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Bu barkod bir sepet barkodu değil."),
            backgroundColor: Colors.red,
          ),
        );
        return false;
      }
    }

    // Yeni okutulan barkodun türünü kontrol et
    final isUrunBarkodu = state.any((urun) => urun.barkod == barkod);
    final isSepetBarkodu = state.any((urun) => urun.sepetler.any((sepet) => sepet.sepetBarkodu == barkod));

    if (isUrunBarkodu) {
      // Barkod bir ürün barkoduysa
      bool sepetBulundu = false;

      state = state
          .map((urun) {
            if (urun.barkod == barkod) {
              // Ürün içindeki sepetlerde selectedSepetBarkod'u ara
              final yeniSepetler = urun.sepetler
                  .map((sepet) {
                    if (sepet.sepetBarkodu == selectedSepetBarkod && sepet.adet > 0) {
                      sepetBulundu = true;
                      return SepetUrun(
                        sepetAdi: sepet.sepetAdi,
                        sepetBarkodu: sepet.sepetBarkodu,
                        adet: sepet.adet - 1,
                      );
                    }
                    return sepet;
                  })
                  .where((sepet) => sepet.adet > 0)
                  .toList();

              return Sepeturun(
                urunAdi: urun.urunAdi,
                barkod: urun.barkod,
                sepetler: yeniSepetler,
              );
            }
            return urun;
          })
          .where((urun) => urun.sepetler.isNotEmpty)
          .toList();

      if (!sepetBulundu) {
        // Ürün barkodu bulundu ama sepet mevcut değil
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Bu üründe böyle bir sepet mevcut değil."),
            backgroundColor: Colors.red,
          ),
        );
        return false;
      }

      // Adet başarıyla düşürüldü
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Adet düşürüldü: $barkod"),
          backgroundColor: Colors.green,
        ),
      );
      return true;
    } else if (isSepetBarkodu) {
      // Barkod bir sepet barkoduysa, selectedSepetBarkod olarak ata
      ref.read(selectedSepetBarkodProvider.notifier).state = barkod;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Yeni sepet barkodu okundu: $barkod"),
          backgroundColor: Colors.green,
        ),
      );
      return true;
    } else {
      // Barkod ne ürün ne de sepet barkodu
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Bu barkod sistemde kayıtlı değil."),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }
  }

  Future<bool> UrunlerveSepetlerTamamla(BuildContext context) async {
    try {
      //Tamamlanacak tüm ürünler bunlar oldu
      final sepetIds = tamamlaData.expand((urun) => urun.sepetler.map((sepet) => sepet.sepetBarkodu)).toList();
      // Tüm ürünlerin içindeki sepetlerin id'lerini (String) toplayın
      //final sepetIds = state.expand((urun) => urun.sepetler.map((sepet) => sepet.sepetBarkodu)).toList();

      if (sepetIds.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Gönderilecek sepet bulunamadı."),
            backgroundColor: Colors.red,
          ),
        );
        return false;
      }

      // Kullanıcı ID'sini alın
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId') ?? "1";

      // API'ye POST isteği gönder
      final success = await _orderServices.bekleyenUrunlerveSiparislerTamamlaa(sepetIds, userId);

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Tüm sepetler başarıyla gönderildi."),
            backgroundColor: Colors.green,
          ),
        );
        return true;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Sepetler gönderilemedi."),
            backgroundColor: Colors.red,
          ),
        );
        return false;
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Bir hata oluştu: $e"),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }
  }

  // Seçili ürünü listeden kaldırma ve API'ye POST gönderme
  Future<bool> removeProductAndPostSepets(String barkod, BuildContext context, List<SepetUrun> sepetler) async {
    try {
      // Barkod eşleşen ürünü bul
      final selectedUrun = state.firstWhere(
        (urun) => urun.barkod == barkod,
        orElse: () => Sepeturun(
          urunAdi: '',
          barkod: '',
          sepetler: [],
        ),
      );

      if (selectedUrun.sepetler.isEmpty) {
        // Eğer ürünün sepeti yoksa hata döndür
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Bu ürün için gönderilecek sepet bulunamadı."),
            backgroundColor: Colors.red,
          ),
        );
        return false;
      }

      // SharedPreferences üzerinden kullanıcı ID'sini alın
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId') ?? "1";
      // `sepetBarkodu` değerlerini `List<int>` formatına dönüştür
      final List<int> sepetIds = sepetler.map((sepet) => int.parse(sepet.sepetBarkodu)).toList();

      // API'ye POST isteği gönder
      final success = await _orderServices.postSepetler(
        sepetIds,
        userId,
      );

      if (success) {
        // Başarılı ise ürünü listeden kaldır
        state = state.where((urun) => urun.barkod != barkod).toList();
        //todo: Beklemeye alınan ürün tamamla datadan da kaldırıldı.O Tamamlanan ürünlerde yer almayacak
        tamamlaData = tamamlaData.where((urun) => urun.barkod != barkod).toList();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Ürün kaldırıldı ve sepetler başarıyla gönderildi."),
            backgroundColor: Colors.green,
          ),
        );
        return true;
      } else {
        // Hata durumunda mesaj göster
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Sepetler gönderilemedi."),
            backgroundColor: Colors.red,
          ),
        );
        return false;
      }
    } catch (e) {
      // Hata yakalama
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Bir hata oluştu: $e"),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }
  }
}

final urunStateProvider = StateNotifierProvider<UrunStateNotifier, List<Sepeturun>>((ref) {
  final orderServices = OrderServices(dio: Dio(BaseOptions(baseUrl: "https://www.kardamiyim.com/wms2/")));
  return UrunStateNotifier(orderServices);
});

final selectedSepetBarkodProvider = StateProvider<String?>((ref) => null);

final navigatorKeyProvider = Provider<GlobalKey<NavigatorState>>((ref) {
  return GlobalKey<NavigatorState>();
});

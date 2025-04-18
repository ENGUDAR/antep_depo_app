import 'package:antep_depo_app/constants/project_dio.dart';
import 'package:antep_depo_app/model/sepet_%C3%BCr%C3%BCn_model.dart';
import 'package:antep_depo_app/service/order_services.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BekleyenSepetUrunlerNotifier extends StateNotifier<List<Sepeturun>> with ProjectDioMixin {
  final IOrderServices orderServices;

  BekleyenSepetUrunlerNotifier({required this.orderServices}) : super([]);

  Future<void> bekleyenSepetUrunFetch(List<String> siparisIds) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId') ?? "1";

    final urunResponse = await orderServices.bekleyenSiparisUrunDetay(userId: userId, siparisIds: siparisIds);

    if (urunResponse != null && urunResponse.data.isNotEmpty) {
      state = urunResponse.data;
    } else {
      state = [];
    }
  }

  Future<bool> bekleyenUrunlerTamamla(List<String> sepetIds, BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId') ?? "1";

    final urunResponse = await orderServices.bekleyenUrunlerTamamlaa(sepetIds, userId);

    if (urunResponse) {
      state = [];
      return true;
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Tamamlama işlemi başarısız"),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }
  }

  void processBarkod(String barkod, BuildContext context) {
    // Barkod ile eşleşen ürünü bul
    final index = state.indexWhere((urun) => urun.barkod == barkod);

    if (index != -1) {
      final urun = state[index];

      // Sepetlerdeki adetleri kontrol et ve azalt
      if (urun.sepetler.isNotEmpty) {
        // İlk sepetin adeti azaltılır
        final updatedSepetler = List<SepetUrun>.from(urun.sepetler);
        updatedSepetler[0] = SepetUrun(
          sepetAdi: urun.sepetler[0].sepetAdi,
          sepetBarkodu: urun.sepetler[0].sepetBarkodu,
          adet: urun.sepetler[0].adet - 1,
        );

        // Eğer adet sıfıra ulaştıysa sepeti kaldır
        if (updatedSepetler[0].adet == 0) {
          updatedSepetler.removeAt(0);
        }

        // Eğer tüm sepetler boşaldıysa ürünü listeden kaldır
        if (updatedSepetler.isEmpty) {
          state = List.from(state)..removeAt(index);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Ürün tamamen kaldırıldı: $barkod"),
              backgroundColor: Colors.red,
            ),
          );
        } else {
          // Güncellenmiş ürünü manuel olarak oluştur
          final updatedUrun = Sepeturun(
            barkod: urun.barkod,
            urunAdi: urun.urunAdi,
            sepetler: updatedSepetler,
          );

          state = List.from(state)..[index] = updatedUrun;

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Ürün adeti azaltıldı: ${urun.barkod}"),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Barkod bulunamadı: $barkod"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

// Sipariş sağlayıcısı için StateNotifierProvider tanımı
final bekleyenSepetUrunlerProvider = StateNotifierProvider<BekleyenSepetUrunlerNotifier, List<Sepeturun>>((ref) {
  return BekleyenSepetUrunlerNotifier(
      orderServices: OrderServices(dio: Dio(BaseOptions(baseUrl: "https://www.kardamiyim.com/wms2/"))));
});

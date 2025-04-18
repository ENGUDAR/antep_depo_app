import 'package:antep_depo_app/constants/project_dio.dart';
import 'package:antep_depo_app/model/siparis_model.dart';
import 'package:antep_depo_app/service/order_services.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SiparisStateNotifier extends StateNotifier<List<Siparis>> with ProjectDioMixin {
  final IOrderServices orderServices;

  SiparisStateNotifier({required this.orderServices}) : super([]);

  Future<bool> sendSiparisData(String userId, {String? kargo, String? kaynak}) async {
    try {
      final apiResponse = await orderServices.sendSiparisData(userId, kargo: kargo, kaynak: kaynak);

      if (apiResponse != null && apiResponse.status == 'success' && apiResponse.data.isNotEmpty) {
        state = apiResponse.data; // Başarılı durumda state güncellenir
        return true;
      } else {
        state = []; // Veri yoksa boş liste atarız
        return false; // Başarısız durumu döndür
      }
    } catch (error) {
      print('Hata: $error');
      state = []; // Hata durumunda da boş liste atarız
      return false; // Başarısız durumu döndür
    }
  }

  Future<void> sendSiparisAta(String userId) async {
    try {
      final apiResponse2 = await orderServices.sendSiparisAta(userId);
      if (apiResponse2 != null) {
        state = apiResponse2.data;
      }
    } catch (error) {
      return;
    }
  }
}

// Sipariş sağlayıcısı için StateNotifierProvider tanımı
final siparisProvider = StateNotifierProvider<SiparisStateNotifier, List<Siparis>>((ref) {
  return SiparisStateNotifier(
      orderServices: OrderServices(dio: Dio(BaseOptions(baseUrl: "https://www.kardamiyim.com/wms2/"))));
});

import 'package:antep_depo_app/constants/project_dio.dart';
import 'package:antep_depo_app/model/siparis_model.dart';
import 'package:antep_depo_app/service/order_services.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BekleyenSiparisNotifier extends StateNotifier<List<Siparis>> with ProjectDioMixin {
  final IOrderServices orderServices;

  BekleyenSiparisNotifier({required this.orderServices}) : super([]);

  Future<void> bekleyenSiparisSepetFetch() async {
    try {
      // SharedPreferences üzerinden kullanıcı ID'sini alın
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId') ?? "1";
      final apiResponse2 = await orderServices.bekleyenSiparisFetchh(userId);
      if (apiResponse2 != null) {
        state = apiResponse2.data;
      }
    } catch (error) {
      return;
    }
  }
}

// Sipariş sağlayıcısı için StateNotifierProvider tanımı
final bekleyenSiparisProvider = StateNotifierProvider<BekleyenSiparisNotifier, List<Siparis>>((ref) {
  return BekleyenSiparisNotifier(
      orderServices: OrderServices(dio: Dio(BaseOptions(baseUrl: "https://www.kardamiyim.com/wms2/"))));
});

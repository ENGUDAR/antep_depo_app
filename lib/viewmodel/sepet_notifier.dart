import 'package:antep_depo_app/constants/project_dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:antep_depo_app/service/order_services.dart';
import 'package:antep_depo_app/model/sepet_model.dart';

class SepetNotifier extends StateNotifier<List<Sepet>> with ProjectDioMixin {
  late final IOrderServices orderServices;

  SepetNotifier() : super([]) {
    orderServices = OrderServices(dio: servicePath);
  }

  Future<void> fetchSepetler() async {
    final response = await orderServices.fetchSepetler();
    if (response != null) {
      state = response.data;
    }
  }

  bool addBarkod(String barkod) {
    if (state.any((sepet) => sepet.sepetBarkodu == barkod)) {
      state = state.where((sepet) => sepet.sepetBarkodu != barkod).toList();
      return true;
    }
    return false;
  }

  Future<bool> sendSepetData(String userId, List<String> sepetler) async {
    return await orderServices.sendSepetData(userId, sepetler);
  }

  void clear() {
    state = [];
  }
}

final sepetProvider = StateNotifierProvider<SepetNotifier, List<Sepet>>((ref) {
  return SepetNotifier();
});

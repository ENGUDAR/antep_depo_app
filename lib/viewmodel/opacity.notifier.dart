import 'package:flutter_riverpod/flutter_riverpod.dart';

// Opacity değeri için StateNotifier
class OpacityNotifier extends StateNotifier<double> {
  OpacityNotifier() : super(0.0); // Başlangıç değeri 0.0 (görünmez)

  // Opacity'yi 1.0'a çıkarmak için bir fonksiyon
  void show() => state = 1.0;
}

// Provider tanımı
final opacityProvider = StateNotifierProvider<OpacityNotifier, double>(
  (ref) => OpacityNotifier(),
);

import 'package:flutter_riverpod/flutter_riverpod.dart';

class CompleteButtonVisibilityNotifier extends StateNotifier<bool> {
  CompleteButtonVisibilityNotifier() : super(false);

  // Butonu göstermek için bu fonksiyonu çağır
  void showButton() {
    state = true;
  }

  // Butonu gizlemek için bu fonksiyonu çağır
  void hideButton() {
    state = false;
  }
}

// Provider'ı tanımlıyoruz
final completeButtonVisibilityProvider =
    StateNotifierProvider<CompleteButtonVisibilityNotifier, bool>((ref) => CompleteButtonVisibilityNotifier());

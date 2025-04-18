// import 'dart:async';
// import 'package:antep_depo_app/viewmodel/screen_utils.dart';
// import 'package:antep_depo_app/views/order_gelen_page.dart';
// import 'package:antep_depo_app/views/order_kabul_edilen.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';

// // Barkod verisini saklamak için bir StateProvider oluşturuyoruz
// final barcodeProvider = StateProvider<String>((ref) => "");
// final scannedProductsProvider = StateProvider<List<String>>((ref) => []);

// class BarcodeScreen extends ConsumerStatefulWidget {
//   const BarcodeScreen({super.key});

//   @override
//   // ignore: library_private_types_in_public_api
//   _BarcodeScreenState createState() => _BarcodeScreenState();
// }

// class _BarcodeScreenState extends ConsumerState<BarcodeScreen> {
//   int scanCount = 0; // Barkodun kaç kez okutulduğunu tutuyoruz

//   Timer? _inactivityTimer; // Kullanıcı aktivitesini dinleyen Timer
//   final int _inactivityDuration = 15; // 15 dakika (saniye cinsinden)

//   @override
//   void initState() {
//     super.initState();
//     // Kullanıcı aktivitesini takip eden Timer başlatılıyor
//     _resetInactivityTimer();
//   }

//   void _resetInactivityTimer() {
//     _inactivityTimer?.cancel(); // Eski Timer'ı iptal et

//     // Yeni bir Timer başlat
//     _inactivityTimer = Timer(Duration(minutes: _inactivityDuration), _navigateToHome);
//   }

//   void _navigateToHome() {
//     //todo: Kullanıcıyı ana ekrana yönlendir
//     // Navigator.pushAndRemoveUntil(
//     //   context,
//     //   MaterialPageRoute(builder: (context) => const MainScreen()),
//     //   (route) => false,
//     // );
//   }

//   final List<Tab> mytabs = <Tab>[
//     const Tab(
//       text: "Gelen Ürünler",
//     ),
//     const Tab(
//       child: Text(
//         "Kabul Edilen Ürünler",
//         textAlign: TextAlign.center,
//       ),
//     )
//   ];
//   @override
//   void dispose() {
//     _inactivityTimer?.cancel(); // Kullanıcı aktivitesini dinleyen Timer'ı iptal et
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     // Ekran boyutlarını bir kez hesaplamak için init fonksiyonunu çağırıyoruz
//     ScreenUtil().init(context);
//     return GestureDetector(
//       behavior: HitTestBehavior.opaque, // Tüm ekran dokunmalarını algılamak için
//       onTap: _resetInactivityTimer, // Kullanıcı dokunduğunda Timer sıfırlanır
//       onPanDown: (details) => _resetInactivityTimer(), // Kullanıcı kaydırma hareketi yaptığında Timer sıfırlanır,
//       child: DefaultTabController(
//           length: mytabs.length,
//           child: SafeArea(
//             child: Scaffold(
//               appBar: AppBar(),
//               body: const TabBarView(children: [OrderGelenPage(), OrderKabulEdilen()]),
//             ),
//           )),
//     );
//   }
// }

// import 'package:antep_depo_app/viewmodel/sepet_notifier.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';

// class SepetList extends ConsumerStatefulWidget {
//   const SepetList({super.key});

//   @override
//   ConsumerState<SepetList> createState() => _SepetListState();
// }

// class _SepetListState extends ConsumerState<SepetList> {
//   @override
//   Widget build(BuildContext context) {
//     final tarananBarkodlar = ref.watch(sepetProvider); // Listeyi dinle

//     return SafeArea(
//       child: Scaffold(
//         appBar: AppBar(
//           title: const Text("Okutulan Barkodlar"),
//         ),
//         body: tarananBarkodlar.isEmpty
//             ? const Center(
//                 child: Text("okutulan barkod yok."),
//               )
//             : ListView.builder(
//                 padding: const EdgeInsets.all(10),
//                 itemCount: tarananBarkodlar.length,
//                 itemBuilder: (context, index) {
//                   final sepetItem = tarananBarkodlar[index];
//                   return Card(
//                     elevation: 4,
//                     margin: const EdgeInsets.symmetric(vertical: 5),
//                     child: ListTile(
//                       leading: const Icon(Icons.qr_code),
//                       title: Text(sepetItem.urunAdi),
//                       subtitle: Text("Barkod: ${sepetItem.barkod}"),
//                     ),
//                   );
//                 },
//               ),
//       ),
//     );
//   }
// }

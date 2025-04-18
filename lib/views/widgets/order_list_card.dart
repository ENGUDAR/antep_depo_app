// import 'package:antep_depo_app/constants/project_dio.dart';
// import 'package:antep_depo_app/model/order_model.dart';
// import 'package:antep_depo_app/service/order_service.dart';
// import 'package:antep_depo_app/viewmodel/order_gelen_notifier.dart';
// import 'package:antep_depo_app/views/widgets/text_style.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';

// // ignore: must_be_immutable
// class OrderListCard extends ConsumerWidget with ProjectDioMixin {
//   OrderListCard({
//     super.key,
//     required this.orderList,
//     required this.textName,
//     required this.heightCard,
//   });

//   final List<OrderModel> orderList;
//   final String textName;
//   final double heightCard;

//   late final IOrderService orderService = OrderService(dio: servicePath);

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final incomingItems = ref.watch(incomingProductsProvider);

//     return Card(
//       child: SizedBox(
//         height: heightCard,
//         child: ListView.builder(
//           itemCount: orderList.isEmpty ? 0 : orderList.length + 1,
//           itemBuilder: (context, index) {
//             if (index == orderList.length && orderList.isNotEmpty) {
//               if (incomingItems.isEmpty) {
//                 return Padding(
//                   padding: const EdgeInsets.all(16.0),
//                   child: ElevatedButton(
//                     onPressed: () async {},
//                     style: buttonStyle(10, 80),
//                     child: Text(
//                       "Tamamla",
//                       style: textStyle(context),
//                     ),
//                   ),
//                 );
//               } else {
//                 return const SizedBox.shrink();
//               }
//             }

//             return Padding(
//               padding: const EdgeInsets.symmetric(vertical: 5),
//               child: Container(
//                 decoration: BoxDecoration(boxShadow: [
//                   BoxShadow(
//                     color: Colors.black.withOpacity(0.3),
//                     spreadRadius: 1,
//                     blurRadius: 5,
//                     offset: const Offset(0, 10), // gölgenin pozisyonu
//                   ),
//                 ]),
//                 child: ListTile(
//                   minVerticalPadding: 15,
//                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
//                   contentPadding: const EdgeInsets.all(15),
//                   tileColor: Colors.white.withOpacity(0.1),
//                   leading: Text(
//                     "${index + 1}",
//                     style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.white),
//                   ),
//                   title: Column(
//                     children: [
//                       Text(
//                         orderList[index].orderName ?? "",
//                         style: textStyle(context),
//                       ),
//                       Text(
//                         orderList[index].barkodNo ?? "",
//                         style: textStyle(context),
//                       ),
//                     ],
//                   ),
//                   trailing: Text(
//                     "${orderList[index].orderPiece} Adet",
//                     style: textStyle(context),
//                   ),
//                 ),
//               ),
//             );
//           },
//         ),
//       ),
//     );
//   }
// }

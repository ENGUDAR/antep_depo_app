import 'package:antep_depo_app/viewmodel/bekleyen_siparis_notifier.dart';
import 'package:antep_depo_app/views/bekleyensiparisler/bekleyen_siparis_list.dart';
import 'package:antep_depo_app/views/widgets/custom_appbar.dart';
import 'package:antep_depo_app/views/widgets/custom_row.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BekleyenSiparisler extends ConsumerStatefulWidget {
  const BekleyenSiparisler({super.key});

  @override
  ConsumerState<BekleyenSiparisler> createState() => _BekleyenSiparislerState();
}

class _BekleyenSiparislerState extends ConsumerState<BekleyenSiparisler> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(bekleyenSiparisProvider.notifier).bekleyenSiparisSepetFetch();
    });
  }

  @override
  Widget build(BuildContext context) {
    final bekleyenSiparisState = ref.watch(bekleyenSiparisProvider);

    return SafeArea(
      child: Scaffold(
        appBar: CustomAppbar(),
        body: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          child: Column(
            children: [
              Expanded(
                child: bekleyenSiparisState.isEmpty
                    ? const Center(child: Text("Gösterilecek sepet yok"))
                    : ListView.builder(
                        itemCount: bekleyenSiparisState.length,
                        itemBuilder: (context, index) {
                          final sepet = bekleyenSiparisState[index];
                          return InkWell(
                            onTap: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => BekleyenSiparisList(
                                  sepetIds: [sepet.sepetId],
                                  siparisIds: sepet.siparisId,
                                ),
                              ));
                            },
                            child: Card(
                              elevation: 7,
                              child: ListTile(
                                leading: const Icon(Icons.shopping_bag_outlined),
                                title: Text(
                                  sepet.sepetAdi,
                                  style: const TextStyle(fontSize: 20),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Divider(),
                                    CustomRow(
                                      message1: "Sepet No",
                                      message2: sepet.siparisId,
                                    ),
                                    CustomRow(message1: "Kargo", message2: sepet.kargo),
                                    CustomRow(message1: "Kaynak", message2: sepet.kaynak),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

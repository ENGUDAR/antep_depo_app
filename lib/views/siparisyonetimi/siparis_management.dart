import 'package:antep_depo_app/service/order_services.dart';
import 'package:antep_depo_app/viewmodel/siparis_listesi_notifier.dart';
import 'package:antep_depo_app/views/siparisyonetimi/siparis_list.dart';
import 'package:antep_depo_app/views/widgets/custom_row.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:antep_depo_app/constants/project_colors.dart';
import 'package:antep_depo_app/model/kargo_model.dart';
import 'package:antep_depo_app/model/kaynak_model.dart';
import 'package:antep_depo_app/views/widgets/custom_appbar.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Seçeneklerin durumunu tutan StateProvider

final selectedKaynakValueProvider = StateProvider<String?>((ref) => null);
final selectedFirmaValueProvider = StateProvider<String?>((ref) => null);

// Dropdown için API'den gelen filtre seçenekleri
final siparisKaynakOptionsProvider = FutureProvider<List<String>>((ref) async {
  Dio dio = Dio(BaseOptions(baseUrl: "https://www.kardamiyim.com/wms2/"));
  OrderServices orderServices = OrderServices(dio: dio);
  KaynakModel? kaynakModel = await orderServices.fetchKaynakData();
  return kaynakModel?.data ?? [];
});

final kargoFirmaOptionsProvider = FutureProvider<List<String>>((ref) async {
  Dio dio = Dio(BaseOptions(baseUrl: "https://www.kardamiyim.com/wms2/"));
  OrderServices orderServices = OrderServices(dio: dio);
  KargoModel? kargoModel = await orderServices.fetchKargoData();
  return kargoModel?.data ?? [];
});

class FilterScreen extends ConsumerStatefulWidget {
  const FilterScreen({super.key});

  @override
  ConsumerState<FilterScreen> createState() => _FilterScreenState();
}

class _FilterScreenState extends ConsumerState<FilterScreen> {
  @override
  void initState() {
    //Burada ekran yeni açıldı dropdown seçilmeleri false olduğı için send sipariş ata api post at
    _sendRequest(context);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final selectedFirmaValue = ref.watch(selectedFirmaValueProvider);
    final selectedKaynakValue = ref.watch(selectedKaynakValueProvider);

    //todo: Bu Filtreye göre verileri getirir.
    final siparisState = ref.watch(siparisProvider);
    final kaynakOptionsAsync = ref.watch(siparisKaynakOptionsProvider);
    final kargoOptionsAsync = ref.watch(kargoFirmaOptionsProvider);

    return PopScope(
      onPopInvokedWithResult: (bool canPop, dynamic result) {
        // Sayfadan çıkıldığında değerleri null yap
        ref.read(selectedKaynakValueProvider.notifier).state = null;
        ref.read(selectedFirmaValueProvider.notifier).state = null;
      },
      child: SafeArea(
        child: Scaffold(
          backgroundColor: const Color(0xFFFDF7E4),
          floatingActionButton: ref.watch(siparisProvider).isEmpty
              ? null // Eğer siparisState boşsa butonu göstermiyoruz
              : FloatingActionButton(
                  backgroundColor: Colors.black,
                  onPressed: () {
                    // Ekranda gösterilen siparişlerin siparis_id'lerini al
                    final siparisIdListesi = ref
                        .read(siparisProvider)
                        .map((siparis) => siparis.siparisId)
                        .toList();

                    // SepetListe sayfasına sipariş ID listesini gönder
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => SiparisList(siparisIdListesi),
                    ));
                  },
                  child: const Icon(
                    Icons.add,
                    color: loginColors,
                  ),
                ),
          appBar: CustomAppbar(
            showBackButton: true,
            onBackPressed: () => Navigator.of(context).pop(),
          ),
          body: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            child: Column(
              children: [
                // Kaynak Dropdown
                Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: loginColors, width: 2)),
                  width: MediaQuery.of(context).size.width,
                  child: kaynakOptionsAsync.when(
                    data: (kaynakOptions) => DropdownButton<String>(
                      isExpanded: true,
                      menuWidth: MediaQuery.of(context).size.width / 1.1,
                      icon: const Icon(
                        Icons.arrow_drop_down_sharp,
                        color: loginColors,
                      ),
                      elevation: 1,
                      borderRadius: BorderRadius.circular(20),
                      underline: const SizedBox(),
                      value: selectedKaynakValue,
                      hint: const Text('Sipariş Kaynak'),
                      items: kaynakOptions.map((String item) {
                        return DropdownMenuItem<String>(
                          value: item,
                          child: Text(item),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        ref.read(selectedKaynakValueProvider.notifier).state =
                            newValue;
                      },
                    ),
                    loading: () => const Center(
                        child: CircularProgressIndicator(
                      color: loginColors,
                    )),
                    error: (error, stack) => Text('Hata: $error'),
                  ),
                ),
                const SizedBox(height: 20),
                // Kargo Dropdown
                Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: loginColors, width: 2)),
                  width: MediaQuery.of(context).size.width,
                  child: kargoOptionsAsync.when(
                    data: (kargoOptions) => DropdownButton<String>(
                      isExpanded: true,
                      menuWidth: MediaQuery.of(context).size.width / 1.1,
                      icon: const Icon(
                        Icons.arrow_drop_down_sharp,
                        color: loginColors,
                      ),
                      elevation: 1,
                      borderRadius: BorderRadius.circular(20),
                      underline: const SizedBox(),
                      value: selectedFirmaValue,
                      hint: const Text('Kargo Firması'),
                      items: kargoOptions.map((String item) {
                        return DropdownMenuItem<String>(
                          value: item,
                          child: Text(item),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        ref.read(selectedFirmaValueProvider.notifier).state =
                            newValue;
                      },
                    ),
                    loading: () => const Center(
                        child: CircularProgressIndicator(
                      color: loginColors,
                    )),
                    error: (error, stack) => Text('Hata: $error'),
                  ),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                    style:
                        ElevatedButton.styleFrom(backgroundColor: loginColors),
                    onPressed: () async {
                      _sendRequest(context);
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Filtrele",
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(color: Colors.white),
                        ),
                        const SizedBox(width: 5),
                        const Icon(
                          Icons.search,
                          color: Colors.white,
                          size: 25,
                        )
                      ],
                    )),
                const SizedBox(height: 20),
                // Diğer filtreler ve liste gösterimi
                Expanded(
                  child: siparisState.isEmpty
                      ? const Center(child: Text("Gösterilecek sipariş yok"))
                      : ListView.builder(
                          itemCount: siparisState.length,
                          itemBuilder: (context, index) {
                            final siparis = siparisState[index];
                            return Card(
                              elevation: 5,
                              margin: const EdgeInsets.symmetric(
                                  vertical: 8, horizontal: 4),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                                side: BorderSide(
                                  color:
                                      const Color(0xFFF2B91D).withOpacity(0.5),
                                  width: 1,
                                ),
                              ),
                              color: Colors.white,
                              child: ListTile(
                                leading:
                                    const Icon(Icons.shopping_bag_outlined),
                                title: Text(
                                  siparis.sepetAdi,
                                  style: const TextStyle(fontSize: 20),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Divider(),
                                    CustomRow(
                                      message1: "Sipariş No",
                                      message2: siparis.siparisId,
                                    ),
                                    CustomRow(
                                        message1: "Kargo",
                                        message2: siparis.kargo),
                                    CustomRow(
                                        message1: "Kaynak",
                                        message2: siparis.kaynak),
                                  ],
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
      ),
    );
  }

  Future<void> _sendRequest(BuildContext context) async {
    final selectedFirmaValue = ref.read(selectedFirmaValueProvider);
    final selectedKaynakValue = ref.read(selectedKaynakValueProvider);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final userId =
        prefs.getString('userId'); // SharedPreferences'tan userId alınır

    if (selectedFirmaValue == null && selectedKaynakValue == null) {
      ref.read(siparisProvider.notifier).sendSiparisAta(userId!);
    } else {
      final success = await ref.read(siparisProvider.notifier).sendSiparisData(
          userId!,
          kargo: selectedFirmaValue,
          kaynak: selectedKaynakValue);

      if (!success) {
        _showMessage(
            'Veri bulunamadı', context); // Eğer false dönerse mesaj göster
      }
    }
  }
}

void _showMessage(String message, BuildContext context) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: Colors.red,
    ),
  );
}

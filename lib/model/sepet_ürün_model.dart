class SepetUrun {
  final String sepetAdi;
  final String sepetBarkodu;
  final int adet;

  SepetUrun({required this.sepetAdi, required this.sepetBarkodu, required this.adet});

  factory SepetUrun.fromJson(Map<String, dynamic> json) {
    return SepetUrun(
      sepetAdi: json['sepet_adi'],
      sepetBarkodu: json['sepet_barkodu'],
      adet: int.parse(json['adet']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sepet_adi': sepetAdi,
      'sepet_barkodu': sepetBarkodu,
      'adet': adet.toString(),
    };
  }
}

class Sepeturun {
  final String urunAdi;
  final String barkod;
  final List<SepetUrun> sepetler;

  Sepeturun({required this.urunAdi, required this.barkod, required this.sepetler});

  factory Sepeturun.fromJson(Map<String, dynamic> json) {
    var list = json['sepetler'] as List;
    List<SepetUrun> sepetList = list.map((i) => SepetUrun.fromJson(i)).toList();

    return Sepeturun(
      urunAdi: json['urun_adi'],
      barkod: json['barkod'],
      sepetler: sepetList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'urun_adi': urunAdi,
      'barkod': barkod,
      'sepetler': sepetler.map((sepet) => sepet.toJson()).toList(),
    };
  }
}

class Cevap {
  final String status;
  final List<Sepeturun> data;

  Cevap({required this.status, required this.data});

  factory Cevap.fromJson(Map<String, dynamic> json) {
    var list = json['data'] as List? ?? []; // null kontrolü yapılıyor, null ise boş liste atanıyor
    List<Sepeturun> urunList = list.map((i) => Sepeturun.fromJson(i)).toList();

    return Cevap(
      status: json['status'],
      data: urunList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'data': data.map((urun) => urun.toJson()).toList(),
    };
  }
}

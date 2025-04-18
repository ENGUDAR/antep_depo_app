class SepetResponse {
  final String status;
  final List<Sepet> data;

  SepetResponse({required this.status, required this.data});

  factory SepetResponse.fromJson(Map<String, dynamic> json) {
    return SepetResponse(
      status: json['status'],
      data: (json['data'] as List).map((e) => Sepet.fromJson(e)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'data': data.map((e) => e.toJson()).toList(),
    };
  }
}

class Sepet {
  final String sepetBarkodu;
  final String sepetAdi;

  Sepet({required this.sepetBarkodu, required this.sepetAdi});

  factory Sepet.fromJson(Map<String, dynamic> json) {
    return Sepet(
      sepetBarkodu: json['sepet_barkodu'],
      sepetAdi: json['sepet_adi'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sepet_barkodu': sepetBarkodu,
      'sepet_adi': sepetAdi,
    };
  }
}

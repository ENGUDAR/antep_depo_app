class Siparis {
  final String sepetId;
  final String siparisId;
  final String sepetAdi;
  final String kargo;
  final String kaynak;

  Siparis({
    required this.sepetId,
    required this.siparisId,
    required this.kargo,
    required this.kaynak,
    required this.sepetAdi,
  });

  factory Siparis.fromJson(Map<String, dynamic> json) {
    return Siparis(
      sepetId: json['sepet_id'] ?? '', // Eğer null ise boş bir String döner
      siparisId: json['siparis_id'] ?? '',
      sepetAdi: json['sepet_adi'] ?? '',
      kargo: json['kargo'] ?? '',
      kaynak: json['kaynak'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sepet_id': sepetId,
      'siparis_id': siparisId,
      "sepet_adi": sepetAdi,
      'kargo': kargo,
      'kaynak': kaynak,
    };
  }
}

class ApiResponse {
  final String status;
  final List<Siparis> data;
  final String? message; // Opsiyonel mesaj alanı

  ApiResponse({required this.status, required this.data, this.message});

  factory ApiResponse.fromJson(Map<String, dynamic> json) {
    List<Siparis> dataList = [];

    // Eğer 'data' alanı varsa ve null değilse listeye dönüştür
    if (json.containsKey('data') && json['data'] != null) {
      var list = json['data'] as List;
      dataList = list.map((i) => Siparis.fromJson(i)).toList();
    }

    return ApiResponse(
      status: json['status'],
      data: dataList,
      message: json['message'], // Mesaj alanı atanır (olabilir ya da olmayabilir)
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'data': data.map((siparis) => siparis.toJson()).toList(),
      'message': message,
    };
  }
}

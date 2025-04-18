class KaynakModel {
  String status;
  List<String> data;
  KaynakModel({required this.status, required this.data}); // JSON'dan model oluşturma
  factory KaynakModel.fromJson(Map<String, dynamic> json) {
    return KaynakModel(
      status: json['status'],
      data: List<String>.from(json['data']),
    );
  } // Modelden JSON oluşturma
  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'data': data,
    };
  }
}

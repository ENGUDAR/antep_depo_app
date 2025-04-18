class KargoModel {
  String status;
  List<String> data;
  KargoModel({required this.status, required this.data}); // JSON'dan model oluşturma
  factory KargoModel.fromJson(Map<String, dynamic> json) {
    return KargoModel(
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

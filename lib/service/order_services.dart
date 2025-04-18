import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:antep_depo_app/constants/project_dio.dart';
import 'package:antep_depo_app/model/kargo_model.dart';
import 'package:antep_depo_app/model/kaynak_model.dart';
import 'package:antep_depo_app/model/sepet_%C3%BCr%C3%BCn_model.dart';
import 'package:antep_depo_app/model/sepet_model.dart';
import 'package:antep_depo_app/model/siparis_model.dart';
import 'package:antep_depo_app/model/user_model.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class IOrderServices {
  final Dio dio;

  IOrderServices({required this.dio});

  Future<bool> login(String kullaniciAdi, String sifre);
  Future<SepetResponse?> fetchSepetler();
  Future<bool> sendSepetData(String userId, List<String> sepetler);
  Future<KargoModel?> fetchKargoData();
  Future<KaynakModel?> fetchKaynakData();
  Future<ApiResponse?> sendSiparisData(String userId, {String? kargo, String? kaynak});
  Future<ApiResponse?> sendSiparisAta(String userId);
  Future<Cevap?> fetchUrunler({required String userId, required List<String> siparisIds});
  Future<bool> addSepet(String userId, String sepetBarkod);
  Future<bool> cikarSepet(String userId, String sepetBarkod);
  Future<bool> logout(String userId);
  Future<bool> postSepetler(List<int> sepetler, String userId);
  Future<ApiResponse?> bekleyenSiparisFetchh(String userId);
  Future<Cevap?> bekleyenSiparisUrunDetay({required String userId, required List<String> siparisIds});
  Future<bool> bekleyenUrunlerTamamlaa(List<String> sepetIds, String userId);
  Future<bool> bekleyenUrunlerveSiparislerTamamlaa(List<String> sepetIds, String userId);
}

//https://www.kardamiyim.com/wms2/-  login.php?isim_soyisim=oguzhan&sifre=123
class OrderServices extends IOrderServices with ProjectDioMixin {
  OrderServices({required super.dio});

  Dio get dio => servicePath; // ProjectDioMixin'in dio nesnesini kullanır

  @override
  Future<bool> login(String kullaniciAdi, String sifre) async {
    try {
      final response = await dio.post(
        "login.php?isim_soyisim=$kullaniciAdi&sifre=$sifre",
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == HttpStatus.ok) {
        // response.data doğrudan Map<String, dynamic> türünde
        final data = response.data as Map<String, dynamic>;
        inspect("data: $data");

        if (data['status'] == 'success') {
          // id'yi User modeline kaydet
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString('userId', data['id']);
          User().id = data['id'];
          return true; // message değerini döndür
        } else {
          return false; // Başarısız mesajını döndür
        }
      }
    } catch (e) {
      log('Hata: $e');
      return false;
    }
    return false;
  }

  @override
  Future<SepetResponse?> fetchSepetler() async {
    try {
      final response = await dio.get('sepet_secimi.php');

      if (response.statusCode == 200) {
        // JSON yanıtını model nesnesine dönüştür
        final sepetResponse = SepetResponse.fromJson(response.data);
        return sepetResponse;
      } else {
        print('İstek başarısız: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Hata: $e');
      return null;
    }
  }

  @override
  Future<bool> sendSepetData(String userId, List<String> sepetler) async {
    try {
      final response = await dio.post(
        "sepet_eslestir.php", // Kendi API URL'nizi buraya yazın
        data: json.encode({
          'user_id': userId,
          'sepetler': sepetler,
        }),
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
        ),
      );
      if (response.statusCode == HttpStatus.ok) {
        return true;
      } else {
        print('İstek başarısız: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('Hata: $e');
      return false;
    }
  }

  Future<KargoModel?> fetchKargoData() async {
    try {
      final response = await dio.get('kargo_listing.php'); // Kendi API endpoint'inizi buraya yazın
      if (response.statusCode == HttpStatus.ok) {
        final kargoModel = KargoModel.fromJson(response.data);
        return kargoModel;
      } else {
        log('İstek başarısız: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      log('Hata: $e');
      return null;
    }
  }

  Future<KaynakModel?> fetchKaynakData() async {
    try {
      final response = await dio.get('kaynak_listing.php'); // Kendi API endpoint'inizi buraya yazın
      if (response.statusCode == HttpStatus.ok) {
        final kaynakModel = KaynakModel.fromJson(response.data);
        return kaynakModel;
      } else {
        log('İstek başarısız: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      log('Hata: $e');
      return null;
    }
  }

  Future<ApiResponse?> sendSiparisData(String userId, {String? kargo, String? kaynak}) async {
    try {
      final response = await dio.post(
        "filter_api.php",
        data: json.encode({
          'user_id': userId,
          'kargo': kargo,
          'kaynak': kaynak,
        }),
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == HttpStatus.ok) {
        if (response.data != null) {
          log("${response.data}");
          final apiResponse = ApiResponse.fromJson(response.data);
          return apiResponse;
        } else {
          throw Exception('Boş veri alındı');
        }
      } else {
        throw Exception('İstek başarısız: ${response.statusCode}');
      }
    } catch (e) {
      print('Hata: $e');
      throw Exception('Bir hata oluştu: $e'); // Hata fırlatılır
    }
  }

  @override
  Future<ApiResponse?> sendSiparisAta(String userId) async {
    try {
      final response = await dio.post(
        "filter_api.php",
        data: json.encode({
          'user_id': userId,
        }),
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
        ),
      );
      if (response.statusCode == HttpStatus.ok) {
        final apiResponse = ApiResponse.fromJson(response.data);
        return apiResponse;
      } else {
        print('İstek başarısız: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Hata: $e');
      return null;
    }
  }

  @override
  Future<Cevap?> fetchUrunler({required String userId, required List<String> siparisIds}) async {
    try {
      final response = await dio.post(
        'barkod_lama.php', // API endpoint'inizi buraya yazın
        data: json.encode({
          'user_id': userId,
          'siparis_ids': siparisIds,
        }),
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        // JSON yanıtını model nesnesine dönüştür
        final urunResponse = Cevap.fromJson(response.data);
        return urunResponse;
      } else {
        print('İstek başarısız: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      log('Hata: $e');
      return null;
    }
  }

  // Sepet ekleme işlemi
  @override
  Future<bool> addSepet(String userId, String sepetBarkod) async {
    try {
      final response = await dio.post(
        'sepet_guncelle_ekle.php',
        data: json.encode({
          'user_id': userId,
          'sepet_barkodu': sepetBarkod,
        }),
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == HttpStatus.ok) {
        final data = response.data as Map<String, dynamic>;
        if (data['status'] == 'success') {
          print('Sepet başarıyla eklendi.');
          return true;
        } else {
          print('Sepet ekleme başarısız: ${data['message']}');
          return false;
        }
      } else {
        print('İstek başarısız: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('Hata: $e');
      return false;
    }
  }

  @override
  Future<bool> cikarSepet(String userId, String sepetBarkod) async {
    try {
      final response = await dio.post(
        'sepet_cikar.php',
        data: json.encode({
          'user_id': userId,
          'sepet_barkodu': sepetBarkod,
        }),
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == HttpStatus.ok) {
        final data = response.data as Map<String, dynamic>;
        if (data['status'] == 'success') {
          print('Sepet başarıyla çıkarıldı.');
          return true;
        } else {
          print('Sepet çıkarma başarısız: ${data['message']}');
          return false;
        }
      } else {
        print('İstek başarısız: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('Hata: $e');
      return false;
    }
  }

  // Kullanıcı çıkış işlemi
  @override
  Future<bool> logout(String userId) async {
    try {
      final response = await dio.post(
        'cikis_yap.php',
        data: json.encode({
          'user_id': userId,
        }),
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == HttpStatus.ok) {
        final data = response.data as Map<String, dynamic>;
        if (data['status'] == 'success') {
          print('Çıkış işlemi başarılı: ${data['message']}');
          return true;
        } else {
          print('Çıkış işlemi başarısız: ${data['message']}');
          return false;
        }
      } else {
        print('İstek başarısız: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('Hata: $e');
      return false;
    }
  }

  Future<bool> postSepetler(List<int> sepetler, String userId) async {
    try {
      final response = await dio.post(
        'sepet_beklemeye_al.php',
        data: json.encode({
          'user_id': userId,
          "sepet_ids": sepetler.join(','),
        }),
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == HttpStatus.ok) {
        final data = response.data as Map<String, dynamic>;
        if (data['status'] == 'success') {
          print('Sepetler başarıyla gönderildi.');
          return true;
        } else {
          print('Sepetler gönderilemedi: ${data['message']}');
          return false;
        }
      } else {
        print('İstek başarısız: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('Hata: $e');
      return false;
    }
  }

  Future<ApiResponse?> bekleyenSiparisFetchh(String userId) async {
    try {
      final response = await dio.post(
        "bekleyen_siparisler.php",
        data: json.encode({
          'user_id': userId,
        }),
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
        ),
      );
      if (response.statusCode == HttpStatus.ok) {
        final apiResponse = ApiResponse.fromJson(response.data);
        return apiResponse;
      } else {
        print('İstek başarısız: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Hata: $e');
      return null;
    }
  }

  @override
  Future<Cevap?> bekleyenSiparisUrunDetay({required String userId, required List<String> siparisIds}) async {
    try {
      final response = await dio.post(
        'bekleyen_siparisle.php', // API endpoint'inizi buraya yazın
        data: json.encode({
          'user_id': userId,
          'siparis_ids': siparisIds,
        }),
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        // JSON yanıtını model nesnesine dönüştür
        final urunResponse = Cevap.fromJson(response.data);
        return urunResponse;
      } else {
        print('İstek başarısız: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      log('Hata: $e');
      return null;
    }
  }

  Future<bool> bekleyenUrunlerTamamlaa(List<String> sepetIds, String userId) async {
    try {
      final response = await dio.post(
        'siparis_tamamla_komple_bekleyen.php',
        data: json.encode({
          'user_id': userId,
          "sepet_ids": sepetIds.join(','),
        }),
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == HttpStatus.ok) {
        final data = response.data as Map<String, dynamic>;
        if (data['status'] == 'success') {
          print('Sepetler başarıyla gönderildi.');
          return true;
        } else {
          print('Sepetler gönderilemedi: ${data['message']}');
          return false;
        }
      } else {
        print('İstek başarısız: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('Hata: $e');
      return false;
    }
  }

  Future<bool> bekleyenUrunlerveSiparislerTamamlaa(List<String> sepetIds, String userId) async {
    try {
      final response = await dio.post(
        'siparis_tamamla_komple.php',
        data: json.encode({
          'user_id': userId,
          "sepet_ids": sepetIds.join(','),
        }),
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == HttpStatus.ok) {
        final data = response.data as Map<String, dynamic>;
        if (data['status'] == 'success') {
          print('Sepetler başarıyla gönderildi.');
          return true;
        } else {
          print('Sepetler gönderilemedi: ${data['message']}');
          return false;
        }
      } else {
        print('İstek başarısız: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('Hata: $e');
      return false;
    }
  }
  // @override
  // Future<SepetResponse?> SepetEkle(String userId, String sepetBarkod) async {
  //   try {
  //     final response = await dio.post(
  //       'sepet_guncelle_ekle.php',
  //       data: json.encode({
  //         'user_id': userId,
  //         'sepet_barkodu': sepetBarkod,
  //       }),
  //     );

  //     if (response.statusCode == 200) {
  //       // JSON yanıtını model nesnesine dönüştür
  //       if(response["status"])
  //     } else {
  //       print('İstek başarısız: ${response.statusCode}');
  //       return null;
  //     }
  //   } catch (e) {
  //     print('Hata: $e');
  //     return null;
  //   }
  // }

  // @override
  // Future<SepetResponse?> SepetCikar(String userId, String sepetBarkod) async {
  //   try {
  //     final response = await dio.post(
  //       'sepet_cikar.php',
  //       data: json.encode({
  //         'user_id': userId,
  //         'sepet_barkodu': sepetBarkod,
  //       }),
  //     );

  //     if (response.statusCode == 200) {
  //       // JSON yanıtını model nesnesine dönüştür
  //       final sepetResponse = SepetResponse.fromJson(response.data);
  //       return sepetResponse;
  //     } else {
  //       print('İstek başarısız: ${response.statusCode}');
  //       return null;
  //     }
  //   } catch (e) {
  //     print('Hata: $e');
  //     return null;
  //   }
  // }
}

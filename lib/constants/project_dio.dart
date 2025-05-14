import 'package:dio/dio.dart';
import 'dart:io';
import 'package:dio/io.dart';

//Bu class bir parametre almaz sadece bu değer kullanılır. diğer classlara with şeklinde eklenir.
mixin ProjectDioMixin {
  final servicePath = Dio(BaseOptions(
    baseUrl: "https://www.kardamiyim.com/wms2/",
    validateStatus: (status) => true,
  ))
    ..httpClientAdapter = IOHttpClientAdapter(
      createHttpClient: () {
        final client = HttpClient();
        client.badCertificateCallback =
            (X509Certificate cert, String host, int port) => true;
        return client;
      },
    );
}

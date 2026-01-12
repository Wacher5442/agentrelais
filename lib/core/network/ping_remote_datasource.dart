import 'dart:developer';

import 'package:dio/dio.dart';

import 'exceptions.dart';

abstract class PingRemoteDataSource {
  Future<bool> pingServer();
}

class PingRemoteDataSourceImpl implements PingRemoteDataSource {
  final Dio dio;

  PingRemoteDataSourceImpl(this.dio);

  @override
  Future<bool> pingServer() async {
    try {
      log('true');
      return true;
      // final response = await dio.get("/ping");

      // if (response.statusCode == 200) {
      //   return true;
      // }
      // throw ServerNotReachableException();
    } catch (_) {
      throw ServerNotReachableException();
    }
  }
}

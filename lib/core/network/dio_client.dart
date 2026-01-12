import 'package:dio/dio.dart';

class DioClient {
  final Dio dio;

  DioClient._internal(this.dio);

  factory DioClient({required String baseUrl, Duration? timeout}) {
    final d = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: timeout ?? const Duration(seconds: 10),
        receiveTimeout: timeout ?? const Duration(seconds: 10),
        sendTimeout: timeout ?? const Duration(seconds: 10),
        responseType: ResponseType.json,
        headers: {'Accept': 'application/json'},
      ),
    );

    d.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          handler.next(options);
        },
        onResponse: (response, handler) {
          handler.next(response);
        },
        onError: (DioException e, handler) async {
          // simple retry once for network-related errors
          if (e.type == DioExceptionType.unknown ||
              e.type == DioExceptionType.connectionTimeout) {
            try {
              final opts = e.requestOptions;
              final clone = await d.request(
                opts.path,
                options: Options(
                  method: opts.method,
                  headers: opts.headers,
                  responseType: opts.responseType,
                ),
                data: opts.data,
                queryParameters: opts.queryParameters,
              );
              return handler.resolve(clone);
            } catch (_) {
              return handler.next(e);
            }
          }
          handler.next(e);
        },
      ),
    );

    return DioClient._internal(d);
  }

  Future<Response> post(
    String path, {
    required dynamic data,
    Options? options,
  }) {
    return dio.post(path, data: data, options: options);
  }

  Future<Response> get(String path, {Map<String, dynamic>? queryParameters}) {
    return dio.get(path, queryParameters: queryParameters);
  }

  Future<Response> put(String path, {required dynamic data, Options? options}) {
    return dio.put(path, data: data, options: options);
  }
}

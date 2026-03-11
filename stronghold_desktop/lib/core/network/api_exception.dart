import 'package:dio/dio.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final List<String> errors;

  ApiException({
    required this.message,
    this.statusCode,
    this.errors = const [],
  });

  factory ApiException.fromDioException(DioException e) {
    if (e.response?.data is Map<String, dynamic>) {
      final data = e.response!.data as Map<String, dynamic>;
      final errors = <String>[];

      if (data['errors'] is List) {
        errors.addAll((data['errors'] as List).map((e) => e.toString()));
      } else if (data['errors'] is String) {
        errors.add(data['errors'] as String);
      }

      return ApiException(
        message: errors.isNotEmpty ? errors.first : 'Doslo je do greske.',
        statusCode: e.response?.statusCode,
        errors: errors,
      );
    }

    return ApiException(
      message: _mapStatusCode(e.response?.statusCode),
      statusCode: e.response?.statusCode,
    );
  }

  static String _mapStatusCode(int? code) {
    switch (code) {
      case 400:
        return 'Neispravan zahtjev.';
      case 401:
        return 'Niste prijavljeni.';
      case 403:
        return 'Nemate pristup.';
      case 404:
        return 'Resurs nije pronadjen.';
      case 409:
        return 'Konflikt podataka.';
      case 500:
        return 'Greska na serveru.';
      default:
        return 'Doslo je do greske.';
    }
  }

  @override
  String toString() => message;
}

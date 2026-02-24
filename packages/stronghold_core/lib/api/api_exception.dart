import 'dart:convert';

/// Custom exception for API errors with structured error information
class ApiException implements Exception {
  final int statusCode;
  final String message;
  final Map<String, dynamic>? errors;

  const ApiException({
    required this.statusCode,
    required this.message,
    this.errors,
  });

  factory ApiException.fromResponse(int statusCode, String body) {
    try {
      final json = jsonDecode(body) as Map<String, dynamic>;
      final parsedErrors = _parseErrors(json);

      return ApiException(
        statusCode: statusCode,
        message: json['error'] as String? ??
                 json['message'] as String? ??
                 json['title'] as String? ??
                 'Error: $statusCode',
        errors: parsedErrors,
      );
    } catch (_) {
      return ApiException(
        statusCode: statusCode,
        message: body.isNotEmpty ? body : 'Error: $statusCode',
      );
    }
  }

  bool get isUnauthorized => statusCode == 401;
  bool get isForbidden => statusCode == 403;
  bool get isNotFound => statusCode == 404;
  bool get isConflict => statusCode == 409;
  bool get isValidationError => statusCode == 400;
  bool get isServerError => statusCode >= 500;
  bool get hasFieldErrors => errors != null && errors!.isNotEmpty;

  /// Get formatted validation errors for display
  String get formattedErrors {
    if (errors == null || errors!.isEmpty) {
      return message;
    }

    final buffer = StringBuffer();
    errors!.forEach((field, errorList) {
      if (errorList is List) {
        for (final error in errorList) {
          buffer.writeln('$error');
        }
      } else if (errorList is String) {
        buffer.writeln('$errorList');
      }
    });

    final result = buffer.toString().trim();
    return result.isNotEmpty ? result : message;
  }

  /// Get errors for a specific field
  List<String> getFieldErrors(String field) {
    if (errors == null) return [];
    final fieldErrors = errors![field];
    if (fieldErrors is List) {
      return fieldErrors.map((e) => e.toString()).toList();
    }
    if (fieldErrors is String) {
      return [fieldErrors];
    }
    return [];
  }

  @override
  String toString() => hasFieldErrors ? formattedErrors : message;

  static Map<String, dynamic>? _parseErrors(Map<String, dynamic> json) {
    final directErrors = json['errors'];
    if (directErrors is Map<String, dynamic>) {
      return directErrors;
    }

    final legacyErrors = json['validationErrors'];
    if (legacyErrors is! List) {
      return null;
    }

    final mapped = <String, List<String>>{};
    for (final item in legacyErrors) {
      if (item is! Map) continue;

      final field = item['field']?.toString();
      final message = item['message']?.toString();
      if (field == null || field.isEmpty || message == null || message.isEmpty) {
        continue;
      }

      mapped.putIfAbsent(field, () => <String>[]).add(message);
    }

    return mapped.isEmpty ? null : mapped;
  }
}

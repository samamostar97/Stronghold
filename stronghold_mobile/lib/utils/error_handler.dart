import 'dart:async';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:stronghold_core/stronghold_core.dart';

/// Centralni error handler za mobilnu aplikaciju.
/// Koristi ApiException iz stronghold_core za parsiranje backend odgovora
/// i dodaje handling za network/timeout/ostale greske.
class ErrorHandler {
  /// Pretvara bilo koji error u user-friendly poruku.
  static String message(dynamic error) {
    // ApiException — backend je vratio strukturiran odgovor
    if (error is ApiException) {
      if (error.hasFieldErrors) {
        return error.formattedErrors;
      }
      return error.message;
    }

    // Network greske
    if (error is SocketException || error is http.ClientException) {
      return 'Problem sa mrezom. Provjerite internet konekciju.';
    }

    // Timeout
    if (error is TimeoutException) {
      return 'Zahtjev je istekao. Pokusajte ponovo.';
    }

    // Sve ostalo
    return 'Doslo je do greske. Pokusajte ponovo.';
  }
}

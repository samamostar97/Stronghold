
/// Utility class that prevents exposing internal implementation details to users
class ErrorHandler {
  /// Converts technical error messages into user-friendly messages
  /// Logs the original error for debugging purposes
  static String getUserFriendlyMessage(dynamic error, {String? context}) {
    final errorString = error.toString().replaceAll('Exception: ', '');

    // Log the actual error for debugging (you can replace print with proper logging)
    print('ERROR [$context]: $errorString');

    // Check for common error patterns and return user-friendly messages

    // Authentication errors
    if (errorString.contains('Unauthorized') ||
        errorString.contains('401') ||
        errorString.contains('login')) {
      return 'Vaša sesija je istekla. Molimo prijavite se ponovo.';
    }

    // Network/connection errors
    if (errorString.contains('SocketException') ||
        errorString.contains('Failed host lookup') ||
        errorString.contains('Network is unreachable')) {
      return 'Problem sa mrežom. Provjerite internet konekciju.';
    }

    // Timeout errors
    if (errorString.contains('TimeoutException') ||
        errorString.contains('timed out')) {
      return 'Zahtjev je istekao. Pokušajte ponovo.';
    }

    // Validation errors (400)
    if (errorString.contains('400') || errorString.contains('Bad Request')) {
      return 'Neispravni podaci. Provjerite unos i pokušajte ponovo.';
    }

    // Already exists (409)
    if (errorString.contains('409') ||
        errorString.contains('already exists') ||
        errorString.contains('duplicate')) {
      return 'Ovaj unos već postoji u sistemu.';
    }

    // Not found (404)
    if (errorString.contains('404') || errorString.contains('Not Found')) {
      return 'Traženi resurs nije pronađen.';
    }

    // Permission denied (403)
    if (errorString.contains('403') || errorString.contains('Forbidden')) {
      return 'Nemate dozvolu za ovu akciju.';
    }

    // Server errors (500)
    if (errorString.contains('500') ||
        errorString.contains('Internal Server Error') ||
        errorString.contains('Server Error')) {
      return 'Greška na serveru. Pokušajte ponovo kasnije.';
    }

    // Format errors
    if (errorString.contains('FormatException') ||
        errorString.contains('JSON')) {
      return 'Greška u obradi podataka. Kontaktirajte podršku.';
    }

    // return a generic message
    return 'Došlo je do greške. Molimo pokušajte ponovo.';
  }

  /// Returns a context-specific error message
  static String getContextualMessage(dynamic error, String operation) {
    final errorString = error.toString().replaceAll('Exception: ', '');

    // Log the actual error
    print('ERROR [$operation]: $errorString');

    // Try to extract validation errors from the response body
    final validationError = _extractValidationError(errorString);
    if (validationError != null) {
      return validationError;
    }

    // Check if this is a user-friendly validation message (no status codes, no technical jargon)
    // If backend sends a clear message, show it to the user
    if (_isUserFriendlyMessage(errorString)) {
      return errorString;
    }

    // Map operations to user-friendly messages
    final Map<String, String> operationMessages = {
      'check-in': 'Prijava korisnika nije uspjela.',
      'check-out': 'Odjava korisnika nije uspjela.',
      'add-user': 'Dodavanje korisnika nije uspjelo.',
      'edit-user': 'Izmjena korisnika nije uspjela.',
      'delete-user': 'Brisanje korisnika nije uspjelo.',
      'add-payment': 'Dodavanje uplate nije uspjelo.',
      'revoke-membership': 'Ukidanje članarine nije uspjelo.',
      'load-users': 'Učitavanje korisnika nije uspjelo.',
      'add-package': 'Dodavanje paketa nije uspjelo.',
      'edit-package': 'Izmjena paketa nije uspjela.',
      'delete-package': 'Brisanje paketa nije uspjelo.',
      'add-supplement': 'Dodavanje suplementa nije uspjelo.',
      'edit-supplement': 'Izmjena suplementa nije uspjela.',
      'delete-supplement': 'Brisanje suplementa nije uspjelo.',
      'create-supplier': 'Dodavanje dobavljača nije uspjelo.',
      'update-supplier': 'Izmjena dobavljača nije uspjela.',
      'delete-supplier': 'Brisanje dobavljača nije uspjelo.',
    };

    // Check for specific error types and provide more context
    if (errorString.toLowerCase().contains('already')) {
      if (operation == 'check-in') {
        return 'Korisnik je već prijavljen u teretanu.';
      }
      return errorString;
    }

    if (errorString.contains('not found') || errorString.contains('404')) {
      return 'Korisnik nije pronađen u sistemu.';
    }

    if (errorString.contains('401') || errorString.contains('Unauthorized')) {
      return 'Nemate pristup. Molimo prijavite se ponovo.';
    }

    // Return the operation-specific message or a generic one
    return operationMessages[operation] ?? 'Operacija nije uspjela.';
  }

  /// Extracts validation error messages from error response
  static String? _extractValidationError(String errorString) {
    // Check for validation errors (400 status)
    if (!errorString.contains('400')) {
      return null;
    }

    // Common validation error patterns
    final patterns = [
      // Pattern: "Name" must be at least X characters
      RegExp(r'"?(\w+)"?\s+must be at least (\d+) characters?', caseSensitive: false),
      // Pattern: "Name" is too short (minimum X characters)
      RegExp(r'"?(\w+)"?\s+is too short.*?minimum[:\s]+(\d+)', caseSensitive: false),
      // Pattern: Field must not be empty
      RegExp(r'"?(\w+)"?\s+(must not be empty|is required)', caseSensitive: false),
      // Pattern: Invalid format
      RegExp(r'"?(\w+)"?\s+has invalid format', caseSensitive: false),
      // Pattern: Value is too long
      RegExp(r'"?(\w+)"?\s+must be at most (\d+) characters?', caseSensitive: false),
    ];

    for (var pattern in patterns) {
      final match = pattern.firstMatch(errorString);
      if (match != null) {
        final fieldName = match.group(1);

        // Map field names to Croatian
        final fieldTranslations = {
          'name': 'Naziv',
          'username': 'Korisničko ime',
          'email': 'Email',
          'password': 'Lozinka',
          'phone': 'Broj telefona',
          'phonenumber': 'Broj telefona',
          'website': 'Web stranica',
          'description': 'Opis',
        };

        final translatedField = fieldTranslations[fieldName?.toLowerCase()] ?? fieldName;

        // Build appropriate message
        if (match.group(2) != null) {
          final number = match.group(2);
          if (errorString.toLowerCase().contains('at least') ||
              errorString.toLowerCase().contains('too short')) {
            return '$translatedField mora imati najmanje $number znakova.';
          } else if (errorString.toLowerCase().contains('at most')) {
            return '$translatedField može imati maksimalno $number znakova.';
          }
        } else if (errorString.toLowerCase().contains('empty') ||
                   errorString.toLowerCase().contains('required')) {
          return '$translatedField je obavezno polje.';
        } else if (errorString.toLowerCase().contains('invalid')) {
          return '$translatedField ima neispravan format.';
        }
      }
    }

    // If it's a 400 error but we couldn't parse it, return a generic validation message
    return 'Provjerite unesene podatke i pokušajte ponovo.';
  }

  /// Checks if an error message is safe to show to users
  /// User-friendly messages don't contain status codes, stack traces, or technical jargon
  static bool _isUserFriendlyMessage(String message) {
    // Check if message contains technical indicators
    final technicalIndicators = [
      RegExp(r'\d{3}'), // HTTP status codes (400, 404, 500, etc.)
      RegExp(r'Exception'),
      RegExp(r'Error:'),
      RegExp(r'Stack trace'),
      RegExp(r'at \w+\.\w+'), // Stack trace patterns
      RegExp(r'Failed to'),
      RegExp(r'Unable to'),
      RegExp(r'JSON'),
      RegExp(r'Socket'),
      RegExp(r'Timeout'),
      RegExp(r'Connection'),
    ];

    for (var indicator in technicalIndicators) {
      if (indicator.hasMatch(message)) {
        return false; // Contains technical details
      }
    }

    // If message is reasonably short and doesn't contain technical stuff, it's user-friendly
    return message.length < 200;
  }
}

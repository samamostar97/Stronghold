import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/appointment_models.dart';
import 'token_storage.dart';

class AppointmentService {
  static Future<List<Appointment>> getAppointments() async {
    final token = await TokenStorage.getToken();
    if (token == null) {
      throw Exception('Niste prijavljeni');
    }

    final response = await http.get(
      ApiConfig.uri('/api/user/appointment'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body) as List<dynamic>;
      return data
          .map((json) => Appointment.fromJson(json as Map<String, dynamic>))
          .toList();
    } else if (response.statusCode == 401) {
      throw Exception('Sesija je istekla. Prijavite se ponovo.');
    } else {
      throw Exception('Greska prilikom ucitavanja termina');
    }
  }

  static Future<List<Trainer>> getTrainers() async {
    final token = await TokenStorage.getToken();
    if (token == null) {
      throw Exception('Niste prijavljeni');
    }

    final response = await http.get(
      ApiConfig.uri('/api/user/appointment/get-trainer-list'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body) as List<dynamic>;
      return data
          .map((json) => Trainer.fromJson(json as Map<String, dynamic>))
          .toList();
    } else if (response.statusCode == 401) {
      throw Exception('Sesija je istekla. Prijavite se ponovo.');
    } else {
      throw Exception('Greska prilikom ucitavanja trenera');
    }
  }

  static Future<List<Nutritionist>> getNutritionists() async {
    final token = await TokenStorage.getToken();
    if (token == null) {
      throw Exception('Niste prijavljeni');
    }

    final response = await http.get(
      ApiConfig.uri('/api/user/appointment/get-nutritionist-list'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body) as List<dynamic>;
      return data
          .map((json) => Nutritionist.fromJson(json as Map<String, dynamic>))
          .toList();
    } else if (response.statusCode == 401) {
      throw Exception('Sesija je istekla. Prijavite se ponovo.');
    } else {
      throw Exception('Greska prilikom ucitavanja nutricionista');
    }
  }

  static Future<void> makeTrainerAppointment(int staffId, DateTime date) async {
    final token = await TokenStorage.getToken();
    if (token == null) {
      throw Exception('Niste prijavljeni');
    }

    final response = await http.post(
      ApiConfig.uri('/api/user/appointment/make-training-appointment'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'staffId': staffId,
        'appointmentDate': date.toIso8601String(),
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return;
    } else if (response.statusCode == 401) {
      throw Exception('Sesija je istekla. Prijavite se ponovo.');
    } else if (response.statusCode == 409) {
      final body = jsonDecode(response.body);
      throw Exception(body['error'] ?? 'Vec imate zakazan termin za taj dan');
    }else if (response.statusCode ==400){
      final body = jsonDecode(response.body);
      throw Exception(body['error'] ?? 'Trener nije dostupan u odabranom terminu');
    }
     else {
      throw Exception('Greska prilikom zakazivanja termina');
    }
  }

  static Future<void> makeNutritionistAppointment(int staffId, DateTime date) async {
    final token = await TokenStorage.getToken();
    if (token == null) {
      throw Exception('Niste prijavljeni');
    }

    final response = await http.post(
      ApiConfig.uri('/api/user/appointment/make-nutritionist-appointment'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'staffId': staffId,
        'appointmentDate': date.toIso8601String(),
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return;
    } else if (response.statusCode == 401) {
      throw Exception('Sesija je istekla. Prijavite se ponovo.');
    } else if (response.statusCode == 409) {
      final body = jsonDecode(response.body);
      throw Exception(body['error'] ?? 'Vec imate zakazan termin za taj dan');
    } else if (response.statusCode ==400){
      final body = jsonDecode(response.body);
      throw Exception(body['error'] ?? 'Nutricionist nije dostupan u odabranom terminu');
    }
    else {
      throw Exception('Greska prilikom zakazivanja termina');
    }
  }

  static Future<List<int>> getAvailableHours(int staffId, DateTime date, bool isTrainer) async {
    final token = await TokenStorage.getToken();
    if (token == null) {
      throw Exception('Niste prijavljeni');
    }

    final queryString = 'staffId=$staffId&date=${Uri.encodeComponent(date.toIso8601String())}&isTrainer=$isTrainer';

    final response = await http.get(
      ApiConfig.uri('/api/user/appointment/available-hours?$queryString'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body) as List<dynamic>;
      return data.map((e) => e as int).toList();
    } else if (response.statusCode == 401) {
      throw Exception('Sesija je istekla. Prijavite se ponovo.');
    } else {
      throw Exception('Greska prilikom ucitavanja dostupnih termina');
    }
  }

  static Future<void> cancelAppointment(int appointmentId) async {
    final token = await TokenStorage.getToken();
    if (token == null) {
      throw Exception('Niste prijavljeni');
    }

    final response = await http.delete(
      ApiConfig.uri('/api/user/appointment/$appointmentId'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 204) {
      return;
    } else if (response.statusCode == 401) {
      throw Exception('Sesija je istekla. Prijavite se ponovo.');
    } else if (response.statusCode == 404) {
      throw Exception('Termin ne postoji');
    } else if (response.statusCode == 400) {
      final body = jsonDecode(response.body);
      throw Exception(body['error'] ?? 'Nemoguce otkazati termin');
    } else {
      throw Exception('Greska prilikom otkazivanja termina');
    }
  }
}

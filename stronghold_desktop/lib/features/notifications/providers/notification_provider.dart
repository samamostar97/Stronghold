import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';

final unreadCountProvider = FutureProvider<int>((ref) async {
  try {
    final response =
        await ApiClient.instance.get('/notifications/unread-count');
    return response.data['count'] as int? ?? 0;
  } on DioException {
    return 0;
  }
});

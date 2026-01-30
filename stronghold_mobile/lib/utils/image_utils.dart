import '../config/api_config.dart';

String getFullImageUrl(String? imageUrl) {
  if (imageUrl == null || imageUrl.isEmpty) return '';
  if (imageUrl.startsWith('http')) return imageUrl;
  return '${ApiConfig.baseUrl}$imageUrl';
}

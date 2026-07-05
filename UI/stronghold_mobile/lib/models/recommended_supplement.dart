import 'supplement.dart';

/// Preporuceni proizvod sa objasnjenjem zasto se preporucuje.
class RecommendedSupplement {
  final Supplement supplement;
  final String reason;

  RecommendedSupplement({required this.supplement, required this.reason});

  factory RecommendedSupplement.fromJson(Map<String, dynamic> json) =>
      RecommendedSupplement(
        supplement:
            Supplement.fromJson(json['supplement'] as Map<String, dynamic>),
        reason: json['reason'] as String,
      );
}

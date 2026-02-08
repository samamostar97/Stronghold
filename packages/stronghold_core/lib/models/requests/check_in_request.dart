/// Request to check in a user
class CheckInRequest {
  final int userId;

  const CheckInRequest({required this.userId});

  Map<String, dynamic> toJson() => {'userId': userId};
}

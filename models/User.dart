import 'package:json_annotation/json_annotation.dart';

@JsonSerializable(explicitToJson: true)
class User {
  User(
      {required this.userId,
      required this.accessToken,
      required this.refreshToken,
      required this.appRole});

  final String userId;
  final String accessToken;
  final String refreshToken;
  final int appRole;
}

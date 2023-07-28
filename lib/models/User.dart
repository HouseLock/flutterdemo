import 'package:json_annotation/json_annotation.dart';

@JsonSerializable(explicitToJson: true)
class User {
  String userId;
  String accessToken;
  String refreshToken;
  String name;
  String surname;
  String email;
  int appRole;

  User({
    this.userId = '',
    this.accessToken = '',
    this.refreshToken = '',
    this.name = '',
    this.surname = '',
    this.email = '',
    this.appRole = 0,
  });

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'accessToken': accessToken,
      'refreshToken': refreshToken,
      'name': name,
      'surname': surname,
      'email': email,
      'appRole': appRole,
    };
  }
}

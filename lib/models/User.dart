import 'package:json_annotation/json_annotation.dart';

@JsonSerializable(explicitToJson: true)
class User {
  String userId;
  String accessToken;
  String refreshToken;
  String name;
  String surname;
  String email;
  String password;
  int appRole;
  String businessName;
  String pec;
  String taxIDCode;
  String vatNumber;
  String sdi;

  User({
    this.userId = '',
    this.accessToken = '',
    this.refreshToken = '',
    this.name = '',
    this.surname = '',
    this.email = '',
    this.password = '',
    this.appRole = 0,
    this.businessName = '',
    this.pec = '',
    this.taxIDCode = '',
    this.vatNumber = '',
    this.sdi = '',
  });

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'accessToken': accessToken,
      'refreshToken': refreshToken,
      'name': name,
      'surname': surname,
      'email': email,
      'password': password,
      'appRole': appRole,
      'businessName': businessName,
      'pec': pec,
      'taxIDCode': taxIDCode,
      'vatNumber': vatNumber,
      'sdi': sdi,
    };
  }
}

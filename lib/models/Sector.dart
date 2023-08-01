import 'package:json_annotation/json_annotation.dart';

@JsonSerializable(explicitToJson: true)
class Sector {
  String sectorId;
  String sectorCode;
  String sectorDescription;

  Sector({
    this.sectorId = '',
    this.sectorCode = '',
    this.sectorDescription = '',
  });

  Map<String, dynamic> toJson() {
    return {
      'sectorId': sectorId,
      'sectorCode': sectorCode,
      'sectorDescription': sectorDescription,
    };
  }
}

class KopoModel {
  final String address;
  final String buildingName;
  final String zonecode;
  final String roadAddress;
  final String jibunAddress;

  KopoModel({
    required this.address,
    this.buildingName = '',
    this.zonecode = '',
    this.roadAddress = '', 
    this.jibunAddress = '',
  });
} 
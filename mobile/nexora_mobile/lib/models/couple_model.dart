class PartnerModel {
  final String id;
  final String email;
  final String fullName;

  PartnerModel({
    required this.id,
    required this.email,
    required this.fullName,
  });

  factory PartnerModel.fromJson(Map<String, dynamic> json) {
    return PartnerModel(
      id: json['id'] as String,
      email: json['email'] as String,
      fullName: json['fullName'] as String,
    );
  }
}

class CoupleModel {
  final String id;
  final String partner1Id;
  final String partner2Id;
  final int status;
  final DateTime connectedAtUtc;
  final PartnerModel partner;

  CoupleModel({
    required this.id,
    required this.partner1Id,
    required this.partner2Id,
    required this.status,
    required this.connectedAtUtc,
    required this.partner,
  });

  factory CoupleModel.fromJson(Map<String, dynamic> json) {
    return CoupleModel(
      id: json['id'] as String,
      partner1Id: json['partner1Id'] as String,
      partner2Id: json['partner2Id'] as String,
      status: json['status'] as int,
      connectedAtUtc: DateTime.parse(json['connectedAtUtc'] as String),
      partner: PartnerModel.fromJson(json['partner'] as Map<String, dynamic>),
    );
  }
}

class CoupleInvitationModel {
  final String id;
  final String invitationCode;
  final int status;
  final DateTime expiresAtUtc;
  final DateTime createdAtUtc;

  CoupleInvitationModel({
    required this.id,
    required this.invitationCode,
    required this.status,
    required this.expiresAtUtc,
    required this.createdAtUtc,
  });

  factory CoupleInvitationModel.fromJson(Map<String, dynamic> json) {
    return CoupleInvitationModel(
      id: json['id'] as String,
      invitationCode: json['invitationCode'] as String,
      status: json['status'] as int,
      expiresAtUtc: DateTime.parse(json['expiresAtUtc'] as String),
      createdAtUtc: DateTime.parse(json['createdAtUtc'] as String),
    );
  }
}

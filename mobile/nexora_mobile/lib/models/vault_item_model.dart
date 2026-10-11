class VaultItemModel {
  final String id;
  final String ownerId;
  final String? coupleId;
  final String title;
  final String? description;
  final int itemType;
  final String encryptedPayload;
  final String? tags;
  final int visibility;
  final DateTime createdAtUtc;
  final DateTime updatedAtUtc;

  VaultItemModel({
    required this.id,
    required this.ownerId,
    this.coupleId,
    required this.title,
    this.description,
    required this.itemType,
    required this.encryptedPayload,
    this.tags,
    required this.visibility,
    required this.createdAtUtc,
    required this.updatedAtUtc,
  });

  factory VaultItemModel.fromJson(Map<String, dynamic> json) {
    return VaultItemModel(
      id: json['id'] as String,
      ownerId: json['ownerId'] as String,
      coupleId: json['coupleId'] as String?,
      title: json['title'] as String,
      description: json['description'] as String?,
      itemType: json['itemType'] as int,
      encryptedPayload: json['encryptedPayload'] as String,
      tags: json['tags'] as String?,
      visibility: json['visibility'] as int,
      createdAtUtc: DateTime.parse(json['createdAtUtc'] as String),
      updatedAtUtc: DateTime.parse(json['updatedAtUtc'] as String),
    );
  }
}

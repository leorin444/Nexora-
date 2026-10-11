class ChatMessageModel {
  final String id;
  final String coupleId;
  final String senderId;
  final String content;
  final String? attachmentUrl;
  final String? attachmentType;
  final int deliveryStatus;
  final DateTime sentAtUtc;
  final DateTime? readAtUtc;

  ChatMessageModel({
    required this.id,
    required this.coupleId,
    required this.senderId,
    required this.content,
    this.attachmentUrl,
    this.attachmentType,
    required this.deliveryStatus,
    required this.sentAtUtc,
    this.readAtUtc,
  });

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    return ChatMessageModel(
      id: json['id'] as String,
      coupleId: json['coupleId'] as String,
      senderId: json['senderId'] as String,
      content: json['content'] as String,
      attachmentUrl: json['attachmentUrl'] as String?,
      attachmentType: json['attachmentType'] as String?,
      deliveryStatus: json['deliveryStatus'] as int,
      sentAtUtc: DateTime.parse(json['sentAtUtc'] as String),
      readAtUtc: json['readAtUtc'] != null ? DateTime.parse(json['readAtUtc'] as String) : null,
    );
  }
}

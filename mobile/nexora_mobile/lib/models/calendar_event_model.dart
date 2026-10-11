class CalendarEventModel {
  final String id;
  final String ownerId;
  final String? coupleId;
  final String title;
  final String? description;
  final String? location;
  final DateTime startTimeUtc;
  final DateTime endTimeUtc;
  final bool isAllDay;
  final int visibility;

  CalendarEventModel({
    required this.id,
    required this.ownerId,
    this.coupleId,
    required this.title,
    this.description,
    this.location,
    required this.startTimeUtc,
    required this.endTimeUtc,
    required this.isAllDay,
    required this.visibility,
  });

  factory CalendarEventModel.fromJson(Map<String, dynamic> json) {
    return CalendarEventModel(
      id: json['id'] as String,
      ownerId: json['ownerId'] as String,
      coupleId: json['coupleId'] as String?,
      title: json['title'] as String,
      description: json['description'] as String?,
      location: json['location'] as String?,
      startTimeUtc: DateTime.parse(json['startTimeUtc'] as String),
      endTimeUtc: DateTime.parse(json['endTimeUtc'] as String),
      isAllDay: json['isAllDay'] as bool,
      visibility: json['visibility'] as int,
    );
  }
}

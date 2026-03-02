class Report {
  final String id;
  final String binId;
  final String userId;
  final ReportType type;
  final String description;
  final List<String> imageUrls;
  final ReportStatus status;
  final DateTime createdAt;
  final DateTime? resolvedAt;

  Report({
    required this.id,
    required this.binId,
    required this.userId,
    required this.type,
    required this.description,
    required this.imageUrls,
    required this.status,
    required this.createdAt,
    this.resolvedAt,
  });

  factory Report.fromJson(Map<String, dynamic> json) {
    return Report(
      id: json['id'] as String,
      binId: json['bin_id'] as String,
      userId: json['user_id'] as String,
      type: ReportType.fromString(json['type'] as String),
      description: json['description'] as String,
      imageUrls: List<String>.from(json['image_urls'] as List),
      status: ReportStatus.fromString(json['status'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
      resolvedAt: json['resolved_at'] != null
          ? DateTime.parse(json['resolved_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bin_id': binId,
      'user_id': userId,
      'type': type.value,
      'description': description,
      'image_urls': imageUrls,
      'status': status.value,
      'created_at': createdAt.toIso8601String(),
      'resolved_at': resolvedAt?.toIso8601String(),
    };
  }

  Report copyWith({
    String? id,
    String? binId,
    String? userId,
    ReportType? type,
    String? description,
    List<String>? imageUrls,
    ReportStatus? status,
    DateTime? createdAt,
    DateTime? resolvedAt,
  }) {
    return Report(
      id: id ?? this.id,
      binId: binId ?? this.binId,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      description: description ?? this.description,
      imageUrls: imageUrls ?? this.imageUrls,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      resolvedAt: resolvedAt ?? this.resolvedAt,
    );
  }
}

enum ReportType {
  full('full'),
  damaged('damaged'),
  missing('missing'),
  overflow('overflow'),
  badOdor('bad_odor'),
  other('other');

  final String value;
  const ReportType(this.value);

  static ReportType fromString(String value) {
    return ReportType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => ReportType.other,
    );
  }

  String get displayName {
    switch (this) {
      case ReportType.full:
        return 'ถังขยะเต็ม';
      case ReportType.damaged:
        return 'ถังขยะชำรุด';
      case ReportType.missing:
        return 'ไม่พบถังขยะ';
      case ReportType.overflow:
        return 'ขยะล้น';
      case ReportType.badOdor:
        return 'มีกลิ่นเหม็น';
      case ReportType.other:
        return 'อื่นๆ';
    }
  }
}

enum ReportStatus {
  pending('pending'),
  inProgress('in_progress'),
  resolved('resolved'),
  rejected('rejected');

  final String value;
  const ReportStatus(this.value);

  static ReportStatus fromString(String value) {
    return ReportStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => ReportStatus.pending,
    );
  }

  String get displayName {
    switch (this) {
      case ReportStatus.pending:
        return 'รอดำเนินการ';
      case ReportStatus.inProgress:
        return 'กำลังดำเนินการ';
      case ReportStatus.resolved:
        return 'ดำเนินการเสร็จสิ้น';
      case ReportStatus.rejected:
        return 'ปฏิเสธ';
    }
  }
}

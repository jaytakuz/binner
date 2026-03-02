class Bin {
  final String id;
  final String name;
  final String location;
  final double latitude;
  final double longitude;
  final String binType; // green, yellow, red, blue, orange
  final BinStatus status;
  final String? description;
  final String? imageUrl;
  final int capacity;
  final DateTime createdAt;
  final DateTime updatedAt;

  Bin({
    required this.id,
    required this.name,
    required this.location,
    required this.latitude,
    required this.longitude,
    required this.binType,
    required this.status,
    this.description,
    this.imageUrl,
    required this.capacity,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Bin.fromJson(Map<String, dynamic> json) {
    return Bin(
      id: json['id'] as String,
      name: json['name'] as String,
      location: json['location'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      binType: json['bin_type'] as String,
      status: BinStatus.fromString(json['status'] as String),
      description: json['description'] as String?,
      imageUrl: json['image_url'] as String?,
      capacity: json['capacity'] as int,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'location': location,
      'latitude': latitude,
      'longitude': longitude,
      'bin_type': binType,
      'status': status.value,
      'description': description,
      'image_url': imageUrl,
      'capacity': capacity,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Bin copyWith({
    String? id,
    String? name,
    String? location,
    double? latitude,
    double? longitude,
    String? binType,
    BinStatus? status,
    String? description,
    String? imageUrl,
    int? capacity,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Bin(
      id: id ?? this.id,
      name: name ?? this.name,
      location: location ?? this.location,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      binType: binType ?? this.binType,
      status: status ?? this.status,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      capacity: capacity ?? this.capacity,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

enum BinStatus {
  available('available'),
  halfFull('half_full'),
  almostFull('almost_full'),
  full('full'),
  maintenance('maintenance'),
  damaged('damaged');

  final String value;
  const BinStatus(this.value);

  static BinStatus fromString(String value) {
    return BinStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => BinStatus.available,
    );
  }

  String get displayName {
    switch (this) {
      case BinStatus.available:
        return 'ว่าง';
      case BinStatus.halfFull:
        return 'เต็มครึ่ง';
      case BinStatus.almostFull:
        return 'เกือบเต็ม';
      case BinStatus.full:
        return 'เต็มแล้ว';
      case BinStatus.maintenance:
        return 'ซ่อมบำรุง';
      case BinStatus.damaged:
        return 'ชำรุด';
    }
  }
}

class Bin {
  final String id;
  final String name;
  final String location;
  final double latitude;
  final double longitude;
  final String binType; // green, yellow, red, blue, orange
  final String? description;
  final String? imageUrl;
  final String? addedById;
  final String addedByName;
  final DateTime createdAt;
  final DateTime updatedAt;

  Bin({
    required this.id,
    required this.name,
    required this.location,
    required this.latitude,
    required this.longitude,
    required this.binType,
    this.description,
    this.imageUrl,
    this.addedById,
    required this.addedByName,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Bin.fromJson(Map<String, dynamic> json) {
    final createdAtString = json['created_at'] as String?;
    final updatedAtString = json['updated_at'] as String?;
    return Bin(
      id: json['id'] as String,
      name: json['name'] as String,
      location: json['location'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      binType: json['bin_type'] as String,
      description: json['description'] as String?,
      imageUrl: json['image_url'] as String?,
      addedById: json['added_by_id'] as String?,
      addedByName: (json['added_by_name'] ?? 'Unknown') as String,
      createdAt: createdAtString != null
          ? DateTime.parse(createdAtString)
          : DateTime.now(),
      updatedAt: updatedAtString != null
          ? DateTime.parse(updatedAtString)
          : DateTime.now(),
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
      'description': description,
      'image_url': imageUrl,
      'added_by_id': addedById,
      'added_by_name': addedByName,
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
    String? description,
    String? imageUrl,
    String? addedById,
    String? addedByName,
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
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      addedById: addedById ?? this.addedById,
      addedByName: addedByName ?? this.addedByName,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

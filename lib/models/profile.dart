class Profile {
  final String id;
  final String? name;
  final String? phoneNumber;
  final String? role;
  final bool? isActive;
  final String? imageUrl;

  Profile({
    required this.id,
    this.name,
    this.phoneNumber,
    this.role,
    this.isActive = true,
    this.imageUrl,
  });

  factory Profile.fromJson(Map<String, dynamic> json) => Profile(
        id: json['id'],
        name: json['name'],
        phoneNumber: json['phone_number'],
        role: json['role'],
        isActive: json['is_active'] ?? true,
        imageUrl: json['image_url'],
      );

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'phone_number': phoneNumber,
      'role': role,
      'is_active': isActive,
      'image_url': imageUrl,
    };
  }

  Profile copyWith({
    String? id,
    String? name,
    String? phoneNumber,
    String? role,
    bool? isActive,
    String? imageUrl,
  }) {
    return Profile(
      id: id ?? this.id,
      name: name ?? this.name,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      role: role ?? this.role,
      isActive: isActive ?? this.isActive,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }

  @override
  String toString() {
    return 'Profile(id: $id, name: $name, phoneNumber: $phoneNumber, role: $role, isActive: $isActive, imageUrl: $imageUrl)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is Profile &&
      other.id == id &&
      other.name == name &&
      other.phoneNumber == phoneNumber &&
      other.role == role &&
      other.isActive == isActive &&
      other.imageUrl == imageUrl;
  }

  @override
  int get hashCode {
    return id.hashCode ^
      name.hashCode ^
      phoneNumber.hashCode ^
      role.hashCode ^
      isActive.hashCode ^
      imageUrl.hashCode;
  }
}
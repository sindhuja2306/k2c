enum UserRole {
  customer,
  admin,
}

class UserModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String address;
  final UserRole role;
  final String? profileImage;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.address,
    this.role = UserRole.customer,
    this.profileImage,
  });

  bool get isAdmin => role == UserRole.admin;
  bool get isCustomer => role == UserRole.customer;

  // From JSON
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      address: json['address'] ?? '',
      role: UserRole.values.firstWhere(
        (e) => e.toString() == 'UserRole.${json['role']}',
        orElse: () => UserRole.customer,
      ),
      profileImage: json['profileImage'],
    );
  }

  // To JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'address': address,
      'role': role.toString().split('.').last,
      'profileImage': profileImage,
    };
  }

  // Copy With
  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? address,
    UserRole? role,
    String? profileImage,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      role: role ?? this.role,
      profileImage: profileImage ?? this.profileImage,
    );
  }
}

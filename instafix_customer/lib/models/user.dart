class User {
  final int id;
  final String name;
  final String phone;
  final String? email;
  final String role; // 'customer', 'technician', 'admin'
  final String? shopName;
  final String? skills;
  final String? address;
  final String? profileImage;
  final String? token;

  User({
    required this.id,
    required this.name,
    required this.phone,
    this.email,
    required this.role,
    this.shopName,
    this.skills,
    this.address,
    this.profileImage,
    this.token,
  });

  factory User.fromJson(Map<String, dynamic> json, {String? token}) {
    return User(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      name: json['name'] ?? 'User',
      phone: json['phone'] ?? '',
      email: json['email'],
      role: json['role'] ?? 'customer',
      shopName: json['shop_name'],
      skills: json['skills'],
      address: json['address'],
      profileImage: json['profile_image'],
      token: token ?? json['token'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'email': email,
      'role': role,
      'shop_name': shopName,
      'skills': skills,
      'address': address,
      'profile_image': profileImage,
      'token': token,
    };
  }

  bool get isTechnician => role == 'technician';
  bool get isCustomer => role == 'customer';
  bool get isAdmin => role == 'admin';
}

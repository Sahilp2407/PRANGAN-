import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String name;
  final String phone;
  final String? email;
  final String flatNumber;
  final String block; // Wing / Tower
  final String status; // 'pending', 'approved', 'rejected'
  final String role; // 'admin', 'member'
  final String? societyId;
  final DateTime joinedAt;

  UserModel({
    required this.uid,
    required this.name,
    required this.phone,
    this.email,
    required this.flatNumber,
    required this.block,
    required this.status,
    required this.role,
    this.societyId,
    required this.joinedAt,
  });

  bool get isApproved => status == 'approved';
  bool get isPending => status == 'pending';
  bool get isAdmin => role == 'admin';

  String get flatDisplay => block.isNotEmpty ? '$block-$flatNumber' : flatNumber;

  factory UserModel.fromMap(Map<String, dynamic> data, String uid) {
    return UserModel(
      uid: uid,
      name: data['name'] ?? '',
      phone: data['phone'] ?? '',
      email: data['email'],
      flatNumber: data['flatNumber'] ?? '',
      block: data['block'] ?? '',
      status: data['status'] ?? 'pending',
      role: data['role'] ?? 'member',
      societyId: data['societyId'],
      joinedAt: (data['joinedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'phone': phone,
      'email': email,
      'flatNumber': flatNumber,
      'block': block,
      'status': status,
      'role': role,
      'societyId': societyId,
      'joinedAt': Timestamp.fromDate(joinedAt),
    };
  }

  UserModel copyWith({
    String? name,
    String? phone,
    String? email,
    String? flatNumber,
    String? block,
    String? status,
    String? role,
    String? societyId,
    DateTime? joinedAt,
  }) {
    return UserModel(
      uid: uid,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      flatNumber: flatNumber ?? this.flatNumber,
      block: block ?? this.block,
      status: status ?? this.status,
      role: role ?? this.role,
      societyId: societyId ?? this.societyId,
      joinedAt: joinedAt ?? this.joinedAt,
    );
  }
}

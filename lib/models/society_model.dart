import 'package:cloud_firestore/cloud_firestore.dart';

class SocietyModel {
  final String id;
  final String name;
  final String address;
  final String sector;
  final String joinCode;
  final String adminUid;
  final String? logoUrl;
  final int totalFlats;
  final int wingsCount;
  final DateTime createdAt;

  SocietyModel({
    required this.id,
    required this.name,
    required this.address,
    required this.sector,
    required this.joinCode,
    required this.adminUid,
    this.logoUrl,
    required this.totalFlats,
    this.wingsCount = 1,
    required this.createdAt,
  });

  String get fullAddress => address.isNotEmpty ? '$address, $sector, Kharghar' : '$sector, Kharghar';

  factory SocietyModel.fromMap(Map<String, dynamic> data, String id) {
    return SocietyModel(
      id: id,
      name: data['name'] ?? '',
      address: data['address'] ?? '',
      sector: data['sector'] ?? 'Sector 20',
      joinCode: data['joinCode'] ?? '',
      adminUid: data['adminUid'] ?? '',
      logoUrl: data['logoUrl'],
      totalFlats: (data['totalFlats'] as num?)?.toInt() ?? 0,
      wingsCount: (data['wingsCount'] as num?)?.toInt() ?? 1,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'address': address,
      'sector': sector,
      'joinCode': joinCode,
      'adminUid': adminUid,
      'logoUrl': logoUrl,
      'totalFlats': totalFlats,
      'wingsCount': wingsCount,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}

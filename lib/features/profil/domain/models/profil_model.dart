import 'package:pulse/core/common/entities/profil.dart';

class ProfilModel extends Profil {
  ProfilModel({
    required super.uid,
    required super.email,
    required super.lastName,
    required super.firstName,
    required super.birthDate,
    required super.profilePhoto,
  });

  factory ProfilModel.fromJson(Map<String, dynamic> map) {
    return ProfilModel(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      lastName: map['last_name'] ?? '',
      firstName: map['first_name'] ?? '',
      birthDate: DateTime.parse(map['birth_date']),
      profilePhoto: map['profile_photo'] ?? '',
    );
  }

  static List<ProfilModel> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((json) => ProfilModel.fromJson(json)).toList();
  }

  ProfilModel copyWith({
    String? uid,
    String? email,
    String? lastName,
    String? firstName,
    DateTime? birthDate,
    String? profilePhoto,
  }) {
    return ProfilModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      lastName: lastName ?? this.lastName,
      firstName: firstName ?? this.firstName,
      birthDate: birthDate ?? this.birthDate,
      profilePhoto: profilePhoto ?? this.profilePhoto,
    );
  }
}

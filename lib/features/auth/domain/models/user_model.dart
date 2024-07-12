import 'package:pulse/core/common/entities/user.dart';

class UserModel extends User {
  UserModel(
      {required super.uid,
      required super.email,
      required super.lastName,
      required super.firstName,
      required super.username,
      required super.birthDate,
      required super.urlProfilePhoto,
      required super.points});

  factory UserModel.fromJson(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      lastName: map['last_name'] ?? '',
      firstName: map['first_name'] ?? '',
      username: map['username'] ?? '',
      birthDate: DateTime.parse(map['birth_date']),
      urlProfilePhoto: map['profile_photo'] ?? '',
      points: map['points'] ?? 0,
    );
  }

  UserModel copyWith({
    String? uid,
    String? email,
    String? lastName,
    String? firstName,
    String? username,
    DateTime? birthDate,
    String? urlProfilePhoto,
    int? points,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      lastName: lastName ?? this.lastName,
      firstName: firstName ?? this.firstName,
      username: username ?? this.username,
      birthDate: birthDate ?? this.birthDate,
      urlProfilePhoto: urlProfilePhoto ?? this.urlProfilePhoto,
      points: points ?? this.points,
    );
  }
}

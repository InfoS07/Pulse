import 'package:pulse/core/common/entities/user.dart';

class UserModel extends User {
  UserModel(
      {required super.id,
      required super.uid,
      required super.email,
      required super.lastName,
      required super.firstName,
      required super.username,
      required super.birthDate,
      required super.heightCm,
      required super.weightKg});

  factory UserModel.fromJson(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] ?? 0,
      uid: map['sub'] ?? '',
      email: map['email'] ?? '',
      lastName: map['last_name'] ?? '',
      firstName: map['first_name'] ?? '',
      username: map['username'] ?? '',
      birthDate: DateTime.parse(map['birth_date']),
      heightCm: map['height_cm'] ?? 0,
      weightKg: map['weight_kg'] ?? 0,
    );
  }

  UserModel copyWith({
    int? id,
    String? uid,
    String? email,
    String? lastName,
    String? firstName,
    String? username,
    DateTime? birthDate,
    int? heightCm,
    int? weightKg,
  }) {
    return UserModel(
      id: id ?? this.id,
      uid: uid ?? this.uid,
      email: email ?? this.email,
      lastName: lastName ?? this.lastName,
      firstName: firstName ?? this.firstName,
      username: username ?? this.username,
      birthDate: birthDate ?? this.birthDate,
      heightCm: heightCm ?? this.heightCm,
      weightKg: weightKg ?? this.weightKg,
      //sex
    );
  }
}

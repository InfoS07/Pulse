class Profil {
  final int id;
  final String uid;
  final String email;
  final String lastName;
  final String firstName;
  final String username;
  final DateTime birthDate;
  final int heightCm;
  final int weightKg;
  final String profilePhoto;

  Profil({
    required this.id,
    required this.uid,
    required this.email,
    required this.lastName,
    required this.firstName,
    required this.username,
    required this.birthDate,
    required this.heightCm,
    required this.weightKg,
    required this.profilePhoto,
  });
}

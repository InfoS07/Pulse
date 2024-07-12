class User {
  final String uid;
  final String email;
  final String lastName;
  final String firstName;
  final String username;
  final DateTime birthDate;
  final String urlProfilePhoto;
  final int points;

  User({
    required this.uid,
    required this.email,
    required this.lastName,
    required this.firstName,
    required this.username,
    required this.birthDate,
    required this.urlProfilePhoto,
    required this.points,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      uid: json['uid'],
      email: json['email'],
      lastName: json['last_name'],
      firstName: json['first_name'],
      username: json['username'],
      birthDate: DateTime.parse(json['birth_date']),
      urlProfilePhoto: json['profile_photo'],
      points: json['points'] ?? 0,
    );
  }

  static User empty() {
    return User(
      uid: '',
      email: '',
      lastName: 'Joubert',
      firstName: 'Thierry',
      username: 'Joujou',
      birthDate: DateTime.now(),
      urlProfilePhoto: '',
      points: 0,
    );
  }
}

class User {
  final String uid;
  final String email;
  final String lastName;
  final String firstName;
  final String username;
  final DateTime birthDate;
  final String urlProfilePhoto;

  User({
    required this.uid,
    required this.email,
    required this.lastName,
    required this.firstName,
    required this.username,
    required this.birthDate,
    required this.urlProfilePhoto,
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
    );
  }
}

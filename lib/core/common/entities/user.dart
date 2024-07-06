class User {
  final int id;
  final String uid;
  final String email;
  final String lastName;
  final String firstName;
  final String username;
  final DateTime birthDate;
  final String urlProfilePhoto;

  User({
    required this.id,
    required this.uid,
    required this.email,
    required this.lastName,
    required this.firstName,
    required this.username,
    required this.birthDate,
    required this.urlProfilePhoto,
  });

  static User empty() {
    return User(
      id: 0,
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

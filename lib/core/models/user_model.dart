class UserModel {
  final String uid;
  final String firstName;
  final String lastName;
  final DateTime birthDate;
  final DateTime createdAt;

  const UserModel({
    required this.uid,
    required this.firstName,
    required this.lastName,
    required this.birthDate,
    required this.createdAt,
  });

  String get fullName => '$firstName $lastName';

  factory UserModel.fromFirestoreMap(String uid, Map<String, dynamic> data) {
    return UserModel(
      uid: uid,
      firstName: data['firstName'] ?? '',
      lastName: data['lastName'] ?? '',
      birthDate: data['birthDate'] != null
          ? DateTime.tryParse(data['birthDate']) ?? DateTime(2000)
          : DateTime(2000),
      createdAt: data['createdAt'] != null
          ? DateTime.tryParse(data['createdAt']) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'birthDate': birthDate.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

class UserProfile {
  final String uid;
  final String email;
  final String farmSize;
  final List<String> crops;
  final String language;
  final bool isProfileComplete;

  UserProfile({
    required this.uid,
    required this.email,
    required this.farmSize,
    required this.crops,
    required this.language,
    required this.isProfileComplete,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'farmSize': farmSize,
      'crops': crops,
      'language': language,
      'isProfileComplete': isProfileComplete,
    };
  }

  factory UserProfile.fromMap(Map<String, dynamic> map, String uid) {
    return UserProfile(
      uid: uid,
      email: map['email'] ?? '',
      farmSize: map['farmSize'] ?? '',
      crops: List<String>.from(map['crops'] ?? []),
      language: map['language'] ?? 'English',
      isProfileComplete: map['isProfileComplete'] ?? false,
    );
  }
}

class UserModel {
  final String uid;
  final String email;
  final String displayName;
  final String phoneNumber;
  final String photoUrl;
  final String? address;

  UserModel({
    required this.uid,
    required this.email,
    required this.displayName,
    required this.phoneNumber,
    required this.photoUrl,
    this.address,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'phoneNumber': phoneNumber,
      'photoUrl': photoUrl,
      'address': address,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      displayName: map['displayName'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      photoUrl: map['photoUrl'] ?? '',
      address: map['address'],
    );
  }

  UserModel copyWith({
    String? uid,
    String? email,
    String? displayName,
    String? phoneNumber,
    String? photoUrl,
    String? address,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      photoUrl: photoUrl ?? this.photoUrl,
      address: address ?? this.address,
    );
  }
}

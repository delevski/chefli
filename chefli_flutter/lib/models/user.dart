class InstantDBUser {
  final String id;
  final String email;
  final String? name;
  final DateTime createdAt;
  final String? googleId;
  final String? photoUrl;

  InstantDBUser({
    required this.id,
    required this.email,
    this.name,
    required this.createdAt,
    this.googleId,
    this.photoUrl,
  });

  factory InstantDBUser.fromJson(Map<String, dynamic> json) {
    return InstantDBUser(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String?,
      createdAt: DateTime.fromMillisecondsSinceEpoch(
        json['createdAt'] as int,
      ),
      googleId: json['googleId'] as String?,
      photoUrl: json['photoUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'googleId': googleId,
      'photoUrl': photoUrl,
    };
  }

  @override
  String toString() {
    return 'InstantDBUser(id: $id, email: $email, name: $name)';
  }
}


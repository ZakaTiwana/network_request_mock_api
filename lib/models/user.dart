class User {
  const User(this.id, this.name, this.profilePic);
  final int id;
  final String name;
  final String? profilePic;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'profilePic': profilePic,
    };
  }
}

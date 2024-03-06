
class User {
  String _id;
  String username;
  String photoUrl;
  bool active;
  DateTime lastseen;

  User({
    required String id,
    required this.username,
    required this.photoUrl,
    required this.active,
    required this.lastseen
  }) : _id = id;

  String get id => _id;


  Map<String, dynamic> toJson() => {
    'username': username,
    'photo_url': photoUrl,
    'active': active,
    'last_seen': lastseen.toIso8601String()
  };
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'],
      photoUrl: json['photo_url'],
      active: json['active'],
      lastseen: DateTime.parse(json['last_seen']),
    );
  }
}

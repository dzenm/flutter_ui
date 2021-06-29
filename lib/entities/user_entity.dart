class UserEntity {
  bool? admin;
  List<dynamic>? chapterTops;
  int? coinCount;
  List<dynamic>? collectIds;
  String? email;
  String? icon;
  int? id;
  String? nickname;
  String? password;
  String? publicName;
  String? token;
  int? type;
  String? username;

  UserEntity();

  UserEntity.fromJson(Map<String, dynamic> json) {
    admin = json['admin'];
    chapterTops = json['chapterTops'];
    coinCount = json['coinCount'];
    collectIds = json['collectIds'];
    email = json['email'];
    icon = json['icon'];
    id = json['id'];
    nickname = json['nickname'];
    password = json['password'];
    publicName = json['publicName'];
    token = json['token'];
    type = json['type'];
    username = json['username'];
  }

  Map<String, dynamic> toJson() => {
        'admin': admin,
        'chapterTops': chapterTops,
        'coinCount': coinCount,
        'collectIds': collectIds,
        'email': email,
        'icon': icon,
        'id': id,
        'nickname': nickname,
        'password': password,
        'publicName': publicName,
        'token': token,
        'type': type,
        'username': username,
      };
}

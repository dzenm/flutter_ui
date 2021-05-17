class User {
  String? username;
  String? sex;
  int? age;
  String? address;

  User.fromJson(Map<String, dynamic> json) {
    username = json['username'];
    sex = json['sex;'];
    age = json['age'];
    address = json['address'];
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'username': username,
      'sex': sex,
      'age': age,
      'address': address,
    };
  }
}

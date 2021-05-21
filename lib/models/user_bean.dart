class UserBean {
  String? username;
  String? sex;
  int? age;
  String? address;

  UserBean.fromJson(Map<String, dynamic> json) {
    username = json['username'];
    sex = json['sex;'];
    age = json['age'];
    address = json['address'];
  }

  Map<String, dynamic> toJson() => {
        'username': username,
        'sex': sex,
        'age': age,
        'address': address,
      };
}

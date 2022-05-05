// ignore_for_file: non_constant_identifier_names

class User {
  String name;
  String email;
  String LastLogin_Date;
  String LastLogin_Time;
  String role_fk;
  int isActive;

  User(this.name, this.email, this.LastLogin_Date, this.LastLogin_Time,
      this.role_fk, this.isActive);

  User.fromJson(Map<String, dynamic> json)
      : name = json['Name'],
        email = json['email'],
        LastLogin_Date = json['LastLogin_Date'],
        LastLogin_Time = json['LastLogin_Time'],
        role_fk = json['role_fk'],
        isActive = json['isActive'];

  Map toJson() {
    return {
      'Name': name,
      'email': email,
      'LastLogin_Date': LastLogin_Date,
      'LastLogin_Time': LastLogin_Time,
      'role_fk': role_fk,
      'isActive': isActive,
    };
  }

  bool isEqual(User model) {
    return name == model.name;
  }

  @override
  String toString() => name;
}

class Role {
  String rolename;

  Role(this.rolename);

  Role.fromJson(Map<String, dynamic> json) : rolename = json['rolename'];

  Map toJson() {
    return {
      'rolename': rolename,
    };
  }
}

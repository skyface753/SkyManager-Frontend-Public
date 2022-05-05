//name, path, uploadedName, type, size, user_fk, customer_fk
class ServerFile {
  int id;
  String name;
  String path;
  String uploadedName;
  String type;
  int size;
  String userfk;
  int customerfk;

  ServerFile(this.id, this.name, this.path, this.uploadedName, this.type,
      this.size, this.userfk, this.customerfk);

  ServerFile.fromJson(Map<String, dynamic> json)
      : id = json['ID'],
        name = json['name'],
        path = json['path'],
        uploadedName = json['uploadedName'],
        type = json['type'],
        size = json['size'],
        userfk = json['user_fk'],
        customerfk = json['customer_fk'];

  Map toJson() {
    return {
      'ID': id,
      'name': name,
      'path': path,
      'uploadedName': uploadedName,
      'type': type,
      'size': size,
      'user_fk': userfk,
      'customer_fk': customerfk,
    };
  }
}

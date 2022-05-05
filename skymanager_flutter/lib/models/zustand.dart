class Zustand {
  int id;
  String name;

  Zustand(this.id, this.name);

  Zustand.fromJson(Map<String, dynamic> json)
      : id = json['ID'],
        name = json['Name'];

  Map toJson() {
    return {'ID': id, 'Name': name};
  }

  bool isEqual(Zustand model) {
    return id == model.id;
  }

  @override
  String toString() => name;
}

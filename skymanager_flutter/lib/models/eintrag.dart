class Eintrag {
  int id;
  String beschreibung;
  String username;
  num arbeitszeit;

  Eintrag(this.id, this.beschreibung, this.username, this.arbeitszeit);

  Eintrag.fromJson(Map json)
      : id = json['ID'],
        beschreibung = json['Beschreibung'],
        username = json['Username'],
        arbeitszeit = json['Arbeitszeit'];

  Map toJson() {
    return {
      'ID': id,
      'Beschreibung': beschreibung,
      'Username': username,
      'Arbeitszeit': arbeitszeit
    };
  }
}

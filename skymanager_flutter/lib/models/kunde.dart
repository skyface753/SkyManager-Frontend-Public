class Kunde {
  int id;
  String name;
  String mail;
  String plz;
  String stadt;
  String strasse;
  String hausnummer;
  int isActive;

  Kunde(this.id, this.name, this.mail, this.plz, this.stadt, this.strasse,
      this.hausnummer, this.isActive);

  Kunde.fromJson(Map<String, dynamic> json)
      : id = json['ID'],
        name = json['Name'],
        mail = json['mail'],
        plz = json['PLZ'],
        stadt = json['Stadt'],
        strasse = json['Strasse'],
        hausnummer = json['Hausnummer'],
        isActive = json['isActive'];

  Map toJson() {
    return {
      'ID': id,
      'Name': name,
      'mail': mail,
      'PLZ': plz,
      'Stadt': stadt,
      'Strasse': strasse,
      'Hausnummer': hausnummer,
      'isActive': isActive
    };
  }

  String userAsString() {
    return '#$id $name';
  }

  bool isEqual(Kunde model) {
    return id == model.id;
  }

  @override
  String toString() => name;
}

class Pass {
  int id;
  String titel;
  String benutzername;
  String passwort;

  Pass(this.id, this.titel, this.benutzername, this.passwort);

  Pass.fromJson(Map<String, dynamic> json)
      : id = json['ID'],
        titel = json['Titel'],
        benutzername = json['Benutzername'],
        passwort = json['Passwort'];

  Map toJson() {
    return {
      'ID': id,
      'Titel': titel,
      'Benutzername': benutzername,
      'Passwort': passwort
    };
  }
}

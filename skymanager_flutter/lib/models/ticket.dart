// Object for Tickets
class Ticket {
  int id;
  String titel;
  String beschreibung;
  String kundenname;
  String zustaendig;
  String zustand;

  Ticket(this.id, this.titel, this.beschreibung, this.kundenname,
      this.zustaendig, this.zustand);

  Ticket.fromJson(Map json) //Convert JSON from HTTP to Ticket Object
      : id = json['ID'],
        titel = json['Titel'],
        beschreibung = json['Beschreibung'],
        kundenname = json['Kundenname'],
        zustaendig = json['Zuständig'],
        zustand = json['Zustand'];

  Map toJson() {
    return {
      'ID': id,
      'Titel': titel,
      'Beschreibung': beschreibung,
      'Kundenname': kundenname,
      'Zuständig': zustaendig,
      'Zustand': zustand
    };
  }

  bool isEqual(Ticket other) {
    return titel == other.titel;
  }

  @override
  String toString() {
    return '#$id $titel';
  }
}

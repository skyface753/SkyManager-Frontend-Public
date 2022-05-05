// ignore_for_file: non_constant_identifier_names

class CurrTicket {
  String titel;
  String beschreibung;
  String kundenname;
  String zustaendig;
  String zustand;
  int kunden_FK;
  String user_FK;
  int zustand_FK;

  CurrTicket(this.titel, this.beschreibung, this.kundenname, this.zustaendig,
      this.zustand, this.kunden_FK, this.user_FK, this.zustand_FK);

  CurrTicket.fromJson(Map<String, dynamic> json)
      : titel = json['Titel'],
        beschreibung = json['Beschreibung'],
        kundenname = json['Kundenname'],
        zustaendig = json['Zuständig'],
        zustand = json['Zustand'],
        kunden_FK = json['Kunden_FK'],
        user_FK = json['User_FK'],
        zustand_FK = json['Zustand_FK'];

  Map toJson() {
    return {
      'Titel': titel,
      'Beschreibung': beschreibung,
      'Kundenname': kundenname,
      'Zuständig': zustaendig,
      'Zustand': zustand,
      'Kunden_FK': kunden_FK,
      'User_FK': user_FK,
      'Zustand_FK': zustand_FK
    };
  }
}

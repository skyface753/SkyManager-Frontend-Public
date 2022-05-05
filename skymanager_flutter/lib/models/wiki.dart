//`ID` int(11) NOT NULL, `Titel` varchar(50) NOT NULL, `Text`
// ignore_for_file: non_constant_identifier_names

class Wiki {
  int ID;
  String Titel;
  String Text;

  Wiki(this.ID, this.Titel, this.Text);

  Wiki.fromJson(Map<String, dynamic> json)
      : ID = json['ID'],
        Titel = json['Titel'],
        Text = json['Text'];

  Map<String, dynamic> toJson() => {'ID': ID, 'Titel': Titel, 'Text': Text};
}

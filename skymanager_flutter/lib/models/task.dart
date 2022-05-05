class Task {
  int id;
  String title;
  String beschreibung;
  String datetime;
  // ignore: non_constant_identifier_names
  int? ticket_fk;
  int isCompleted;
  String owner;
  List<String>? users;

  Task(this.id, this.title, this.beschreibung, this.datetime, this.ticket_fk,
      this.isCompleted, this.owner, this.users);

  Task.fromJson(Map json)
      : id = json['ID'],
        title = json['Titel'],
        beschreibung = json['Beschreibung'],
        datetime = json['DateTime'],
        ticket_fk = json['ticket_fk'],
        isCompleted = json['isCompleted'],
        owner = json['owner'],
        users = json['Users'];

  Map toJson() {
    return {
      'ID': id,
      'Titel': title,
      'Beschreibung': beschreibung,
      'DateTime': datetime,
      'ticket_fk': ticket_fk,
      'isCompleted': isCompleted,
      'owner': owner,
      'Users': users
    };
  }
}

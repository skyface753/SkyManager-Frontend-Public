import 'dart:convert';

class Instance {
  String url;
  String username;
  String password;

  Instance(this.url, this.username, this.password);

  factory Instance.fromJson(Map<String, dynamic> json) {
    return Instance(json['url'], json['username'], json['password']);
  }

  Map<String, dynamic> toJson() {
    return {
      'url': url,
      'username': username,
      'password': password,
    };
  }

  static Map<String, dynamic> toMap(Instance instance) => {
        'url': instance.url,
        'username': instance.username,
        'password': instance.password,
      };

  static String encode(List<Instance> instances) => json.encode(
        instances
            .map<Map<String, dynamic>>((instance) => Instance.toMap(instance))
            .toList(),
      );

  static List<Instance> decode(String instances) =>
      (json.decode(instances) as List<dynamic>)
          .map<Instance>((item) => Instance.fromJson(item))
          .toList();
}

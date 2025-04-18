class User {
  String? id;

  static final User _instance = User._internal();

  factory User() {
    return _instance;
  }

  User._internal();
}

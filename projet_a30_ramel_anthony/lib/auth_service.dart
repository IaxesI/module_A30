import 'beans/user.dart';

class AuthService {
  final List<User> _users = [
    User(username: 'RamelA', password: r'Pa$$w0rd'),
    User(username: 'Admin', password: r'Pa$$w0rd'),
  ];

  User? _currentUser;

  User? get currentUser => _currentUser;

  bool login(String username, String password) {
    for (var user in _users) {
      if (user.username == username && user.password == password) {
        _currentUser = user;
        return true;
      }
    }
    return false;
  }

  void logout() {
    _currentUser = null;
  }
}

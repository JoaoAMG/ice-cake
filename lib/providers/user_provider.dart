import 'package:flutter/material.dart';
import 'package:doceria_app/model/usuario.dart';



class UserProvider extends ChangeNotifier {
  Usuario? _currentUser;

  Usuario? get currentUser => _currentUser;

  void setUser(Usuario user) {
    _currentUser = user;
    
    notifyListeners();
  }

  void clearUser() {
    _currentUser = null;
    notifyListeners();
  }
}
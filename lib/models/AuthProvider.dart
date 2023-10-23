import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutterdemo/models/User.dart';

class AuthProvider with ChangeNotifier {
  String? accessToken;
  String? refreshToken;
  User? currentUser;

  // Controlla se l'utente è autenticato
  bool isAuthenticated() {
    return accessToken != null && refreshToken != null;
  }

  void setUser(User user) {
    currentUser = user;
    notifyListeners();
  }

  Future<void> loadTokens() async {
    final storage = FlutterSecureStorage();
    accessToken = await storage.read(key: 'access_token');
    refreshToken = await storage.read(key: 'refresh_token');
    notifyListeners();
  }

  Future<void> loadAll(User user) async {
    final storage = FlutterSecureStorage();
    accessToken = await storage.read(key: 'access_token');
    refreshToken = await storage.read(key: 'refresh_token');
    currentUser = user;
    notifyListeners();
  }

  // Esegui il logout
  void logout() {
    accessToken = null;
    refreshToken = null;
    currentUser = null;
    notifyListeners();
  }
}

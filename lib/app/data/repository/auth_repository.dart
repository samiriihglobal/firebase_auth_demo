import '../provider/auth_provider.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;

class AuthRepository{
  final AuthProvider _provider;

  AuthRepository(this._provider);

  User? get currentUser => _provider.currentUser;

  Stream<User?> get authStateChanges => _provider.authStateChanges;

  Future<UserCredential> login(String email, String password) {
    return _provider.signIn(email: email, password: password);
  }

  Future<UserCredential> register(String email, String password) {
    return _provider.signUp(email: email, password: password);
  }

  Future<void> logout() {
    return _provider.signOut();
  }
}
// hello

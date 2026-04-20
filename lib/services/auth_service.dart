import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<String?> signUp(String email, String password) async {
    try {
      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return null;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'email-already-in-use':
          return 'Bu email zaten kullanımda.';
        case 'invalid-email':
          return 'Geçersiz email adresi.';
        case 'weak-password':
          return 'Şifre çok zayıf, en az 6 karakter kullan.';
        default:
          return 'Bir hata oluştu: ${e.message}';
      }
    }
  }

  Future<String?> signIn(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return null;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          return 'Bu emaile kayıtlı kullanıcı bulunamadı.';
        case 'wrong-password':
          return 'Şifre yanlış.';
        case 'invalid-email':
          return 'Geçersiz email adresi.';
        case 'invalid-credential':
          return 'Email veya şifre hatalı.';
        default:
          return 'Bir hata oluştu: ${e.message}';
      }
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  User? get currentUser => _auth.currentUser;
}
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<String?> signUp(
    String email,
    String password, {
    String? displayName,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = credential.user;
      final cleanedDisplayName = displayName?.trim();

      if (user != null) {
        if (cleanedDisplayName != null && cleanedDisplayName.isNotEmpty) {
          await user.updateDisplayName(cleanedDisplayName);
          await user.reload();
        }

        await _firestore.collection('users').doc(user.uid).set({
          'id': user.uid,
          'createdBy': user.uid,
          'email': user.email ?? email,
          'displayName': cleanedDisplayName?.isNotEmpty == true
              ? cleanedDisplayName
              : email.split('@').first,
          'bio': '',
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }

      return null;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'email-already-in-use':
          return 'Bu email zaten kullanımda.';
        case 'invalid-email':
          return 'Geçersiz email adresi.';
        case 'weak-password':
          return 'Şifre çok zayıf, en az 6 karakter kullan.';
        case 'network-request-failed':
          return 'Ağ bağlantısı hatası. İnternet bağlantını kontrol et.';
        default:
          return 'Bir hata oluştu: ${e.message}';
      }
    } catch (e) {
      return 'Bir hata oluştu: $e';
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
        case 'network-request-failed':
          return 'Ağ bağlantısı hatası. İnternet bağlantını kontrol et.';
        default:
          return 'Bir hata oluştu: ${e.message}';
      }
    } catch (e) {
      return 'Bir hata oluştu: $e';
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  User? get currentUser => _auth.currentUser;
}
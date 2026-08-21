import 'package:firebase_auth/firebase_auth.dart';

class AuthRepository {
  AuthRepository(this._firebaseAuth);

  final FirebaseAuth _firebaseAuth;

  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  User? get currentUser => _firebaseAuth.currentUser;

  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) {
    return _firebaseAuth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  Future<UserCredential> signUp({
  required String fullName,
  required String email,
  required String password,
}) async {
  final credential =
      await _firebaseAuth.createUserWithEmailAndPassword(
    email: email.trim(),
    password: password,
  );

  await credential.user?.updateDisplayName(fullName.trim());

  return credential;
}

  Future<void> sendPasswordResetEmail(String email) {
    return _firebaseAuth.sendPasswordResetEmail(
      email: email.trim(),
    );
  }

  Future<void> signOut() {
    return _firebaseAuth.signOut();
  }
}
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthRepository {
  AuthRepository(
    this._firebaseAuth, [
    FirebaseFirestore? firestore,
  ]) : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  Stream<User?> get authStateChanges =>
      _firebaseAuth.authStateChanges();

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
    required String role,
  }) async {
    final credential =
        await _firebaseAuth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    final user = credential.user;

    if (user == null) {
      throw FirebaseAuthException(
        code: 'user-not-created',
        message: 'Unable to create your account.',
      );
    }

    await user.updateDisplayName(fullName.trim());

    await _firestore
        .collection('users')
        .doc(user.uid)
        .set(
      {
        'uid': user.uid,
        'name': fullName.trim(),
        'email': email.trim(),
        'role': role,
        'location': 'San Francisco, CA',
        'bio': role == 'organization'
            ? 'Organization profile coming soon.'
            : 'Looking for opportunities to make a difference.',
        'interests': role == 'volunteer'
            ? [
                'Environment',
                'Education',
                'Community',
                'Animals',
              ]
            : [],
        'createdAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );

    return credential;
  }

  Future<String> getCurrentUserRole() async {
    final user = _firebaseAuth.currentUser;

    if (user == null) {
      return 'volunteer';
    }

    final document = await _firestore
        .collection('users')
        .doc(user.uid)
        .get();

    final data = document.data();

    final role = data?['role'];

    if (role == 'organization') {
      return 'organization';
    }

    // Existing users created before role selection
    // are safely treated as volunteers.
    if (role != 'volunteer') {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .set(
        {
          'role': 'volunteer',
        },
        SetOptions(merge: true),
      );
    }

    return 'volunteer';
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
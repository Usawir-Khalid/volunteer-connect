import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class ProfileData extends ChangeNotifier {
  ProfileData._();

  static final ProfileData instance = ProfileData._();

  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  String name = 'Volunteer';
  String email = '';
  String location = 'San Francisco, CA';

  String bio =
      'Looking for opportunities to make a difference.';

  String role = 'volunteer';

  Set<String> interests = {
    'Environment',
    'Education',
    'Community',
    'Animals',
  };

  bool _isLoaded = false;
  bool _isLoading = false;

  bool get isLoaded => _isLoaded;
  bool get isLoading => _isLoading;

  bool get isVolunteer => role == 'volunteer';
  bool get isOrganization => role == 'organization';

  User? get _currentUser =>
      FirebaseAuth.instance.currentUser;

  String get _uid => _currentUser?.uid ?? '';

  String _authenticatedEmail() {
    return _currentUser?.email ?? '';
  }

  void refreshAuthenticatedEmail() {
    final authenticatedEmail =
        _authenticatedEmail();

    if (email != authenticatedEmail) {
      email = authenticatedEmail;
      notifyListeners();
    }
  }

  Future<void> loadFromFirestore() async {
    final uid = _uid;

    if (uid.isEmpty || _isLoading) {
      return;
    }

    _isLoading = true;

    try {
      final document = await _firestore
          .collection('users')
          .doc(uid)
          .get();

      final data = document.data();

      if (data != null) {
        final firestoreName =
            data['name'] as String?;

        final firestoreEmail =
            data['email'] as String?;

        final firestoreLocation =
            data['location'] as String?;

        final firestoreBio =
            data['bio'] as String?;

        final firestoreRole =
            data['role'] as String?;

        final firestoreInterests =
            data['interests'];

        if (firestoreName != null &&
            firestoreName.trim().isNotEmpty) {
          name = firestoreName;
        }

        email = firestoreEmail ??
            _authenticatedEmail();

        if (firestoreLocation != null &&
            firestoreLocation.trim().isNotEmpty) {
          location = firestoreLocation;
        }

        if (firestoreBio != null) {
          bio = firestoreBio;
        }

        if (firestoreRole == 'organization') {
          role = 'organization';
        } else {
          role = 'volunteer';
        }

        if (firestoreInterests is List) {
          interests = firestoreInterests
              .whereType<String>()
              .toSet();
        }

        // Existing accounts created before role
        // selection are treated as volunteers.
        if (firestoreRole == null) {
          await _firestore
              .collection('users')
              .doc(uid)
              .set(
            {
              'role': 'volunteer',
            },
            SetOptions(merge: true),
          );
        }
      } else {
        email = _authenticatedEmail();

        await _firestore
            .collection('users')
            .doc(uid)
            .set(
          {
            'uid': uid,
            'email': email,
            'name': name,
            'role': 'volunteer',
            'location': location,
            'bio': bio,
            'interests': interests.toList(),
          },
          SetOptions(merge: true),
        );

        role = 'volunteer';
      }

      _isLoaded = true;
      notifyListeners();
    } catch (e) {
      debugPrint(
        'ProfileData load error: $e',
      );
    } finally {
      _isLoading = false;
    }
  }

  Future<void> loadCurrentUser() async {
    refreshAuthenticatedEmail();
    await loadFromFirestore();
  }

  Future<bool> updateProfile({
    required String name,
    required String location,
    String? bio,
    Set<String>? interests,
  }) async {
    final uid = _uid;

    if (uid.isEmpty) {
      return false;
    }

    final newName = name.trim();
    final newLocation = location.trim();

    if (newName.isEmpty ||
        newLocation.isEmpty) {
      return false;
    }

    final newBio =
        bio?.trim() ?? this.bio;

    final newInterests =
        interests != null
            ? Set<String>.from(interests)
            : Set<String>.from(
                this.interests,
              );

    try {
      await _firestore
          .collection('users')
          .doc(uid)
          .set(
        {
          'uid': uid,
          'email': _authenticatedEmail(),
          'name': newName,
          'location': newLocation,
          'bio': newBio,
          'interests':
              newInterests.toList(),
          'role': role,
          'updatedAt':
              FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );

      this.name = newName;
      this.location = newLocation;
      this.bio = newBio;
      this.interests = newInterests;
      email = _authenticatedEmail();

      _isLoaded = true;

      notifyListeners();

      return true;
    } catch (e) {
      debugPrint(
        'ProfileData update error: $e',
      );

      return false;
    }
  }

  Future<bool> updateLocation(
    String newLocation,
  ) async {
    return updateProfile(
      name: name,
      location: newLocation,
      bio: bio,
      interests: interests,
    );
  }

  void clear() {
    name = 'Volunteer';
    email = '';
    location = 'San Francisco, CA';

    bio =
        'Looking for opportunities to make a difference.';

    role = 'volunteer';

    interests = {
      'Environment',
      'Education',
      'Community',
      'Animals',
    };

    _isLoaded = false;

    notifyListeners();
  }
}
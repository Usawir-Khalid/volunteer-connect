import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class ProfileData extends ChangeNotifier {
  ProfileData._();

  static final ProfileData instance = ProfileData._();

  String name = 'Volunteer';
  String email = _getAuthenticatedEmail();
  String location = 'San Francisco, CA';
  String bio = 'Looking for opportunities to make a difference.';

  Set<String> interests = {
    'Environment',
    'Education',
    'Community',
    'Animals',
  };

  static String _getAuthenticatedEmail() {
    return FirebaseAuth.instance.currentUser?.email ??
        'No email available';
  }

  void refreshAuthenticatedEmail() {
    final authenticatedEmail = _getAuthenticatedEmail();

    if (email != authenticatedEmail) {
      email = authenticatedEmail;
      notifyListeners();
    }
  }

  void updateProfile({
    required String name,
    required String location,
    required String bio,
    required Set<String> interests,
  }) {
    this.name = name;
    this.location = location;
    this.bio = bio;
    this.interests = Set<String>.from(interests);

    refreshAuthenticatedEmail();
    notifyListeners();
  }
}
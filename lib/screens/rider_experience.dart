import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'auth_screen.dart';
import 'home_map_screen.dart';

class RiderExperience extends StatefulWidget {
  const RiderExperience({super.key});

  @override
  State<RiderExperience> createState() => _RiderExperienceState();
}

class _RiderExperienceState extends State<RiderExperience> {
  bool _signedIn = true;

  @override
  void initState() {
    super.initState();
    _ensureAuth();
  }

  Future<void> _ensureAuth() async {
    try {
      if (FirebaseAuth.instance.currentUser == null) {
        await FirebaseAuth.instance.signInAnonymously();
      }
    } catch (e) {
      debugPrint('Anonymous auth failed: $e');
    }
  }

  void _signOut() {
    setState(() => _signedIn = false);
  }

  void _signIn() {
    setState(() => _signedIn = true);
    _ensureAuth();
  }

  @override
  Widget build(BuildContext context) {
    if (_signedIn) {
      return HomeMapScreen(onLogout: _signOut);
    }

    return SignedOutScreen(onSignIn: _signIn);
  }
}

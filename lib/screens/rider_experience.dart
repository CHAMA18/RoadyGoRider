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

  void _signOut() {
    setState(() => _signedIn = false);
  }

  void _signIn() {
    setState(() => _signedIn = true);
  }

  @override
  Widget build(BuildContext context) {
    if (_signedIn) {
      return HomeMapScreen(onLogout: _signOut);
    }

    return SignedOutScreen(onSignIn: _signIn);
  }
}

import 'package:flutter/material.dart';
import 'login.dart';
import 'package:transition/transition.dart';

class SplashPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: () {
          Navigator.push(
              context,
              Transition(
                  child: LoginPage(), transitionEffect: TransitionEffect.FADE));
        },
        child: Container(
          width: double.infinity,
          height: double.infinity,
          child: Image.asset(
            MediaQuery.of(context).platformBrightness == Brightness.dark
                ? 'assets/dark_mode/splash.jpg'
                : 'assets/light_mode/splash.jpg',
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}

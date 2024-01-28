import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tgpersonalcloud/in/channels.dart';
import 'package:transition/transition.dart';
import 'login.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(useMaterial3: false),
      debugShowCheckedModeBanner: false,
      home: FutureBuilder(
        future: checkSession(),
        builder: (context, AsyncSnapshot<bool> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Muestra un indicador de carga mientras se verifica la sesión
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          } else {
            // Si la sesión existe, redirige a la página correspondiente
            if (snapshot.data == true) {
              return FutureBuilder(
                future: getSharedPreferencesInstance(),
                builder:
                    (context, AsyncSnapshot<SharedPreferences> prefsSnapshot) {
                  if (prefsSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const Scaffold(
                      body: Center(child: CircularProgressIndicator()),
                    );
                  } else {
                    String? phoneNumber =
                        prefsSnapshot.data?.getString('phoneNumber');
                    return ChannelsPage(phoneNumber ?? '');
                  }
                },
              );
            } else {
              // Si no existe una sesión, muestra la página de inicio de sesión
              return const SplashPage(); // Cambia esta línea según tus necesidades
            }
          }
        },
      ),
    );
  }

  Future<SharedPreferences> getSharedPreferencesInstance() async {
    return await SharedPreferences.getInstance();
  }

  Future<bool> checkSession() async {
    SharedPreferences prefs = await getSharedPreferencesInstance();

    // Verifica si existe alguna información de sesión en SharedPreferences
    String? phoneNumber = prefs.getString('phoneNumber');
    bool sessionExists = phoneNumber != null;

    return sessionExists;
  }
}

class SplashPage extends StatelessWidget {
  const SplashPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            Transition(
              child: const LoginPage(),
              transitionEffect: TransitionEffect.FADE,
            ),
          );
        },
        child: SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: Image.asset(
            kIsWeb
                ? MediaQuery.of(context).platformBrightness == Brightness.dark
                    ? 'assets/splash_dark_desk_4k.png'
                    : 'assets/splash_light_desk_4k.png'
                : MediaQuery.of(context).platformBrightness == Brightness.dark
                    ? 'assets/dark_mode/splash.jpg'
                    : 'assets/light_mode/splash.jpg',
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}

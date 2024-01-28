import 'package:flutter/material.dart';
import 'package:transition/transition.dart';
import '../in/channels.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import 'package:top_snackbar_flutter/custom_snack_bar.dart';
// import 'package:top_snackbar_flutter/safe_area_values.dart';
// import 'package:top_snackbar_flutter/tap_bounce_container.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

import 'package:google_fonts/google_fonts.dart';

class EnterPasswordPage extends StatefulWidget {
  final String phoneNumber;

  EnterPasswordPage(this.phoneNumber);

  @override
  EnterPasswordPageState createState() => EnterPasswordPageState();
}

class EnterPasswordPageState extends State<EnterPasswordPage> {
  final TextEditingController passwordController = TextEditingController();

  late bool passwordVisibility = true;

  @override
  void dispose() {
    passwordController.dispose();
    super.dispose();
  }

  Future<bool> _onBackPressed() {
    return Future.value(false);
  }

  Future<bool> sendPasswordToServer(
      String code, String phoneNumber, String password) async {
    const url = 'http://10.0.2.2:5000/send_password';
    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'code': code,
        'phone_number': "+$phoneNumber",
        'password': password
      }),
    );
    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }

  showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFFF5F9FE),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              LoadingAnimationWidget.waveDots(
                  color: const Color.fromRGBO(88, 172, 255, 1), size: 50),
              const SizedBox(height: 20.0),
              Text(
                'Loading ...',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF7C8BA0),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onBackPressed,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: SafeArea(
          top: true,
          child: Stack(
            children: [
              Align(
                alignment: const AlignmentDirectional(0.00, 0.00),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(
                    Theme.of(context).brightness == Brightness.dark
                        ? 'assets/dark_mode/enterpassword.jpg'
                        : 'assets/light_mode/enterpassword.jpg',
                    width: 536,
                    height: 839,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Align(
                alignment: const AlignmentDirectional(0, 0.13),
                child: SizedBox(
                  width: 300,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        obscureText: passwordVisibility,
                        controller: passwordController,
                        cursorColor: const Color.fromRGBO(88, 172, 255, 1),
                        keyboardType: TextInputType.text,
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF7C8BA0),
                        ),
                        decoration: InputDecoration(
                          suffixIcon: InkWell(
                            onTap: () => setState(
                              () => passwordVisibility = !passwordVisibility,
                            ),
                            focusNode: FocusNode(skipTraversal: true),
                            child: Icon(
                              passwordVisibility
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              color: const Color(0xFF7C8BA0),
                              size: 20,
                            ),
                          ),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? const Color(
                                      0xFFF5F9FE) // Color del borde en modo oscuro
                                  : const Color(
                                      0xFFEFF4F9), // Color del borde en modo claro
                              width: 0,
                            ),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? const Color(
                                      0xFFF5F9FE) // Color del borde en modo oscuro
                                  : const Color(
                                      0xFFEFF4F9), // Color del borde en modo claro
                              width: 0,
                            ),
                          ),
                          labelStyle: GoogleFonts.poppins(
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF7C8BA0),
                          ),
                          filled: true,
                          fillColor: Theme.of(context).brightness ==
                                  Brightness.dark
                              ? const Color(
                                  0xFFF5F9FE) // Color del fondo en modo oscuro
                              : const Color(
                                  0xFFEFF4F9), // Color del fondo en modo claro
                          labelText: 'Password',
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 10.0),
                        ),
                      ),
                      const SizedBox(height: 30),
                      Opacity(
                        opacity: 0,
                        child: ElevatedButton(
                          onPressed: () async {
                            FocusScope.of(context).unfocus();

                            showLoadingDialog(context);

                            if (await sendPasswordToServer(
                                    "", "34616789929", "adrip") ==
                                true) {
                              Navigator.push(
                                context,
                                Transition(
                                  child: ChannelsPage("34616789929"),
                                  transitionEffect: TransitionEffect.FADE,
                                ),
                              );
                            } else {
                              Navigator.of(context).pop();
                              showTopSnackBar(
                                Overlay.of(context),
                                CustomSnackBar.error(
                                  message:
                                      "Something went wrong. Please check your credentials and try again",
                                  textStyle: GoogleFonts.poppins(),
                                ),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 200,
                              vertical: 20,
                            ),
                          ),
                          child: const Text(''),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

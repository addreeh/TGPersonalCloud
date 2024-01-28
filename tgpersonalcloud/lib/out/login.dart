import 'package:flutter/material.dart';
import 'package:tgpersonalcloud/out/enterPassword.dart';
import 'package:tgpersonalcloud/out/otp.dart';
import 'package:transition/transition.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import 'package:google_fonts/google_fonts.dart';

import 'package:top_snackbar_flutter/custom_snack_bar.dart';
// import 'package:top_snackbar_flutter/safe_area_values.dart';
// import 'package:top_snackbar_flutter/tap_bounce_container.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

import 'package:country_picker/country_picker.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController prefixController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();

  @override
  void dispose() {
    prefixController.dispose();
    phoneNumberController.dispose();
    super.dispose();
  }

  Future<bool> _onBackPressed() {
    return Future.value(false);
  }

  Future<int> sendPhoneNumberToTelegram(String phoneNumber) async {
    const url = 'http://10.0.2.2:5000/send_phone_number';
    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'phone_number': "+$phoneNumber"}),
    );
    return response.statusCode;
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
                        ? 'assets/dark_mode/login3.jpg'
                        : 'assets/light_mode/login.jpg',
                    width: 536,
                    height: 839,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Align(
                alignment: const AlignmentDirectional(0, 0.15),
                child: SizedBox(
                  width: 300,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                              width: 75,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10.0),
                                color: Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? const Color(0xFFF5F9FE)
                                    : const Color(0xFFEFF4F9),
                              ),
                              child: TextField(
                                readOnly: true,
                                controller: prefixController,
                                cursorColor:
                                    const Color.fromRGBO(88, 172, 255, 1),
                                keyboardType: TextInputType.phone,
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF7C8BA0),
                                ),
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  labelStyle: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFF7C8BA0),
                                  ),
                                  filled: true,
                                  fillColor: Colors.transparent,
                                  labelText: 'Prefix',
                                  contentPadding:
                                      EdgeInsets.fromLTRB(15, 10, 12, 10),
                                ),
                                onTap: () {
                                  // Cuando el campo de texto se toca, muestra el selector de países.
                                  showCountryPicker(
                                    context: context,
                                    countryListTheme: CountryListThemeData(
                                        backgroundColor: Color(0xFF565656),
                                        textStyle: GoogleFonts.poppins(
                                          fontWeight: FontWeight.w500,
                                          color: Color(0xFFFFFFFF),
                                        ),
                                        searchTextStyle: GoogleFonts.poppins(
                                          fontWeight: FontWeight.w500,
                                          color: Color(0xFFFFFFFF),
                                        ),
                                        margin:
                                            EdgeInsets.fromLTRB(20, 20, 20, 0),
                                        flagSize: 20),
                                    showPhoneCode: true,
                                    onSelect: (Country country) {
                                      // Cuando se selecciona un país, actualiza el valor del prefijo.
                                      setState(() {
                                        prefixController.text =
                                            country.phoneCode;
                                      });
                                    },
                                  );
                                },
                              )),
                          const SizedBox(width: 25),
                          Container(
                            width: 200,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10.0),
                              color: Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? const Color(0xFFF5F9FE)
                                  : const Color(0xFFEFF4F9),
                            ),
                            child: TextField(
                              controller: phoneNumberController,
                              cursorColor:
                                  const Color.fromRGBO(88, 172, 255, 1),
                              keyboardType: TextInputType.phone,
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF7C8BA0),
                              ),
                              decoration: InputDecoration(
                                suffixIcon: IconButton(
                                  onPressed: () {
                                    phoneNumberController.clear();
                                    setState(() {});
                                  },
                                  icon: const Icon(
                                    Icons.clear,
                                    color: Color(0xFF7C8BA0),
                                    size: 20,
                                  ),
                                ),
                                border: InputBorder.none,
                                labelStyle: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF7C8BA0),
                                ),
                                filled: true,
                                fillColor: Colors.transparent,
                                labelText: 'Phone Number',
                                contentPadding:
                                    const EdgeInsets.fromLTRB(15, 10, 12, 10),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 40),
                      Opacity(
                        opacity: 0,
                        child: ElevatedButton(
                          onPressed: () async {
                            FocusScope.of(context).unfocus();

                            showLoadingDialog(context);

                            final responseCode =
                                await sendPhoneNumberToTelegram(
                              "34616789929",
                            );

                            if (responseCode == 777) {
                              Navigator.of(context).pop();

                              // ScaffoldMessenger.of(context).showSnackBar(
                              // const SnackBar(
                              // content: Text(
                              // "Invalid phone number. Try it again."),
                              // ),
                              // );
                              showTopSnackBar(
                                Overlay.of(context),
                                CustomSnackBar.error(
                                  message:
                                      "Something went wrong. Please check your credentials and try again",
                                  textStyle: GoogleFonts.poppins(),
                                ),
                              );
                            } else if (responseCode == 500) {
                              Navigator.push(
                                context,
                                Transition(
                                  child: OtpPage(prefixController.text +
                                      phoneNumberController.text),
                                  transitionEffect: TransitionEffect.FADE,
                                ),
                              );
                            } else {
                              Navigator.push(
                                context,
                                Transition(
                                  child: EnterPasswordPage("34616789929"),
                                  transitionEffect: TransitionEffect.FADE,
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
                          child: const Text(''), // Texto del botón
                        ),
                      ),
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

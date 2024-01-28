import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tgpersonalcloud/out/createPassword.dart';
import 'package:transition/transition.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import 'package:top_snackbar_flutter/custom_snack_bar.dart';
// import 'package:top_snackbar_flutter/safe_area_values.dart';
// import 'package:top_snackbar_flutter/tap_bounce_container.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

class OtpPage extends StatefulWidget {
  final String phoneNumber;

  OtpPage(this.phoneNumber);

  @override
  _OtpPageState createState() => _OtpPageState();
}

class _OtpPageState extends State<OtpPage> {
  final TextEditingController otpController = TextEditingController();

  String otpCode = "";

  @override
  void dispose() {
    otpController.dispose();
    super.dispose();
  }

  Future<bool> _onBackPressed() {
    return Future.value(false);
  }

  Future<int> sendVerificationCodeToTelegram(
      String code, String phoneNumber) async {
    const url = 'http://10.0.2.2:5000/send_verification_code';
    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'code': code, 'phone_number': "+$phoneNumber"}),
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
                        ? 'assets/dark_mode/otp2.jpg'
                        : 'assets/light_mode/otp2.jpg',
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
                      OtpTextField(
                        textStyle: GoogleFonts.poppins(
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF7C8BA0),
                        ),
                        borderRadius:
                            const BorderRadius.all(Radius.circular(10.0)),
                        cursorColor: const Color(0xFF58ACFF),
                        filled: true,
                        fillColor:
                            Theme.of(context).brightness == Brightness.dark
                                ? const Color(0xFFF5F9FE)
                                : const Color(0xFFEFF4F9),
                        fieldWidth: 50,
                        numberOfFields: 5,
                        enabledBorderColor:
                            Theme.of(context).brightness == Brightness.dark
                                ? const Color(0xFFF5F9FE)
                                : const Color(0xFFEFF4F9),
                        borderColor:
                            Theme.of(context).brightness == Brightness.dark
                                ? const Color(0xFFF5F9FE)
                                : const Color(0xFFEFF4F9),
                        focusedBorderColor: const Color(0xFF58ACFF),
                        showFieldAsBox: true,
                        onCodeChanged: (String code) {},
                        //runs when every textfield is filled
                        onSubmit: (String verificationCode) {
                          otpCode = verificationCode;
                        }, // end on
                      ),
                      const SizedBox(height: 40),
                      Opacity(
                        opacity: 0,
                        child: ElevatedButton(
                          onPressed: () async {
                            print(otpCode);
                            print(widget.phoneNumber);
                            FocusScope.of(context).unfocus();

                            showLoadingDialog(context);

                            print("NUMERASO ${widget.phoneNumber}");

                            final responseCode =
                                await sendVerificationCodeToTelegram(
                                    otpCode, widget.phoneNumber);

                            if (responseCode == 777) {
                              Navigator.of(context).pop();
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
                                  child: CreatePasswordPage(
                                      widget.phoneNumber, otpCode),
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

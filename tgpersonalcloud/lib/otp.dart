// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tgpersonalcloud/create.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';
import 'package:transition/transition.dart';

import 'functions.dart';

class OtpPage extends StatefulWidget {
  final String phoneNumber;

  const OtpPage(this.phoneNumber, {super.key});

  @override
  // ignore: library_private_types_in_public_api
  _OtpPageState createState() => _OtpPageState();
}

class _OtpPageState extends State<OtpPage> {
  final TextEditingController otpController = TextEditingController();
  String otpCode = "";
  var appColors = AppColors();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appColors.bgColorOut(context),
      body: Column(
        children: <Widget>[
          const SizedBox(
            height: 75,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 32,
                height: 4,
                decoration: BoxDecoration(
                  color: appColors.indicatorColorOut(context),
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
              const SizedBox(width: 10),
              Container(
                width: 32,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFF58ACFF),
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
              const SizedBox(width: 10),
              Container(
                width: 32,
                height: 4,
                decoration: BoxDecoration(
                  color: appColors.indicatorColorOut(context),
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 70,
          ),
          Container(
            width: 100,
            height: 100,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: appColors.boxColorOut(context),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Image.asset(
              'assets/message.png',
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(
            height: 40,
          ),
          Text(
            'OTP Code',
            style: GoogleFonts.poppins(
              fontSize: 32.0,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF58ACFF),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          SizedBox(
            width: 300,
            child: Text(
              'Enter the OTP code Telegram just sent you on your Telegram personal chat',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 14.0,
                fontWeight: FontWeight.normal,
                color: appColors.textColorOut(context),
              ),
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          OtpTextField(
            textStyle: GoogleFonts.poppins(
              fontWeight: FontWeight.w500,
              color: appColors.textColorOut(context),
            ),
            borderRadius: const BorderRadius.all(Radius.circular(10.0)),
            cursorColor: const Color(0xFF58ACFF),
            filled: true,
            fillColor: Theme.of(context).brightness == Brightness.dark
                ? const Color(0xFFF5F9FE)
                : const Color(0xFFEFF4F9),
            fieldWidth: 50,
            numberOfFields: 5,
            enabledBorderColor: Theme.of(context).brightness == Brightness.dark
                ? const Color(0xFFF5F9FE)
                : const Color(0xFFEFF4F9),
            borderColor: Theme.of(context).brightness == Brightness.dark
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
          const SizedBox(
            height: 20,
          ),
          Container(
            width: 300,
            height: 60,
            margin: const EdgeInsets.symmetric(horizontal: 20),
            child: ElevatedButton(
              onPressed: () async {
                FocusScope.of(context).unfocus();

                showLoadingDialog(context, const Color(0xFF58ACFF));

                final responseCode = await sendVerificationCodeToTelegram(
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
                      child: CreatePasswordPage(widget.phoneNumber, otpCode),
                      transitionEffect: TransitionEffect.FADE,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF58ACFF),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                elevation: 15,
                shadowColor: const Color(0xFF58ACFF),
              ),
              child: Text(
                'Send OTP',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFFFFFFFF),
                ),
              ),
            ),
          ),
          const SizedBox(
            height: 75,
          ),
          Row(
            children: [
              Expanded(
                child: Container(
                  margin: const EdgeInsets.fromLTRB(50, 0, 0, 0),
                  child: const Divider(
                    color: Color(0xFF757171),
                    thickness: 2,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Text(
                  "follow the development at",
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.normal,
                    color: const Color(0xFF757171),
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  margin: const EdgeInsets.fromLTRB(0, 0, 50, 0),
                  child: const Divider(
                    color: Color(0xFF757171),
                    thickness: 2,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 20,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                width: 75,
                height: 50,
                decoration: BoxDecoration(
                  color: appColors.boxColorOut(context),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Image.asset(
                  'assets/telegram.png',
                  fit: BoxFit.contain, // Ajusta la imagen dentro del contenedor
                ),
              ),
              const SizedBox(width: 20),
              Container(
                padding: const EdgeInsets.all(10),
                width: 75,
                height: 50,
                decoration: BoxDecoration(
                  color: appColors.boxColorOut(context),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Image.asset(
                  'assets/github.png',
                  fit: BoxFit.contain, // Ajusta la imagen dentro del contenedor
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ignore_for_file: use_build_context_synchronously

import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tgpersonalcloud/enter.dart';
import 'package:tgpersonalcloud/otp.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';
import 'package:transition/transition.dart';

import 'functions.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController prefixController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();
  var appColors = AppColors();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
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
                'assets/hand.png',
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(
              height: 40,
            ),
            Text(
              'Login',
              style: GoogleFonts.poppins(
                fontSize: 32.0,
                fontWeight: FontWeight.bold,
                color: appColors.mainColor(context),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            SizedBox(
              width: 300,
              child: Text(
                'Enter your phone number like the following sample +34612345678',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 14.0,
                  fontWeight: FontWeight.normal,
                  color: appColors.textColor(context),
                ),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 75,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.0),
                    color: appColors.textFieldColorOut(context),
                  ),
                  child: TextField(
                    readOnly: true,
                    controller: prefixController,
                    cursorColor: const Color.fromRGBO(88, 172, 255, 1),
                    keyboardType: TextInputType.phone,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF7C8BA0),
                    ),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      labelStyle: GoogleFonts.poppins(
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF7C8BA0),
                      ),
                      filled: true,
                      fillColor: Colors.transparent,
                      labelText: 'Prefix',
                      contentPadding: const EdgeInsets.fromLTRB(15, 10, 12, 10),
                    ),
                    onTap: () {
                      showCountryPicker(
                        context: context,
                        countryListTheme: CountryListThemeData(
                            backgroundColor: appColors.countryColorOut(context),
                            textStyle: GoogleFonts.poppins(
                              fontWeight: FontWeight.w500,
                              color: appColors.textColorOut(context),
                            ),
                            searchTextStyle: GoogleFonts.poppins(
                              fontWeight: FontWeight.w500,
                              color: appColors.textColorOut(context),
                            ),
                            margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                            flagSize: 20),
                        showPhoneCode: true,
                        onSelect: (Country country) {
                          setState(() {
                            prefixController.text = country.phoneCode;
                          });
                        },
                      );
                    },
                  ),
                ),
                const SizedBox(
                  width: 20,
                ),
                Container(
                  width: 200,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.0),
                    color: appColors.textFieldColorOut(context),
                  ),
                  child: TextField(
                    controller: phoneNumberController,
                    cursorColor: const Color.fromRGBO(88, 172, 255, 1),
                    keyboardType: TextInputType.phone,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF7C8BA0),
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
                        color: const Color(0xFF7C8BA0),
                      ),
                      filled: true,
                      fillColor: Colors.transparent,
                      labelText: 'Phone Number',
                      contentPadding: const EdgeInsets.fromLTRB(15, 10, 12, 10),
                    ),
                  ),
                ),
              ],
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

                  final responseCode = await sendPhoneNumberToTelegram(
                    prefixController.text + phoneNumberController.text,
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
                        textStyle: GoogleFonts.poppins(color: Colors.white),
                      ),
                    );
                  } else if (responseCode == 500) {
                    Navigator.push(
                      context,
                      Transition(
                        child: OtpPage(
                            prefixController.text + phoneNumberController.text),
                        transitionEffect: TransitionEffect.FADE,
                      ),
                    );
                  } else {
                    Navigator.push(
                      context,
                      Transition(
                        child: EnterPasswordPage(
                            prefixController.text + phoneNumberController.text),
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
                  'Continue',
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
                    fit: BoxFit
                        .contain, // Ajusta la imagen dentro del contenedor
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
                    fit: BoxFit
                        .contain, // Ajusta la imagen dentro del contenedor
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

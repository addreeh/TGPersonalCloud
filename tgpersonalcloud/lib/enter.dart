// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tgpersonalcloud/functions.dart';
import 'package:tgpersonalcloud/in/channels.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';
import 'package:transition/transition.dart';

class EnterPasswordPage extends StatefulWidget {
  final String phoneNumber;

  const EnterPasswordPage(this.phoneNumber, {super.key});

  @override
  // ignore: library_private_types_in_public_api
  _EnterPasswordPageState createState() => _EnterPasswordPageState();
}

class _EnterPasswordPageState extends State<EnterPasswordPage> {
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController repeatPasswordController =
      TextEditingController();
  late bool passwordVisibility = true;
  late bool repeatPasswordVisibility = true;
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
              'assets/lock.png',
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(
            height: 40,
          ),
          Text(
            'Enter Password',
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
              'This phone number has already been used in the application, enter password',
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
          Container(
            width: 300,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.0),
              color: appColors.textFieldColorOut(context),
            ),
            child: TextField(
              obscureText: passwordVisibility,
              controller: passwordController,
              cursorColor: const Color.fromRGBO(88, 172, 255, 1),
              keyboardType: TextInputType.text,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w500,
                color: const Color(0xFF7C8BA0),
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
                    color: Theme.of(context).brightness == Brightness.dark
                        ? const Color(
                            0xFFF5F9FE) // Color del borde en modo oscuro
                        : const Color(
                            0xFFEFF4F9), // Color del borde en modo claro
                    width: 0,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? const Color(
                            0xFFF5F9FE) // Color del borde en modo oscuro
                        : const Color(
                            0xFFEFF4F9), // Color del borde en modo claro
                    width: 0,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                labelStyle: GoogleFonts.poppins(
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF7C8BA0),
                ),
                filled: true,
                fillColor: Theme.of(context).brightness == Brightness.dark
                    ? const Color(0xFFF5F9FE) // Color del fondo en modo oscuro
                    : const Color(0xFFEFF4F9), // Color del fondo en modo claro
                labelText: 'Password',
                contentPadding: const EdgeInsets.fromLTRB(15, 10, 12, 10),
              ),
            ),
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

                if (await sendPasswordToServer(
                        "", widget.phoneNumber, passwordController.text) ==
                    true) {
                  SharedPreferences prefs =
                      await SharedPreferences.getInstance();
                  prefs.setString('phoneNumber', widget.phoneNumber);

                  Navigator.push(
                    context,
                    Transition(
                      child: ChannelsPage(widget.phoneNumber),
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
                      textStyle: GoogleFonts.poppins(color: Colors.white),
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
                'Submit',
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

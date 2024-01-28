// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';

const String server = "http://10.0.2.2:5000";

String getServerString() {
  return server;
}

class AppColors {
  // Singleton para asegurarse de que solo haya una instancia
  static final AppColors _instance = AppColors._internal();

  factory AppColors() {
    return _instance;
  }

  AppColors._internal();

  Color mainColor(BuildContext context) {
    return const Color(0xFF58ACFF);
  }

  Color bgColorOut(BuildContext context) {
    var brightness = MediaQuery.of(context).platformBrightness;
    return brightness == Brightness.light
        ? const Color(0xFFFFFFFF)
        : const Color(0xFF1E1E1E);
  }

  Color boxColorOut(BuildContext context) {
    var brightness = MediaQuery.of(context).platformBrightness;
    return brightness == Brightness.light
        ? const Color(0xFFD6DFFF)
        : const Color(0xFFF5F9FE);
  }

  Color textFieldColorOut(BuildContext context) {
    var brightness = MediaQuery.of(context).platformBrightness;
    return brightness == Brightness.light
        ? const Color(0xFFEFF4F9)
        : const Color(0xFFF5F9FE);
  }

  Color textColorOut(BuildContext context) {
    var brightness = MediaQuery.of(context).platformBrightness;
    return brightness == Brightness.light
        ? const Color(0xFF61677D)
        : const Color(0xFFCCCCCC);
  }

  Color indicatorColorOut(BuildContext context) {
    var brightness = MediaQuery.of(context).platformBrightness;
    return brightness == Brightness.light
        ? const Color(0xFFD6DFFF)
        : const Color(0xFF8B8B8B);
  }

  Color countryColorOut(BuildContext context) {
    var brightness = MediaQuery.of(context).platformBrightness;
    return brightness == Brightness.light
        ? const Color(0xFFDFDFDF)
        : const Color(0xFF565656);
  }

  Color bgLoadingDialogColor(BuildContext context) {
    var brightness = MediaQuery.of(context).platformBrightness;
    return brightness == Brightness.light
        ? const Color(0xFFEFF4F9)
        : const Color(0xFF3A3A3A);
  }

  Color textLoadingDialogColor(BuildContext context) {
    var brightness = MediaQuery.of(context).platformBrightness;
    return brightness == Brightness.light
        ? const Color(0xFF61677D)
        : const Color(0xFFF5F9FE);
  }

  Color textColor(BuildContext context) {
    var brightness = MediaQuery.of(context).platformBrightness;
    return brightness == Brightness.light
        ? const Color(0xFF61677D)
        : const Color(0xFFCCCCCC);
  }

  Color appBarTextColor(BuildContext context) {
    return const Color(0xFFFFFFFF);
  }

  Color appBarBgColor(BuildContext context) {
    var brightness = MediaQuery.of(context).platformBrightness;
    return brightness == Brightness.light
        ? const Color(0xFF58ACFF)
        : const Color(0xFF222222);
  }

  Color cardTextColor(BuildContext context) {
    var brightness = MediaQuery.of(context).platformBrightness;
    return brightness == Brightness.light
        ? const Color(0xFF000000)
        : const Color(0xFFFFFFFF);
  }

  Color cardBgColor(BuildContext context) {
    var brightness = MediaQuery.of(context).platformBrightness;
    return brightness == Brightness.light
        ? const Color(0xFFFAFAFA)
        : const Color(0xFF3C3C3C);
  }

  Color cardBgExpColor(BuildContext context) {
    var brightness = MediaQuery.of(context).platformBrightness;
    return brightness == Brightness.light
        ? const Color(0xFFFAFAFA)
        : const Color(0xFF868686);
  }

  Color userListBgColor(BuildContext context) {
    var brightness = MediaQuery.of(context).platformBrightness;
    return brightness == Brightness.light
        ? const Color(0xFFFAFAFA)
        : const Color(0xFF484848);
  }

  Color dialogTextColor(BuildContext context) {
    return const Color(0xFF646464);
  }
}

Future<bool> onBackPressed() {
  return Future.value(false);
}

// LOGIN //////////////////////////////////////////////////////////////////////
// ENVIAR TLF
Future<int> sendPhoneNumberToTelegram(String phoneNumber) async {
  const url = '$server/send_phone_number';
  final response = await http.post(
    Uri.parse(url),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({'phone_number': "+$phoneNumber"}),
  );
  return response.statusCode;
}

// ENVIAR OTP
Future<int> sendVerificationCodeToTelegram(
    String code, String phoneNumber) async {
  const url = '$server/send_verification_code';
  final response = await http.post(
    Uri.parse(url),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({'code': code, 'phone_number': "+$phoneNumber"}),
  );

  return response.statusCode;
}

// ENVIAR PASS
Future<bool> sendPasswordToServer(
    String code, String phoneNumber, String password) async {
  const url = '$server/send_password';
  final response = await http.post(
    Uri.parse(url),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode(
        {'code': code, 'phone_number': "+$phoneNumber", 'password': password}),
  );
  if (response.statusCode == 200) {
    return true;
  } else {
    return false;
  }
}

// CERRAR SESIÓN
Future<void> logOut(String phoneNumber) async {
  final url = Uri.parse('$server/log_out');
  final response = await http.post(
    (url),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({'phone_number': "+$phoneNumber"}),
  );

  if (response.statusCode == 200) {
    print('Bien');
  } else {
    print('Error al obtener los mensajes');
  }

  exit(0);
}

//////////////////////////////////////////////////////////////////////////////////
// OBTENER INFORMACIÓN DEL USUARIO
Future<Map<String, dynamic>> getUserInfo(String phoneNumber) async {
  final response = await http.post(
    Uri.parse('$server/get_user_info'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({'phone_number': "+$phoneNumber"}),
  );
  print('Respuesta del servidor: ${response.body}');

  if (response.statusCode == 200) {
    final user_info = json.decode(response.body);
    print('Usuario recibido desde el servidor: $user_info');
    return user_info;
  } else {
    throw Exception(
        'No se pudo obtener la información del usuario. Código de estado: ${response.statusCode}');
  }
}
//////////////////////////////////////////////////////////////////////////////////

// CHANNELS //////////////////////////////////////////////////////////////////////
// OBTENER CANALES DEL USUARIO
Future<Map<String, dynamic>> getChannels(String phoneNumber) async {
  final response = await http.post(Uri.parse('$server/get_channels'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'phone_number': "+$phoneNumber"}));

  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  } else {
    throw Exception('Error al obtener los grupos');
  }
}

// OBTENER TOPICS DEL CANAL
Future<Map<String, dynamic>> getTopics(
    String phoneNumber, int channelId) async {
  final response = await http.post(Uri.parse('$server/get_topics'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'phone_number': "+$phoneNumber", 'id': channelId}));

  if (response.statusCode == 200) {
    final topics = jsonDecode(response.body);
    return topics;
  } else {
    throw Exception('Error al obtener los topics');
  }
}

// OBTENER MENSAJES DEL TOPIC
Future<Map<String, dynamic>> getMessages(
    String phoneNumber, int channelId, int topicId) async {
  final response = await http.post(Uri.parse('$server/get_messages'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'phone_number': "+$phoneNumber",
        'channel_id': channelId,
        'topic_id': topicId
      }));

  if (response.statusCode == 200) {
    final messages = jsonDecode(response.body);
    return messages;
  } else {
    throw Exception('Error al obtener los mensajes');
  }
}
////////////////////////////////////////////////////////////////////////////////

// CONTACTS //////////////////////////////////////////////////////////////////////
// OBTENER CONTACTOS DEL CANAL
Future<Map<String, dynamic>> getContacts(
    String phoneNumber, int channelId) async {
  final response = await http.post(Uri.parse('$server/get_contacts'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(
          {'phone_number': "+$phoneNumber", 'channel_id': channelId}));

  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  } else {
    throw Exception('Error al obtener los grupos');
  }
}

// ENVIAR CONTACTO AL CANAL
Future<bool> sendContact(
    String phoneNumber, int channelId, String contactId) async {
  final response = await http.post(Uri.parse('$server/insert_contact'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'phone_number': "+$phoneNumber",
        'channel_id': "$channelId",
        'contact_id': contactId
      }));

  if (response.statusCode == 200) {
    final responseBody = response.body.trim(); // Elimina espacios en blanco
    if (responseBody == "Insertado con exito") {
      return true;
    } else {
      return false;
    }
  } else {
    return false;
  }
}

// BORRAR CONTACTO DEL CANAL
Future<bool> deleteContact(
    String phoneNumber, int channelId, String? contactId) async {
  final response = await http.post(Uri.parse('$server/delete_contact'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'phone_number': "+$phoneNumber",
        'channel_id': channelId,
        'contact_id': contactId
      }));

  if (response.statusCode == 200) {
    return true;
  }
  return false;
}
////////////////////////////////////////////////////////////////////////////////

// RIGHTS //////////////////////////////////////////////////////////////////////
// OBTENER PERMISOS DEL CONTACTO
Future<Map<String, dynamic>> getRights(
    String phoneNumber, int channelId, String? contactId) async {
  final response = await http.post(Uri.parse('$server/get_rights'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'phone_number': "+$phoneNumber",
        'channel_id': channelId,
        'contact_id': contactId
      }));

  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  } else {
    throw Exception('Error al obtener los grupos');
  }
}

// ENVIAR PERMISOS DEL CONTACTO
Future<bool> sendRights(String phoneNumber, int channelId, String? userId,
    List selectedRights) async {
  final response = await http.post(Uri.parse('$server/send_rights'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'phone_number': "+$phoneNumber",
        'channel_id': channelId,
        'user_id': "$userId",
        'selected_rights': selectedRights
      }));

  if (response.statusCode == 200) return true;
  return false;
}
////////////////////////////////////////////////////////////////////////////////

// DIALOGS /////////////////////////////////////////////////////////////////////
showLoadingDialog(BuildContext context, Color mainColor) {
  var appColors = AppColors();
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: appColors.bgLoadingDialogColor(context),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            LoadingAnimationWidget.waveDots(color: mainColor, size: 50),
            const SizedBox(height: 20.0),
            Text(
              'Loading ...',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w500,
                color: appColors.textColor(context),
              ),
            ),
          ],
        ),
      );
    },
  );
}
//////////////////////////////////////////////////////////////////////////////////////

// FILES /////////////////////////////////////////////////////////////////////
// ENVIAR ARCHIVOS AL TOPIC
Future<void> sendFileToTopic(
    File file, int groupId, int topicId, String phoneNumber) async {
  String filePath = file.path;
  String fileName = file.uri.pathSegments.last;
  String? mimeType = lookupMimeType(filePath);

  int fileSize = await file.length();

  var url = Uri.parse(
      '$server/send_media_topic/$groupId/$topicId/$phoneNumber/$fileSize');
  var request = http.MultipartRequest('POST', url);

  if (mimeType != null) {
    var fileBytes = file
        .readAsBytesSync(); // No es necesario leer de nuevo, ya tenemos los bytes
    var multipartFile = http.MultipartFile.fromBytes(
      'file',
      fileBytes,
      filename: fileName,
      contentType: MediaType.parse(mimeType),
    );

    request.files.add(multipartFile);

    var response = await request.send();

    if (response.statusCode == 200) {
      print('Enviado con éxito $fileName, Tamaño: $fileSize bytes');
    } else {
      print('Error al enviar el archivo');
    }
  } else {
    print('No se pudo determinar el tipo MIME para $filePath');
  }
}


//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:io';

import 'package:dropdown_model_list/drop_down/model.dart';
import 'package:dropdown_model_list/drop_down/select_drop_list.dart';
import 'package:expansion_tile_card/expansion_tile_card.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_multi_select_items/flutter_multi_select_items.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tgpersonalcloud/in/chat.dart';
import 'package:tgpersonalcloud/in/topics.dart';
import 'package:tgpersonalcloud/main.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'dart:convert';
import 'package:top_snackbar_flutter/top_snack_bar.dart';
import 'package:transition/transition.dart';

import 'package:slide_popup_dialog_null_safety/slide_popup_dialog.dart'
    // ignore: library_prefixes
    as slideDialog;

import 'package:rflutter_alert/rflutter_alert.dart';

import 'package:tgpersonalcloud/functions.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

String server = getServerString();

class ChannelsPage extends StatefulWidget {
  final String phoneNumber;
  const ChannelsPage(this.phoneNumber, {super.key});

  @override
  ChannelsPageState createState() => ChannelsPageState();
}

class ChannelsPageState extends State<ChannelsPage> {
  bool isLoading = true;
  bool isDone = false;
  bool isLoadingCreate = false;

  List<dynamic> userChannels = [];
  List<dynamic> usersList = [];

  var mainColor = const Color(0xFF58ACFF);
  var bgColor = Color.fromARGB(255, 0, 0, 0);
  var boxColor = Color.fromARGB(255, 0, 0, 0);
  var textFieldColor = Color.fromARGB(255, 0, 0, 0);
  var textColor = Color.fromARGB(255, 0, 0, 0);
  var indicatorColor = Color.fromARGB(255, 0, 0, 0);
  var countryColor = Color.fromARGB(255, 0, 0, 0);
  var loadingBgColor = Color.fromARGB(255, 0, 0, 0);
  var loadingTextColor = Color.fromARGB(255, 0, 0, 0);
  var appBarBgColor = Color.fromARGB(255, 0, 0, 0);
  var cardTextColor = Color.fromARGB(255, 0, 0, 0);
  var cardBgColor = Color.fromARGB(255, 0, 0, 0);
  var cardBgExpColor = Color.fromARGB(255, 0, 0, 0);
  var userListBgColor = Color.fromARGB(255, 0, 0, 0);
  var dialogTextColor = Color.fromARGB(255, 0, 0, 0);

  late bool darkMode;

  void changeColor(Color color) async {
    setState(() => mainColor = color);
    SharedPreferences prefs = await SharedPreferences.getInstance();

    prefs.setString('color', color.value.toRadixString(16));
  }

  @override
  void didChangeDependencies() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    if (prefs.getString('color') != null) {
      String? storedColor = prefs.getString('color');
      mainColor = Color(int.parse(storedColor!, radix: 16));
    }

    if (prefs.getBool('darkMode') != null) {
      darkMode = prefs.getBool('darkMode')!;
    } else {
      darkMode = MediaQuery.of(context).platformBrightness == Brightness.dark
          ? true
          : false;
    }

    // Llamado después de que el widget ha sido construido
    super.didChangeDependencies();
    if (darkMode) {
      bgColor = const Color(0xFF1E1E1E);
      boxColor = const Color(0xFFF5F9FE);
      textFieldColor = const Color(0xFFF5F9FE);
      textColor = const Color(0xFFCCCCCC);
      indicatorColor = const Color(0xFF8B8B8B);
      countryColor = const Color(0xFF565656);
      loadingBgColor = const Color(0xFF3A3A3A);
      loadingTextColor = const Color(0xFFF5F9FE);
      appBarBgColor = const Color(0xFF222222);
      cardTextColor = const Color(0xFFFFFFFF);
      cardBgColor = const Color(0xFF3C3C3C);
      cardBgExpColor = const Color(0xFF868686);
      userListBgColor = const Color(0xFF484848);
      dialogTextColor = const Color(0xFF646464);
    } else {
      bgColor = const Color(0xFFFFFFFF);
      boxColor = const Color(0xFFD6DFFF);
      textFieldColor = const Color(0xFFEFF4F9);
      textColor = const Color(0xFF61677D);
      indicatorColor = const Color(0xFFD6DFFF);
      countryColor = const Color(0xFFDFDFDF);
      loadingBgColor = const Color(0xFFEFF4F9);
      loadingTextColor = const Color(0xFF61677D);
      appBarBgColor = mainColor;
      cardTextColor = const Color(0xFF000000);
      cardBgColor = const Color(0xFFFAFAFA);
      cardBgExpColor = const Color(0xFFFAFAFA);
      userListBgColor = const Color(0xFFFAFAFA);
      dialogTextColor = const Color(0xFF646464);
    }
  }

  bool toggleMode(bool darkMode) {
    if (darkMode) {
      darkMode = false;
      bgColor = const Color(0xFFFFFFFF);
      boxColor = const Color(0xFFD6DFFF);
      textFieldColor = const Color(0xFFEFF4F9);
      textColor = const Color(0xFF61677D);
      indicatorColor = const Color(0xFFD6DFFF);
      countryColor = const Color(0xFFDFDFDF);
      loadingBgColor = const Color(0xFFEFF4F9);
      loadingTextColor = const Color(0xFF61677D);
      appBarBgColor = mainColor;
      cardTextColor = const Color(0xFF000000);
      cardBgColor = const Color(0xFFFAFAFA);
      cardBgExpColor = const Color(0xFFFAFAFA);
      userListBgColor = const Color(0xFFFAFAFA);
      dialogTextColor = const Color(0xFF646464);
    } else {
      darkMode = true;
      bgColor = const Color(0xFF1E1E1E);
      boxColor = const Color(0xFFF5F9FE);
      textFieldColor = const Color(0xFFF5F9FE);
      textColor = const Color(0xFFCCCCCC);
      indicatorColor = const Color(0xFF8B8B8B);
      countryColor = const Color(0xFF565656);
      loadingBgColor = const Color(0xFF3A3A3A);
      loadingTextColor = const Color(0xFFF5F9FE);
      appBarBgColor = const Color(0xFF222222);
      cardTextColor = const Color(0xFFFFFFFF);
      cardBgColor = const Color(0xFF3C3C3C);
      cardBgExpColor = const Color(0xFF868686);
      userListBgColor = const Color(0xFF484848);
      dialogTextColor = const Color(0xFF646464);
    }
    return darkMode;
  }

  Future<bool> toggleModeAsync(bool darkMode) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    if (darkMode) {
      darkMode = false;
      prefs.setBool('darkMode', false);
    } else {
      darkMode = true;
      prefs.setBool('darkMode', true);
    }

    return darkMode;
  }

  @override
  void initState() {
    super.initState();
    try {
      initializeAsyncData();
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  bool isDarkMode() {
    if (MediaQuery.of(context).platformBrightness == Brightness.dark) {
      return true;
    }
    return false;
  }

  Future<void> showPopup(String phoneNumber) async {
    // Mostrar el popup con la animación de carga
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: loadingBgColor,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              LoadingAnimationWidget.waveDots(color: mainColor, size: 50),
              const SizedBox(height: 20.0),
              Text(
                'Loading ...',
                style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w500, color: loadingTextColor),
              ),
            ],
          ),
        );
      },
    );

    // Obtener la información del usuario
    Map<String, dynamic> userInfo = await getUserInfo(phoneNumber);

    // Actualizar el contenido del popup con la información del usuario
    Navigator.pop(context); // Cerrar el popup actual
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String userInfoText = '';

        if (userInfo['id'] != null) userInfoText += 'ID ➜ ${userInfo['id']}\n';
        if (userInfo['nombre'] != null) {
          userInfoText += 'Name ➜ ${userInfo['nombre']}\n';
        }
        if (userInfo['apellido'] != null) {
          userInfoText += 'Surname ➜ ${userInfo['apellido']}\n';
        }
        if (userInfo['username'] != null) {
          userInfoText += 'Username ➜ ${userInfo['username']}\n';
        }
        if (userInfo['phone'] != null) {
          userInfoText += 'Phone Number ➜ +${userInfo['phone']}';
        }

        return AlertDialog(
          backgroundColor: cardBgColor,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.person,
                    color: mainColor,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "User Info",
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w500,
                      color: mainColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              Text(
                userInfoText,
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w500,
                  color: cardTextColor,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Icon(
                    Icons.settings,
                    color: mainColor,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "App Settings",
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w500,
                      color: mainColor,
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Current Theme Mode ➜",
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w500,
                      color: cardTextColor,
                    ),
                  ),
                  IconButton(
                      icon:
                          Icon(darkMode ? Icons.nightlight_sharp : Icons.sunny),
                      color: cardTextColor,
                      onPressed: () {
                        setState(() {
                          toggleModeAsync(darkMode);
                          darkMode = toggleMode(darkMode);
                          Navigator.pop(context);
                          showPopup(phoneNumber);
                        });
                      }),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Current Main Color ➜",
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w500,
                      color: cardTextColor,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.color_lens),
                    color: cardTextColor,
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text('Pick a color'),
                            content: SingleChildScrollView(
                              child: ColorPicker(
                                pickerColor: mainColor,
                                onColorChanged: changeColor,
                                showLabel: true,
                                pickerAreaHeightPercent: 0.8,
                              ),
                            ),
                            actions: <Widget>[
                              TextButton(
                                child: Text('OK'),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  Navigator.pop(context);
                                  showPopup(phoneNumber);
                                },
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
          actions: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment
                  .spaceEvenly, // Puedes ajustar el espacio entre los botones
              children: [
                DialogButton(
                  color: Colors.transparent,
                  onPressed: () => Navigator.pop(context),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD3E4FF),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                    ),
                    onPressed: () async {
                      // logOut(phoneNumber);
                      //Navigator.pop(context);
                      SharedPreferences prefs =
                          await SharedPreferences.getInstance();

                      prefs.remove('phoneNumber');
                      prefs.remove('darkMode');
                      prefs.remove('color');
                      //  exit(0);
                      Navigator.push(
                        context,
                        Transition(
                          child: const SplashPage(),
                          transitionEffect: TransitionEffect.FADE,
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.login_rounded,
                            color: Color(0xFF1E1E1E),
                            size: 20.0,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            "Log Out",
                            style: GoogleFonts.poppins(
                              fontSize: 12.0,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF1E1E1E),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                DialogButton(
                  color: Colors.transparent,
                  onPressed: () => Navigator.pop(context),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2F4156),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                    ),
                    onPressed: () async {
                      Navigator.pop(context);
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Text(
                        "Cancel",
                        style: GoogleFonts.poppins(
                          fontSize: 12.0,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

// INIT /////////////////////////////////////////////////////////////////////
// EVITAR BOTON ATRAS
  Future<bool> onBackPressed() {
    return Future.value(false);
  }

// INICIALIZAR DATOS
  Future<void> initializeAsyncData() async {
    try {
      setState(() {
        isLoading = true; // Indicar que se está cargando
      });

      final channels = await getChannels(widget.phoneNumber);

      setState(() {
        userChannels = channels['channels'];
        // userChannels = [];
        isLoading = false; // Indicar que la carga ha finalizado
      });
    } catch (e) {
      if (kDebugMode) {
        print("Error al obtener grupos: $e");
      }
    }
  }

// REFRESCAR LISTA CONTACTOS
  void refreshContactList(int channelId) async {
    final users = await getContacts(widget.phoneNumber, channelId);
    setState(() {
      usersList = users['users'];
    });
  }
////////////////////////////////////////////////////////////////////////////////

// DIALOGS /////////////////////////////////////////////////////////////////////
// MOSTRAR DIALOGO USUARIOS
  showUsers(int channelId) async {
    final users = await getContacts(widget.phoneNumber, channelId);
    usersList = users['users'];

    List<OptionItem> optionItems = [];

    for (var user in usersList) {
      String id = user['id'].toString();
      String title =
          "${user['first_name']} ${user['last_name'] ?? ''} | ${user['phone_number']} ${user['user_name'] != null ? ' | ${user['user_name']}' : ''}";

      OptionItem optionItem = OptionItem(id: id, title: title);
      optionItems.add(optionItem);
    }

    DropListModel dropListModel = DropListModel(optionItems);

    OptionItem optionItemSelected = OptionItem(title: "Select User");

    final TextEditingController textFieldController = TextEditingController();

    slideDialog.showSlideDialog(
      context: context,
      child: Column(
        children: [
          Center(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 30),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w500, color: cardTextColor),
                      controller: textFieldController,
                      decoration: InputDecoration(
                        hintText: "Search Users",
                        hintStyle: GoogleFonts.poppins(
                          fontWeight: FontWeight.w500,
                          color: cardTextColor,
                        ),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color:
                                cardTextColor, // Cambia este color al que desees
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 30,
                  ),
                  Ink(
                    decoration: ShapeDecoration(
                      color: const Color(0xFF2F4156),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.person_add_alt_1_rounded),
                      color: Colors.white,
                      onPressed: () async {
                        if (textFieldController.text != "") {
                          if (await sendContact(widget.phoneNumber, channelId,
                              textFieldController.text)) {
                            refreshContactList(channelId);
                            Navigator.of(context).pop();

                            showUsers(channelId);
                          } else {
                            showTopSnackBar(
                              Overlay.of(context),
                              CustomSnackBar.error(
                                message:
                                    "Something went wrong. Please check your credentials and try again",
                                textStyle: GoogleFonts.poppins(),
                              ),
                            );
                          }
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          Visibility(
            visible: usersList.isNotEmpty,
            child: Column(
              children: <Widget>[
                SelectDropList(
                  heightBottomContainer: 150,
                  itemSelected: optionItemSelected,
                  dropListModel: dropListModel,
                  showIcon: true,
                  showArrowIcon: true,
                  showBorder: false,
                  shadowColor: const Color.fromRGBO(88, 172, 255, 1),
                  paddingTop: 0,
                  paddingDropItem: 10,
                  suffixIcon: Icons.arrow_drop_down,
                  containerPadding: const EdgeInsets.all(10),
                  icon: const Icon(Icons.person, color: Color(0xFF2F4156)),
                  arrowColor: const Color(0xFF2F4156),
                  onOptionSelected: (optionItem) {
                    setState(() {
                      Navigator.of(context).pop();
                      showUsersV2(channelId, optionItem);
                    });
                  },
                ),
              ],
            ),
          ),
        ],
      ),
      barrierColor: Colors.white.withOpacity(0.7),
      pillColor: mainColor,
      backgroundColor: userListBgColor,
    );
  }

// MOSTRAR DIALOGO PERMISOS CONTACTO
  showUsersV2(int channelId, OptionItem optionItem) async {
    final rights =
        await getRights(widget.phoneNumber, channelId, optionItem.id);
    final rightsGranted = rights['rightsGranted'];
    final rightsRevoked = rights['rightsRevoked'];

    List<String>? selectedRights = [];

    List<MultiSelectCard> permissionsList = [];

    for (var right in rightsGranted) {
      permissionsList
          .add(MultiSelectCard(value: right, label: right, selected: true));
    }
    for (var right in rightsRevoked) {
      permissionsList.add(MultiSelectCard(value: right, label: right));
    }

    slideDialog.showSlideDialog(
      context: context,
      child: Column(
        children: [
          Center(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 30),
              child: Row(
                children: [
                  Expanded(
                    child: Ink(
                      padding: const EdgeInsets.all(16.5),
                      decoration: ShapeDecoration(
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      child: Text(
                        optionItem.title,
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Ink(
                    decoration: ShapeDecoration(
                      color: const Color(0xFF2F4156),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.person_remove_sharp),
                      color: Colors.white,
                      onPressed: () async {
                        deleteContact(
                            widget.phoneNumber, channelId, optionItem.id);
                        await Future.delayed(const Duration(seconds: 2));
                        Navigator.of(context).pop();
                        showUsers(channelId);
                      },
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                ],
              ),
            ),
          ),
          Column(
            children: <Widget>[
              const SizedBox(
                height: 15,
              ),
              const Divider(
                thickness: 1,
                color: Color(0xFFD3E4FF),
              ),
              const SizedBox(
                height: 10,
              ),
              Text(
                "Permissions",
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  children: <Widget>[
                    MultiSelectContainer(
                        splashColor: Colors.blue.withOpacity(0.1),
                        highlightColor: Colors.blue.withOpacity(0.1),
                        textStyles: const MultiSelectTextStyles(
                            selectedTextStyle: TextStyle(
                                fontWeight: FontWeight.w400,
                                color: Colors.white)),
                        itemsDecoration: MultiSelectDecorations(
                          decoration: BoxDecoration(
                              color: Colors.grey.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20)),
                          selectedDecoration: BoxDecoration(
                              color: const Color(0xFF2F4156),
                              borderRadius: BorderRadius.circular(20)),
                          disabledDecoration: BoxDecoration(
                              color: Colors.grey,
                              border: Border.all(color: Colors.grey[500]!),
                              borderRadius: BorderRadius.circular(10)),
                        ),
                        items: permissionsList,
                        onChange: (userRights, selectedItem) {
                          selectedRights = userRights.cast<String>();
                        }),
                    const SizedBox(
                      height: 20,
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD3E4FF),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                      ),
                      onPressed: () async {
                        sendRights(widget.phoneNumber, channelId, optionItem.id,
                            selectedRights!);
                        await Future.delayed(const Duration(seconds: 2));

                        Navigator.of(context).pop();
                        showUsersV2(channelId, optionItem);
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Text(
                          "Update Rights",
                          style: GoogleFonts.poppins(
                            fontSize: 12.0,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF1E1E1E),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      barrierColor: Colors.white.withOpacity(0.7),
      pillColor: const Color(0xFFD3E4FF),
      backgroundColor: const Color(0xFF484848),
    );
  }
////////////////////////////////////////////////////////////////////////////////

// CHANNELS /////////////////////////////////////////////////////////////////////
// CREAR CANAL
  Future<bool> createChannel(
      String phoneNumber, String title, String desc) async {
    try {
      showLoadingDialog(context, mainColor);

      final response = await http.post(Uri.parse('$server/create_channel'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(
              {'phone_number': "+$phoneNumber", 'title': title, 'desc': desc}));

      if (response.statusCode == 200) {
        if (kDebugMode) {
          print("Grupo creado");
        }
        final channels = await getChannels(widget.phoneNumber);

        setState(() {
          userChannels = channels['channels'];
        });
        Navigator.of(context).pop();

        return true;
      } else {
        throw Exception('Error al crear el grupo');
      }
    } catch (error) {
      if (kDebugMode) {
        print(error);
      }
    }

    return false;
  }

// DIALOGO CREACION CANAL
  Future<bool> showCreateChannel(BuildContext context) async {
    final TextEditingController name = TextEditingController();
    final TextEditingController about = TextEditingController();
    bool isDone = false;

    Completer<bool> completer = Completer<bool>();

    await Alert(
        type: AlertType.none,
        context: context,
        title: "New Channel",
        style: AlertStyle(
          backgroundColor: cardBgColor,
          isCloseButton: false,
          titleStyle: GoogleFonts.poppins(
            fontWeight: FontWeight.w500,
            color: cardTextColor,
          ),
        ),
        content: Column(
          children: [
            const SizedBox(
              height: 10,
            ),
            Container(
              height: 50,
              width: 225,
              decoration: BoxDecoration(
                color: textFieldColor,
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: TextField(
                controller: name,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 12.0,
                    horizontal: 16.0,
                  ),
                  icon: const Padding(
                    padding: EdgeInsets.only(left: 8.0),
                    child: Icon(Icons.add),
                  ),
                  iconColor: textColor,
                  labelStyle: GoogleFonts.poppins(
                    fontWeight: FontWeight.w500,
                    color: textColor,
                  ),
                  labelText: 'Channel Name',
                  border: InputBorder.none,
                ),
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w500,
                  color: textColor,
                ),
                cursorColor: mainColor,
              ),
            ),
            const SizedBox(height: 16.0),
            Container(
              height: 60,
              width: 225,
              decoration: BoxDecoration(
                color: textFieldColor,
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: SingleChildScrollView(
                child: TextField(
                  controller: about,
                  maxLines: null,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w500,
                    color: textColor,
                  ),
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 12.0,
                      horizontal: 16.0,
                    ),
                    icon: const Padding(
                      padding: EdgeInsets.only(left: 8.0),
                      child: Icon(Icons.add_comment_rounded),
                    ),
                    iconColor: textColor,
                    labelStyle: GoogleFonts.poppins(
                      fontWeight: FontWeight.w500,
                      color: textColor,
                    ),
                    labelText: 'New Description',
                    border: InputBorder.none,
                  ),
                  cursorColor: mainColor,
                ),
              ),
            )
          ],
        ),
        buttons: [
          DialogButton(
            color: Colors.transparent,
            onPressed: () => Navigator.pop(context),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD3E4FF),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
              ),
              onPressed: () async {
                Navigator.pop(context);
                isDone = await createChannel(
                    widget.phoneNumber, name.text, about.text);
                completer.complete(isDone);
              },
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.check_rounded,
                      color: Color(0xFF1E1E1E),
                      size: 20.0,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      "Confirm",
                      style: GoogleFonts.poppins(
                        fontSize: 12.0,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF1E1E1E),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          DialogButton(
            color: Colors.transparent,
            onPressed: () => Navigator.pop(context),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2F4156),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
              ),
              onPressed: () async {
                Navigator.pop(context);
                completer.complete(false);
              },
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Text(
                  "Cancel",
                  style: GoogleFonts.poppins(
                    fontSize: 12.0,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          )
        ]).show();
    isDone = await completer.future;

    return isDone;
  }

// EDITAR CANAL
  Future<bool> editChannel(
      String phoneNumber, int channelId, String title, String about) async {
    try {
      showLoadingDialog(context, mainColor);

      final response = await http.post(Uri.parse('$server/edit_channel'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'phone_number': "+$phoneNumber",
            'id': channelId,
            'title': title,
            'about': about
          }));

      if (response.statusCode == 200) {
        if (kDebugMode) {
          print("Grupo editado");
        }
        final channels = await getChannels(widget.phoneNumber);

        setState(() {
          userChannels = channels['channels'];
        });
        Navigator.of(context).pop();

        return true;
      } else {
        throw Exception('Error al editar el grupo');
      }
    } catch (error) {
      if (kDebugMode) {
        print(error);
      }
    }

    return false;
  }

// DIALOGO EDITAR CANAL
  Future<bool> showEditChannel(BuildContext context, int channelId) async {
    bool isDone = false;

    final TextEditingController name = TextEditingController();
    final TextEditingController about = TextEditingController();

    Completer<bool> completer = Completer<bool>();
    await Alert(
        type: AlertType.none,
        context: context,
        title: "Edit Channel Name",
        style: AlertStyle(
          backgroundColor: cardBgColor,
          isCloseButton: false,
          titleStyle: GoogleFonts.poppins(
            fontWeight: FontWeight.w500,
            color: cardTextColor,
          ),
        ),
        content: Column(
          children: [
            const SizedBox(
              height: 10,
            ),
            Container(
              height: 50,
              width: 225,
              decoration: BoxDecoration(
                color: textFieldColor,
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: TextField(
                controller: name,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 12.0,
                    horizontal: 16.0,
                  ),
                  icon: const Padding(
                    padding: EdgeInsets.only(left: 8.0),
                    child: Icon(Icons.edit),
                  ),
                  iconColor: textColor,
                  labelStyle: GoogleFonts.poppins(
                    fontWeight: FontWeight.w500,
                    color: textColor,
                  ),
                  labelText: 'New Name',
                  border: InputBorder.none,
                ),
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w500,
                  color: textColor,
                ),
                cursorColor: mainColor,
              ),
            ),
            const SizedBox(height: 16.0),
            Container(
              height: 60,
              width: 225,
              decoration: BoxDecoration(
                color: textFieldColor,
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: SingleChildScrollView(
                child: TextField(
                  controller: about,
                  maxLines: null,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w500,
                    color: textColor,
                  ),
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 12.0,
                      horizontal: 16.0,
                    ),
                    icon: const Padding(
                      padding: EdgeInsets.only(left: 8.0),
                      child: Icon(Icons.edit_note_rounded),
                    ),
                    iconColor: textColor,
                    labelStyle: GoogleFonts.poppins(
                      fontWeight: FontWeight.w500,
                      color: textColor,
                    ),
                    labelText: 'New Description',
                    border: InputBorder.none,
                  ),
                  cursorColor: mainColor,
                ),
              ),
            )
          ],
        ),
        buttons: [
          DialogButton(
            color: Colors.transparent,
            onPressed: () => Navigator.pop(context),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD3E4FF),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
              ),
              onPressed: () async {
                Navigator.pop(context);
                isDone = await editChannel(
                    widget.phoneNumber, channelId, name.text, about.text);
                completer.complete(isDone);
              },
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.check_rounded,
                      color: Color(0xFF1E1E1E),
                      size: 20.0,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      "Confirm",
                      style: GoogleFonts.poppins(
                        fontSize: 12.0,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF1E1E1E),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          DialogButton(
            color: Colors.transparent,
            onPressed: () => Navigator.pop(context),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2F4156),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
              ),
              onPressed: () async {
                Navigator.pop(context);
                completer.complete(false);
              },
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Text(
                  "Cancel",
                  style: GoogleFonts.poppins(
                    fontSize: 12.0,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          )
        ]).show();

    isDone = await completer.future;

    return isDone;
  }

// BORRAR CANAL
  Future<bool> deleteChannel(String phoneNumber, int channelId) async {
    try {
      showLoadingDialog(context, mainColor); // Muestra el diálogo de carga

      final response = await http.post(Uri.parse('$server/delete_channel'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'phone_number': "+$phoneNumber", 'id': channelId}));

      if (response.statusCode == 200) {
        if (kDebugMode) {
          print("Grupo eliminado");
        }
        final channels = await getChannels(widget.phoneNumber);

        setState(() {
          userChannels = channels['channels'];
        });
        Navigator.of(context).pop();

        return true;
      } else {
        throw Exception('Error al eliminar el grupo');
      }
    } catch (error) {
      if (kDebugMode) {
        print(error);
      }
    }

    return false;
  }

// DIALOGO BORRAR CANAL
  Future<bool> showDeleteChannel(BuildContext context, int channelId) async {
    bool isDone = false;

    Completer<bool> completer = Completer<bool>();
    await Alert(
        type: AlertType.warning,
        context: context,
        title: "Delete Channel",
        style: AlertStyle(
          backgroundColor: cardBgColor,
          isCloseButton: false,
          titleStyle: GoogleFonts.poppins(
            fontWeight: FontWeight.w500,
            color: cardTextColor,
          ),
        ),
        buttons: [
          DialogButton(
            color: Colors.transparent,
            onPressed: () => Navigator.pop(context),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD3E4FF),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
              ),
              onPressed: () async {
                Navigator.pop(context);
                isDone = await deleteChannel(widget.phoneNumber, channelId);
                completer.complete(isDone);
              },
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.check_rounded,
                      color: Color(0xFF1E1E1E),
                      size: 20.0,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      "Confirm",
                      style: GoogleFonts.poppins(
                        fontSize: 12.0,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF1E1E1E),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          DialogButton(
            color: Colors.transparent,
            onPressed: () => Navigator.pop(context),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2F4156),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
              ),
              onPressed: () async {
                Navigator.pop(context);
                completer.complete(false);
              },
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Text(
                  "Cancel",
                  style: GoogleFonts.poppins(
                    fontSize: 12.0,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          )
        ]).show();
    isDone = await completer.future;

    return isDone;
  }
/////////////////////////////////////////////////////////////////////////////////

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: onBackPressed,
      child: Scaffold(
        appBar: AppBar(
          title: Padding(
            padding: const EdgeInsets.only(left: 20.0),
            child: Text(
              "TGPersonalCloud",
              style: GoogleFonts.poppins(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
                color: const Color(0xFFFFFFFF),
              ),
            ),
          ),
          titleSpacing: 0.0,
          toolbarHeight: 60.2,
          toolbarOpacity: 0.8,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              bottomRight: Radius.circular(25),
              bottomLeft: Radius.circular(25),
            ),
          ),
          elevation: 0.0,
          backgroundColor: appBarBgColor,
          actions: [
            IconButton(
              color: const Color(0xFFFFFFFF),
              onPressed: () {
                initializeAsyncData();
              },
              icon: const Icon(Icons.refresh),
            ),
            IconButton(
              color: const Color(0xFFFFFFFF),
              onPressed: () => {
                showPopup(widget.phoneNumber),
              },
              icon: const Icon(Icons.person),
            ),
          ],
          shadowColor: mainColor,
          automaticallyImplyLeading: false,
        ),
        backgroundColor: bgColor,
        body: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Center(
                child: Text(
                  "Canales BackUp",
                  style: GoogleFonts.poppins(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                    color: mainColor,
                  ),
                ),
              ),
            ),
            Expanded(
              child: isLoading
                  ? Center(
                      child: LoadingAnimationWidget.threeRotatingDots(
                          color: mainColor, size: 50),
                    )
                  : userChannels.isNotEmpty
                      ? ListView.builder(
                          itemCount: userChannels.length,
                          itemBuilder: (BuildContext context, int index) {
                            final channel = userChannels[index];
                            final channelId = channel['id'];
                            final channelTitle = channel['title'];
                            final channelDesc = channel['desc'];
                            final GlobalKey<ExpansionTileCardState> cardKey =
                                GlobalKey();

                            return Column(
                              children: [
                                Container(
                                  margin:
                                      const EdgeInsets.fromLTRB(25, 0, 25, 0),
                                  decoration: BoxDecoration(
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(10.0)),
                                    boxShadow: [
                                      BoxShadow(
                                        color: mainColor,
                                        blurRadius: 5.0,
                                      ),
                                    ],
                                  ),
                                  child: ExpansionTileCard(
                                    trailing: const Icon(null),
                                    borderRadius: BorderRadius.circular(10),
                                    baseColor: cardBgColor,
                                    expandedColor: cardBgColor,
                                    expandedTextColor: cardTextColor,
                                    key: cardKey,
                                    leading: CircleAvatar(
                                      backgroundColor: mainColor,
                                      child: Text(
                                        (index + 1).toString(),
                                        style: GoogleFonts.poppins(
                                          fontSize: 16.0,
                                          fontWeight: FontWeight.bold,
                                          color: const Color(0xFFFFFFFF),
                                        ),
                                      ),
                                    ),
                                    title: Text(
                                      channelTitle,
                                      style: GoogleFonts.poppins(
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.bold,
                                        color: cardTextColor,
                                      ),
                                    ),
                                    subtitle: Text(
                                      channelDesc.isEmpty
                                          ? 'Copias de seguridad del canal $channelTitle'
                                          : channelDesc,
                                      style: GoogleFonts.poppins(
                                        fontSize: 12.0,
                                        fontWeight: FontWeight.normal,
                                        color: cardTextColor,
                                      ),
                                    ),
                                    children: <Widget>[
                                      Divider(
                                        thickness: 3.0,
                                        height: 1.0,
                                        color: mainColor,
                                      ),
                                      ButtonBar(
                                        alignment:
                                            MainAxisAlignment.spaceEvenly,
                                        buttonHeight: 52.0,
                                        buttonMinWidth: 90.0,
                                        children: <Widget>[
                                          ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  const Color(0xFFD3E4FF),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(20.0),
                                              ),
                                            ),
                                            onPressed: () async {
                                              Navigator.push(
                                                context,
                                                Transition(
                                                  child: TopicsPage(
                                                      widget.phoneNumber,
                                                      channelId,
                                                      channelTitle,
                                                      darkMode,
                                                      mainColor),
                                                  transitionEffect:
                                                      TransitionEffect.FADE,
                                                ),
                                              );
                                            },
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(12.0),
                                              child: Text(
                                                "Show Topics",
                                                style: GoogleFonts.poppins(
                                                  fontSize: 12.0,
                                                  fontWeight: FontWeight.w500,
                                                  color:
                                                      const Color(0xFF1E1E1E),
                                                ),
                                              ),
                                            ),
                                          ),
                                          Ink(
                                            decoration: ShapeDecoration(
                                              color: const Color(0xFF2F4156),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10.0),
                                              ),
                                            ),
                                            child: IconButton(
                                              icon: const Icon(Icons.person),
                                              color: Colors.white,
                                              onPressed: () async {
                                                showUsers(channelId);
                                              },
                                            ),
                                          ),
                                          Ink(
                                            decoration: ShapeDecoration(
                                              color: const Color(0xFF2F4156),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10.0),
                                              ),
                                            ),
                                            child: IconButton(
                                              icon: const Icon(Icons.edit),
                                              color: Colors.white,
                                              onPressed: () async {
                                                if (await showEditChannel(
                                                    context, channelId)) {
                                                  showTopSnackBar(
                                                    Overlay.of(context),
                                                    const CustomSnackBar
                                                        .success(
                                                      message:
                                                          "Channel information successfully updated.",
                                                    ),
                                                  );
                                                }
                                              },
                                            ),
                                          ),
                                          Ink(
                                            decoration: ShapeDecoration(
                                              color: const Color(0xFF2F4156),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10.0),
                                              ),
                                            ),
                                            child: IconButton(
                                              icon: const Icon(Icons.delete),
                                              color: Colors.white,
                                              onPressed: () async {
                                                if (await showDeleteChannel(
                                                    context, channelId)) {
                                                  showTopSnackBar(
                                                    Overlay.of(context),
                                                    const CustomSnackBar
                                                        .success(
                                                      message:
                                                          "Channel successfully deleted.",
                                                    ),
                                                  );
                                                }
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 20.0),
                                if (userChannels.length < 6 &&
                                    index == userChannels.length - 1)
                                  SizedBox(
                                    width: 150,
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            const Color(0xFFD3E4FF),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(20.0),
                                        ),
                                      ),
                                      onPressed: () async {
                                        if (kDebugMode) {
                                          print(userChannels.length - 1);
                                        }
                                        if (kDebugMode) {
                                          print(index);
                                        }
                                        if (await showCreateChannel(context)) {
                                          showTopSnackBar(
                                            Overlay.of(context),
                                            const CustomSnackBar.success(
                                              message:
                                                  "Good job, your release is successful. Have a nice day",
                                            ),
                                          );
                                        }
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                            0, 10, 0, 10),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            const Icon(
                                              Icons.add,
                                              color: Color(0xFF1E1E1E),
                                              size: 20.0,
                                            ),
                                            const SizedBox(width: 5),
                                            Text(
                                              "New Channel",
                                              style: GoogleFonts.poppins(
                                                fontSize: 12.0,
                                                fontWeight: FontWeight.w500,
                                                color: const Color(0xFF1E1E1E),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            );
                          },
                        )
                      : Center(
                          child: SizedBox(
                            width: 150,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFD3E4FF),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20.0),
                                ),
                              ),
                              onPressed: () async {
                                if (kDebugMode) {
                                  print(userChannels.length - 1);
                                }
                                if (await showCreateChannel(context)) {
                                  showTopSnackBar(
                                    Overlay.of(context),
                                    const CustomSnackBar.success(
                                      message:
                                          "Good job, your release is successful. Have a nice day",
                                    ),
                                  );
                                }
                              },
                              child: Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(0, 10, 0, 10),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.add,
                                      color: Color(0xFF1E1E1E),
                                      size: 20.0,
                                    ),
                                    const SizedBox(width: 5),
                                    Text(
                                      "New Channel",
                                      style: GoogleFonts.poppins(
                                        fontSize: 12.0,
                                        fontWeight: FontWeight.w500,
                                        color: const Color(0xFF1E1E1E),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const SizedBox(width: 16),
                FloatingActionButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        Transition(
                            child: ChatPage(darkMode),
                            transitionEffect: TransitionEffect.FADE));
                  },
                  backgroundColor: mainColor,
                  child: const Icon(Icons.send_rounded),
                ),
                const SizedBox(
                  width: 40,
                ),
              ],
            ),
            const SizedBox(
                height:
                    40), // Añade un espacio de 20 de altura debajo del FloatingActionButton
          ],
        ),
      ),
    );
  }
}

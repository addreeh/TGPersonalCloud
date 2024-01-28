// ignore_for_file: use_build_context_synchronously

import 'dart:async';

import 'package:dropdown_model_list/drop_down/model.dart';
import 'package:dropdown_model_list/drop_down/select_drop_list.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_multi_select_items/flutter_multi_select_items.dart';
import 'package:foldable_list/foldable_list.dart';
import 'package:foldable_list/resources/arrays.dart' as manolito;
import 'package:get/get_navigation/src/routes/transitions_type.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:http/http.dart' as http;
import 'package:tgpersonalcloud/in/topics.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'dart:convert';
import 'package:top_snackbar_flutter/top_snack_bar.dart';
import 'package:slide_popup_dialog_null_safety/slide_popup_dialog.dart'
    // ignore: library_prefixes
    as slideDialog;

import 'package:rflutter_alert/rflutter_alert.dart';

String server = "http://10.0.2.2:5000";

class ChannelsPage extends StatefulWidget {
  final String phoneNumber;
  const ChannelsPage(this.phoneNumber, {super.key});

  @override
  ChannelsPageState createState() => ChannelsPageState();
}

class ChannelsPageState extends State<ChannelsPage> {
  late List<Widget> simpleWidgetList;
  late List<Widget> expandedWidgetList;
  bool isLoading = true;
  bool isDone = false;
  bool isLoadingCreate = false;

  List<dynamic> userGroups = [];
  List<dynamic> usersList = [];

  @override
  void initState() {
    super.initState();
    try {
      _initializeAsyncData();
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  // OBTENER GRUPOS DEL USUARIO
  Future<bool> sendRights(String phoneNumber, int channelId, String? userId,
      List selectedRights) async {
    final response = await http.post(Uri.parse('$server/send_rights'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'phone_number': "+$phoneNumber",
          'channel_id': "$channelId",
          'user_id': "$userId",
          'selected_rights': selectedRights
        }));

    if (response.statusCode == 200) return true;
    return false;
  }

  // OBTENER GRUPOS DEL USUARIO
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

  Future<bool> _onBackPressed() {
    return Future.value(false);
  }

  Widget renderSimpleWidget(group, int cont) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 0),
      height: 75,
      decoration: const BoxDecoration(
        color: Color(0xFF3C3C3C),
        borderRadius: BorderRadius.all(Radius.circular(10.0)),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF58ACFF),
            blurRadius: 5.0,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(
              width: 10,
            ),
            Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: Color(0xFF58ACFF),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                cont.toString(),
                style: const TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFFFFFFF),
                ),
              ),
            ),
            const SizedBox(
              width: 20,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  group['title'],
                  style: GoogleFonts.poppins(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFFFFFFFF),
                  ),
                ),
                const SizedBox(
                  height: 7.5,
                ),
                Text(
                  group['desc'].isEmpty
                      ? 'Copias de seguridad del canal ${group['title']}'
                      : group['desc'],
                  style: GoogleFonts.poppins(
                    fontSize: 12.0,
                    fontWeight: FontWeight.normal,
                    color: const Color(0xFFFFFFFF),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget renderExpandedWidget(group, int cont) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 0),
      height: 150,
      decoration: const BoxDecoration(
        color: Color(0xFF3C3C3C),
        borderRadius: BorderRadius.all(Radius.circular(10.0)),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF58ACFF),
            blurRadius: 5.0,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(
              width: 10,
            ),
            Column(
              children: [
                SizedBox(
                  height: 7.5,
                ),
                Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    color: Color(0xFF58ACFF),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    cont.toString(),
                    style: const TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFFFFFFF),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(
              width: 20,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  group['title'],
                  style: GoogleFonts.poppins(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFFFFFFFF),
                  ),
                ),
                const SizedBox(
                  height: 7.5,
                ),
                Text(
                  group['desc'].isEmpty
                      ? 'Copias de seguridad del canal ${group['title']}'
                      : group['desc'],
                  style: GoogleFonts.poppins(
                    fontSize: 12.0,
                    fontWeight: FontWeight.normal,
                    color: const Color(0xFFFFFFFF),
                  ),
                ),
                const Divider(
                  thickness: 3.0,
                  height: 1.0,
                  color: Color(0xFF58ACFF),
                ),
                ButtonBar(
                  alignment: MainAxisAlignment.spaceEvenly,
                  buttonHeight: 52.0,
                  buttonMinWidth: 90.0,
                  children: <Widget>[
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD3E4FF),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                      ),
                      onPressed: () async {},
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Text(
                          "Show Topics",
                          style: GoogleFonts.poppins(
                            fontSize: 12.0,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF1E1E1E),
                          ),
                        ),
                      ),
                    ),
                    Ink(
                      decoration: ShapeDecoration(
                        color: const Color(0xFF2F4156),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.person),
                        color: Colors.white,
                        onPressed: () async {
                          showUsers(group['id']);
                        },
                      ),
                    ),
                    Ink(
                      decoration: ShapeDecoration(
                        color: const Color(0xFF2F4156),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.edit),
                        color: Colors.white,
                        onPressed: () async {
                          if (!await showEditChannelDialog(
                              context, group['id'])) {
                            showTopSnackBar(
                              Overlay.of(context),
                              const CustomSnackBar.error(
                                message:
                                    "Something went wrong. Please check your credentials and try again",
                              ),
                            );
                          } else {
                            showTopSnackBar(
                              Overlay.of(context),
                              const CustomSnackBar.success(
                                message: "Channel name successfully edited.",
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
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.delete),
                        color: Colors.white,
                        onPressed: () async {
                          if (!await showDeleteChannelDialog(
                              context, group['id'])) {
                            showTopSnackBar(
                              Overlay.of(context),
                              const CustomSnackBar.error(
                                message:
                                    "Something went wrong. Please check your credentials and try again",
                              ),
                            );
                          } else {
                            showTopSnackBar(
                              Overlay.of(context),
                              const CustomSnackBar.success(
                                message: "Channel successfully deleted.",
                              ),
                            );
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Future<void> _initializeAsyncData() async {
    try {
      setState(() {
        isLoading = true; // Indicar que se está cargando
      });

      final groups = await getChannels(widget.phoneNumber);

      this.simpleWidgetList = [];
      this.expandedWidgetList = [];

      setState(() {
        userGroups = groups['groups'];
        var cont = 1;
        for (var group in userGroups) {
          this.simpleWidgetList.add(renderSimpleWidget(group, cont));
          this.expandedWidgetList.add(renderExpandedWidget(group, cont));
          cont++;
        }
        // userGroups = [];
        isLoading = false; // Indicar que la carga ha finalizado
      });
    } catch (e) {
      if (kDebugMode) {
        print("Error al obtener grupos: $e");
      }
    }
  }

  // OBTENER GRUPOS DEL USUARIO
  Future<Map<String, dynamic>> getUsers(
      String phoneNumber, int channelId) async {
    final response = await http.post(Uri.parse('$server/get_users'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(
            {'phone_number': "+$phoneNumber", 'channel_id': channelId}));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error al obtener los grupos');
    }
  }

  // OBTENER GRUPOS DEL USUARIO
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

  // OBTENER GRUPOS DEL USUARIO
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

  Future<bool> sendUser(
      String phoneNumber, int channelId, String contactId) async {
    final response = await http.post(Uri.parse('$server/insert_user'),
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
        showTopSnackBar(
          Overlay.of(context),
          CustomSnackBar.error(
            message:
                "Something went wrong. Please check your credentials and try again",
            textStyle: GoogleFonts.poppins(),
          ),
        );
      }
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
    return false;
  }

  void refreshUsersList(int channelId) async {
    final users = await getUsers(widget.phoneNumber, channelId);
    setState(() {
      usersList = users['users'];
    });
  }

  showUsers(int channelId) async {
    final users = await getUsers(widget.phoneNumber, channelId);
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

    // Define a TextEditingController and a variable to store the entered text
    final TextEditingController textFieldController = TextEditingController();

    slideDialog.showSlideDialog(
      context: context,
      child: Column(
        children: [
          // Center the TextField and Button
          Center(
            child: Container(
              margin: const EdgeInsets.symmetric(
                  horizontal: 30), // Añade márgenes para separar del borde
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: textFieldController,
                      decoration: InputDecoration(
                          hintText: "Search Users",
                          hintStyle: GoogleFonts.poppins(
                            fontWeight: FontWeight.w500,
                          )),
                    ),
                  ),
                  const SizedBox(
                    width: 30,
                  ),
                  // Configura el botón para ocupar menos espacio
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
                          if (await sendUser(widget.phoneNumber, channelId,
                              textFieldController.text)) {
                            refreshUsersList(channelId);
                            Navigator.of(context)
                                .pop(); // Cierra el diálogo anterior

                            showUsers(
                                channelId); // Llama a showUsers nuevamente para actualizar el dialog
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
                ///Simple DropDown
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
      pillColor: const Color.fromRGBO(88, 172, 255, 1),
      backgroundColor: const Color(0xFF484848),
    );
  }

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
          // Center the TextField and Button
          Center(
            child: Container(
              margin: const EdgeInsets.symmetric(
                  horizontal: 30), // Añade márgenes para separar del borde
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
              Column(
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
            ],
          ),
        ],
      ),
      barrierColor: Colors.white.withOpacity(0.7),
      pillColor: const Color(0xFFD3E4FF),
      backgroundColor: const Color(0xFF484848),
    );
  }

  showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF484848),
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
                  color: const Color(0xFFFFFFFF),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  Future<bool> showCreateChannelDialog(BuildContext context) async {
    final TextEditingController name = TextEditingController();
    final TextEditingController description = TextEditingController();
    bool isDone = false;

    // Utilizamos un Completer para esperar la ejecución de createChannel
    Completer<bool> completer = Completer<bool>();

    await Alert(
        type: AlertType.none,
        context: context,
        title: "New Channel",
        style: AlertStyle(
          isCloseButton: false,
          titleStyle: GoogleFonts.poppins(
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
        content: Column(
          children: <Widget>[
            SizedBox(
              width: 225,
              child: TextField(
                controller: name,
                decoration: const InputDecoration(
                  icon: Icon(Icons.add),
                  labelText: 'Channel Name',
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                ),
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ),
            SizedBox(
              width: 225,
              child: TextField(
                controller: name,
                decoration: const InputDecoration(
                  icon: Icon(Icons.add_comment_rounded),
                  labelText: 'Channel Description',
                ),
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ),
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
                    widget.phoneNumber, name.text, description.text);
                // Resolvemos el Completer con el valor de isDone
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
                    const SizedBox(
                        width: 5), // Espacio entre el icono y el texto
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
    // Esperamos a que el Completer se complete antes de devolver el valor
    isDone = await completer.future;

    return isDone;
  }

  //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  Future<bool> showEditChannelDialog(
      BuildContext context, int idChannel) async {
    bool isDone = false;

    final TextEditingController name = TextEditingController();

    Completer<bool> completer = Completer<bool>();
    await Alert(
        type: AlertType.none,
        context: context,
        title: "Edit Channel Name",
        style: AlertStyle(
          isCloseButton: false,
          titleStyle: GoogleFonts.poppins(
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
        content: TextField(
          controller: name,
          decoration: const InputDecoration(
            icon: Icon(Icons.edit),
            labelText: 'New Name',
          ),
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w500,
            color: Colors.white,
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
                isDone =
                    await editChannel(widget.phoneNumber, idChannel, name.text);
                // Resolvemos el Completer con el valor de isDone
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
                    const SizedBox(
                        width: 5), // Espacio entre el icono y el texto
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

    // Esperamos a que el Completer se complete antes de devolver el valor
    isDone = await completer.future;

    return isDone;
  }

  //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  Future<bool> showDeleteChannelDialog(
      BuildContext context, int idChannel) async {
    bool isDone = false;

    // Utilizamos un Completer para esperar la ejecución de createChannel
    Completer<bool> completer = Completer<bool>();
    await Alert(
        type: AlertType.warning,
        context: context,
        title: "Delete Channel",
        style: AlertStyle(
          isCloseButton: false,
          titleStyle: GoogleFonts.poppins(
            fontWeight: FontWeight.w500,
            color: Colors.white,
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
                isDone = await deleteChannel(widget.phoneNumber, idChannel);
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
                    const SizedBox(
                        width: 5), // Espacio entre el icono y el texto
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
    // Esperamos a que el Completer se complete antes de devolver el valor
    isDone = await completer.future;

    return isDone;
  }

  // CREAR GRUPO
  Future<bool> createChannel(
      String phoneNumber, String title, String desc) async {
    try {
      showLoadingDialog(context); // Muestra el diálogo de carga

      final response = await http.post(Uri.parse('$server/create_channel'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(
              {'phone_number': "+$phoneNumber", 'title': title, 'desc': desc}));

      if (response.statusCode == 200) {
        if (kDebugMode) {
          print("Grupo creado");
        }
        final groups = await getChannels(widget.phoneNumber);

        setState(() {
          userGroups = groups['groups'];
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

  // CREAR GRUPO
  Future<bool> editChannel(
      String phoneNumber, int idChannel, String title) async {
    try {
      showLoadingDialog(context); // Muestra el diálogo de carga

      final response = await http.post(Uri.parse('$server/edit_channel'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'phone_number': "+$phoneNumber",
            'id': idChannel,
            'title': title
          }));

      if (response.statusCode == 200) {
        if (kDebugMode) {
          print("Grupo editado");
        }
        final groups = await getChannels(widget.phoneNumber);

        setState(() {
          userGroups = groups['groups'];
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

  // BORRAR GRUPO
  Future<bool> deleteChannel(String phoneNumber, int idChannel) async {
    try {
      showLoadingDialog(context); // Muestra el diálogo de carga

      final response = await http.post(Uri.parse('$server/delete_channel'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'phone_number': "+$phoneNumber", 'id': idChannel}));

      if (response.statusCode == 200) {
        if (kDebugMode) {
          print("Grupo eliminado");
        }
        final groups = await getChannels(widget.phoneNumber);

        setState(() {
          userGroups = groups['groups'];
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

  Future<void> _showPopup(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF484848),
          title: Text(
            "Título del Popup",
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w500,
              color: const Color(0xFF7C8BA0),
            ),
          ),
          content: Text(
            "Este es un mensaje de ejemplo en el popup.",
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w500,
              color: const Color(0xFF7C8BA0),
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                "Cerrar",
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF7C8BA0),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onBackPressed,
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
          backgroundColor: const Color(0xFF222222),
          actions: [
            IconButton(
              onPressed: () {
                _initializeAsyncData();
              },
              icon: const Icon(
                  Icons.refresh), // Aquí puedes usar el icono de recarga
            ),
            IconButton(
              onPressed: () => {
                _showPopup(context),
              },
              icon: const Icon(Icons.more_vert),
            ),
          ],
          shadowColor: const Color(0xFF58ACFF),
          automaticallyImplyLeading: false,
        ),
        backgroundColor: const Color(0xFF1E1E1E),
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
                    color: const Color(0xFF58ACFF),
                  ),
                ),
              ),
            ),
            Expanded(
              child: isLoading
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
                  : userGroups.isNotEmpty
                      ? Container(
                          child: FoldableList(
                              animationType: manolito.AnimationType.scale,
                              foldableItems: this.expandedWidgetList,
                              items: this.simpleWidgetList),
                        )
                      : Center(
                          child: Text(
                            "Todavía no existen grupos :(",
                            style: GoogleFonts.poppins(
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFFFFFFFF),
                            ),
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }
}

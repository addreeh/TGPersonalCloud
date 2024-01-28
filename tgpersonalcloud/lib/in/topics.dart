// ignore_for_file: use_build_context_synchronously, depend_on_referenced_packages

import 'dart:async';
import 'dart:io';

import 'package:cron/cron.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:accordion/accordion.dart';
import 'package:file_picker/file_picker.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:path/path.dart' as path;
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:tgpersonalcloud/functions.dart';

String server = getServerString();

// Mapa para mapear los valores de color a los colores correspondientes
Map<int, Color> colorMap = {
  7322096: const Color(0xBB6FB9F0),
  16766590: const Color(0xBBFFD67E),
  13338331: const Color(0xBBCB86DB),
  9367192: const Color(0xBB8EEE98),
  16749490: const Color(0xBBFF93B2),
  16478047: const Color(0xBBFB6F5F),
};

class TopicsPage extends StatefulWidget {
  final String phoneNumber;
  final int channelId;
  final String channelTitle;
  final bool darkMode;
  final Color mainColor;
  const TopicsPage(this.phoneNumber, this.channelId, this.channelTitle,
      this.darkMode, this.mainColor,
      {super.key});

  @override
  TopicsPageState createState() => TopicsPageState();
}

class TopicsPageState extends State<TopicsPage> {
  bool isLoading = true;
  List<dynamic> topicsList = [];
  List<Accordion> accordionList = [];
  Map<int, Map<int, Set<String>>> selectedFolders = {};
  String? selectedTime;
  String buttonText = "Timer";

  var mainColor = const Color(0xFF58ACFF);

  late Color bgColor;
  late Color boxColor;
  late Color textFieldColor;
  late Color textColor;
  late Color indicatorColor;
  late Color countryColor;
  late Color loadingBgColor;
  late Color loadingTextColor;
  late Color appBarBgColor;
  late Color cardTextColor;
  late Color cardBgColor;
  late Color cardBgExpColor;
  late Color userListBgColor;
  late Color dialogTextColor;

  @override
  void didChangeDependencies() {
    // Llamado después de que el widget ha sido construido
    super.didChangeDependencies();
    mainColor = widget.mainColor;
    if (!widget.darkMode) {
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
    } else if (widget.darkMode) {
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
  }

  @override
  void initState() {
    super.initState();
    try {
      initializeAsyncData();
      loadSelectedFolders();
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

// INIT /////////////////////////////////////////////////////////////////////
// INICIALIZAR DATOS
  Future<void> initializeAsyncData() async {
    try {
      setState(() {
        isLoading = true;
      });

      final topics = await getTopics(widget.phoneNumber, widget.channelId);
      final List<dynamic> topicsListMessages = topics['topics'];

      for (var i = 0; i < topicsListMessages.length; i++) {
        final topicId = topicsListMessages[i]['id'];
        final messages =
            await getMessages(widget.phoneNumber, widget.channelId, topicId);

        final filteredMessages = messages['messages']
            .where((message) =>
                message['file_size'] != null || message['text'] != null)
            .toList();

        // Obtener solo los primeros diez mensajes
        final firstTenMessages = filteredMessages.length > 5
            ? filteredMessages.take(5).toList()
            : filteredMessages;

        topicsListMessages[i]['content'] = {'messages': firstTenMessages};
      }

      setState(() {
        topicsList = topicsListMessages;
        isLoading = false;
      });
    } catch (e) {
      if (kDebugMode) {
        print("Error al obtener grupos: $e");
      }
    }
  }

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

// TOPICS ///////////////////////////////////////////////////////////////////////////////////////////////////////////
// CREAR TOPIC
  Future<bool> createTopic(
      String phoneNumber, int channelId, String title) async {
    try {
      showLoadingDialog(context, mainColor); // Muestra el diálogo de carga

      final response = await http.post(Uri.parse('$server/create_topic'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'phone_number': "+$phoneNumber",
            'channel_id': channelId,
            'title': title
          }));

      if (response.statusCode == 200) {
        if (kDebugMode) {
          print("Grupo creado");
        }
        initializeAsyncData();

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

// DIALOGO CREAR TOPIC
  Future<bool> showCreateDialog() async {
    final TextEditingController name = TextEditingController();
    bool isCreated = false;

    Completer<bool> completer = Completer<bool>();

    await Alert(
        type: AlertType.none,
        context: context,
        title: "New Topic",
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
                  labelText: 'Topic Name',
                  border: InputBorder.none,
                ),
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w500,
                  color: textColor,
                ),
                cursorColor: mainColor,
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
                isCreated = await createTopic(
                    widget.phoneNumber, widget.channelId, name.text);
                completer.complete(isCreated);
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

    isCreated = await completer.future;

    return isCreated;
  }

// BORRAR TOPIC
  Future<bool> deleteTopic(
      String phoneNumber, int channelId, int topicId) async {
    try {
      showLoadingDialog(context, mainColor); // Muestra el diálogo de carga

      final response = await http.post(Uri.parse('$server/delete_topic'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'phone_number': "+$phoneNumber",
            'channel_id': channelId,
            'topic_id': topicId
          }));

      if (response.statusCode == 200) {
        if (kDebugMode) {
          print("Topic Eliminado");
        }
        initializeAsyncData();

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
  Future<bool> showDeleteTopic(
      BuildContext context, int channelId, int topicId) async {
    bool isDone = false;

    Completer<bool> completer = Completer<bool>();
    await Alert(
        type: AlertType.warning,
        context: context,
        title: "Delete Topic",
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
                isDone =
                    await deleteTopic(widget.phoneNumber, channelId, topicId);
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

// MESSAGES /////////////////////////////////////////////////////////////////////
// BORRAR TOPIC
  Future<bool> deleteMessages(
      String phoneNumber, int channelId, int topicId) async {
    try {
      showLoadingDialog(context, mainColor); // Muestra el diálogo de carga

      final response = await http.post(Uri.parse('$server/delete_messages'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'phone_number': "+$phoneNumber",
            'channel_id': channelId,
            'topic_id': topicId
          }));

      if (response.statusCode == 200) {
        if (kDebugMode) {
          print("Mensajes Eliminados");
        }
        initializeAsyncData();

        Navigator.of(context).pop();

        return true;
      } else {
        throw Exception('Error al eliminar los mensajes');
      }
    } catch (error) {
      if (kDebugMode) {
        print(error);
      }
    }

    return false;
  }

// DIALOGO BORRAR CANAL
  Future<bool> showDeleteMessages(
      BuildContext context, int channelId, int topicId) async {
    bool isDone = false;

    Completer<bool> completer = Completer<bool>();
    await Alert(
        type: AlertType.warning,
        context: context,
        title: "Delete Messages",
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
                isDone = await deleteMessages(
                    widget.phoneNumber, channelId, topicId);
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

// LISTAR ARCHIVOS Y ENVIAR AL TOPIC
  Future<void> fullSend() async {
    // Mostrar el diálogo de carga
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              LoadingAnimationWidget.fallingDot(color: mainColor, size: 50),
              const SizedBox(height: 16),
              const Text('Sending files ...'),
            ],
          ),
        );
      },
    );
    try {
      for (int index = 0; index < topicsList.length; index++) {
        String? selectedFolder = selectedFolders[widget.channelId]
                ?[topicsList[index]['id']]
            ?.firstOrNull;

        if (selectedFolder != null) {
          await listFilesAndSend(
              selectedFolder,
              widget.channelId,
              topicsList[index]['id'],
              widget
                  .phoneNumber); // Llama a la función para listar y mostrar los archivos
        }
      }
      // Cerrar el diálogo de carga cuando la función haya terminado
      Navigator.of(context, rootNavigator: true).pop();
    } catch (error) {
      // Manejar cualquier error que pueda ocurrir
      print('Error al enviar archivos: $error');
      // Cerrar el diálogo de carga y mostrar un mensaje de error
      Navigator.of(context, rootNavigator: true).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al enviar archivos')),
      );
    }
  }

// LISTAR ARCHIVOS Y ENVIAR
  Future<void> listFilesAndSend(String? selectedDirectory, int groupId,
      int topicId, String phoneNumber) async {
    if (selectedDirectory != null) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                LoadingAnimationWidget.fallingDot(color: mainColor, size: 50),
                const SizedBox(height: 16),
                Text(
                  'Sending files ...',
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

      try {
        final messages =
            await getMessages(phoneNumber, widget.channelId, topicId);

        final filteredMessages = messages['messages']
            .where((message) =>
                message['file_size'] != null || message['text'] != null)
            .toList();

        Directory directory = Directory(selectedDirectory);
        List<FileSystemEntity> files = directory.listSync();

        for (FileSystemEntity file in files) {
          if (file is File) {
            String fileName = file.uri.pathSegments.last;
            int fileSize = await file.length();

            bool fileMatched =
                false; // Bandera para indicar si se encontró una coincidencia para el archivo

            if (filteredMessages.isNotEmpty) {
              for (var message in filteredMessages) {
                print(message);
                if (message['text'] == fileName &&
                    message['file_size'] == fileSize) {
                  print(
                      'Mensaje: ${message['text']} coincide con el archivo: $fileName');
                  fileMatched =
                      true; // Establecer la bandera en true si hay una coincidencia
                }
              }
            }

            if (!fileMatched) {
              print("MALITO");
              await sendFileToTopic(file, groupId, topicId, phoneNumber);
              // Aquí puedes poner la lógica para enviar el archivo si no hay coincidencia
              // await sendFileToTopic(file, groupId, topicId, phoneNumber);
            }
          }
        }

        Navigator.of(context, rootNavigator: true).pop();
        try {
          showLoadingDialog(context, mainColor);

          initializeAsyncData();

          Navigator.of(context).pop();
        } catch (error) {
          throw Exception('Error al enviar el mensaje');
        }
      } catch (error) {
        Navigator.of(context, rootNavigator: true).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al enviar archivos')),
        );
      }
    }
  }
/////////////////////////////////////////////////////////////////////////////////

// FOLDERS //////////////////////////////////////////////////////////////////////
// SELECCIONAR CARPETA
  Future<void> pickFolder(Map<String, dynamic> topic) async {
    String? selectedDirectory = await FilePicker.platform.getDirectoryPath();
    if (selectedDirectory != null) {
      int topicId = topic['id'];
      selectedFolders[widget.channelId] ??= {};
      selectedFolders[widget.channelId]![topicId] = {};

      bool isFolderAlreadyAssigned = selectedFolders[widget.channelId]!
          .entries
          .any((entry) => entry.value.contains(selectedDirectory));

      if (isFolderAlreadyAssigned) {
        showTopSnackBar(
          Overlay.of(context),
          CustomSnackBar.error(
            message: "Something went wrong. The folder is already selected.",
            textStyle: GoogleFonts.poppins(),
          ),
        );
        return;
      }

      setState(() {
        selectedFolders[widget.channelId]![topicId]!.add(selectedDirectory);
      });
      await saveSelectedFolders();
    }
  }

// GUARDAR CARPETA SELECCIONADA
  Future<void> saveSelectedFolders() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      'selectedFolders_${widget.channelId}',
      selectedFolders[widget.channelId]
              ?.entries
              .map((entry) => '${entry.key}:${entry.value.join(',')}')
              .toList() ??
          [],
    );
  }

// CARGAR CARPETAS SELECCIONADAS
  Future<void> loadSelectedFolders() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? savedFolders =
        prefs.getStringList('selectedFolders_${widget.channelId}');
    if (savedFolders != null) {
      for (String folderEntry in savedFolders) {
        List<String> parts = folderEntry.split(':');
        int topicId = int.tryParse(parts[0]) ?? 0;
        Set<String> folders = parts[1].split(',').toSet();
        selectedFolders[widget.channelId] ??= {};
        selectedFolders[widget.channelId]![topicId] = folders;
      }
      setState(() {});
    }
  }

// RESETEAR TODAS LAS CARPETAS
  Future<void> clearSelectedFolders() async {
    setState(() {
      selectedFolders[widget.channelId] = {};
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('selectedFolders_${widget.channelId}');
  }

// COMPROBAR CARPETAS SELECCIONADAS
  bool checkSelectedFolders() {
    if (selectedFolders[widget.channelId] != null &&
        selectedFolders[widget.channelId]!.isEmpty) {
      return false;
    }
    return true;
  }
////////////////////////////////////////////////////////////////////////////////

// TIME PICKER /////////////////////////////////////////////////////////////////
// CARGAR HORA SELECCIONADA
  void loadSelectedTimeFromPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? savedHour = prefs.getInt('selectedHour_${widget.channelId}');
    int? savedMinute = prefs.getInt('selectedMinute_${widget.channelId}');

    if (savedHour != null && savedMinute != null) {
      setState(() {
        selectedTime =
            TimeOfDay(hour: savedHour, minute: savedMinute).format(context);
        buttonText = selectedTime!;
      });
    }
  }

// MOSTRAR TIME PICKER
  void showTimePickerDialog() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    if (buttonText == "Timer") {
      TimeOfDay initialTime = TimeOfDay.now();

      int? savedHour = prefs.getInt('selectedHour_${widget.channelId}');
      int? savedMinute = prefs.getInt('selectedMinute_${widget.channelId}');
      if (savedHour != null && savedMinute != null) {
        initialTime = TimeOfDay(hour: savedHour, minute: savedMinute);
      }

      TimeOfDay? time = await showTimePicker(
        context: context,
        initialTime: initialTime,
      );

      if (time != null) {
        setState(() {
          selectedTime = time.format(context);
          buttonText = selectedTime!;
          prefs.setInt('selectedHour_${widget.channelId}', time.hour);
          prefs.setInt('selectedMinute_${widget.channelId}', time.minute);
        });

        handleTimeSelected(time.hour, time.minute);
      }
    } else {
      setState(() {
        selectedTime = null;
        buttonText = "Timer";
        prefs.remove('selectedHour_${widget.channelId}');
        prefs.remove('selectedMinute_${widget.channelId}');
      });
    }
  }

// EJECUTAR TAREA PROGRAMADA
  void handleTimeSelected(int hour, int minute) {
    final cron = Cron();
    final cronPattern = "$minute $hour * * *";
    cron.schedule(Schedule.parse(cronPattern), () {
      // Aquí colocas el código que quieres ejecutar a la hora seleccionada
      // Por ejemplo, puedes llamar a la función _sendMessage para enviar un mensaje a Telegram
      // listFilesAndTopicId();
    });
  }
////////////////////////////////////////////////////////////////////////////////

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Padding(
          padding: const EdgeInsets.only(left: 20.0),
          child: Text(
            widget.channelTitle,
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
            onPressed: () {
              initializeAsyncData();
            },
            icon: const Icon(Icons.refresh),
          ),
          PopupMenuButton<String>(
            color: cardBgColor,
            shadowColor: mainColor,
            icon: const Icon(
              Icons.more_vert, // Icono de tres puntos
              color: Color(0xFFFFFFFF), // Cambia a tu color deseado
            ),
            onSelected: (choice) {
              if (choice == 'clearSelectedFolders') {
                clearSelectedFolders();
              } else if (choice == 'nuevaOpcion') {}
            },
            itemBuilder: (BuildContext context) {
              return <PopupMenuEntry<String>>[
                PopupMenuItem<String>(
                  value: 'clearSelectedFolders',
                  child: Row(
                    children: [
                      Icon(
                        Icons.folder_off_rounded,
                        color: cardTextColor,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Unselect Folders',
                        style: GoogleFonts.poppins(
                          fontSize: 12.0,
                          fontWeight: FontWeight.w500,
                          color: cardTextColor,
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuItem<String>(
                  value: 'nuevaOpcion',
                  child: Row(
                    children: [
                      Icon(
                        Icons.watch,
                        color: cardTextColor,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Nueva Opción',
                        style: GoogleFonts.poppins(
                          fontSize: 12.0,
                          fontWeight: FontWeight.w500,
                          color: cardTextColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ];
            },
            offset: const Offset(0, kToolbarHeight),
          ),
        ],
        shadowColor: const Color(0xFF58ACFF),
      ),
      backgroundColor: bgColor,
      body: Column(
        children: <Widget>[
          Expanded(
            child: isLoading
                ? Center(
                    child: LoadingAnimationWidget.fourRotatingDots(
                        color: mainColor, size: 50),
                  )
                : Column(
                    children: [
                      Accordion(
                        maxOpenSections: 1,
                        paddingListHorizontal: 20,
                        children: topicsList.map<AccordionSection>((topic) {
                          final topicId = topic['id'];
                          final topicTitle = topic['title'];
                          final topicColor = colorMap[topic['color']];
                          final topicContent = topic['content'];

                          return AccordionSection(
                            headerPadding: const EdgeInsets.all(10),
                            contentBorderColor: topicColor,
                            contentBackgroundColor: const Color(0xFFFFFFFF),
                            headerBorderColor: topicColor,
                            headerBorderColorOpened: topicColor,
                            headerBackgroundColor: topicColor,
                            headerBackgroundColorOpened: topicColor,
                            isOpen: false,
                            leftIcon: const Icon(Icons.folder_copy,
                                color: Colors.white),
                            header: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  topicTitle,
                                  style: GoogleFonts.poppins(
                                    fontSize: 18.0,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFFFFFFFF),
                                  ),
                                ),
                                Text(
                                  selectedFolders[widget.channelId]?[topicId]
                                              ?.isNotEmpty ==
                                          true
                                      ? "Selected Folder ➜ ${selectedFolders[widget.channelId]![topicId]!.map((folder) => path.basename(folder)).join(', ')}"
                                      : "Unselected Folder",
                                  style: const TextStyle(
                                    fontSize: 14.0,
                                    fontWeight: FontWeight.normal,
                                    color: Color(0xFFFFFFFF),
                                  ),
                                )
                              ],
                            ),
                            content: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (topicContent['messages'].isNotEmpty)
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                            0, 0, 0, 10),
                                        child: Text(
                                          'Latest files backuped',
                                          style: GoogleFonts.poppins(
                                            fontSize: 16.0,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.black87,
                                          ),
                                        ),
                                      ),
                                      Column(
                                        children: [
                                          Container(
                                            width: MediaQuery.of(context)
                                                .size
                                                .width,
                                            padding: const EdgeInsets.all(8.0),
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                  color: Colors.grey),
                                              borderRadius:
                                                  BorderRadius.circular(8.0),
                                            ),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                ...topicContent['messages']
                                                    .map<Widget>((message) {
                                                  final fileText =
                                                      message['text'];

                                                  if (fileText != null) {
                                                    return Text(
                                                      fileText,
                                                      style:
                                                          GoogleFonts.poppins(
                                                        fontSize: 12.0,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        color: Colors.black54,
                                                      ),
                                                    );
                                                  }

                                                  return const SizedBox
                                                      .shrink();
                                                }).toList(),
                                                const SizedBox(
                                                  height: 10,
                                                ),
                                                Center(
                                                  child: ElevatedButton(
                                                    style: ElevatedButton
                                                        .styleFrom(
                                                      backgroundColor:
                                                          Colors.red.shade400,
                                                      shape:
                                                          RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(20.0),
                                                      ),
                                                    ),
                                                    onPressed: () async {
                                                      showDeleteMessages(
                                                          context,
                                                          widget.channelId,
                                                          topicId);
                                                    },
                                                    child: Padding(
                                                      padding: const EdgeInsets
                                                          .fromLTRB(
                                                          0, 12, 0, 12),
                                                      child: Row(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center, // Centramos el Row
                                                        children: [
                                                          const Icon(
                                                              Icons
                                                                  .delete_sweep_rounded,
                                                              color:
                                                                  Colors.white),
                                                          const SizedBox(
                                                              width: 8.0),
                                                          Text(
                                                            "Delete Messages",
                                                            style: GoogleFonts
                                                                .poppins(
                                                              fontSize: 12.0,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                              color:
                                                                  Colors.white,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                const SizedBox(
                                  height: 10,
                                ),
                                ButtonBar(
                                  alignment: MainAxisAlignment.spaceEvenly,
                                  buttonHeight: 52.0,
                                  buttonMinWidth: 90.0,
                                  children: <Widget>[
                                    Row(
                                      children: [
                                        ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: topicColor,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(20.0),
                                            ),
                                          ),
                                          onPressed: () async {
                                            print("PERMISSO");

                                            if (await Permission.photos.request().isGranted &&
                                                await Permission.videos
                                                    .request()
                                                    .isGranted &&
                                                await Permission
                                                    .manageExternalStorage
                                                    .isGranted) {
                                              pickFolder(topic);
                                            } else {
                                              await Permission.photos.request();
                                              await Permission.videos.request();
                                              await Permission
                                                  .manageExternalStorage
                                                  .request();
                                            }
                                          },
                                          child: Padding(
                                            padding: const EdgeInsets.fromLTRB(
                                                0, 12, 0, 12),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                const Icon(Icons.folder,
                                                    color: Colors.white),
                                                const SizedBox(width: 8.0),
                                                Text(
                                                  selectedFolders[widget
                                                                      .channelId]
                                                                  ?[topicId]
                                                              ?.isNotEmpty ==
                                                          true
                                                      ? "Change Folder"
                                                      : "Select Folder",
                                                  style: GoogleFonts.poppins(
                                                    fontSize: 12.0,
                                                    fontWeight: FontWeight.w500,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        const SizedBox(
                                          width: 10,
                                        ),
                                        ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                const Color(0xFF2F4156),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10.0),
                                            ),
                                          ),
                                          onPressed: () async {
                                            showDeleteTopic(context,
                                                widget.channelId, topicId);
                                          },
                                          child: const Center(
                                            child: Padding(
                                              padding: EdgeInsets.fromLTRB(
                                                  0, 10, 0, 10),
                                              child: Icon(Icons.delete,
                                                  color: Colors.white),
                                            ),
                                          ),
                                        ),
                                        if (selectedFolders[widget.channelId]
                                                    ?[topicId]
                                                ?.isNotEmpty ==
                                            true)
                                          Row(
                                            children: [
                                              const SizedBox(
                                                width: 10,
                                              ),
                                              ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      const Color(0xFF2F4156),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10.0),
                                                  ),
                                                ),
                                                onPressed: () async {
                                                  listFilesAndSend(
                                                      selectedFolders[widget
                                                                  .channelId]![
                                                              topicId]!
                                                          .map((folder) =>
                                                              Directory(folder)
                                                                  .absolute
                                                                  .path)
                                                          .join(', '),
                                                      widget.channelId,
                                                      topicId,
                                                      widget.phoneNumber);
                                                },
                                                child: const Center(
                                                  child: Padding(
                                                    padding:
                                                        EdgeInsets.fromLTRB(
                                                            0, 10, 0, 10),
                                                    child: Icon(Icons.upload,
                                                        color: Colors.white),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                      ],
                                    )
                                  ],
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                      Visibility(
                        visible: topicsList.isNotEmpty,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF2F4156),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                              ),
                              onPressed: () async {
                                await fullSend();
                              },
                              child: const Center(
                                child: Padding(
                                  padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
                                  child: Icon(Icons.drive_folder_upload_rounded,
                                      color: Colors.white),
                                ),
                              ),
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF58ACFF),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20.0),
                                ),
                              ),
                              onPressed: () async {
                                showTimePickerDialog();
                              },
                              child: Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(0, 12, 0, 12),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.lock_clock,
                                        color: Colors.white),
                                    const SizedBox(width: 8.0),
                                    Text(
                                      buttonText,
                                      style: GoogleFonts.poppins(
                                        fontSize: 12.0,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF2F4156),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                              ),
                              onPressed: () async {
                                showCreateDialog();
                              },
                              child: const Center(
                                child: Padding(
                                  padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
                                  child: Icon(Icons.add, color: Colors.white),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Visibility(
                        visible: topicsList.isEmpty,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2F4156),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                          ),
                          onPressed: () async {
                            showCreateDialog();
                          },
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(0, 12, 0, 12),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment:
                                  MainAxisAlignment.center, // Centramos el Row
                              children: [
                                const Icon(Icons.add_comment_rounded,
                                    color: Colors.white),
                                const SizedBox(width: 8.0),
                                Text(
                                  "New Topic",
                                  style: GoogleFonts.poppins(
                                    fontSize: 12.0,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

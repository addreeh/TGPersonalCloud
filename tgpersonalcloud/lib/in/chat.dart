import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ikchatbot/ikchatbot.dart';

final List<String> keywords = [
  'TGPersonalCloud',
  'tgpersonalcloud',
  'Use',
  'use',
  'Limitations',
  'limitations',
  'Language',
  'language',
  'Technology',
  'technology',
  'Contact',
  'contact'
];

final List<String> responses = [
  "Welcome to TGPersonalCloud! 👋\nOur friendly bot is here to help you 24/7. Need assistance with setup, file management, or exploring cool features? Just ask! Your privacy and data security are our top priorities. 🛡️\nEnjoy your TGPersonalCloud journey! 🚀",
  "Welcome to TGPersonalCloud! 👋\nOur friendly bot is here to help you 24/7. Need assistance with setup, file management, or exploring cool features? Just ask! Your privacy and data security are our top priorities. 🛡️\nEnjoy your TGPersonalCloud journey! 🚀",
  "TGPersonalCloud operates by allowing users to create groups, such as 'Travel,' within which they can create topics representing different types of trips, like 'Trip to Madrid,' 'Trip to Stockholm,' 'Trip to Croatia,' and so on. Each topic can be linked to a folder on the user's device. Users have the flexibility to perform manual backups or schedule automatic backups for each topic independently, selecting the desired backup time. This structure ensures organized and automated cloud backups for their specific folders and topics. 📂🔒🔄",
  "TGPersonalCloud operates by allowing users to create groups, such as 'Travel,' within which they can create topics representing different types of trips, like 'Trip to Madrid,' 'Trip to Stockholm,' 'Trip to Croatia,' and so on. Each topic can be linked to a folder on the user's device. Users have the flexibility to perform manual backups or schedule automatic backups for each topic independently, selecting the desired backup time. This structure ensures organized and automated cloud backups for their specific folders and topics. 📂🔒🔄",
  'The limitations of the application are minimal and designed to provide an efficient and organized experience. Each user can create up to 5 groups, and within each group, they can have a maximum of 10 topics. This means you have the capacity to manage up to 50 different topics for effectively storing and organizing your data. Plenty of space for your needs! 📦🔒✨',
  'The limitations of the application are minimal and designed to provide an efficient and organized experience. Each user can create up to 5 groups, and within each group, they can have a maximum of 10 topics. This means you have the capacity to manage up to 50 different topics for effectively storing and organizing your data. Plenty of space for your needs! 📦🔒✨',
  "The front-end is built using Flutter, while the back-end utilizes Python, specifically incorporating the Telethon library for Telegram API integration. Notably, ChatGPT was employed in the development of the application. 📱🖥️🐍📡🤖",
  "The front-end is built using Flutter, while the back-end utilizes Python, specifically incorporating the Telethon library for Telegram API integration. Notably, ChatGPT was employed in the development of the application. 📱🖥️🐍📡🤖",
  "The front-end is built using Flutter, while the back-end utilizes Python, specifically incorporating the Telethon library for Telegram API integration. Notably, ChatGPT was employed in the development of the application. 📱🖥️🐍📡🤖",
  "The front-end is built using Flutter, while the back-end utilizes Python, specifically incorporating the Telethon library for Telegram API integration. Notably, ChatGPT was employed in the development of the application. 📱🖥️🐍📡🤖",
  '📧 adrianpinohidalgo@gmail.com',
  '📧 adrianpinohidalgo@gmail.com',
];

class ChatPage extends StatefulWidget {
  final bool darkMode;
  const ChatPage(this.darkMode, {super.key});

  @override
  State<ChatPage> createState() => ChatPageState();
}

class ChatPageState extends State<ChatPage> {
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
  late Color userChatColor;

  late IkChatBotConfig chatBotConfig;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!widget.darkMode) {
      bgColor = const Color(0xFFFFFFFF);
      boxColor = const Color(0xFFD6DFFF);
      textFieldColor = const Color(0xFFEFF4F9);
      textColor = const Color(0xFF61677D);
      indicatorColor = const Color(0xFFD6DFFF);
      countryColor = const Color(0xFFDFDFDF);
      loadingBgColor = const Color(0xFFEFF4F9);
      loadingTextColor = const Color(0xFF61677D);
      appBarBgColor = const Color(0xFF58ACFF);
      cardTextColor = const Color(0xFF000000);
      cardBgColor = const Color(0xFFFAFAFA);
      cardBgExpColor = const Color(0xFFFAFAFA);
      userListBgColor = const Color(0xFFFAFAFA);
      dialogTextColor = const Color(0xFF646464);
      userChatColor = const Color(0xFF61677D);
    } else if (widget.darkMode) {
      bgColor = const Color(0xFF212121);
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
      userChatColor = const Color(0xFF565656);
    }

    chatBotConfig = IkChatBotConfig(
      backgroundAssetimage:
          widget.darkMode ? 'assets/chat2.png' : 'assets/chat_light.jpg',
      ratingIconYes: const Icon(Icons.star),
      ratingIconNo: const Icon(Icons.star_border),
      ratingIconColor: Colors.black,
      ratingBackgroundColor: Colors.white,
      ratingButtonText: '',
      thankyouText: '',
      ratingText: '',
      ratingTitle: '',
      body: 'This is a test email sent from Flutter and Dart.',
      subject: 'Test Rating',
      recipient: 'recipient@example.com',
      isSecure: false,
      senderName: 'Your Name',
      smtpUsername: 'Your Email',
      smtpPassword: 'your password',
      smtpServer: 'stmp.gmail.com',
      smtpPort: 587,
      sendIcon: Icon(Icons.send, color: textColor),
      userIcon: const Icon(Icons.person_rounded, color: Colors.white),
      botIcon: const Icon(Icons.android, color: Colors.white),
      botChatColor: appBarBgColor,
      delayBot: 100,
      closingTime: 1,
      delayResponse: 1,
      userChatColor: userChatColor,
      waitingTime: 1,
      keywords: keywords,
      responses: responses,
      backgroundColor: textFieldColor,
      backgroundImage:
          widget.darkMode ? 'assets/chat2.png' : 'assets/chat_light.jpg',
      initialGreeting:
          "Hello! \nWelcome to TGPersonalCloud! 🚀\nHow can I assist you today? 😊\n\nFeel free to ask me about:\n- 🌐 TGPersonalCloud\n- 💻 General Use\n- 🚫 Limitations\n- 🗣️ Language\n- 🤖 Technology\n- 📞 Contact\n\nI'm here to make your experience smooth! What can I help you with?",
      defaultResponse: "Sorry, I didn't understand your response.",
      inactivityMessage: "Is there anything else you need help with?",
      closingMessage: "This conversation will now close.",
      inputHint: 'Send a message',
      waitingText: 'Please wait...',
      useAsset: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Padding(
          padding: const EdgeInsets.only(left: 20.0),
          child: Text(
            "Chat Bot",
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
        backgroundColor: appBarBgColor,
      ),
      body: ikchatbot(config: chatBotConfig),
    );
  }
}

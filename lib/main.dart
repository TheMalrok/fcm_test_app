import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

// Handler dla powiadomień w tle
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print("Obsługa powiadomienia w tle: ${message.messageId}");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicjalizacja Firebase
  await Firebase.initializeApp();

  // Ustawienie handlera dla powiadomień w tle
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FCM Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: FCMDemo(),
    );
  }
}

class FCMDemo extends StatefulWidget {
  @override
  _FCMDemoState createState() => _FCMDemoState();
}

class _FCMDemoState extends State<FCMDemo> {
  String? _token;
  String _lastMessage = "Brak wiadomości";

  @override
  void initState() {
    super.initState();
    _setupFCM();
  }

  Future<void> _setupFCM() async {
    // Pobierz token FCM
    final token = await FirebaseMessaging.instance.getToken();
    setState(() {
      _token = token;
    });
    print("FCM Token: $token");

    // Żądanie uprawnień (iOS)
    await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // Nasłuchuj na powiadomienia gdy aplikacja jest na pierwszym planie
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Otrzymano wiadomość na pierwszym planie!');
      print('Tytuł: ${message.notification?.title}');
      print('Treść: ${message.notification?.body}');

      setState(() {
        _lastMessage =
            "${message.notification?.title}: ${message.notification?.body}";
      });
    });

    // Obsługa kliknięcia w powiadomienie
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('Użytkownik kliknął powiadomienie!');
      setState(() {
        _lastMessage = "Kliknięto: ${message.notification?.title}";
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('FCM Demo')),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Token FCM:', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
              SelectableText(
                _token ?? 'Ładowanie tokenu...',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12),
              ),
              SizedBox(height: 30),
              Text(
                'Ostatnia wiadomość:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text(_lastMessage, textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}

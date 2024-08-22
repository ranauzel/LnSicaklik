import 'dart:convert';
import 'dart:ui'; // ImageFilter için gerekli import
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_local_notifications/flutter_local_notifications.dart'; // Bildirimler için import
import 'package:audioplayers/audioplayers.dart'; // Ses çalmak için import
import 'package:permission_handler/permission_handler.dart'; // İzinler için import
// Background fetch import
import 'login_screen.dart'; // Login ekranı import
import 'temperature_widget.dart'; // Sıcaklık ekranı import

// Global notification plugin
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();
final AudioPlayer _audioPlayer = AudioPlayer(); // Ses çalar

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Notification initialization
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');
  final InitializationSettings initializationSettings =
      InitializationSettings(android: initializationSettingsAndroid);
  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  runApp(MyApp());
}

void _playWarningSound() async {
  await _audioPlayer.play(AssetSource('assets/sounds/warning.mp3'));
}

Future<void> _showNotification(String title, String body) async {
  const AndroidNotificationDetails androidPlatformChannelSpecifics =
      AndroidNotificationDetails(
    'temperature_channel_id',
    'Temperature Alerts',
    channelDescription: 'Channel for temperature alerts',
    importance: Importance.max,
    priority: Priority.high,
  );

  const NotificationDetails platformChannelSpecifics =
      NotificationDetails(android: androidPlatformChannelSpecifics);

  await flutterLocalNotificationsPlugin.show(
    0,
    title,
    body,
    platformChannelSpecifics,
    payload: 'item x',
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sıcaklık App',
      theme: ThemeData(
        primarySwatch: Colors.teal, // Uygulama genelinde kullanılan ana renk
        visualDensity: VisualDensity
            .adaptivePlatformDensity, // Platforma bağlı görsel yoğunluk ayarı
      ),
      home: LoginScreen(), // Uygulama başlatıldığında gösterilecek ekran
      debugShowCheckedModeBanner: false, // Debug banner'ını gizleme
    );
  }
}

import 'dart:async';
import 'dart:convert';
import 'dart:ui'; // ImageFilter için gerekli
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_local_notifications/flutter_local_notifications.dart'; // Bildirimler için
import 'package:audioplayers/audioplayers.dart'; // Ses çalmak için
import 'warning_screen.dart'; // Uyarı ekranı
import 'login_screen.dart'; // Login ekranı
import 'room1.dart';
import 'temperature_graph_screen.dart'; // Sıcaklık grafik ekranı
import 'package:permission_handler/permission_handler.dart'; // İzinler için

// Global notification plugin
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

class Room2Screen extends StatefulWidget {
  @override
  _Room2ScreenState createState() => _Room2ScreenState();
}

class _Room2ScreenState extends State<Room2Screen> {
  String temperature = '...'; // Başlangıç sıcaklık değeri
  final String apiUrl =
      'https://api.thingspeak.com/channels/2626921/fields/1/last.json?api_key=YOUR_API_KEY';
  final AudioPlayer _audioPlayer = AudioPlayer(); // Ses çalar

  @override
  void initState() {
    super.initState();
    _initializeNotification(); // Bildirimleri başlat
    _requestPermissions(); // Gerekli izinleri iste
    fetchTemperature(); // Widget oluşturulduğunda sıcaklığı çek
  }

  Future<void> _requestPermissions() async {
    if (await Permission.notification.isDenied) {
      await Permission.notification.request();
    }
  }

  Future<void> _initializeNotification() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    final InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Future<void> fetchTemperature() async {
    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final temp = double.tryParse(data['field1'] ?? '');

        setState(() {
          temperature = '${data['field1']}°C'; // Sıcaklık değerini güncelle
        });

        if (temp != null && temp > 25) {
          // Sıcaklık 25°C'yi geçtiyse ses çal
          _playWarningSound();
          _showNotification('Sıcaklık Uyarısı', 'Sıcaklık $temperature oldu!');
          _showWarningScreen(); // Uyarı ekranını göster
        }
      } else {
        throw Exception('Sıcaklık yüklenemedi');
      }
    } catch (e) {
      setState(() {
        temperature = 'Hata'; // Hata varsa göster
      });
      _playWarningSound(); // Hata durumunda uyarı sesini çal
    }
  }

  void _playWarningSound() async {
    await _audioPlayer.play(
        AssetSource('assets/glitch-lazer-232465.mp3')); // Ses dosyasını çal
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

  void _showWarningScreen() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => WarningScreen()),
    );
  }

  void _logout() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }

  void _showGraph() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => TemperatureGraphScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color darkBlue = Colors.blue[800]!; // Daha koyu mavi
    final Color darkerBlue = Colors.blue[900]!; // Daha koyu mavi tonu
    final Color lightBlue = Colors.blue[200]!; // Açık mavi tonu

    return Scaffold(
      backgroundColor: darkBlue, // Arka plan rengini koyu mavi yaptık
      appBar: AppBar(
        title: Text('2. Sunucu Odası Sıcaklık',
            style:
                TextStyle(fontFamily: 'Roboto', fontWeight: FontWeight.bold)),
        backgroundColor: darkerBlue,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: lightBlue,
              ),
              child: Text(
                'Menü',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.router),
              title: Text('1. Sunucu Odası'),
              onTap: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => Room1Screen()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.exit_to_app),
              title: Text('Çıkış Yap'),
              onTap: _logout,
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.network(
              'https://i.pinimg.com/originals/19/6e/17/196e178a5d70af3ed070249089c7506c.jpg',
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 1.5, sigmaY: 1.5),
              child: Container(
                color:
                    Colors.black.withOpacity(0.5), // Yarı saydam siyah katman
              ),
            ),
          ),
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 1.0, sigmaY: 1.0),
              child: Container(
                color:
                    Colors.black.withOpacity(0.2), // Yarı saydam siyah katman
              ),
            ),
          ),
          Positioned(
            top: 50, // Logoyu biraz aşağıya indirdik
            left: 16,
            child: Image.network(
              'https://ln.com.tr/assets/modules/Theme/images/logo-white.png',
              width: 100, // Logo genişliği
              height: 50, // Logo yüksekliği
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                    height:
                        130), // Üst boşluğu oluşturur ve sıcaklık bilgisini ortalar
                Card(
                  color: lightBlue.withOpacity(0.9), // Kart rengi
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'Sıcaklık: $temperature',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontFamily: 'Roboto',
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20), // Sıcaklık ve butonlar arasında mesafe
              ],
            ),
          ),
        ],
      ),
    );
  }
}

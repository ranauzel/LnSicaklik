import 'dart:async';
import 'dart:convert';
import 'dart:ui'; // ImageFilter için gerekli
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_local_notifications/flutter_local_notifications.dart'; // Bildirimler için
import 'package:audioplayers/audioplayers.dart'; // Ses çalmak için
import 'login_screen.dart'; // Login ekranı
import 'temperature_graph_screen.dart'; // Sıcaklık grafik ekranı
import 'warning_screen.dart'; // Uyarı ekranı
import 'room2.dart';
import 'package:permission_handler/permission_handler.dart'; // İzinler için

// Global notification plugin
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

class Room1Screen extends StatefulWidget {
  @override
  _Room1ScreenState createState() => _Room1ScreenState();
}

class _Room1ScreenState extends State<Room1Screen> {
  String temperature = '...'; // Başlangıç sıcaklık değeri
  final String apiUrl =
      'https://api.thingspeak.com/channels/2626920/fields/1/last.json?api_key=374WR0W8MPADP3T9';
  final String dailyDataUrl =
      'https://api.thingspeak.com/channels/2626920/feeds.json?api_key=374WR0W8MPADP3T9&results=100';
  List<dynamic> dailyData = []; // Günlük veriler için liste
  final AudioPlayer _audioPlayer = AudioPlayer(); // Ses çalar

  @override
  void initState() {
    super.initState();
    _initializeNotification(); // Bildirimleri başlat
    _requestPermissions(); // Gerekli izinleri iste
    fetchTemperature(); // Widget oluşturulduğunda sıcaklığı çek
    fetchDailyData(); // Günlük verileri çek
    Timer.periodic(Duration(minutes: 20), (Timer t) => fetchDailyData());
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

  Future<void> fetchDailyData() async {
    try {
      final response = await http.get(Uri.parse(dailyDataUrl));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final now = DateTime.now();
        final twoDaysAgo = now.subtract(Duration(days: 2));

        setState(() {
          dailyData = data['feeds'].where((data) {
            final dateTime = DateTime.parse(data['created_at']);
            return dateTime.isAfter(twoDaysAgo);
          }).toList()
            ..sort((a, b) => DateTime.parse(b['created_at']).compareTo(
                DateTime.parse(
                    a['created_at']))); // Son veriden ilk veriye sıralama
        });
      } else {
        throw Exception('Günlük veriler yüklenemedi');
      }
    } catch (e) {
      setState(() {
        dailyData = []; // Hata durumunda listeyi boş bırak
      });
    }
  }

  void _playWarningSound() async {
    await _audioPlayer.play(AssetSource(
        'assets/images/glitch-lazer-232465.mp3')); // Ses dosyasını çal
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

  void _showRoom2() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => Room2Screen()),
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
        title: Text('1. Sunucu Odası Sıcaklık Verisi',
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
              title: Text('2. Sunucu Odası'),
              onTap: _showRoom2,
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
          Column(
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
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: _showGraph,
                    icon: Icon(Icons.bar_chart),
                    label: Text('Grafik'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: lightBlue,
                      textStyle: TextStyle(fontSize: 20),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20), // Butonlar ve tablo arasında mesafe
              Expanded(
                child: dailyData.isEmpty
                    ? Center(
                        child: Text(
                          'Veri yok',
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        ),
                      )
                    : SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: Container(
                          padding: EdgeInsets.all(16.0),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: DataTable(
                            columns: [
                              DataColumn(
                                  label: Text('Tarih ve Saat',
                                      style: TextStyle(color: Colors.white))),
                              DataColumn(
                                  label: Text('Sıcaklık',
                                      style: TextStyle(color: Colors.white))),
                            ],
                            rows: dailyData.map((data) {
                              final dateTime =
                                  DateTime.parse(data['created_at']);
                              final formattedDate =
                                  '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute}:${dateTime.second}';
                              return DataRow(cells: [
                                DataCell(Text(formattedDate,
                                    style: TextStyle(color: Colors.white))),
                                DataCell(Text(data['field1'],
                                    style: TextStyle(color: Colors.white))),
                              ]);
                            }).toList(),
                          ),
                        ),
                      ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

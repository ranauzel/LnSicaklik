import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'login_screen.dart'; // Correct import for LoginScreen

const String THINGSPEAK_CHANNEL_ID = '2626920';
const String THINGSPEAK_READ_API_KEY = '374WR0W8MPADP3T9';

Future<List<FlSpot>> fetchTemperatureData() async {
  final url = 'https://api.thingspeak.com/channels/$THINGSPEAK_CHANNEL_ID/feeds.json?api_key=$THINGSPEAK_READ_API_KEY&results=1000';
  final response = await http.get(Uri.parse(url));

  if (response.statusCode == 200) {
    try {
      final data = jsonDecode(response.body);
      final List<dynamic> feeds = data['feeds'];
      List<FlSpot> spots = [];

      for (int i = 0; i < feeds.length; i++) {
        final temperatureString = feeds[i]['field1'];
        final temperature = double.tryParse(temperatureString) ?? 0.0;

        final timestamp = feeds[i]['created_at'];
        final dateTime = DateTime.parse(timestamp);
        final now = DateTime.now();
        final oneDayAgo = now.subtract(Duration(days: 1));

        if (dateTime.isAfter(oneDayAgo)) {
          spots.add(FlSpot(dateTime.millisecondsSinceEpoch.toDouble(), temperature));
        }
      }

      return spots;
    } catch (e) {
      print('Veri ayrıştırma hatası: $e');
      return [];
    }
  } else {
    print('API isteği başarısız: ${response.statusCode}');
    return [];
  }
}

class TemperatureGraphScreen extends StatefulWidget {
  @override
  _TemperatureGraphScreenState createState() => _TemperatureGraphScreenState();
}

class _TemperatureGraphScreenState extends State<TemperatureGraphScreen> {
  Future<List<FlSpot>>? _temperatureData;

  @override
  void initState() {
    super.initState();
    _temperatureData = fetchTemperatureData();
  }

  String formatTimestamp(double timestamp) {
    final dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp.toInt());
    return DateFormat('HH:mm').format(dateTime);
  }

  void _logout() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop(); // Go back to the previous screen
          },
        ),
        title: Text('Sıcaklık Grafiği'),
        actions: [
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: _logout,
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.lightBlueAccent,
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
              leading: Icon(Icons.exit_to_app),
              title: Text('Çıkış Yap'),
              onTap: _logout,
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: NetworkImage('https://i.pinimg.com/originals/19/6e/17/196e178a5d70af3ed070249089c7506c.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Positioned(
            top: 16.0,
            left: 16.0,
            child: Image.network(
              'https://ln.com.tr/assets/modules/Theme/images/logo-white.png',
              width: 100,
              height: 50,
            ),
          ),
          Center(
            child: Card(
              elevation: 4.0,
              margin: EdgeInsets.all(16.0),
              color: Colors.lightBlue[50], // Set the graph's background to light blue
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: FutureBuilder<List<FlSpot>>(
                  future: _temperatureData,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Hata: ${snapshot.error}'));
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Center(child: Text('Veri bulunamadı.'));
                    } else {
                      final spots = snapshot.data!;

                      return Container(
                        height: 300,
                        child: LineChart(
                          LineChartData(
                            gridData: FlGridData(show: true),
                            titlesData: FlTitlesData(
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  getTitlesWidget: (value, _) {
                                    return Text(
                                      formatTimestamp(value),
                                      style: TextStyle(color: Colors.black, fontSize: 10),
                                    );
                                  },
                                ),
                              ),
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 32,
                                  getTitlesWidget: (value, _) {
                                    return Text(
                                      '${value.toStringAsFixed(1)}°C',
                                      style: TextStyle(color: Colors.black, fontSize: 10),
                                    );
                                  },
                                ),
                              ),
                              topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                              rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            ),
                            borderData: FlBorderData(
                              show: true,
                              border: Border.all(
                                color: const Color(0xff37434d),
                                width: 1,
                              ),
                            ),
                            lineBarsData: [
                              LineChartBarData(
                                spots: spots,
                                isCurved: true,
                                color: Colors.blue,
                                dotData: FlDotData(show: false),
                                belowBarData: BarAreaData(show: false),
                              ),
                            ],
                            minX: spots.first.x,
                            maxX: spots.last.x,
                            minY: spots.map((spot) => spot.y).reduce((a, b) => a < b ? a : b),
                            maxY: spots.map((spot) => spot.y).reduce((a, b) => a > b ? a : b),
                          ),
                        ),
                      );
                    }
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
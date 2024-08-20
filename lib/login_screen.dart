import 'package:flutter/material.dart';
import 'dart:ui'; // ImageFilter için gerekli
import 'dart:convert'; // JSON verilerini işlemek için gerekli
import 'package:shared_preferences/shared_preferences.dart'; // SharedPreferences için import
import 'temperature_widget.dart'; // TemperatureScreen importu
import 'package:http/http.dart' as http;

// ThingSpeak API'den sıcaklık verisini çekmek için yardımcı fonksiyon
Future<double?> fetchTemperature() async {
  final channelId = '2626920'; // ThingSpeak kanal ID'si
  final readApiKey = '374WR0W8MPADP3T9'; // ThingSpeak read API anahtarı
  final url =
      'https://api.thingspeak.com/channels/$channelId/fields/1.json?api_key=$readApiKey&results=1';

  try {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final feeds = data['feeds'];
      if (feeds.isNotEmpty) {
        final temperature = double.tryParse(feeds[0]['field1']);
        return temperature;
      }
    } else {
      print('API yanıt hatası: ${response.statusCode}');
    }
  } catch (e) {
    print('Hata: $e');
  }
  return null;
}

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Login App',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: LoginScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _rememberMe = false;

  @override
  void initState() {
    super.initState();
    _loadLoginData();
  }

  void _loadLoginData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _emailController.text = prefs.getString('username') ?? '';
      _passwordController.text = prefs.getString('password') ?? '';
      _rememberMe = prefs.getBool('rememberMe') ?? false;
    });
  }

  void _login() async {
    const String correctEmail = 'ln1993@ln.com.tr';
    const String correctPassword = 'LN1993';

    if (_emailController.text == correctEmail &&
        _passwordController.text == correctPassword) {
      // Giriş başarılı, TemperatureScreen'e geçiş yap
      final prefs = await SharedPreferences.getInstance();
      if (_rememberMe) {
        await prefs.setString('username', _emailController.text);
        await prefs.setString('password', _passwordController.text);
        await prefs.setBool('rememberMe', _rememberMe);
      } else {
        await prefs.remove('username');
        await prefs.remove('password');
        await prefs.remove('rememberMe');
      }

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => TemperatureScreen()),
      );
    } else {
      // Giriş başarısız
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Geçersiz e-posta veya şifre')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color navyBlue = Colors.blue[800]!; // Lacivert renk
    final Color lightBlue = Colors.lightBlue[100]!; // Açık mavi arka plan
    final Color blackText = Colors.black; // Siyah yazı rengi
    final Color darkBorder = Colors.blue[800]!; // Lacivert çerçeve rengi

    return Scaffold(
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
              filter: ImageFilter.blur(
                  sigmaX: 2.0, sigmaY: 2.0), // Daha belirgin blur efekti
              child: Container(
                color: Colors.black.withOpacity(0.4),
              ),
            ),
          ),
          Positioned(
            top: 50,
            left: 16,
            child: Image.network(
              'https://ln.com.tr/assets/modules/Theme/images/logo-white.png',
              width: 100,
              height: 50,
            ),
          ),
          Center(
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(24.0), // Daha yuvarlak köşeler
              ),
              elevation: 20, // Daha belirgin gölge
              shadowColor: Colors.black.withOpacity(0.5),
              color: Colors.white.withOpacity(0.9),
              child: Padding(
                padding: const EdgeInsets.all(32.0), // Artırılmış padding
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Giriş Yap',
                      style: TextStyle(
                        fontSize: 32, // Daha büyük font boyutu
                        fontWeight: FontWeight.bold,
                        color: navyBlue, // Güncellenmiş renk
                      ),
                    ),
                    SizedBox(height: 32), // Artırılmış boşluk
                    TextField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: 'E-posta',
                        labelStyle: TextStyle(color: navyBlue),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: darkBorder, width: 2.0), // Kalın çerçeve
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: navyBlue, width: 2.0), // Kalın çerçeve
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: darkBorder, width: 2.0), // Kalın çerçeve
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    TextField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'Şifre',
                        labelStyle: TextStyle(color: navyBlue),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: darkBorder, width: 2.0), // Kalın çerçeve
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: navyBlue, width: 2.0), // Kalın çerçeve
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: darkBorder, width: 2.0), // Kalın çerçeve
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Checkbox(
                          value: _rememberMe,
                          onChanged: (bool? value) {
                            setState(() {
                              _rememberMe = value ?? false;
                            });
                          },
                        ),
                        Text(
                          'Beni Hatırla',
                          style: TextStyle(
                            color: navyBlue,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: _login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: lightBlue, // Açık mavi arka plan
                        foregroundColor: blackText, // Siyah yazı rengi
                        padding: EdgeInsets.symmetric(
                            horizontal: 32, vertical: 14), // Artırılmış padding
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                              30.0), // Daha yuvarlak köşeler
                        ),
                      ),
                      child: Text('Giriş Yap',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

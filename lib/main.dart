import 'package:flutter/material.dart';
import 'login_screen.dart'; // Giriş ekranı
import 'temperature_widget.dart'; // Sıcaklık widget'ı (eğer gerekli ise import edin)

void main() {
  runApp(MyApp());
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

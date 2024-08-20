import 'dart:convert';
import 'package:http/http.dart' as http;

const String THINGSPEAK_CHANNEL_ID = '2626920';
const String THINGSPEAK_READ_API_KEY = '374WR0W8MPADP3T9';

Future<double?> fetchTemperature() async {
  final url = 'https://api.thingspeak.com/channels/$THINGSPEAK_CHANNEL_ID/feeds.json?api_key=$THINGSPEAK_READ_API_KEY&results=1';
  final response = await http.get(Uri.parse(url));
  
  print('API yanıt kodu: ${response.statusCode}'); // Yanıt kodunu kontrol edin
  print('API yanıtı: ${response.body}'); // Yanıt gövdesini kontrol edin

  if (response.statusCode == 200) {
    try {
      final data = jsonDecode(response.body);
      final temperatureString = data['feeds'][0]['field1'];
      return double.tryParse(temperatureString);
    } catch (e) {
      print('Veri ayrıştırma hatası: $e');
      return null;
    }
  } else {
    print('API isteği başarısız: ${response.statusCode}');
    return null;
  }
}

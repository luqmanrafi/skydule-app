import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/matakuliah.dart';

class ApiService {
  
  static const String baseUrl = 'https://42f0-36-79-111-120.ngrok-free.app/matakuliah';

  static Future<List<Matakuliah>> fetchMatakuliah() async {
    final url = Uri.parse('$baseUrl');

    try {
      final response = await http.get(
        url,
        headers: {
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);

        print('Response body: ${response.body}');

        final List<dynamic> data = jsonResponse['data'];

        return data.map((item) => Matakuliah.fromJson(item)).toList();
      } else {
        print("Status: ${response.statusCode}");
        print("Body: ${response.body}");
        throw Exception('Gagal memuat data matakuliah');
      }
    } catch (e) {
      print('Error fetching data: $e');
      rethrow;
    }
  }
}

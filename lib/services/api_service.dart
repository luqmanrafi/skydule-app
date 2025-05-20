import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/matakuliah.dart';

class ApiService {
  
  static const String baseUrl = 'http://3.1.95.240/api';
  static Future<List<Matakuliah>> fetchMatakuliah() async {
    final url = Uri.parse('$baseUrl/matakuliah');
    final urlTugas = Uri.parse('$baseUrl/tugas');

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
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/matakuliah.dart';
import '../models/tugas.dart';

class ApiService {
  static const String baseUrl = 'http://3.1.95.240/api';

  // Fungsi untuk mengambil data matakuliah dari server
  static Future<List<Matakuliah>> fetchMatakuliah() async {
    final url = Uri.parse('$baseUrl/matakuliah');

    try {
      final response = await http.get(
        url,
        headers: {
          'Accept': 'application/json',
          'Cache-Control': 'no-cache'
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

  static Future<List<Tugas>> fetchTugas() async {
    final url = Uri.parse('$baseUrl/tugas');

    try {
      final response = await http.get(
        url,
        headers: {
          'Accept': 'application/json',
          'Cache-Control': 'no-cache'
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);

        print('Response body: ${response.body}');

        final List<dynamic> data = jsonResponse['data'];

        return data.map((item) => Tugas.fromJson(item)).toList();
      } else {
        print("Status: ${response.statusCode}");
        print("Body: ${response.body}");
        throw Exception('Gagal memuat data tugas');
      }
    } catch (e) {
      print('Error fetching data: $e');
      rethrow;
    }
  }

  static Future<bool> createMatakuliah(Matakuliah matakuliah) async {
    final url = Uri.parse('$baseUrl/tugas');
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',

        },
          body: jsonEncode(matakuliah.toJson()),
      );
      print("Response body: ${response.body}");
      if (response.statusCode == 201 || response.statusCode == 200){
        print("Tugas berhasil dibuat");
        return true;
      } else {
        print("Status create: ${response.statusCode}");
        print("Body create: ${response.body}");
        return false;
      }
    } catch (e){
      print("Terjadi kesalahan saat membuat tugas: $e");
      return false;
    }
  }
}
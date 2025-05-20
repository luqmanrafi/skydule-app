import 'package:flutter/material.dart';
import '../home_screen.dart';
import '../models/matakuliah.dart';
import '../services/api_service.dart';

class JadwalPage extends StatefulWidget {
  @override
  _JadwalPageState createState() => _JadwalPageState();
}

class _JadwalPageState extends State<JadwalPage> {
  Map<String, List<Matakuliah>> jadwalByHari = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchJadwal();
  }

  Future<void> fetchJadwal() async {
    try {
      List<Matakuliah> semuaMatkul = await ApiService.fetchMatakuliah();
      Map<String, List<Matakuliah>> grouped = {};

      for (var matkul in semuaMatkul) {
        grouped.putIfAbsent(matkul.hari, () => []).add(matkul);
      }

      setState(() {
        jadwalByHari = grouped;
        isLoading = false;
      });
    } catch (e) {
      print('Gagal fetch jadwal: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<String> urutanHari = [
      'Senin',
      'Selasa',
      'Rabu',
      'Kamis',
      'Jumat',
      'Sabtu',
      'Minggu',
    ];
    return Scaffold(
      appBar: AppBar(
        title: Text("Jadwal", style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xFF0E1836),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : jadwalByHari.isEmpty
              ? _buildEmptySchedule()
              : Padding(
                  padding: EdgeInsets.all(16.0),
                  child: ListView(
                    children: urutanHari
                        .where((hari) => jadwalByHari.containsKey(hari))
                        .map((hari) {
                      return _buildDaySection(
                        hari,
                        jadwalByHari[hari]!.map((item) {
                          return _buildScheduleCard(
                            item.namaMatakuliah,
                            "${item.jamMulai} - ${item.jamSelesai}",
                            item.ruangan,
                            _getColorByType(item.jenisMatakuliah),
                            item.jenisMatakuliah,
                          );
                        }).toList(),
                      );
                    }).toList(),
                  ),
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Tambahkan logika untuk tambah jadwal di sini
        },
        backgroundColor: Color(0xFF0E1836),
        shape: CircleBorder(),
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildDaySection(String day, List<Widget> schedules) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          day,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        ...schedules,
        SizedBox(height: 22),
      ],
    );
  }

  Widget _buildScheduleCard(String title, String time, String location, Color color, String type) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.white,
      elevation: 3,
      child: ListTile(
        title: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text("$time\n$location", style: TextStyle(height: 1.5)),
        trailing: Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(type, style: TextStyle(color: color)),
        ),
      ),
    );
  }

  Widget _buildEmptySchedule() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.event_note, size: 100, color: Colors.grey[400]),
          SizedBox(height: 16),
          Text(
            "Jadwal Kuliah Tidak Tersedia",
            style: TextStyle(color: Colors.grey, fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Color _getColorByType(String jenisMatakuliah) {
    switch (jenisMatakuliah.toLowerCase()) {
      case 'praktikum':
        return Colors.green;
      case 'teori':
        return Colors.red;
      default:
        return Colors.blueGrey;
    }
  }
}

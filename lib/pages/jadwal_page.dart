import 'package:flutter/material.dart';
import '../home_screen.dart'; // Pastikan mengimpor HomeScreen

class JadwalPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Jadwal",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Color(0xFF0E1836), // Warna AppBar diperbarui
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            // Pastikan kembali ke HomeScreen dengan mengganti halaman
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => HomeScreen()),
            );
          },
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: ListView(
          children: [
            _buildDaySection("Senin", [
              _buildScheduleCard("Kecerdasan Buatan", "08:00 - 09:40", "LA - K.203", Colors.red, "Teori"),
              _buildScheduleCard("Workshop Administrasi Jaringan", "10:30 - 13:10", "LA - K.205", Colors.green, "Praktikum"),
            ]),
            _buildDaySection("Selasa", [
              _buildScheduleCard("Workshop Administrasi Basis Data", "10:30 - 13:10", "LA - K.205", Colors.green, "Praktikum"),
              _buildScheduleCard("Workshop Aplikasi dan Komputasi Awan", "14:00 - 16:40", "LA - K.205", Colors.green, "Praktikum"),
            ]),
            _buildDaySection("Rabu", [
              _buildScheduleCard("Kecerdasan Buatan", "08:00 - 09:40", "LA - K.203", Colors.red, "Teori"),
            ]),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: Color(0xFF0E1836), // Warna FAB diperbarui
        shape: CircleBorder(), // Pastikan FAB berbentuk lingkaran
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
        SizedBox(height: 16),
      ],
    );
  }

  Widget _buildScheduleCard(String title, String time, String location, Color color, String type) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), // Lebih smooth
      color: Colors.white, // Warna latar card tetap putih
      elevation: 3, // Efek bayangan card agar lebih elegan
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
}

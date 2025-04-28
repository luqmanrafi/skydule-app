import 'package:flutter/material.dart';
import '../home_screen.dart'; 

class JadwalPage extends StatelessWidget {
  // Data jadwal
  final Map<String, List<Map<String, dynamic>>> jadwal = {
    "Senin": [
      {
        "title": "Kecerdasan Buatan",
        "time": "08:00 - 09:40",
        "location": "LA - K.203",
        "color": Colors.red,
        "type": "Teori",
      },
      {
        "title": "Workshop Administrasi Jaringan",
        "time": "10:30 - 13:10",
        "location": "LA - K.205",
        "color": Colors.green,
        "type": "Praktikum",
      },
    ],
    "Selasa": [
      {
        "title": "Workshop Administrasi Basis Data",
        "time": "10:30 - 13:10",
        "location": "LA - K.205",
        "color": Colors.green,
        "type": "Praktikum",
      },
      {
        "title": "Workshop Aplikasi dan Komputasi Awan",
        "time": "14:00 - 16:40",
        "location": "LA - K.205",
        "color": Colors.green,
        "type": "Praktikum",
      },
    ],
    "Rabu": [
      {
        "title": "Kecerdasan Buatan",
        "time": "08:00 - 09:40",
        "location": "LA - K.203",
        "color": Colors.red,
        "type": "Teori",
      },
    ],
  };

  @override
  Widget build(BuildContext context) {
    bool isEmpty = jadwal.values.every((list) => list.isEmpty);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Jadwal",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Color(0xFF0E1836),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => HomeScreen()),
            );
          },
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: isEmpty
            ? _buildEmptySchedule()
            : ListView(
                children: jadwal.entries.map((entry) {
                  return _buildDaySection(
                    entry.key,
                    entry.value.map((item) {
                      return _buildScheduleCard(
                        item['title'],
                        item['time'],
                        item['location'],
                        item['color'],
                        item['type'],
                      );
                    }).toList(),
                  );
                }).toList(),
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
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
}

import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../widgets/task_card.dart';
import '../models/matakuliah.dart'; 
import '../services/api_service.dart'; 

final List<Map<String, dynamic>> jadwalHariIni = [
  {"title": "Kecerdasan Buatan", "time": "08:00 - 10:00"},
];

final List<Map<String, dynamic>> tugasHariIni = [
  {"title": "Laporan Praktikum Basis Data", "deadline": "21:00"},
];

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  late Future<List<Matakuliah>> futureMatakuliah;

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      _selectedDay = selectedDay;
      _focusedDay = focusedDay;
    });
  }

  void _changeMonth(bool next) {
    setState(() {
      _focusedDay = DateTime(
        _focusedDay.year,
        next ? _focusedDay.month + 1 : _focusedDay.month - 1,
      );
    });
  }

  @override
  void initState() {
  super.initState();
  futureMatakuliah = ApiService.fetchMatakuliah();
  }
  
  @override
Widget build(BuildContext context) {
  bool jadwalKosong = jadwalHariIni.isEmpty;
  bool tugasKosong = tugasHariIni.isEmpty;

  return SingleChildScrollView(
    padding: const EdgeInsets.symmetric(horizontal: 16.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildCalendar(),

        SizedBox(height: 20),

        Text(
          "Jadwal Hari Ini",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E2A47),
          ),
        ),

        SizedBox(height: 16),

        if (jadwalKosong && tugasKosong)
          Center(child: Text("Tidak ada jadwal hari ini"))
        else ...[
          if (!jadwalKosong)
            ...jadwalHariIni.map((jadwal) => TaskCard(
                  title: jadwal["title"],
                  time: jadwal["time"],
                  isTask: false,
                )),
          if (!tugasKosong)
            ...tugasHariIni.map((tugas) => TaskCard(
                  title: tugas["title"],
                  time: "Deadline: ${tugas["deadline"]}",
                  isTask: true,
                )),
        ],

        SizedBox(height: 24),

        Text(
          "Daftar Matakuliah",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E2A47),
          ),
        ),

        SizedBox(height: 8),

        FutureBuilder<List<Matakuliah>>(
          future: futureMatakuliah,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Text('Gagal memuat data: ${snapshot.error}');
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Text('Tidak ada data matakuliah.');
            } else {
              return ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  final mk = snapshot.data![index];
                  return ListTile(
                    title: Text(mk.namaMatakuliah),
              
                  );
                },
              );
            }
          },
        ),
      ],
    ),
  );
}

  Widget _buildCalendar() {
    return Container(
      decoration: BoxDecoration(
        color: Color(0xFFE9EEF5),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 5,
          ),
        ],
      ),
      padding: EdgeInsets.all(12),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                DateFormat('MMMM yyyy', 'id_ID').format(_focusedDay),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E2A47),
                ),
              ),
              Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.chevron_left, color: Color(0xFF1E2A47)),
                    onPressed: () => _changeMonth(false),
                  ),
                  IconButton(
                    icon: Icon(Icons.chevron_right, color: Color(0xFF1E2A47)),
                    onPressed: () => _changeMonth(true),
                  ),
                ], 
              ),
            ],
          ),
          TableCalendar(
            locale: 'id_ID',
            focusedDay: _focusedDay,
            firstDay: DateTime(2000),
            lastDay: DateTime(2100),
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: _onDaySelected,
            calendarFormat: CalendarFormat.month,
            headerVisible: false,
            daysOfWeekStyle: DaysOfWeekStyle(
              dowTextFormatter: (date, locale) {
                final List<String> shortDays = ["Min", "Sen", "Sel", "Rab", "Kam", "Jum", "Sab"];
                return shortDays[date.weekday % 7];
              },
              weekdayStyle: TextStyle(color: Color(0xFF1E2A47)),
              weekendStyle: TextStyle(color: Colors.redAccent),
            ),
            calendarStyle: CalendarStyle(
              defaultTextStyle: TextStyle(
                fontWeight: FontWeight.w500,
                color: Color(0xFF1E2A47),
              ),
              outsideTextStyle: TextStyle(color: Colors.grey),
              todayDecoration: BoxDecoration(
                color: Color.fromARGB(255, 94, 119, 160),
                shape: BoxShape.circle,
              ),
              selectedDecoration: BoxDecoration(
                color: Color(0xFF4D6DAF),
                shape: BoxShape.circle,
              ),
              selectedTextStyle: TextStyle(
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
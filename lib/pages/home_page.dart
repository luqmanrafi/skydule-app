import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../widgets/task_card.dart';
import '../models/matakuliah.dart'; 
import '../services/api_service.dart'; 

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
  List<Matakuliah> semuaMatakuliah = [];

  @override
  void initState() {
    super.initState();
    futureMatakuliah = ApiService.fetchMatakuliah();
    futureMatakuliah.then((list) {
      setState(() {
        semuaMatakuliah = list;
      });
    });
    _selectedDay = DateTime.now(); // default pilih hari ini
  }

  String getNamaHari(DateTime date) {
    return DateFormat('EEEE', 'id_ID').format(date);
  }

  List<Matakuliah> filterMatakuliahByDate(DateTime date) {
    final namaHari = getNamaHari(date);
    return semuaMatakuliah.where((mk) => mk.hari == namaHari).toList();
  }

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
  Widget build(BuildContext context) {
    final tanggalDipilih = _selectedDay ?? DateTime.now();
    final jadwalHariIni = filterMatakuliahByDate(tanggalDipilih);
    final tugasKosong = tugasHariIni.isEmpty;

    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard Jadwal'),
        backgroundColor: Color(0xFF1E2A47),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
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

            if (jadwalHariIni.isEmpty)
              TaskCard(
                title: "Tidak ada jadwal untuk hari ini",
                time: "",
                isTask: false,
              )
            else
              ...jadwalHariIni.map((jadwal) => TaskCard(
                    title: jadwal.namaMatakuliah,
                    time: '${jadwal.jamMulai} - ${jadwal.jamSelesai}',
                    isTask: false,
                  )),

            SizedBox(height: 20),

            Text(
              "Tugas Hari Ini",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E2A47),
              ),
            ),

            SizedBox(height: 16),

            if (tugasKosong)
              TaskCard(
                title: "Tidak ada tugas untuk hari ini",
                time: "",
                isTask: false,
              )
            else
              ...tugasHariIni.map((tugas) => TaskCard(
                  title: tugas["title"],
                  time: "Deadline: ${tugas["deadline"]}",
                  isTask: true,
                  )),
          ],
        ),
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
          selectedDayPredicate: (day) => isSameDay(day, _selectedDay),
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
              color: Colors.blue, // bulat biru untuk today
              shape: BoxShape.circle,
            ),
            todayTextStyle: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
            selectedDecoration: BoxDecoration(
              color: Colors.blue, // bulat biru untuk today
              shape: BoxShape.circle,
             ), // tidak kasih highlight biru saat klik
            selectedTextStyle: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            )
           // weekendTextStyle: TextStyle(color: Colors.redAccent),
          ),
        ),
      ],
    ),
  );
}
}
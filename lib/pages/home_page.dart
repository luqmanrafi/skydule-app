import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../widgets/task_card.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Color(0xFFE9EEF5), // Warna latar belakang kalender
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
                        color: Color(0xFF1E2A47), // Warna teks biru tua
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
                      final List<String> shortDays = [
                        "Min", "Sen", "Sel", "Rab", "Kam", "Jum", "Sab"
                      ];
                      return shortDays[date.weekday % 7]; // Sesuai urutan hari dalam kalender
                    },
                    weekdayStyle: TextStyle(color: Color(0xFF1E2A47)), // Warna teks hari kerja
                    weekendStyle: TextStyle(color: Colors.redAccent), // Warna akhir pekan
                  ),
                  calendarStyle: CalendarStyle(
                    defaultTextStyle: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF1E2A47), // Warna teks utama biru tua
                    ),
                    outsideTextStyle: TextStyle(color: Colors.grey),
                    todayDecoration: BoxDecoration(
                      color: Color(0xFFAFC6EC), // Warna hari ini
                      shape: BoxShape.circle,
                    ),
                    selectedDecoration: BoxDecoration(
                      color: Color(0xFF4D6DAF), // Warna hari yang dipilih
                      shape: BoxShape.circle,
                    ),
                    selectedTextStyle: TextStyle(
                      color: Colors.white, // Warna teks hari yang dipilih
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 20),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "Jadwal Hari Ini",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E2A47), // Warna teks biru tua
              ),
            ),
          ),
          SizedBox(height: 10),
          Expanded(
            child: ListView(
              children: [
                TaskCard(title: "Kecerdasan Buatan", time: "08:00 - 10:00", isTask: false), // Mata kuliah tanpa checkbox
                TaskCard(title: "Laporan Praktikum Basis Data", time: "Deadline: 21:00", isTask: true), // Tugas dengan checkbox
              ],
            ),
          ),
        ],
      ),
    );
  }
}

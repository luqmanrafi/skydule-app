import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../widgets/task_card.dart';
import '../models/matakuliah.dart';
import '../models/tugas.dart';
import '../services/api_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Future<List<Matakuliah>>? _matakuliahFuture;
  List<Matakuliah> semuaMatakuliah = [];

  // ✅ Tambahan untuk Tugas
  List<Map<String, dynamic>> tugasHariIni = [];
  bool tugasKosong = false;

  @override
  void initState() {
    super.initState();
    _fetchMatakuliahData();
    _selectedDay = DateTime.now();
    fetchTugasHariIni(_selectedDay!);
 // Panggil saat init
  }

  Future<void> _fetchMatakuliahData() async {
    if (!mounted) return;
    _matakuliahFuture = ApiService.fetchMatakuliah();

    try {
      final list = await _matakuliahFuture!;
      if (!mounted) return;
      setState(() {
        semuaMatakuliah = list;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        semuaMatakuliah = [];
      });
    }
  }
void fetchTugasHariIni(DateTime selectedDate) async {
  final semuaTugas = await ApiService.fetchTugas();
  final filtered = semuaTugas.where((tugas) {
    final deadline = tugas.deadline;
    return deadline.year == selectedDate.year &&
        deadline.month == selectedDate.month &&
        deadline.day == selectedDate.day;
  }).toList();

  setState(() {
    tugasHariIni = filtered.map((tugas) => {
      "title": tugas.judulTugas,
      "deadline": DateFormat.Hm().format(tugas.deadline),
    }).toList();
    tugasKosong = tugasHariIni.isEmpty;
  });
}

  String getNamaHari(DateTime date) {
    return DateFormat('EEEE', 'id_ID').format(date);
  }

  List<Matakuliah> filterMatakuliahByDate(DateTime date) {
    final namaHari = getNamaHari(date);
    return semuaMatakuliah.where((mk) => mk.hari == namaHari).toList();
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!mounted) return;
    setState(() {
      _selectedDay = selectedDay;
      _focusedDay = focusedDay;
    });
     fetchTugasHariIni(selectedDay);
  }

  void _changeMonth(bool next) {
    if (!mounted) return;
    setState(() {
      _focusedDay = DateTime(
        _focusedDay.year,
        next ? _focusedDay.month + 1 : _focusedDay.month - 1,
        _focusedDay.day,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final tanggalDipilih = _selectedDay ?? _focusedDay;

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
            FutureBuilder<List<Matakuliah>>(
              future: _matakuliahFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return TaskCard(
                    title: "Gagal memuat data jadwal",
                    time: "Silakan coba lagi nanti.",
                    isTask: false,
                  );
                } else if (snapshot.hasData) {
                  final list = snapshot.data!;
                  final jadwalHariIni = list.where(
                    (mk) => mk.hari == getNamaHari(tanggalDipilih),
                  ).toList();

                  if (jadwalHariIni.isEmpty) {
                    return TaskCard(
                      title: "Tidak ada jadwal untuk hari ini",
                      time: "",
                      isTask: false,
                    );
                  }

                  return Column(
                    children: jadwalHariIni.map((jadwal) => TaskCard(
                      title: jadwal.namaMatakuliah,
                      time: '${jadwal.jamMulai} - ${jadwal.jamSelesai}',
                      isTask: false,
                    )).toList(),
                  );
                } else {
                  return TaskCard(
                    title: "Belum ada data jadwal",
                    time: "Silakan coba refresh atau tambahkan jadwal baru.",
                    isTask: false,
                  );
                }
              },
            ),
            SizedBox(height: 20),

            // ✅ Tugas Hari Ini
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
              Column(
                children: tugasHariIni.map((tugas) => TaskCard(
                  title: tugas["title"],
                  time: "Deadline: ${tugas["deadline"]}",
                  isTask: true,
                )).toList(),
              ),
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
            firstDay: DateTime.utc(2000),
            lastDay: DateTime.utc(2100),
            selectedDayPredicate: (day) => isSameDay(day, _selectedDay ?? _focusedDay),
            onDaySelected: _onDaySelected,
            calendarFormat: CalendarFormat.month,
            headerVisible: false,
            daysOfWeekStyle: DaysOfWeekStyle(
              dowTextFormatter: (date, locale) {
                return DateFormat.E(locale).format(date);
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
                color: Colors.blue.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              todayTextStyle: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              selectedDecoration: BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
              ),
              selectedTextStyle: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              weekendTextStyle: TextStyle(color: Colors.redAccent),
            ),
            onPageChanged: (focusedDay) {
              if (!mounted) return;
              setState(() {
                _focusedDay = focusedDay;
              });
            },
          ),
        ],
      ),
    );
  }
}

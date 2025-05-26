import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../widgets/task_card.dart';
import '../models/matakuliah.dart';
import '../services/api_service.dart';

// Data tugasHariIni masih statis, ini di luar scope refresh data matakuliah dari API
final List<Map<String, dynamic>> tugasHariIni = [
  {"title": "Laporan Praktikum Basis Data", "deadline": "21:00"},
];

// Kelas HomePage diubah jadi StatefulWidget jika belum (tapi di kode asli sudah)
class HomePage extends StatefulWidget {
  // Tambahkan Key di konstruktor agar bisa di-force rebuild dari HomeScreen jika diperlukan
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;


  // futureMatakuliah akan kita ganti cara pakainya sedikit
  // agar bisa di-re-assign untuk trigger FutureBuilder (jika dipakai)
  // atau untuk nge-fetch ulang secara manual
  Future<List<Matakuliah>>? _matakuliahFuture; // DIUBAH: Jadi nullable dan akan diisi di initState & refresh
  List<Matakuliah> semuaMatakuliah = []; // Tetap untuk nyimpen hasil fetch

  @override
  void initState() {
    super.initState();
    print("HomePage: initState dipanggil.");
    _fetchMatakuliahData(); // DIPERBAIKI: Panggil fungsi fetch data yang baru
    _selectedDay = DateTime.now(); // default pilih hari ini
  }

  // DITAMBAHKAN: Fungsi baru untuk fetch data matakuliah
  // Fungsi ini bisa dipanggil ulang untuk refresh
  Future<void> _fetchMatakuliahData() async {
    print("HomePage: Memulai _fetchMatakuliahData...");
    if (!mounted) return; // Cek mounted sebelum setState

    // Tunjukkan loading jika perlu (misalnya dengan variabel state isLoading)
    // setState(() { _isLoading = true; }); // Jika mau ada indikator loading khusus

    // Assign Future baru ke _matakuliahFuture untuk bisa dipakai FutureBuilder
    // atau untuk nge-handle hasil fetch-nya di sini
    _matakuliahFuture = ApiService.fetchMatakuliah(); //

    try {
      final list = await _matakuliahFuture!; // Tunggu hasilnya
      if (!mounted) return; // Cek mounted lagi setelah await

      setState(() {
        semuaMatakuliah = list;
        // _isLoading = false; // Jika pakai _isLoading
      });
      print("HomePage: _fetchMatakuliahData selesai, semuaMatakuliah di-update dengan ${list.length} item.");
    } catch (error) {
      if (!mounted) return;
      print("HomePage: Error saat fetch matakuliah data: $error");
      setState(() {
        semuaMatakuliah = []; // Kosongkan jika error atau beri pesan error
        // _isLoading = false; // Jika pakai _isLoading
      });
      // Opsional: tampilkan SnackBar error
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(content: Text('Gagal memuat data matakuliah: $error')),
      // );
    }
  }

  // DITAMBAHKAN: Fungsi yang bisa dipanggil dari luar (misal dari HomeScreen) untuk refresh
  // Ini contoh jika HomePage diakses via GlobalKey oleh HomeScreen
  // void refreshData() {
  //   print("HomePage: Menerima panggilan refreshData().");
  //   _fetchMatakuliahData();
  // }

  String getNamaHari(DateTime date) {
    return DateFormat('EEEE', 'id_ID').format(date);
  }

  List<Matakuliah> filterMatakuliahByDate(DateTime date) {
    final namaHari = getNamaHari(date);
    // Pastikan semuaMatakuliah tidak null sebelum di-filter
    return semuaMatakuliah.where((mk) => mk.hari == namaHari).toList();
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!mounted) return;
    setState(() {
      _selectedDay = selectedDay;
      _focusedDay = focusedDay;
    });
  }

  void _changeMonth(bool next) {
    if (!mounted) return;
    setState(() {
      _focusedDay = DateTime(
        _focusedDay.year,
        next ? _focusedDay.month + 1 : _focusedDay.month - 1,
        _focusedDay.day, // Tambahkan _focusedDay.day agar tanggal tidak reset ke 1
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    print("HomePage: build method dipanggil.");
    // PERBAIKAN: Ambil tanggalDipilih dengan fallback ke _focusedDay jika _selectedDay null di awal
    final tanggalDipilih = _selectedDay ?? _focusedDay;
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
              "Jadwal Hari Ini (${DateFormat('d MMMM yyyy', 'id_ID').format(tanggalDipilih)})", // Tambah info tanggal
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E2A47),
              ),
            ),
            SizedBox(height: 16),

            // DIPERBAIKI: Handle jika _matakuliahFuture masih null atau lagi loading
            // Ini bisa diganti dengan FutureBuilder yang lebih proper jika mau
            _matakuliahFuture == null // Jika future belum diinisialisasi (seharusnya tidak terjadi jika initState benar)
                ? Center(child: Text("Memuat jadwal...")) // Atau CircularProgressIndicator
                : jadwalHariIni.isEmpty && semuaMatakuliah.isNotEmpty // Jika sudah fetch tapi hari ini kosong
                ? TaskCard(
              title: "Tidak ada jadwal untuk hari ini",
              time: "",
              isTask: false,
            )
                : jadwalHariIni.isEmpty && semuaMatakuliah.isEmpty // Jika belum ada data sama sekali (mungkin masih loading awal atau error)
                ? TaskCard(
              title: "Belum ada data jadwal",
              time: "Silakan coba refresh atau tambahkan jadwal baru.",
              isTask: false,
            )
                : Column( // Gunakan Column jika ada item, atau widget lain jika kosong
              children: jadwalHariIni.map((jadwal) => TaskCard(
                title: jadwal.namaMatakuliah,
                time: '${jadwal.jamMulai} - ${jadwal.jamSelesai}',
                isTask: false,
              )).toList(),
            ),
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
      // DITAMBAHKAN: FloatingActionButton untuk refresh manual (buat ngetes)
      // Ini bisa dihapus kalo refresh otomatis dari HomeScreen udah jalan
      // floatingActionButton: FloatingActionButton(
      //   onPressed: _fetchMatakuliahData,
      //   tooltip: 'Refresh Jadwal',
      //   child: Icon(Icons.refresh),
      // ),
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
                DateFormat('MMMM yyyy', 'id_ID').format(_focusedDay), // Diubah jadi MMMM yyyy
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
            firstDay: DateTime.utc(2000), // DIUBAH: Pake DateTime.utc biar konsisten
            lastDay: DateTime.utc(2100),  // DIUBAH: Pake DateTime.utc
            selectedDayPredicate: (day) => isSameDay(day, _selectedDay ?? _focusedDay), // PERBAIKAN: Fallback ke _focusedDay
            onDaySelected: _onDaySelected,
            calendarFormat: CalendarFormat.month,
            headerVisible: false, // Header TableCalendar sendiri disembunyikan, kita pake header custom di atas
            daysOfWeekStyle: DaysOfWeekStyle(
              dowTextFormatter: (date, locale) {
                // Menggunakan nama hari pendek dari DateFormat Indonesia
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
                color: Colors.blue.withOpacity(0.5), // Sedikit transparan
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
              weekendTextStyle: TextStyle(color: Colors.redAccent), // Pastikan ini juga ada
            ),
            // DITAMBAHKAN: Callback saat halaman kalender berubah (misal ganti bulan)
            // Ini bisa dipake buat nge-fetch data kalo jadwal per bulan lo banyak dan mau di-load per bulan
            // Untuk sekarang, _focusedDay di-update oleh _changeMonth, dan build akan nge-filter ulang
            onPageChanged: (focusedDay) {
              if (!mounted) return;
              setState(() {
                _focusedDay = focusedDay;
              });
              // Jika lo mau nge-fetch data lagi pas ganti bulan:
              // _fetchMatakuliahData();
            },
          ),
        ],
      ),
    );
  }
}
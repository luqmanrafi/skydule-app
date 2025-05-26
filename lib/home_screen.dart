import 'package:flutter/material.dart';
import 'package:animations/animations.dart'; //
import 'pages/home_page.dart';
import 'pages/jadwal_page.dart';
import 'pages/tugas_page.dart';
import 'pages/add_tugas_page.dart'; //
import 'pages/add_jadwal_page.dart'; //

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  bool _isFabExpanded = false;

  // DITAMBAHKAN: GlobalKey atau UniqueKey untuk setiap page yang butuh di-force refresh initState-nya
  // Kita pake UniqueKey biar lebih simpel buat force rebuild total
  Key _homePageKey = UniqueKey();
  Key _jadwalPageKey = UniqueKey();
  // TugasPage mungkin juga perlu kalo ada fitur tambah tugas dari FAB di HomeScreen
  // Key _tugasPageKey = UniqueKey();


  // DIPERBAIKI: _pages sekarang di-build di dalam build method atau initState
  // agar bisa menggunakan Key yang diperbarui. Atau, buat fungsi yang nge-return list ini.
  List<Widget> _buildPages() {
    return [
      HomePage(key: _homePageKey), // Beri Key ke HomePage
      JadwalPage(key: _jadwalPageKey), // Beri Key ke JadwalPage (jika perlu refresh dari sini juga)
      TugasPage(), // Jika TugasPage juga perlu, tambahkan Key
    ];
  }


  // DITAMBAHKAN: Fungsi untuk navigasi ke AddJadwalPage dan handle refresh
  void _navigateToTambahJadwal() async {
    if (!mounted) return;
    print("HomeScreen: Navigasi ke AddJadwalPage...");
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddJadwalPage()),
    );

    if (!mounted) return;
    print('HomeScreen: Hasil dari AddJadwalPage: $result');

    if (result == true) {
      print("HomeScreen: Sukses tambah jadwal, akan me-refresh page yang relevan.");
      // Refresh HomePage jika sedang aktif
      if (_selectedIndex == 0) {
        setState(() {
          _homePageKey = UniqueKey(); // Ganti Key HomePage untuk memicu initState ulang
          print("HomeScreen: HomePage Key diubah, akan memicu initState HomePage.");
        });
      }
      // Refresh JadwalPage jika sedang aktif
      // JadwalPage sudah punya mekanisme FutureBuilder sendiri yang di-refresh oleh _refreshDataJadwal
      // TAPI, jika kita mau force panggil initState-nya juga dari sini, bisa dengan cara yang sama:
      else if (_selectedIndex == 1) {
        setState(() {
          _jadwalPageKey = UniqueKey(); // Ganti Key JadwalPage untuk memicu initState ulang
          print("HomeScreen: JadwalPage Key diubah, akan memicu initState JadwalPage.");
        });
      }
      // Tutup menu FAB kecil setelah aksi
      if (_isFabExpanded) {
        setState(() {
          _isFabExpanded = false;
        });
      }
    }
  }

  // DITAMBAHKAN (Jika ada fitur tambah tugas dari sini juga): Fungsi untuk navigasi ke AddTugasPage dan handle refresh
  void _navigateToTambahTugas() async {
    if (!mounted) return;
    print("HomeScreen: Navigasi ke AddTugasPage...");
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddTugasPage()),
    );

    if (!mounted) return;
    print('HomeScreen: Hasil dari AddTugasPage: $result');

    if (result == true) {
      print("HomeScreen: Sukses tambah tugas, akan me-refresh page yang relevan.");
      // Logika refresh untuk HomePage (jika nampilin tugas) atau TugasPage
      if (_selectedIndex == 0) { // Jika HomePage yang aktif dan perlu refresh tugas
        setState(() {
          _homePageKey = UniqueKey();
          print("HomeScreen: HomePage Key diubah karena ada tugas baru.");
        });
      } else if (_selectedIndex == 2) { // Jika TugasPage yang aktif
        // Logika refresh TugasPage (misalnya dengan Key atau panggil method refresh)
        // setState(() {
        //   _tugasPageKey = UniqueKey();
        // });
        print("HomeScreen: Perlu mekanisme refresh untuk TugasPage.");
      }
      // Tutup menu FAB kecil setelah aksi
      if (_isFabExpanded) {
        setState(() {
          _isFabExpanded = false;
        });
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    // Panggil _buildPages() di sini agar Key terbaru digunakan setiap kali HomeScreen build
    final List<Widget> pages = _buildPages();

    return Scaffold(
      backgroundColor: Color(0xFF0E1836),
      appBar: _selectedIndex == 0
          ? AppBar(
        title: Text(
          "SKYDULE",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Color(0xFF0E1836),
        elevation: 0,
      )
          : null,
      body: PageTransitionSwitcher(
        duration: Duration(milliseconds: 300),
        transitionBuilder: (child, animation, secondaryAnimation) {
          return FadeThroughTransition(
            animation: animation,
            secondaryAnimation: secondaryAnimation,
            child: child,
          );
        },
        child: pages[_selectedIndex], // Gunakan pages yang sudah di-build dengan Key
      ),
      bottomNavigationBar: BottomNavigationBar(
        // ... (kode BottomNavigationBar lo gak berubah) ...
        backgroundColor: Color(0xFF0E1836),
        currentIndex: _selectedIndex,
        onTap: (index) {
          if (!mounted) return;
          setState(() {
            _selectedIndex = index;
          });
        },
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.grey,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today_outlined), activeIcon: Icon(Icons.calendar_today), label: "Jadwal"),
          BottomNavigationBarItem(icon: Icon(Icons.article_outlined), activeIcon: Icon(Icons.article), label: "Tugas"),
        ],
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_isFabExpanded) ...[
            FloatingActionButton(
              heroTag: "addTugasFromHome", // Ganti heroTag biar unik
              backgroundColor: Color(0xFF0E1836),
              onPressed: _navigateToTambahTugas, // DIPERBAIKI: Panggil fungsi yang benar
              child: Icon(Icons.article, color: Colors.white),
              mini: true,
              shape: CircleBorder(),
            ),
            SizedBox(height: 10),
            FloatingActionButton(
              heroTag: "addJadwalFromHome", // Ganti heroTag biar unik
              backgroundColor: Color(0xFF0E1836),
              onPressed: _navigateToTambahJadwal, // DIPERBAIKI: Panggil fungsi yang benar
              child: Icon(Icons.calendar_today, color: Colors.white),
              mini: true,
              shape: CircleBorder(),
            ),
            SizedBox(height: 10),
          ],
          FloatingActionButton(
            heroTag: "mainFAB",
            backgroundColor: Color(0xFF0E1836),
            onPressed: () {
              if (!mounted) return;
              setState(() {
                _isFabExpanded = !_isFabExpanded;
              });
            },
            shape: CircleBorder(),
            child: AnimatedSwitcher(
              duration: Duration(milliseconds: 300),
              transitionBuilder: (child, animation) {
                return RotationTransition(turns: animation, child: child);
              },
              child: _isFabExpanded
                  ? Icon(Icons.close, key: ValueKey('close'), color: Colors.white)
                  : Icon(Icons.add, key: ValueKey('add'), color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
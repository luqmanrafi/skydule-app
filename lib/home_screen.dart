import 'package:flutter/material.dart';
import 'package:animations/animations.dart';
import 'pages/home_page.dart';
import 'pages/jadwal_page.dart';
import 'pages/tugas_page.dart';
import 'pages/add_tugas_page.dart';
import 'pages/add_jadwal_page.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  bool _isFabExpanded = false;

  final List<Widget> _pages = [
    HomePage(),
    JadwalPage(),
    TugasPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF0E1836), // Warna utama

      // AppBar hanya muncul di halaman Home
      appBar: _selectedIndex == 0
          ? AppBar(
              title: Text(
                "SKYDULE",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.white),
              ),
              centerTitle: true,
              backgroundColor: Color(0xFF0E1836), // Warna utama
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
        child: _pages[_selectedIndex],
      ),

      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Color(0xFF0E1836), // Warna utama
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        selectedItemColor: Colors.white, // Warna ikon aktif
        unselectedItemColor: Colors.grey, // Warna ikon tidak aktif
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
              heroTag: "addSchedule",
              backgroundColor: Color(0xFF0E1836), // Warna latar FAB kecil
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddTugasPage()),
                );
              },
              child: Icon(Icons.article, color: Colors.white), // Ikon putih
              mini: true,
              shape: CircleBorder(), // Pastikan berbentuk lingkaran
            ),
            SizedBox(height: 10),
            FloatingActionButton(
              heroTag: "addReminder",
              backgroundColor: Color(0xFF0E1836), // Warna latar FAB kecil
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddJadwalPage()),
                );
              },
              child: Icon(Icons.calendar_today, color: Colors.white), // Ikon putih
              mini: true,
              shape: CircleBorder(), // Pastikan berbentuk lingkaran
            ),
            SizedBox(height: 10),
          ],
          FloatingActionButton(
            heroTag: "mainFAB",
            backgroundColor: Color(0xFF0E1836), // Warna latar FAB utama
            onPressed: () {
              setState(() {
                _isFabExpanded = !_isFabExpanded;
              });
            },
            shape: CircleBorder(), // Pastikan berbentuk lingkaran
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
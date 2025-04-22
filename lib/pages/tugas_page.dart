import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import '../home_screen.dart';

class TugasPage extends StatefulWidget {
  @override
  _TugasPageState createState() => _TugasPageState();
}

class _TugasPageState extends State<TugasPage> {
  DateTime selectedDate = DateTime.now();
  Map<String, bool> taskCompletion = {}; // Menyimpan status tugas

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('id_ID', null);
  }

  void _previousMonth() {
    setState(() {
      selectedDate = DateTime(selectedDate.year, selectedDate.month - 1, selectedDate.day);
    });
  }

  void _nextMonth() {
    setState(() {
      selectedDate = DateTime(selectedDate.year, selectedDate.month + 1, selectedDate.day);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Tugas", style: TextStyle(color: Colors.white)),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildMonthSelector(),
            SizedBox(height: 16),
            _buildDateSelector(),
            SizedBox(height: 20),
            _buildTaskSection("Tugas Mendatang", [
              _buildTaskCard("Laporan Praktikum Basis Data", "Deadline: Hari Ini - 21:00", Colors.red),
              _buildTaskCard("Tugas Teknik Presentasi", "Deadline: Hari Ini - 23:59", Colors.orange),
            ]),
            _buildTaskSection("Tugas Mendatang", [
              _buildTaskCard("Laporan Kecerdasan Buatan", "Deadline: Minggu, 30 Maret - 23:59", Colors.yellow),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          DateFormat("MMMM yyyy", 'id_ID').format(selectedDate),
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Row(
          children: [
            IconButton(
              icon: Icon(Icons.chevron_left, size: 24, color: Colors.black),
              onPressed: _previousMonth,
            ),
            IconButton(
              icon: Icon(Icons.chevron_right, size: 24, color: Colors.black),
              onPressed: _nextMonth,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDateSelector() {
    List<String> days = ["Sen", "Sel", "Rab", "Kam", "Jum", "Sab", "Min"];
    DateTime firstDay = DateTime(selectedDate.year, selectedDate.month, selectedDate.day - selectedDate.weekday + 1);
    List<Widget> dateWidgets = [];

    for (int i = 0; i < 7; i++) {
      DateTime currentDate = firstDay.add(Duration(days: i));
      bool isSelected = currentDate.day == selectedDate.day;

      dateWidgets.add(Column(
        children: [
          Text(days[i], style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
          SizedBox(height: 4),
          GestureDetector(
            onTap: () {
              setState(() {
                selectedDate = currentDate;
              });
            },
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: isSelected ? Colors.blue : Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: isSelected ? Colors.blue : Colors.grey),
              ),
              child: Center(
                child: Text(
                  currentDate.day.toString(),
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ));
    }

    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.grey.shade300, blurRadius: 5)],
      ),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: dateWidgets),
    );
  }

  Widget _buildTaskSection(String title, List<Widget> tasks) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        SizedBox(height: 8),
        ...tasks,
        SizedBox(height: 16),
      ],
    );
  }

  Widget _buildTaskCard(String title, String deadline, Color borderColor) {
    taskCompletion.putIfAbsent(title, () => false); // Default tugas belum dicentang

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: ListTile(
        leading: GestureDetector(
          onTap: () {
            setState(() {
              taskCompletion[title] = !(taskCompletion[title] ?? false);
            });
          },
          child: Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: borderColor, width: 2),
              color: taskCompletion[title]! ? borderColor : Colors.transparent,
            ),
            child: taskCompletion[title]!
                ? Icon(Icons.check, color: Colors.white, size: 18)
                : null,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            decoration: taskCompletion[title]! ? TextDecoration.lineThrough : TextDecoration.none,
            color: taskCompletion[title]! ? Colors.grey : Colors.black,
          ),
        ),
        subtitle: Text(deadline),
        trailing: Container(
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            border: Border.all(color: borderColor),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            "To-Do",
            style: TextStyle(color: borderColor, fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import '../models/tugas.dart';
import '../services/api_service.dart';

class TugasPage extends StatefulWidget {
  @override
  _TugasPageState createState() => _TugasPageState();
}

class _TugasPageState extends State<TugasPage> {
  List<Tugas> tugasList = [];
  bool isLoading = true;
  Map<String, bool> taskCompletion = {};
  DateTime selectedDate = DateTime.now();
  List<DateTime> visibleDates = [];

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('id_ID', null);
    fetchTugas();
    generateVisibleDates(selectedDate);
  }

  Future<void> fetchTugas() async {
    try {
      final data = await ApiService.fetchTugas();
      setState(() {
        tugasList = data;
        isLoading = false;
      });
    } catch (e) {
      print('Error mengambil tugas: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  void generateVisibleDates(DateTime baseDate) {
    visibleDates = List.generate(7, (i) => baseDate.add(Duration(days: i - 3)));
  }

  void _previousDay() {
    setState(() {
      selectedDate = selectedDate.subtract(Duration(days: 1));
      generateVisibleDates(selectedDate);
    });
  }

  void _nextDay() {
    setState(() {
      selectedDate = selectedDate.add(Duration(days: 1));
      generateVisibleDates(selectedDate);
    });
  }

  bool isSameDate(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  @override
  Widget build(BuildContext context) {
    final filteredTugas = tugasList.where((tugas) => isSameDate(tugas.deadline, selectedDate)).toList();

    return Scaffold(
     appBar: AppBar(
      title: Text('Tugas'),
      backgroundColor: Color(0xFF0E1836),
      foregroundColor: Colors.white,
      ),

      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                SizedBox(height: 12),
                _buildHeaderNavigator(),
                _buildDateSelector(),
                if (!isSameDate(selectedDate, DateTime.now()))
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: TextButton(
                      onPressed: () {
                        setState(() {
                          selectedDate = DateTime.now();
                          generateVisibleDates(selectedDate);
                        });
                      },
                      child: Text('Tampilkan Tugas Hari Ini'),
                    ),
                  ),
                Expanded(
                  child: (filteredTugas.isEmpty)
                      ? Center(child: Text('Tidak ada tugas pada hari ini.'))
                      : ListView.builder(
                          itemCount: filteredTugas.length,
                          itemBuilder: (context, index) {
                            final tugas = filteredTugas[index];
                            final formattedDeadline = DateFormat("EEEE, dd MMMM yyyy", "id_ID")
                                .format(tugas.deadline);

                            return Card(
  margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  elevation: 2,
  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  child: ListTile(
    leading: GestureDetector(
      onTap: () {
        setState(() {
          taskCompletion[tugas.judulTugas] = !(taskCompletion[tugas.judulTugas] ?? false);
        });
      },
      child: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: taskCompletion[tugas.judulTugas] == true ? Colors.green : Colors.grey,
            width: 2,
          ),
          color: taskCompletion[tugas.judulTugas] == true ? Colors.green : Colors.transparent,
        ),
        child: taskCompletion[tugas.judulTugas] == true
            ? Icon(Icons.check, color: Colors.white, size: 18)
            : null,
      ),
    ),
    title: Text(
      tugas.judulTugas,
      style: TextStyle(
        fontWeight: FontWeight.bold,
        decoration: taskCompletion[tugas.judulTugas] == true
            ? TextDecoration.lineThrough
            : TextDecoration.none,
        color: taskCompletion[tugas.judulTugas] == true ? Colors.grey : Colors.black,
      ),
    ),
    subtitle: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Mata Kuliah: ${tugas.namaMatakuliah}'),
        Text('Deadline: $formattedDeadline'),
      ],
    ),
    trailing: Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue),
      ),
      child: Text(
        'To-Do',
        style: TextStyle(
          color: Colors.blue,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    ),
  ),
);

                          },
                        ),
                ),
              ],
            ),
    );
  }

  Widget _buildHeaderNavigator() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            DateFormat("EEEE, dd MMMM yyyy", "id_ID").format(selectedDate),
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          Row(
            children: [
              IconButton(icon: Icon(Icons.chevron_left), onPressed: _previousDay),
              IconButton(icon: Icon(Icons.chevron_right), onPressed: _nextDay),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDateSelector() {
    List<String> days = ["Min", "Sen", "Sel", "Rab", "Kam", "Jum", "Sab"];

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: visibleDates.map((date) {
          bool isSelected = isSameDate(date, selectedDate);
          return Column(
            children: [
              Text(days[date.weekday % 7], style: TextStyle(fontSize: 14)),
              SizedBox(height: 4),
              GestureDetector(
                onTap: () {
                  setState(() {
                    selectedDate = date;
                    generateVisibleDates(selectedDate);
                  });
                },
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: isSelected ? Color(0xFF0E1836) : Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? Color(0xFF0E1836) : Colors.grey,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      '${date.day}',
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}

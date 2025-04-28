import 'package:flutter/material.dart';

class AddJadwalPage extends StatefulWidget {
  @override
  _AddJadwalPageState createState() => _AddJadwalPageState();
}

class _AddJadwalPageState extends State<AddJadwalPage> {
  List<JadwalForm> jadwalForms = [JadwalForm(key: UniqueKey(), onRemove: () {})];

  void _addNewForm() {
    setState(() {
      jadwalForms.add(JadwalForm(
        key: UniqueKey(),
        onRemove: () {
          setState(() {
            jadwalForms.removeLast();
          });
        },
      ));
    });
  }

  void _saveJadwal() {
    print("Jadwal Disimpan!");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF1E2A47),
        title: Text("Tambah Jadwal", style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            children: [
              ...jadwalForms,
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildButton("Tambah", const Color.fromARGB(255, 95, 129, 158), _addNewForm),
                  _buildButton("Simpan", const Color.fromARGB(255, 59, 100, 60), _saveJadwal),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildButton(String text, Color color, VoidCallback onPressed) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      ),
      onPressed: onPressed,
      child: Text(text, style: TextStyle(color: Colors.white, fontSize: 16)),
    );
  }
}

class JadwalForm extends StatefulWidget {
  final VoidCallback onRemove;

  JadwalForm({Key? key, required this.onRemove}) : super(key: key);

  @override
  _JadwalFormState createState() => _JadwalFormState();
}

class _JadwalFormState extends State<JadwalForm> {
  String? selectedDay;
  String? selectedType;
  TimeOfDay startTime = TimeOfDay(hour: 8, minute: 0);
  TimeOfDay endTime = TimeOfDay(hour: 9, minute: 40);
  List<bool> reminders = [true, false, false];

  Future<void> _selectTime(BuildContext context, bool isStartTime) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isStartTime ? startTime : endTime,
    );
    if (picked != null) {
      setState(() {
        if (isStartTime) {
          startTime = picked;
        } else {
          endTime = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 20),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 5)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Informasi Mata Kuliah", style: TextStyle(fontWeight: FontWeight.bold)),
              IconButton(
                icon: Icon(Icons.delete, color: Colors.red),
                onPressed: widget.onRemove,
              ),
            ],
          ),
          _buildTextField("Nama Mata Kuliah", "Masukkan nama mata kuliah"),
          _buildTextField("Dosen Pengajar", "Masukkan nama dosen"),
          _buildDropdown("Jenis Mata Kuliah", ["Teori", "Praktikum"], (value) {
            setState(() {
              selectedType = value;
            });
          }),
          SizedBox(height: 10),
          Text("Jadwal Perkuliahan", style: TextStyle(fontWeight: FontWeight.bold)),
          _buildDropdown("Hari", ["Senin", "Selasa", "Rabu", "Kamis", "Jumat", "Sabtu", "Minggu"], (value) {
            setState(() {
              selectedDay = value;
            });
          }),
          _buildTimePicker("Waktu Kuliah", startTime, endTime),
          _buildTextField("Tempat Perkuliahan", "Contoh: PSDKU - L.A - 203"),
          SizedBox(height: 10),
          Text("Pengingat", style: TextStyle(fontWeight: FontWeight.bold)),
          _buildReminderSelection(),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, String hint) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10),
      child: TextField(
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }

  Widget _buildDropdown(String label, List<String> items, ValueChanged<String?> onChanged) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
        items: items.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildTimePicker(String label, TimeOfDay start, TimeOfDay end) {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () => _selectTime(context, true),
            child: _buildTimeBox("${start.hour.toString().padLeft(2, '0')}:${start.minute.toString().padLeft(2, '0')}"),
          ),
        ),
        Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: Text("-")),
        Expanded(
          child: GestureDetector(
            onTap: () => _selectTime(context, false),
            child: _buildTimeBox("${end.hour.toString().padLeft(2, '0')}:${end.minute.toString().padLeft(2, '0')}"),
          ),
        ),
      ],
    );
  }

  Widget _buildTimeBox(String time) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8),
      ),
      alignment: Alignment.center,
      child: Text(time, style: TextStyle(fontSize: 16)),
    );
  }

  Widget _buildReminderSelection() {
    List<String> options = ["15 menit", "1 jam", "1 hari"];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(3, (index) {
        return GestureDetector(
          onTap: () {
            setState(() {
              reminders = List.filled(3, false);
              reminders[index] = true;
            });
          },
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
            decoration: BoxDecoration(
              color: reminders[index] ? const Color.fromARGB(255, 95, 129, 158) : Colors.white,
              border: Border.all(color: const Color.fromARGB(255, 95, 129, 158)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              options[index],
              style: TextStyle(
                color: reminders[index] ? Colors.white : const Color.fromARGB(255, 95, 129, 158),
                fontSize: 14,
              ),
            ),
          ),
        );
      }),
    );
  }
}

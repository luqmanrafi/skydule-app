import 'package:flutter/material.dart';
import 'package:skydule_app/models/matakuliah.dart';
import '../services/api_service.dart';


class AddJadwalPage extends StatefulWidget {
  @override
  _AddJadwalPageState createState() => _AddJadwalPageState();
}

class _AddJadwalPageState extends State<AddJadwalPage> {
  List<GlobalKey<_JadwalFormState>> _formKeys = [GlobalKey<_JadwalFormState>()];
  List<Widget> _buildJadwalForm(){
    return _formKeys
        .asMap()
        .map((index, key) => MapEntry(
          index,
          JadwalForm(
            key: key,
            onRemove: () => _removeForm(index),
          )))
        .values
        .toList();
  }
  void _addNewForm(){
    setState(() {
      _formKeys.add(GlobalKey<_JadwalFormState>());
    });
  }

  void _removeForm(int index){
    setState(() {
      if (_formKeys.length>1){
        _formKeys.removeAt(index);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Harus ada setidaknya 1 form.")),
        );
      }
    });
  }

  // Di dalam class _AddJadwalPageState di file lib/pages/add_jadwal_page.dart

  Future<void> _saveJadwal() async {
    bool allFormsValid = true;
    List<Matakuliah> matakuliahList = [];

    if (_formKeys.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Tidak ada data jadwal untuk disimpan.')),
      );
      return;
    }

    for (var key in _formKeys) {
      final formState = key.currentState;
      if (formState == null) {
        print("Error: Form state is null for one of the forms. Skipping.");
        allFormsValid = false;
        continue;
      }

      final Map<String, dynamic>? data = formState.getJadwalData();

      if (data == null) {
        print("Error: getJadwalData() returned null for one of the forms. Skipping.");
        allFormsValid = false;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ada form yang datanya tidak lengkap/valid.')),
        );
        continue;
      }

      print('--- DEBUG: Data dari getJadwalData() untuk satu form ---');
      data.forEach((key, value) {
        print('$key: $value (Tipe: ${value.runtimeType})');
      });
      print('--- AKHIR DEBUG DATA ---');

      String namaMatakuliah = data['namaMatakuliah']?.toString() ?? '';
      String dosenPengajar = data['dosenPengajar']?.toString() ?? '';
      String jenisMatakuliah = data['jenisMatakuliah']?.toString() ?? 'Teori';
      String hari = data['hari']?.toString() ?? 'Senin';
      String jamMulai = data['jamMulai']?.toString() ?? '08:00';
      String jamSelesai = data['jamSelesai']?.toString() ?? '09:40';
      String ruangan = data['ruangan']?.toString() ?? '';

      final matakuliah = Matakuliah(
        idMatakuliah: '',
        namaMatakuliah: namaMatakuliah,
        dosenPengajar: dosenPengajar,
        jenisMatakuliah: jenisMatakuliah,
        hari: hari,
        jamMulai: jamMulai,
        jamSelesai: jamSelesai,
        ruangan: ruangan,
      );
      matakuliahList.add(matakuliah);
    }

    if (!allFormsValid) {
      print("Proses simpan dibatalkan karena ada form yang tidak valid atau data null.");
      return;
    }

    if (matakuliahList.isEmpty && _formKeys.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memproses data dari form.')),
      );
      // if (Navigator.of(context).canPop()) Navigator.of(context).pop(); // Dismiss loading
      return;
    }


    // Kirim semua matakuliah yang valid ke API
    int successCount = 0;
    bool anyFailed = false;

    for (var matkul in matakuliahList) {
      print('--- MENGIRIM MATAKULIAH KE API ---');
      print('Data yang dikirim (setelah toJson akan menghilangkan id jika di-setting): ${matkul.toJson()}'); // Cetak apa yang akan di-encode
      bool success = await ApiService.createMatakuliah(matkul);
      if (success) {
        successCount++;
      } else {
        anyFailed = true;
      }
    }

    // Dismiss loading indicator jika ada
    // if (Navigator.of(context).canPop()) Navigator.of(context).pop();

    // Tampilkan feedback berdasarkan hasil
    if (successCount == matakuliahList.length && !anyFailed) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Semua (${matakuliahList.length}) jadwal berhasil disimpan!')),
      );
      if(mounted) {
        Navigator.pop(context, true);
      }// Kembali dan tandai ada perubahan
    } else if (successCount > 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$successCount jadwal berhasil disimpan, namun ada yang gagal.')),
      );
    } else if (matakuliahList.isNotEmpty) { // Hanya tampilkan gagal total jika memang ada data yang coba dikirim
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menyimpan semua jadwal. Coba lagi.')),
      );
    }
    // Jika matakuliahList kosong tapi _formKeys tidak, pesan error sudah ditangani di atas
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
              ..._buildJadwalForm(),
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
  final _namaMatkulController = TextEditingController();
  final _dosenPengajarController = TextEditingController();
  final _ruanganController = TextEditingController();

  String? selectedDay;
  String? selectedType;
  TimeOfDay startTime = TimeOfDay(hour: 8, minute: 0);
  TimeOfDay endTime = TimeOfDay(hour: 9, minute: 40);
  List<bool> reminders = [true, false, false];


    @override
    void dispose(){
      _namaMatkulController.dispose();
      _dosenPengajarController.dispose();
      _ruanganController.dispose();
      super.dispose();
    }

    Map<String, dynamic>getJadwalData() {
      return{
        'namaMatakuliah': _namaMatkulController.text,
        'dosenPengajar': _dosenPengajarController.text,
        'jenisMatakuliah': selectedType,
        'hari': selectedDay,
        'jamMulai': "${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}",
        'jamSelesai': "${endTime.hour.toString().padLeft(2, '0')}:${endTime.minute.toString().padLeft(2, '0')}",
        'ruangan': _ruanganController.text,
      };
    }
    Future<void>_selectTime(BuildContext context, bool isStartTime)async{
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
          _buildTextField("Nama Mata Kuliah", "Masukkan nama mata kuliah", _namaMatkulController),
          _buildTextField("Dosen Pengajar", "Masukkan nama dosen", _dosenPengajarController),
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
          _buildTextField("Tempat Perkuliahan", "Contoh: PSDKU - L.A - 203", _ruanganController),
          SizedBox(height: 10),
          // Text("Pengingat", style: TextStyle(fontWeight: FontWeight.bold)),
          // _buildReminderSelection(),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, String hint, TextEditingController controller) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: controller,
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

class Matakuliah {
  final String idMatakuliah;
  final String namaMatakuliah;
  final String dosenPengajar;
  final String jenisMatakuliah;
  final String hari;
  final String jamMulai;
  final String jamSelesai;
  final String ruangan;

  Matakuliah({
    required this.idMatakuliah,
    required this.namaMatakuliah,
    required this.dosenPengajar,
    required this.jenisMatakuliah,
    required this.hari,
    required this.jamMulai,
    required this.jamSelesai,
    required this.ruangan,
  });

  factory Matakuliah.fromJson(Map<String, dynamic> json) {
    return Matakuliah(
      idMatakuliah: json['id_matakuliah'],
      namaMatakuliah: json['nama_matakuliah'],
      dosenPengajar: json['dosen_pengajar'],
      jenisMatakuliah: json['jenis_matakuliah'],
      hari: json['hari'],
      jamMulai: json['jam_mulai'],
      jamSelesai: json['jam_selesai'],
      ruangan: json['ruangan'],
    );
  }
}

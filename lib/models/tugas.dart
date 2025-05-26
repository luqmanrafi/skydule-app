class Matakuliah {
  final String namaMatakuliah;
  final String judulTugas;
  final String deadlineTugas;
  final String deskripsiTugas;

  Matakuliah({
    required this.namaMatakuliah,
    required this.judulTugas,
    required this.deadlineTugas,
    required this.deskripsiTugas,
  });

  factory Matakuliah.fromJson(Map<String, dynamic> json) {
    return Matakuliah(
      namaMatakuliah: json['nama_matakuliah'],
      judulTugas: json['judul_tugas'],
      deadlineTugas: json['deadline_tugas'],
      deskripsiTugas: json['deskripsi_tugas'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nama_matakuliah': namaMatakuliah,
      'judul_tugas': judulTugas,
      'deadline_tugas': deadlineTugas,
      'deskripsi_tugas': deskripsiTugas,
    };
  }
}

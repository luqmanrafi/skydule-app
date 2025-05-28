class Tugas {
  final String namaMatakuliah;
  final String judulTugas;
  final String deskripsiTugas;
  final DateTime deadline;

  Tugas({
    required this.namaMatakuliah,
    required this.judulTugas,
    required this.deskripsiTugas,
    required this.deadline,
  });

  factory Tugas.fromJson(Map<String, dynamic> json) {
    return Tugas(
      namaMatakuliah: json['nama_matakuliah'] ?? '',
      judulTugas: json['judul_tugas'] ?? '',
      deskripsiTugas: json['deskripsi_tugas'] ?? '',
      deadline: (json['deadline_tugas'] != null)
          ? DateTime.parse(json['deadline_tugas'])
          : DateTime(2100), // Atau fallback date lain
    );
  }
}

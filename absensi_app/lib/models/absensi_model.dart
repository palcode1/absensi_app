class AbsensiModel {
  final int? id; // Auto increment
  final String uid; // Refer ke user yang login
  final String tanggal; // Format: "2025-04-23"
  final String checkIn; // Format: "08:00"
  final String? checkOut; // Boleh null
  final String lokasi; // Alamat atau koordinat

  AbsensiModel({
    this.id,
    required this.uid,
    required this.tanggal,
    required this.checkIn,
    required this.checkOut,
    required this.lokasi,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'uid': uid,
      'tanggal': tanggal,
      'jam_check_in': checkIn,
      'jam_check_out': checkOut,
      'lokasi': lokasi,
    };
  }

  factory AbsensiModel.fromMap(Map<String, dynamic> map) {
    return AbsensiModel(
      id: map['id'],
      uid: map['uid'],
      tanggal: map['tanggal'],
      checkIn: map['jam_check_in'],
      checkOut: map['jam_check_out'],
      lokasi: map['lokasi'],
    );
  }
}

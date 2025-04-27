import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class LocationService {
  /// Ambil lokasi terkini dari perangkat (GPS)
  static Future<Position> getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception("Layanan lokasi tidak aktif.");
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception("Izin lokasi ditolak.");
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception("Izin lokasi ditolak permanen.");
    }

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  /// Ubah posisi (latitude & longitude) menjadi alamat lengkap
  static Future<String> getAddress(Position position) async {
    List<Placemark> placemarks = await placemarkFromCoordinates(
      position.latitude,
      position.longitude,
    );
    final place = placemarks.first;
    return "${place.street}, ${place.subLocality}, ${place.locality}";
  }

  /// Hitung jarak (dalam meter) antara user dan titik target
  static double distanceTo(
    Position userPos,
    double latTarget,
    double lonTarget,
  ) {
    return Geolocator.distanceBetween(
      userPos.latitude,
      userPos.longitude,
      latTarget,
      lonTarget,
    );
  }
}

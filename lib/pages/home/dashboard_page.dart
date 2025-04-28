import 'dart:async';
import 'package:absensi_app/pages/main_navigation/main_navigation_page.dart';
import 'package:absensi_app/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:absensi_app/services/location_service.dart';
import 'package:absensi_app/services/shared_pref_service.dart';
import 'package:absensi_app/services/absensi_service.dart';
import 'package:absensi_app/services/db_service.dart';
import 'package:absensi_app/models/absensi_model.dart';
import 'package:absensi_app/widgets/custom_button.dart';
import 'package:absensi_app/widgets/custom_appbar.dart';
import 'package:absensi_app/utils/helper.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int? _lastAbsensiId;
  String? name;
  String _currentTime = '';
  String _currentDate = '';
  String _currentAddress = '-';
  Position? _currentPosition;
  late Timer _timer;
  bool isCheckedIn = false;
  bool isCheckedOut = false;

  // Titik lokasi kantor
  late GoogleMapController mapController;
  final LatLng attendancePoint = const LatLng(-6.21087, 106.81298);
  static const double maxDistance = 15.0; // meter

  @override
  void initState() {
    super.initState();
    loadUserName();
    _setCurrentTime();
    _getLocation();
    checkTodayAbsensi();
  }

  void _setCurrentTime() {
    _updateTime();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _updateTime());
  }

  void _updateTime() {
    final now = DateTime.now();
    if (!mounted) return;
    setState(() {
      _currentDate = DateFormat("EEEE, dd-MM-yyyy", "id_ID").format(now);
      _currentTime = DateFormat("HH:mm:ss").format(now);
    });
  }

  Future<void> loadUserName() async {
    final uid = await SharedPrefService.getUID();
    if (uid != null) {
      final user = await DBService.getUserByUID(uid);
      if (user != null && mounted) {
        setState(() {
          name = user.name;
        });
      }
    }
  }

  Future<void> _getLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        permission = await Geolocator.requestPermission();
      }
      final pos = await LocationService.getCurrentLocation();
      final addr = await LocationService.getAddress(pos);
      if (!mounted) return;
      setState(() {
        _currentPosition = pos;
        _currentAddress = addr;
      });
    } catch (e) {
      if (mounted) {
        showErrorToast("Gagal mendapatkan lokasi: $e");
      }
    }
  }

  Future<void> _handleCheckIn() async {
    if (_currentPosition == null) return;

    final uid = await SharedPrefService.getUID();
    if (uid == null) return;

    final distance = LocationService.distanceTo(
      _currentPosition!,
      attendancePoint.latitude,
      attendancePoint.longitude,
    );
    if (distance > maxDistance) {
      if (mounted) {
        showErrorToast("Kamu berada di luar jangkauan absen.");
      }
      return;
    }

    final now = DateTime.now();
    final absensi = AbsensiModel(
      uid: uid,
      tanggal: DateFormat("yyyy-MM-dd").format(now),
      checkIn: DateFormat("HH:mm:ss").format(now),
      checkOut: null,
      lokasi: _currentAddress,
    );

    final id = await AbsensiService.checkIn(absensi);
    if (!mounted) return;
    setState(() {
      showSuccessToast('Kamu berhasil check-in pada ${absensi.checkIn}');
      isCheckedIn = true;
      _lastAbsensiId = id;
    });
  }

  Future<void> _handleCheckOut() async {
    if (_lastAbsensiId == null) return;

    final uid = await SharedPrefService.getUID();
    if (uid == null) return;

    final todayAbsensi = await AbsensiService.getTodayAbsensi(uid);

    if (todayAbsensi != null) {
      if (todayAbsensi.checkOut == null) {
        // ✅ Belum check-out → Simpan jam check-out
        final now = DateTime.now();
        final checkOut = DateFormat("HH:mm:ss").format(now);

        await AbsensiService.checkOut(_lastAbsensiId!, checkOut);
        if (mounted) {
          showSuccessToast("Kamu berhasil check-out pada $checkOut");
        }
      } else {
        // ✅ Sudah check-out → Tampilkan toast "Kamu sudah Check-Out hari ini"
        if (mounted) {
          showSuccessToast("Kamu sudah Check-Out hari ini");
        }
      }
    }

    // ✅ Apapun kondisinya, langsung ke halaman History
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const MainNavigationPage(initialIndex: 1),
        ),
      );
    }
  }

  Future<void> checkTodayAbsensi() async {
    final uid = await SharedPrefService.getUID();
    if (uid == null) return;

    final allAbsensi = await AbsensiService.getAbsensiUser(uid);
    final today = DateFormat("yyyy-MM-dd").format(DateTime.now());

    final absensiHariIniList =
        allAbsensi.where((absen) => absen.tanggal == today).toList();
    if (absensiHariIniList.isNotEmpty) {
      final absensiHariIni = absensiHariIniList.first;
      if (!mounted) return;
      setState(() {
        isCheckedIn = true;
        _lastAbsensiId = absensiHariIni.id;
      });
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final VoidCallback? checkInCallback =
        isCheckedIn ? null : () => _handleCheckIn();

    final VoidCallback? checkOutCallback =
        isCheckedIn ? () => _handleCheckOut() : null;
    return Scaffold(
      backgroundColor: AppColors.yellowSoft,
      body: Column(
        children: [
          CustomAppBar(
            content: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Hi, ${name ?? "User"}",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, color: AppColors.greenDark),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _currentDate,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            _currentTime,
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      height: 250,
                      child:
                          _currentPosition == null
                              ? const Center(child: CircularProgressIndicator())
                              : GoogleMap(
                                initialCameraPosition: CameraPosition(
                                  target: LatLng(
                                    _currentPosition!.latitude,
                                    _currentPosition!.longitude,
                                  ),
                                  zoom: 19,
                                ),
                                myLocationEnabled: true,
                                onMapCreated: (GoogleMapController controller) {
                                  mapController = controller;
                                },
                                markers: {
                                  Marker(
                                    markerId: const MarkerId("user"),
                                    position: LatLng(
                                      _currentPosition!.latitude,
                                      _currentPosition!.longitude,
                                    ),
                                    infoWindow: InfoWindow(
                                      title: 'Posisi Kamu',
                                    ),
                                  ),
                                  Marker(
                                    markerId: const MarkerId("absen"),
                                    position: attendancePoint,
                                    infoWindow: InfoWindow(
                                      title: 'Titik Absen',
                                    ),
                                  ),
                                },
                                circles: {
                                  Circle(
                                    circleId: const CircleId('absen-radius'),
                                    center: attendancePoint,
                                    radius: 20.0,
                                    fillColor: Colors.red.withOpacity(0.2),
                                    strokeColor: Colors.red,
                                    strokeWidth: 1,
                                  ),
                                },
                              ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "Lokasi kamu:",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(_currentAddress, style: TextStyle(fontSize: 16)),
                    const SizedBox(height: 30),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        CustomButton(
                          label: "Check-In",
                          icon: Icons.login,
                          backgroundColor: AppColors.greenLight,
                          onPressed: checkInCallback,
                        ),
                        const SizedBox(height: 12),
                        CustomButton(
                          label: "Check-Out",
                          icon: Icons.logout,
                          backgroundColor: AppColors.greenLight,
                          onPressed: checkOutCallback,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

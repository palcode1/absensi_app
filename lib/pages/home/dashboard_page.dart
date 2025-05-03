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
  String? checkInTime;
  AbsensiStatus absensiStatus = AbsensiStatus.notCheckedIn;

  // Titik lokasi kantor
  late GoogleMapController mapController;
  final LatLng attendancePoint = const LatLng(
    -6.200134272691985,
    106.80993160797331,
  );
  static const double maxDistance = 50.0; // meter

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
      _currentTime = DateFormat("HH:mm:ss a").format(now);
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

  Future<void> _showConfirmDialog({
    required String title,
    required String message,
    required VoidCallback onConfirm,
    bool isCheckOut = false,
  }) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isCheckOut ? AppColors.alert : AppColors.greenDark,
            ),
          ),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(foregroundColor: Colors.grey),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                onConfirm();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    isCheckOut ? AppColors.alert : AppColors.greenDark,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Konfirmasi'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _handleCheckIn() async {
    if (_currentPosition == null) return;

    _showConfirmDialog(
      title: 'Konfirmasi Check-In',
      message: 'Apakah Anda yakin ingin melakukan check-in sekarang?',
      isCheckOut: false,
      onConfirm: () async {
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
        final checkInTime = DateFormat("HH:mm:ss").format(now);
        final absensi = AbsensiModel(
          uid: uid,
          tanggal: DateFormat("yyyy-MM-dd").format(now),
          checkIn: checkInTime,
          checkOut: null,
          lokasi: _currentAddress,
        );

        final id = await AbsensiService.checkIn(absensi);
        if (!mounted) return;
        setState(() {
          showSuccessToast('Kamu berhasil check-in pada ${absensi.checkIn}');
          isCheckedIn = true;
          this.checkInTime = checkInTime;
          _lastAbsensiId = id;
          absensiStatus = AbsensiStatus.checkedIn;
        });
      },
    );
  }

  Future<void> _handleCheckOut() async {
    if (_lastAbsensiId == null) return;

    _showConfirmDialog(
      title: 'Konfirmasi Check-Out',
      message: 'Apakah Anda yakin ingin melakukan check-out sekarang?',
      isCheckOut: true,
      onConfirm: () async {
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
              setState(() {
                isCheckedOut = true;
                absensiStatus = AbsensiStatus.checkedOut;
              });
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
      },
    );
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
        checkInTime = absensiHariIni.checkIn;
        _lastAbsensiId = absensiHariIni.id;

        if (absensiHariIni.checkOut != null) {
          isCheckedOut = true;
          absensiStatus = AbsensiStatus.checkedOut;
        } else {
          absensiStatus = AbsensiStatus.checkedIn;
        }
      });
    } else {
      setState(() {
        absensiStatus = AbsensiStatus.notCheckedIn;
      });
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  String getUserInitial() {
    if (name == null || name!.isEmpty) return "U";
    return name![0].toUpperCase();
  }

  Widget _buildStatusBadge() {
    late Color backgroundColor;
    late Color textColor;
    late String text;
    late IconData icon;

    switch (absensiStatus) {
      case AbsensiStatus.notCheckedIn:
        backgroundColor = Colors.grey.shade200;
        textColor = Colors.grey.shade700;
        text = "Belum Absen";
        icon = Icons.pending_outlined;
        break;
      case AbsensiStatus.checkedIn:
        backgroundColor = AppColors.greenLight.withOpacity(0.2);
        textColor = AppColors.greenDark;
        text = "Sudah Check-In pada $checkInTime";
        icon = Icons.login;
        break;
      case AbsensiStatus.checkedOut:
        backgroundColor = AppColors.alert.withOpacity(0.2);
        textColor = AppColors.alert;
        text = "Sudah Check-Out";
        icon = Icons.check_circle_outline;
        break;
    }

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: textColor.withOpacity(0.3), width: 1),
      ),
      child: Row(
        children: [
          Icon(icon, color: textColor, size: 22),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final VoidCallback? checkInCallback =
        isCheckedIn ? null : () => _handleCheckIn();

    final VoidCallback? checkOutCallback =
        isCheckedIn && !isCheckedOut ? () => _handleCheckOut() : null;
    return Scaffold(
      backgroundColor: AppColors.yellowSoft,
      body: Column(
        children: [
          // Custom App Bar with curved bottom
          Container(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top,
              left: 20,
              right: 20,
              bottom: 15,
            ),
            decoration: BoxDecoration(
              color: AppColors.greenDark,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              children: [
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.white,
                          radius: 20,
                          child: Text(
                            getUserInitial(),
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.greenDark,
                            ),
                          ),
                        ),
                        SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Hi, ${name ?? "User"}",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 10),
                // Time and Date display with card
                Container(
                  padding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _currentDate,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          _currentTime,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.greenLight,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Main Content
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Status Badge
                    _buildStatusBadge(),

                    SizedBox(height: 15),

                    // Title for Map
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          color: AppColors.greenDark,
                          size: 24,
                        ),
                        SizedBox(width: 8),
                        Text(
                          "Lokasi Absensi",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),

                    // Map Container with rounded corners
                    Container(
                      height: 230,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: Offset(0, 5),
                          ),
                        ],
                      ),
                      clipBehavior: Clip.antiAlias,
                      child:
                          _currentPosition == null
                              ? Center(
                                child: CircularProgressIndicator(
                                  color: AppColors.greenDark,
                                ),
                              )
                              : GoogleMap(
                                initialCameraPosition: CameraPosition(
                                  target: LatLng(
                                    _currentPosition!.latitude,
                                    _currentPosition!.longitude,
                                  ),
                                  zoom: 18.5,
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
                                    icon: BitmapDescriptor.defaultMarkerWithHue(
                                      BitmapDescriptor.hueAzure,
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
                                    radius: 50.0,
                                    fillColor: AppColors.alert.withOpacity(0.5),
                                    strokeColor: AppColors.black,
                                    strokeWidth: 1,
                                  ),
                                },
                              ),
                    ),

                    SizedBox(height: 15),

                    // Location info card
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.pin_drop,
                                color: AppColors.greenDark,
                                size: 20,
                              ),
                              SizedBox(width: 8),
                              Text(
                                "Lokasi kamu:",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          Text(
                            _currentAddress,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 10),

                    // Check In Button
                    SizedBox(
                      width: double.infinity,
                      height: 45,
                      child: ElevatedButton.icon(
                        onPressed: checkInCallback,
                        icon: Icon(
                          Icons.login,
                          size: 20,
                          color: AppColors.white,
                        ),
                        label: Text(
                          "Check-In",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              isCheckedIn
                                  ? Colors.grey.shade300
                                  : AppColors.greenDark,
                          foregroundColor:
                              isCheckedIn ? Colors.grey.shade700 : Colors.white,
                          elevation: isCheckedIn ? 0 : 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: 10),

                    // Check Out Button
                    SizedBox(
                      width: double.infinity,
                      height: 45,
                      child: ElevatedButton.icon(
                        onPressed: checkOutCallback,
                        icon: Icon(Icons.logout, size: 20, color: Colors.white),
                        label: Text(
                          "Check-Out",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              isCheckedIn && !isCheckedOut
                                  ? AppColors.alert
                                  : Colors.grey.shade300,
                          foregroundColor:
                              isCheckedIn && !isCheckedOut
                                  ? Colors.white
                                  : Colors.grey.shade700,
                          elevation: isCheckedIn && !isCheckedOut ? 2 : 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
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

// Enum to represent attendance status
enum AbsensiStatus {
  notCheckedIn, // Belum absen sama sekali
  checkedIn, // Sudah check-in, belum check-out
  checkedOut, // Sudah check-in dan check-out
}

import 'package:absensi_app/utils/constants.dart';
import 'package:absensi_app/utils/helper.dart';
import 'package:absensi_app/widgets/custom_appbar.dart';
import 'package:flutter/material.dart';
import 'package:absensi_app/models/absensi_model.dart';
import 'package:absensi_app/services/shared_pref_service.dart';
import 'package:absensi_app/services/absensi_service.dart';
import 'package:intl/intl.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  List<AbsensiModel> _historyList = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final uid = await SharedPrefService.getUID();
    if (uid != null) {
      final data = await AbsensiService.getAbsensiUser(uid);
      if (!mounted) return;
      setState(() {
        _historyList = data;
        isLoading = false;
      });
    }
  }

  void _confirmDelete(int id) {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            title: const Text(
              "Hapus Data",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.greenDark,
              ),
            ),
            content: const Text(
              "Apakah kamu yakin ingin menghapus absensi ini?",
              style: TextStyle(fontSize: 16),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  "Batal",
                  style: TextStyle(
                    color: AppColors.greenLight,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  showSuccessToast('Data absen berhasil dihapus!');
                  Navigator.pop(context); // tutup dialog
                  await AbsensiService.deleteAbsensi(id);
                  _loadHistory(); // refresh
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.alert,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                ),
                child: const Text(
                  "Hapus",
                  style: TextStyle(
                    color: AppColors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
    );
  }

  Widget _buildItem(AbsensiModel item) {
    final bool hasCheckOut = item.checkOut != null && item.checkOut != "-";

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with date and delete button
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: AppColors.greenLight,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(15),
                topRight: Radius.circular(15),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_today,
                      color: AppColors.white,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "Tanggal: ${_formatTanggal(item.tanggal)}",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: AppColors.white,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(
                    Icons.delete_outline,
                    color: AppColors.white,
                  ),
                  onPressed: () => _confirmDelete(item.id!),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Check-in
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.greenLight,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.login_rounded,
                        color: AppColors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Check-In",
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.black,
                          ),
                        ),
                        Text(
                          item.checkIn,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.greenDark,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Check-out
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color:
                            hasCheckOut
                                ? AppColors.alert.withOpacity(0.1)
                                : AppColors.darkGrey.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.logout_rounded,
                        color:
                            hasCheckOut ? AppColors.alert : AppColors.darkGrey,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Check-Out",
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.black,
                          ),
                        ),
                        Text(
                          item.checkOut ?? "-",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color:
                                hasCheckOut
                                    ? AppColors.alert
                                    : AppColors.darkGrey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Location
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.location_on,
                        color: AppColors.greenLight,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Lokasi",
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.darkGrey,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              item.lokasi,
                              style: const TextStyle(
                                fontSize: 15,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTanggal(String rawDate) {
    try {
      final parsedDate = DateTime.parse(
        rawDate,
      ); // pastikan format 'yyyy-MM-dd'
      return DateFormat('dd-MM-yyyy').format(parsedDate); // hasil: 25-04-2025
    } catch (e) {
      return rawDate;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.yellowSoft,
      body: Column(
        children: [
          const CustomAppBar(
            content: Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.0),
              child: Row(
                children: [
                  Icon(Icons.history, color: AppColors.white, size: 24),
                  SizedBox(width: 10),
                  Text(
                    "Riwayat Absensi",
                    style: TextStyle(
                      color: AppColors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child:
                isLoading
                    ? const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.greenLight,
                      ),
                    )
                    : _historyList.isEmpty
                    ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.history_toggle_off,
                            size: 80,
                            color: Colors.grey.withOpacity(0.5),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            "Belum ada data absensi",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    )
                    : RefreshIndicator(
                      color: AppColors.greenLight,
                      onRefresh: _loadHistory,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _historyList.length,
                        itemBuilder: (context, index) {
                          return _buildItem(_historyList[index]);
                        },
                      ),
                    ),
          ),
        ],
      ),
    );
  }
}

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
            title: const Text("Hapus Data"),
            content: const Text(
              "Apakah kamu yakin ingin menghapus absensi ini?",
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  "Batal",
                  style: TextStyle(color: AppColors.greenLight),
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
                ),
                child: const Text(
                  "Hapus",
                  style: TextStyle(color: AppColors.white),
                ),
              ),
            ],
          ),
    );
  }

  Widget _buildItem(AbsensiModel item) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Tanggal : ${_formatTanggal(item.tanggal)}",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: AppColors.alert),
                onPressed: () => _confirmDelete(item.id!),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Text(
                "✅ Check-In : ",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              Text(
                item.checkIn,
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Text(
                "❌ Check-Out : ",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              Text(
                item.checkOut ?? "-",
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            "📍 Lokasi : ",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 4),
          Text(
            item.lokasi,
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
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
            content: Text(
              "Riwayat Absensi",
              style: TextStyle(
                color: AppColors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child:
                isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _historyList.isEmpty
                    ? const Center(child: Text("Belum ada data absensi."))
                    : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _historyList.length,
                      itemBuilder: (context, index) {
                        return _buildItem(_historyList[index]);
                      },
                    ),
          ),
        ],
      ),
    );
  }
}

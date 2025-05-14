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

enum FilterType { all, month, custom }

class _HistoryPageState extends State<HistoryPage> {
  List<AbsensiModel> _historyList = [];
  List<AbsensiModel> _allAbsensiData = []; // Menyimpan semua data untuk filter
  bool isLoading = true;
  DateTimeRange? _selectedRange;
  FilterType _filterType = FilterType.all;

  // Filter berdasarkan bulan
  DateTime _selectedMonth = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() => isLoading = true);
    final uid = await SharedPrefService.getUID();
    if (uid != null) {
      final data = await AbsensiService.getAbsensiUser(uid);
      if (!mounted) return;
      setState(() {
        _allAbsensiData = data; // Simpan semua data
        _historyList = data; // Tampilkan semua data sebagai default
        isLoading = false;
      });
    }
  }

  Future<void> _pickDateRange() async {
    final DateTime now = DateTime.now();
    final DateTime firstDay = DateTime(now.year - 2);
    final DateTime lastDay = now;

    final picked = await showDateRangePicker(
      context: context,
      firstDate: firstDay,
      lastDate: lastDay,
      initialDateRange:
          _selectedRange ??
          DateTimeRange(
            start: DateTime(now.year, now.month, 1),
            end: DateTime(now.year, now.month, now.day), // end = hari ini
          ),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(primary: AppColors.greenDark),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && mounted) {
      setState(() {
        _selectedRange = picked;
        _filterType = FilterType.custom;
      });
      _applyFilter();
    }
  }

  // Metode baru untuk memilih bulan
  Future<void> _pickMonth() async {
    final DateTime now = DateTime.now();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: const Text(
            "Pilih Bulan",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.greenDark,
            ),
          ),
          content: SizedBox(
            height: 300,
            width: 300,
            child: YearPicker(
              firstDate: DateTime(now.year - 2, 1),
              lastDate: now,
              selectedDate: _selectedMonth,
              onChanged: (DateTime dateTime) {
                Navigator.pop(context);
                // Tampilkan dialog untuk memilih bulan dalam tahun tersebut
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      title: Text(
                        "Pilih Bulan ${dateTime.year}",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.greenDark,
                        ),
                      ),
                      content: SizedBox(
                        height: 300,
                        width: 300,
                        child: GridView.builder(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                childAspectRatio: 1.5,
                              ),
                          itemCount: 12,
                          itemBuilder: (context, index) {
                            return InkWell(
                              onTap: () {
                                final selectedDate = DateTime(
                                  dateTime.year,
                                  index + 1,
                                );
                                setState(() {
                                  _selectedMonth = selectedDate;
                                  _filterType = FilterType.month;
                                });
                                _applyFilter();
                                Navigator.pop(context);
                              },
                              child: Container(
                                margin: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color:
                                      _selectedMonth.year == dateTime.year &&
                                              _selectedMonth.month == index + 1
                                          ? AppColors.greenLight
                                          : Colors.grey.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Center(
                                  child: Text(
                                    DateFormat('MMM').format(
                                      DateTime(dateTime.year, index + 1),
                                    ),
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color:
                                          _selectedMonth.year ==
                                                      dateTime.year &&
                                                  _selectedMonth.month ==
                                                      index + 1
                                              ? AppColors.white
                                              : AppColors.black,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }

  // Metode baru untuk menerapkan filter
  void _applyFilter() {
    if (_allAbsensiData.isEmpty) return;

    List<AbsensiModel> filtered = [];

    switch (_filterType) {
      case FilterType.all:
        filtered = List.from(_allAbsensiData);
        break;

      case FilterType.month:
        filtered =
            _allAbsensiData.where((item) {
              final tgl = DateTime.parse(item.tanggal);
              return tgl.month == _selectedMonth.month &&
                  tgl.year == _selectedMonth.year;
            }).toList();
        break;

      case FilterType.custom:
        if (_selectedRange != null) {
          filtered =
              _allAbsensiData.where((item) {
                try {
                  final tgl = DateTime.parse(item.tanggal);
                  return !tgl.isBefore(_selectedRange!.start) &&
                      !tgl.isAfter(_selectedRange!.end);
                } catch (e) {
                  return false; // Lewati jika tanggal tidak valid
                }
              }).toList();
        }
        break;
    }

    // Urutkan data berdasarkan tanggal terbaru
    filtered.sort(
      (a, b) => DateTime.parse(b.tanggal).compareTo(DateTime.parse(a.tanggal)),
    );

    setState(() => _historyList = filtered);
  }

  String _getFilterText() {
    switch (_filterType) {
      case FilterType.all:
        return "Semua Data";
      case FilterType.month:
        return "Bulan ${DateFormat('MMMM yyyy').format(_selectedMonth)}";
      case FilterType.custom:
        if (_selectedRange != null) {
          return "${DateFormat('dd MMM yyyy').format(_selectedRange!.start)} - ${DateFormat('dd MMM yyyy').format(_selectedRange!.end)}";
        }
        return "Rentang Tanggal";
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
      return DateFormat(
        'dd MMMM yyyy',
        'id_ID',
      ).format(parsedDate); // hasil: 25-04-2025
    } catch (e) {
      return rawDate;
    }
  }

  // UI untuk filter area yang lebih baik
  Widget _buildFilterBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Filter Data",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: AppColors.greenDark,
            ),
          ),
          const SizedBox(height: 8),

          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.greenLight.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColors.greenLight.withOpacity(0.3),
                    ),
                  ),
                  child: Text(
                    _getFilterText(),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.greenDark,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              _buildFilterButton(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterButton() {
    return Builder(
      builder: (context) {
        return PopupMenuButton<FilterType>(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.greenLight,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.filter_list, color: AppColors.white),
          ),
          onSelected: (FilterType result) {
            if (result == FilterType.all) {
              setState(() {
                _filterType = FilterType.all;
              });
              _applyFilter();
            } else if (result == FilterType.month) {
              // jalankan setelah pop-up tertutup
              Future.microtask(() => _pickMonth());
            } else if (result == FilterType.custom) {
              Future.microtask(() => _pickDateRange());
            }
          },
          itemBuilder:
              (BuildContext context) => <PopupMenuEntry<FilterType>>[
                const PopupMenuItem<FilterType>(
                  value: FilterType.all,
                  child: Row(
                    children: [
                      Icon(Icons.clear_all, color: AppColors.greenDark),
                      SizedBox(width: 8),
                      Text('Semua Data'),
                    ],
                  ),
                ),
                const PopupMenuItem<FilterType>(
                  value: FilterType.month,
                  child: Row(
                    children: [
                      Icon(Icons.calendar_month, color: AppColors.greenDark),
                      SizedBox(width: 8),
                      Text('Filter Bulan'),
                    ],
                  ),
                ),
                const PopupMenuItem<FilterType>(
                  value: FilterType.custom,
                  child: Row(
                    children: [
                      Icon(Icons.date_range, color: AppColors.greenDark),
                      SizedBox(width: 8),
                      Text('Rentang Tanggal'),
                    ],
                  ),
                ),
              ],
        );
      },
    );
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

          // Filter area baru
          Padding(padding: const EdgeInsets.all(16), child: _buildFilterBar()),

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
                          if (_filterType != FilterType.all) ...[
                            const SizedBox(height: 24),
                            ElevatedButton.icon(
                              onPressed: () {
                                setState(() => _filterType = FilterType.all);
                                _applyFilter();
                              },
                              icon: const Icon(
                                Icons.refresh,
                                color: AppColors.white,
                              ),
                              label: const Text(
                                "Tampilkan Semua Data",
                                style: TextStyle(color: AppColors.white),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.greenLight,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          ],
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

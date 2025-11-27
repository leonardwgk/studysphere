import 'package:flutter/material.dart';

class WeeklyReportSection extends StatelessWidget {
  const WeeklyReportSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Weekly Report',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 15),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.05),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Total Average Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        '4 h 26 m',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Daily average study time',
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ],
                  ),
                  const Text(
                    '(10 November - 16 November)',
                    style: TextStyle(color: Colors.grey, fontSize: 10),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Custom Bar Chart
              const SizedBox(
                height: 150,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _ChartBar(label: 'Mon', heightPct: 0.4, isSelected: false),
                    _ChartBar(label: 'Tue', heightPct: 0.35, isSelected: false),
                    _ChartBar(label: 'Wed', heightPct: 0.6, isSelected: false),
                    _ChartBar(label: 'Thu', heightPct: 0.5, isSelected: false),
                    _ChartBar(
                      label: 'Fri',
                      heightPct: 0.7,
                      isSelected: false,
                    ), // Tertinggi
                    _ChartBar(label: 'Sat', heightPct: 0.3, isSelected: false),
                    _ChartBar(label: 'Sun', heightPct: 0.2, isSelected: false),
                  ],
                ),
              ),

              const SizedBox(height: 20),
              const Divider(),
              const SizedBox(height: 10),

              // Footer
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text(
                    'Total Study Time',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  Text(
                    '31 h 01 m',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// Widget kecil untuk menggambar satu batang grafik
class _ChartBar extends StatelessWidget {
  final String label;
  final double heightPct; // 0.0 sampai 1.0
  final bool isSelected;

  const _ChartBar({
    required this.label,
    required this.heightPct,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        // Batang Grafik
        Container(
          width: 30, // Lebar batang
          height: 120 * heightPct, // Tinggi maksimal grafik diasumsikan 120
          decoration: BoxDecoration(
            // Gradient biru seperti di desain
            gradient: LinearGradient(
              colors: [Colors.blue.shade200, Colors.blue.shade600],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
          ),
        ),
        const SizedBox(height: 8),
        // Label Hari
        Text(
          label,
          style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
        ),
      ],
    );
  }
}

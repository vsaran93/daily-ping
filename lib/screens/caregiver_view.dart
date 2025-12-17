import 'package:daily_ping/models/alert_item.dart';
import 'package:daily_ping/models/elder.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CaregiverView extends StatefulWidget {
  const CaregiverView({super.key});

  @override
  State<CaregiverView> createState() => _CaregiverViewState();
}

class _CaregiverViewState extends State<CaregiverView> {
  late List<Elder> elders;
  late List<AlertItem> alerts;

  @override
  void initState() {
    super.initState();

    elders = [
      Elder(
        id: '1',
        name: 'Margaret Smith',
        status: ElderStatus.safe,
        lastCheckIn: DateTime.now().subtract(const Duration(hours: 2)),
        phoneNumber: '+1 (555) 123-4567',
      ),
      Elder(
        id: '2',
        name: 'Robert Johnson',
        status: ElderStatus.pending,
        lastCheckIn: DateTime.now().subtract(const Duration(hours: 24)),
        phoneNumber: '+1 (555) 234-5678',
      ),
      Elder(
        id: '3',
        name: 'Helen Davis',
        status: ElderStatus.missed,
        lastCheckIn: DateTime.now().subtract(const Duration(hours: 26)),
        phoneNumber: '+1 (555) 345-6789',
      ),
    ];

    alerts = [
      AlertItem(
        id: '1',
        elderName: 'Helen Davis',
        message: 'Missed check-in for over 24 hours',
        time: DateTime.now().subtract(const Duration(minutes: 30)),
        severity: 'high',
      ),
      AlertItem(
        id: '2',
        elderName: 'Robert Johnson',
        message: 'Check-in reminder not confirmed yet',
        time: DateTime.now().subtract(const Duration(hours: 2)),
        severity: 'medium',
      ),
    ];
  }

  String formatTimeAgo(DateTime? date) {
    if (date == null) return 'Never';

    final diff = DateTime.now().difference(date);

    if (diff.inDays > 0) return '${diff.inDays} day${diff.inDays > 1 ? 's' : ''} ago';
    if (diff.inHours > 0) return '${diff.inHours} hour${diff.inHours > 1 ? 's' : ''} ago';
    if (diff.inMinutes > 0) return '${diff.inMinutes} min ago';
    return 'Just now';
  }

  Icon _statusIcon(ElderStatus status) {
    switch (status) {
      case ElderStatus.safe:
        return const Icon(Icons.check_circle, color: Colors.green, size: 32);
      case ElderStatus.pending:
        return const Icon(Icons.schedule, color: Colors.orange, size: 32);
      case ElderStatus.missed:
        return const Icon(Icons.error, color: Colors.red, size: 32);
    }
  }

  @override
  Widget build(BuildContext context) {
    final safeCount = elders.where((e) => e.status == ElderStatus.safe).length;
    final pendingCount = elders.where((e) => e.status == ElderStatus.pending).length;
    final missedCount = elders.where((e) => e.status == ElderStatus.missed).length;

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: const BackButton(color: Colors.black),
        title: const Text('Caregiver Dashboard', style: TextStyle(color: Colors.black)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _statusSummary(safeCount, pendingCount, missedCount),
          const SizedBox(height: 24),
          if (alerts.isNotEmpty) _alertsSection(),
          const SizedBox(height: 24),
          _elderList(),
        ],
      ),
    );
  }

  Widget _statusSummary(int safe, int pending, int missed) {
    Widget box(Color bg, Color border, String label, int count) {
      return Expanded(
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: border, width: 2),
          ),
          child: Column(
            children: [
              Text('$count', style: TextStyle(fontSize: 24, color: border)),
              Text(label, style: TextStyle(color: border)),
            ],
          ),
        ),
      );
    }

    return Row(
      children: [
        box(Colors.green.shade50, Colors.green, 'Safe', safe),
        const SizedBox(width: 8),
        box(Colors.yellow.shade50, Colors.orange, 'Pending', pending),
        const SizedBox(width: 8),
        box(Colors.red.shade50, Colors.red, 'Missed', missed),
      ],
    );
  }

  Widget _alertsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.notifications, color: Colors.red),
            SizedBox(width: 8),
            Text('Active Alerts', style: TextStyle(fontSize: 18)),
          ],
        ),
        const SizedBox(height: 12),
        ...alerts.map((alert) {
          final isHigh = alert.severity == 'high';

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isHigh ? Colors.red.shade50 : Colors.yellow.shade50,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isHigh ? Colors.red : Colors.orange,
                width: 2,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(alert.elderName, style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text(formatTimeAgo(alert.time), style: const TextStyle(fontSize: 12)),
                  ],
                ),
                const SizedBox(height: 8),
                Text(alert.message),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _actionButton(Icons.phone, 'Call Now', Colors.blue),
                    const SizedBox(width: 8),
                    _actionButton(Icons.message, 'SMS', Colors.grey),
                  ],
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _actionButton(IconData icon, String text, Color color) {
    return Expanded(
      child: ElevatedButton.icon(
        onPressed: () {},
        icon: Icon(icon, size: 16),
        label: Text(text),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  Widget _elderList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('All Contacts', style: TextStyle(fontSize: 18)),
        const SizedBox(height: 12),
        ...elders.map((elder) {
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200, width: 2),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    _statusIcon(elder.status),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(elder.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                          Text('Last check-in: ${formatTimeAgo(elder.lastCheckIn)}',
                              style: const TextStyle(fontSize: 12)),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.phone, color: Colors.green),
                      onPressed: () {},
                    ),
                  ],
                ),
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Next reminder: Today 9:00 AM', style: TextStyle(fontSize: 12)),
                    if (elder.lastCheckIn != null)
                      Text(DateFormat('hh:mm a').format(elder.lastCheckIn!),
                          style: const TextStyle(fontSize: 12)),
                  ],
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}

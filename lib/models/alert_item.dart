class AlertItem {
  final String id;
  final String elderName;
  final String message;
  final DateTime time;
  final String severity; // high | medium

  AlertItem({
    required this.id,
    required this.elderName,
    required this.message,
    required this.time,
    required this.severity,
  });
}
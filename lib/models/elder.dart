enum ElderStatus { safe, pending, missed }

class Elder {
  final String id;
  final String name;
  final ElderStatus status;
  final DateTime? lastCheckIn;
  final String phoneNumber;

  Elder({
    required this.id,
    required this.name,
    required this.status,
    required this.lastCheckIn,
    required this.phoneNumber,
  });
}


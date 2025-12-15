import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:intl/intl.dart';

class ElderView extends StatefulWidget {
  const ElderView({super.key});

  @override
  State<ElderView> createState() => _ElderViewState();
}

class _ElderViewState extends State<ElderView> {
  bool checkedInToday = false;
  DateTime? lastCheckIn;
  bool showConfirmation = false;

  final FlutterTts tts = FlutterTts();

  @override
  void initState() {
    super.initState();
    _loadCheckInStatus();
  }

  Future<void> _loadCheckInStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final lastCheck = prefs.getString('lastCheckIn');

    if (lastCheck != null) {
      final checkDate = DateTime.parse(lastCheck);
      final now = DateTime.now();

      if (DateUtils.isSameDay(checkDate, now)) {
        setState(() {
          checkedInToday = true;
          lastCheckIn = checkDate;
        });
      }
    }
  }

  Future<void> _handleCheckIn() async {
    final now = DateTime.now();
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('lastCheckIn', now.toIso8601String());

    setState(() {
      checkedInToday = true;
      lastCheckIn = now;
      showConfirmation = true;
    });

    _speakConfirmation();

    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() => showConfirmation = false);
      }
    });
  }

  Future<void> _speakConfirmation() async {
    await tts.setSpeechRate(0.45);
    await tts.setPitch(1.0);
    await tts.speak("You're marked safe today");
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();

    return Scaffold(
      backgroundColor: const Color(0xFFF0FDF4),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.grey),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Daily Check-In',
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              _buildDateSection(now),
              const SizedBox(height: 20),
              checkedInToday ? _checkedInCard() : _checkInButton(),
              const SizedBox(height: 20),
              if (showConfirmation) _confirmationBanner(),
              const SizedBox(height: 20),
              _nextReminderCard(),
              const SizedBox(height: 20),
              _emergencyButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateSection(DateTime now) {
    return Column(
      children: [
        const Text("Today is", style: TextStyle(color: Colors.grey)),
        Text(
          DateFormat('EEEE, MMMM d').format(now),
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
        ),
        Text(
          DateFormat('hh:mm a').format(now),
          style: const TextStyle(fontSize: 20, color: Colors.black54),
        ),
      ],
    );
  }

  Widget _checkInButton() {
    return ElevatedButton(
      onPressed: _handleCheckIn,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green,
        padding: const EdgeInsets.symmetric(vertical: 48),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(32),
          side: const BorderSide(color: Colors.greenAccent, width: 6),
        ),
        elevation: 10,
      ),
      child: const SizedBox(
        width: double.infinity,
        child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.check_circle, size: 96, color: Colors.white),
          SizedBox(height: 16),
          Text("I'm OK", style: TextStyle(fontSize: 36)),
          SizedBox(height: 8),
          Text("Tap to confirm", style: TextStyle(fontSize: 20)),
        ],
      ),)
    );
  }

  Widget _checkedInCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 48),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Colors.green, Colors.greenAccent],
        ),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: Colors.green.shade300, width: 6),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 10)
        ],
      ),
      child: Column(
        children: [
          const CircleAvatar(
            radius: 48,
            backgroundColor: Colors.white,
            child: Icon(Icons.check, size: 48, color: Colors.green),
          ),
          const SizedBox(height: 16),
          const Text("All Set!",
              style: TextStyle(fontSize: 36, color: Colors.white)),
          const SizedBox(height: 8),
          const Text("You're safe for today",
              style: TextStyle(fontSize: 20, color: Colors.white70)),
          if (lastCheckIn != null)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text(
                "Checked in at ${DateFormat('hh:mm a').format(lastCheckIn!)}",
                style: const TextStyle(color: Colors.white70),
              ),
            ),
        ],
      ),
    );
  }

  Widget _confirmationBanner() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.green.shade100,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.green, width: 4),
      ),
      child: const Column(
        children: [
          Icon(Icons.volume_up, size: 48),
          SizedBox(height: 8),
          Text("✓ Confirmed!", style: TextStyle(fontSize: 24)),
          SizedBox(height: 4),
          Text("Your family has been notified",
              style: TextStyle(fontSize: 18)),
        ],
      ),
    );
  }

  Widget _nextReminderCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [BoxShadow(blurRadius: 6, color: Colors.black12)],
      ),
      child: const Column(
        children: [
          Text("Next reminder", style: TextStyle(color: Colors.grey)),
          SizedBox(height: 4),
          Text("Tomorrow at 9:00 AM",
              style: TextStyle(fontSize: 22)),
        ],
      ),
    );
  }

  Widget _emergencyButton() {
    return ElevatedButton(
      onPressed: () {
        // TODO: Call caregiver / emergency
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.red,
        padding: const EdgeInsets.symmetric(vertical: 24),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
      ),
      child: const SizedBox(
        width: double.infinity,
        child: Column(
        children: [
          Text("🚨 Emergency Help", style: TextStyle(fontSize: 24)),
          SizedBox(height: 4),
          Text("Call caregiver now"),
        ],
      ),)
    );
  }
}

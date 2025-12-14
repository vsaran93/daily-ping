import 'package:daily_ping/screens/auth_screen.dart';
import 'package:flutter/material.dart';

class MyHomePage extends StatelessWidget  {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFE3F2FD),
              Colors.white
            ]
          )
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _header(),
                const SizedBox(height: 32,),
                _elderButton(context),
                const SizedBox(height: 16,),
                _caregiverButton(context),
                const SizedBox(height: 32,),
                _footerText(),
              ],
            ),
          ),
        ),
      )
    );
  }

  Widget _header() {
    return const Column(
      children: [
        Icon(
          Icons.home_rounded,
          size: 64,
          color: Colors.blue,
        ),
        SizedBox(height: 16),
        Text(
          'SafeCheck Daily',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 8),
        Text(
          'Stay connected, stay safe',
          style: TextStyle(
            fontSize: 16,
            color: Colors.black54,
          ),
        ),
      ],
    );
  }

  Widget _elderButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AuthScreen(userType: 'elder'))
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          elevation: 6,
        ),
        child: const Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.elderly,
                  size: 24,
                  color: Colors.white,
                ),
                SizedBox(width: 10,),
                Text(
                'Elder Check-In',
                style: TextStyle(fontSize: 22, color: Colors.white),
                ),
              ],
            ),
            SizedBox(height: 4),
            Text(
              "I'm the one checking in",
              style: TextStyle(
                fontSize: 14,
                color: Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }

Widget _caregiverButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AuthScreen(userType: 'caregiver'))
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          elevation: 6,
        ),
        child: const Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.health_and_safety,
                  size: 24,
                  color: Colors.white,
                ),
                SizedBox(width: 10,),
                Text(
                  'Caregiver Dashboard',
                  style: TextStyle(fontSize: 22, color: Colors.white),
                ),
              ],
            ),
            SizedBox(height: 4),
            Text(
              "I'm monitoring safety",
              style: TextStyle(
                fontSize: 14,
                color: Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _footerText() {
    return const Text(
      'Simple daily check-ins for peace of mind',
      style: TextStyle(
        fontSize: 14,
        color: Colors.black45,
      ),
      textAlign: TextAlign.center,
    );
  }
}
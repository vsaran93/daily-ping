import 'dart:async';
import 'package:daily_ping/screens/elder_view_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum AuthStep { input, otp }
enum ContactMethod { phone, email }

class AuthScreen extends StatefulWidget {
  final String userType;

  const AuthScreen({super.key, required this.userType});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  AuthStep step = AuthStep.input;
  ContactMethod contactMethod = ContactMethod.phone;

  final TextEditingController contactController = TextEditingController();
  final List<TextEditingController> otpControllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> otpFocusNodes =
      List.generate(6, (_) => FocusNode());

  bool isLoading = false;
  String error = '';

  String get title =>
      widget.userType == 'elder' ? 'Elder Check-In' : 'Caregiver Dashboard';

  Widget get icon =>
      widget.userType == 'elder' ? const Icon(Icons.elderly, size: 56, color: Colors.blue,) : const Icon(Icons.health_and_safety, size: 56, color: Colors.green,);

  String get redirectRoute =>
      widget.userType == 'elder' ? '/elder' : '/caregiver';

  bool _validateEmail(String email) {
    return RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(email);
  }

  bool _validatePhone(String phone) {
    return RegExp(r'^[\d\s\-\+\(\)]{10,}$').hasMatch(phone);
  }

  void _sendOtp() {
    setState(() => error = '');

    final value = contactController.text.trim();

    if (contactMethod == ContactMethod.email && !_validateEmail(value)) {
      setState(() => error = 'Please enter a valid email address');
      return;
    }

    if (contactMethod == ContactMethod.phone && !_validatePhone(value)) {
      setState(() => error = 'Please enter a valid phone number');
      return;
    }

    setState(() => isLoading = true);

    Timer(const Duration(seconds: 1), () {
      setState(() {
        isLoading = false;
        step = AuthStep.otp;
      });
      otpFocusNodes.first.requestFocus();
    });
  }

  void _verifyOtp() {
    final otp = otpControllers.map((e) => e.text).join();

    if (otp.length != 6) {
      setState(() => error = 'Please enter the complete 6-digit OTP');
      return;
    }

    setState(() {
      isLoading = true;
      error = '';
    });

    Timer(const Duration(seconds: 1), () {
      setState(() => isLoading = false);
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const ElderView())
      );
    });
  }

  void _resendOtp() {
    for (final c in otpControllers) {
      c.clear();
    }

    setState(() {
      error = '';
      isLoading = true;
    });

    Timer(const Duration(seconds: 1), () {
      setState(() => isLoading = false);
      otpFocusNodes.first.requestFocus();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('OTP resent successfully')),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black54),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Login', style: TextStyle(color: Colors.black87)),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFE3F2FD), Colors.white],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                children: [
                  _header(),
                  const SizedBox(height: 24),
                  step == AuthStep.input
                      ? _inputCard()
                      : _otpCard(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _header() {
    return Column(
      children: [
        icon,
        const SizedBox(height: 8),
        Text(title, style: const TextStyle(fontSize: 24)),
        const SizedBox(height: 4),
        Text(
          step == AuthStep.input
              ? 'Enter your contact information to continue'
              : 'Enter the verification code sent to you',
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.black54),
        ),
      ],
    );
  }

  Widget _inputCard() {
    return _card(
      Column(
        children: [
          _methodToggle(),
          const SizedBox(height: 16),
          _contactField(),
          if (error.isNotEmpty) _errorBox(),
          const SizedBox(height: 12),
          _primaryButton(
            text: isLoading ? 'Sending OTP...' : 'Send OTP',
            onPressed: isLoading ? null : _sendOtp,
            color: Colors.blue,
          ),
        ],
      ),
    );
  }

  Widget _otpCard() {
    return _card(
      Column(
        children: [
          _contactInfo(),
          const SizedBox(height: 16),
          _otpInputs(),
          if (error.isNotEmpty) _errorBox(),
          const SizedBox(height: 12),
          _primaryButton(
            text: isLoading ? 'Verifying...' : 'Verify & Continue',
            onPressed: isLoading ? null : _verifyOtp,
            color: Colors.green,
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: isLoading ? null : _resendOtp,
            child: const Text('Didn\'t receive code? Resend OTP'),
          ),
          TextButton(
            onPressed: isLoading
                ? null
                : () => setState(() => step = AuthStep.input),
            child: const Text('← Change contact information'),
          ),
        ],
      ),
    );
  }

  Widget _methodToggle() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          _toggleButton(ContactMethod.phone, Icons.phone, 'Phone'),
          _toggleButton(ContactMethod.email, Icons.email, 'Email'),
        ],
      ),
    );
  }

  Widget _toggleButton(ContactMethod method, IconData icon, String label) {
    final active = contactMethod == method;

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => contactMethod = method),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: active ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: active ? Colors.blue : Colors.grey),
              const SizedBox(width: 6),
              Text(label),
            ],
          ),
        ),
      ),
    );
  }

  Widget _contactField() {
    return TextField(
      controller: contactController,
      keyboardType: contactMethod == ContactMethod.phone
          ? TextInputType.phone
          : TextInputType.emailAddress,
      decoration: InputDecoration(
        labelText:
            contactMethod == ContactMethod.phone ? 'Phone Number' : 'Email',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  Widget _otpInputs() {
    return LayoutBuilder(
    builder: (context, constraints) {
      const totalSpacing = 5 * 8; // spacing between boxes
      final boxWidth = (constraints.maxWidth - totalSpacing) / 6;

      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(6, (i) {
          return Container(
            width: boxWidth.clamp(40.0, 56.0),
            margin: EdgeInsets.only(right: i < 5 ? 8 : 0),
            child: TextField(
              controller: otpControllers[i],
              focusNode: otpFocusNodes[i],
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              maxLength: 1,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(
                counterText: '',
                contentPadding: EdgeInsets.symmetric(vertical: 14),
              ),
              onChanged: (v) {
                if (v.isNotEmpty && i < 5) {
                  otpFocusNodes[i + 1].requestFocus();
                } else if (v.isEmpty && i > 0) {
                  otpFocusNodes[i - 1].requestFocus();
                }
              },
            ),
          );
        }),
      );
    },
    );
  }

  Widget _contactInfo() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const Text('Code sent to', style: TextStyle(fontSize: 12)),
          Text(contactController.text),
        ],
      ),
    );
  }

  Widget _errorBox() {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(error, style: const TextStyle(color: Colors.red)),
    );
  }

  Widget _primaryButton({
    required String text,
    required VoidCallback? onPressed,
    required Color color,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        onPressed: onPressed,
        child: Text(text),
      ),
    );
  }

  Widget _card(Widget child) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [BoxShadow(blurRadius: 8, color: Colors.black12)],
      ),
      child: child,
    );
  }
}

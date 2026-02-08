import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crimereport/features/home/presentation/pages/home_screen.dart';

/// Aadhaar Verification Screen (Simplified)
///
/// This screen handles user input for a 12-digit Aadhaar number
/// and simulates a verification check based on format correctnes.
class AadhaarVerificationScreen extends StatefulWidget {
  const AadhaarVerificationScreen({super.key});

  @override
  State<AadhaarVerificationScreen> createState() =>
      _AadhaarVerificationScreenState();
}

class _AadhaarVerificationScreenState extends State<AadhaarVerificationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _aadhaarController = TextEditingController();

  bool _verificationAttempted = false;
  String? _resultMessage;
  Color? _resultColor;

  @override
  void initState() {
    super.initState();
    _checkVerificationStatus();
  }

  /// Check if user is already verified
  Future<void> _checkVerificationStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final isVerified = prefs.getBool('isVerified') ?? false;

    if (isVerified && mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    }
  }

  @override
  void dispose() {
    _aadhaarController.dispose();
    super.dispose();
  }

  /// Handles the verify button press.
  Future<void> _verifyAadhaar() async {
    // Reset state
    setState(() {
      _verificationAttempted = true;
      _resultMessage = null;
    });

    // Validate using the form
    if (_formKey.currentState!.validate()) {
      // Simulate verification success

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isVerified', true);
      // We could store last 4 digits if needed:
      // await prefs.setString('aadhaarLast4', _aadhaarController.text.substring(8));

      if (mounted) {
        setState(() {
          _resultMessage = "Verification Successful!";
          _resultColor = Colors.green;
        });

        // Brief delay to show success message before navigating
        await Future.delayed(const Duration(seconds: 1));
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const HomeScreen()),
          );
        }
      }
    } else {
      // If validation fails
      setState(() {
        _resultMessage = "Verification Failed. Please check the number.";
        _resultColor = Colors.red;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Aadhaar Verification')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Enter Aadhaar Details',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),

              // Aadhaar Input Field
              TextFormField(
                controller: _aadhaarController,
                keyboardType: TextInputType.number,
                maxLength: 12, // Visual limit
                decoration: const InputDecoration(
                  labelText: 'Aadhaar Number',
                  hintText: 'Enter 12-digit UID',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.fingerprint),
                  counterText: "", // Hide character counter for clean look
                ),
                // Only allow digits
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(12),
                ],
                // Validation Logic
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter Aadhaar number';
                  }
                  // Check 1: Numeric only (implied by inputFormatters but good to be safe)
                  if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
                    return 'Aadhaar must contain only digits';
                  }
                  // Check 2: Exact length
                  if (value.length != 12) {
                    return 'Aadhaar number must be exactly 12 digits';
                  }
                  return null; // Valid
                },
              ),

              const SizedBox(height: 20),

              // Verify Button
              ElevatedButton(
                onPressed: _verifyAadhaar,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  textStyle: const TextStyle(fontSize: 18),
                ),
                child: const Text('Verify'),
              ),

              const SizedBox(height: 30),

              // Result Message
              if (_verificationAttempted && _resultMessage != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _resultColor?.withOpacity(0.1),
                    border: Border.all(color: _resultColor ?? Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _resultMessage!,
                    style: TextStyle(
                      color: _resultColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

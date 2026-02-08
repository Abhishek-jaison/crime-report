import 'package:flutter/material.dart';
import 'package:crimereport/core/services/auth_service.dart';
import 'package:crimereport/features/auth/presentation/pages/login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _otpController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _aadhaarController = TextEditingController();

  final AuthService _authService = AuthService();
  bool _isLoading = false;
  int _currentStep = 0; // 0: Email, 1: OTP, 2: Details

  @override
  void dispose() {
    _emailController.dispose();
    _otpController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _aadhaarController.dispose();
    super.dispose();
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  Future<void> _sendOtp() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      final result = await _authService.sendOtp(_emailController.text.trim());
      setState(() => _isLoading = false);

      if (result['success']) {
        _showSnackBar('OTP Sent! Check your email.');
        setState(() => _currentStep = 1);
      } else {
        _showSnackBar(result['message'] ?? 'Failed to send OTP', isError: true);
      }
    }
  }

  Future<void> _verifyOtp() async {
    if (_otpController.text.isEmpty || _otpController.text.length != 6) {
      _showSnackBar('Please enter a valid 6-digit OTP', isError: true);
      return;
    }

    setState(() => _isLoading = true);
    final result = await _authService.verifyOtp(
      _emailController.text.trim(),
      _otpController.text.trim(),
    );
    setState(() => _isLoading = false);

    if (result['success']) {
      _showSnackBar('Email Verified Successfully!');
      setState(() => _currentStep = 2);
    } else {
      _showSnackBar(result['message'] ?? 'Invalid OTP', isError: true);
    }
  }

  Future<void> _signup() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      final result = await _authService.signup(
        _emailController.text.trim(),
        _passwordController.text.trim(),
        _aadhaarController.text.trim(),
      );
      setState(() => _isLoading = false);

      if (result['success']) {
        // Save email locally
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_email', _emailController.text.trim());

        _showSnackBar('Account Created Successfully! Please Login.');
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      } else {
        _showSnackBar(result['message'] ?? 'Signup Failed', isError: true);
      }
    }
  }

  Widget _buildEmailStep() {
    return Column(
      children: [
        TextFormField(
          controller: _emailController,
          decoration: const InputDecoration(
            labelText: "Email Address",
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.email),
          ),
          keyboardType: TextInputType.emailAddress,
          validator: (value) {
            if (value == null || value.isEmpty) return 'Please enter email';
            if (!value.contains('@')) return 'Invalid email';
            return null;
          },
        ),
        const SizedBox(height: 20),
        _isLoading
            ? const CircularProgressIndicator()
            : ElevatedButton(
                onPressed: _sendOtp,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                ),
                child: const Text("Send OTP"),
              ),
      ],
    );
  }

  Widget _buildOtpStep() {
    return Column(
      children: [
        Text(
          "Enter OTP sent to ${_emailController.text}",
          textAlign: TextAlign.center,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        TextFormField(
          controller: _otpController,
          decoration: const InputDecoration(
            labelText: "6-Digit OTP",
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.lock_clock),
          ),
          keyboardType: TextInputType.number,
          maxLength: 6,
        ),
        const SizedBox(height: 20),
        _isLoading
            ? const CircularProgressIndicator()
            : ElevatedButton(
                onPressed: _verifyOtp,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                ),
                child: const Text("Verify OTP"),
              ),
        TextButton(
          onPressed: () => setState(() => _currentStep = 0),
          child: const Text("Change Email"),
        ),
      ],
    );
  }

  Widget _buildDetailsStep() {
    return Column(
      children: [
        const Text(
          "Complete Your Profile",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        TextFormField(
          controller: _aadhaarController,
          decoration: const InputDecoration(
            labelText: "Aadhaar Number",
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.credit_card),
          ),
          keyboardType: TextInputType.number,
          validator: (value) {
            if (value == null || value.isEmpty) return 'Enter Aadhaar Number';
            if (value.length != 12) return 'Must be 12 digits';
            return null;
          },
        ),
        const SizedBox(height: 20),
        TextFormField(
          controller: _passwordController,
          decoration: const InputDecoration(
            labelText: "Password",
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.lock),
          ),
          obscureText: true,
          validator: (value) {
            if (value == null || value.isEmpty) return 'Enter Password';
            if (value.length < 6) return 'Min 6 characters';
            return null;
          },
        ),
        const SizedBox(height: 20),
        TextFormField(
          controller: _confirmPasswordController,
          decoration: const InputDecoration(
            labelText: "Confirm Password",
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.lock_outline),
          ),
          obscureText: true,
          validator: (value) {
            if (value != _passwordController.text)
              return 'Passwords do not match';
            return null;
          },
        ),
        const SizedBox(height: 20),
        _isLoading
            ? const CircularProgressIndicator()
            : ElevatedButton(
                onPressed: _signup,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                ),
                child: const Text("Create Account"),
              ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Sign Up")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                if (_currentStep == 0) _buildEmailStep(),
                if (_currentStep == 1) _buildOtpStep(),
                if (_currentStep == 2) _buildDetailsStep(),

                if (_currentStep == 0) ...[
                  const SizedBox(height: 20),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) => const LoginScreen(),
                        ),
                      );
                    },
                    child: const Text("Already have an account? Login"),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

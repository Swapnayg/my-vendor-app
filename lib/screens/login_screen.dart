// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/colors.dart';
import 'forgot_password_screen.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool rememberMe = false;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool isLoading = false;

  String? emailErrorText;
  String? passwordErrorText;

  @override
  void initState() {
    super.initState();
    _loadSavedCredentials();
  }

  Future<void> _loadSavedCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    final savedEmail = prefs.getString('email');
    final savedPassword = prefs.getString('password');

    if (savedEmail != null && savedPassword != null) {
      setState(() {
        rememberMe = true;
        _emailController.text = savedEmail;
        _passwordController.text = savedPassword;
      });
    }
  }

  bool _validateInputs() {
    bool isValid = true;
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    setState(() {
      emailErrorText = null;
      passwordErrorText = null;

      if (email.isEmpty) {
        emailErrorText = 'Email is required';
        isValid = false;
      } else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email)) {
        emailErrorText = 'Enter a valid email address';
        isValid = false;
      }

      if (password.isEmpty) {
        passwordErrorText = 'Password is required';
        isValid = false;
      }
    });

    return isValid;
  }

  void _login() async {
    if (!_validateInputs()) return;

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    setState(() => isLoading = true);
    try {
      final response = await Supabase.instance.client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      final user = response.user;
      if (user != null) {
        // ✅ Supabase login success

        final uri = Uri.parse('http://localhost:3000/api/auth/verify-user');
        final verifyRes = await http.post(
          uri,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'email': email, 'password': password}),
        );

        if (verifyRes.statusCode == 200) {
          final data = jsonDecode(verifyRes.body);
          final user = data['user'];
          final token = data['token']; // 👈 Extract token

          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('email', email);
          await prefs.setString('userId', user['id'].toString());
          await prefs.setString('role', user['role']);
          await prefs.setString('token', token); // 👈 Store token securely

          if (rememberMe) {
            await prefs.setString('password', password);
          }

          _showMessage(
            'Login successful!',
            isSuccess: true,
          ); // ✅ Only called once
        } else {
          _showMessage('Login succeeded, but failed to fetch user details.');
        }
      } else {
        _showMessage('Login failed. Try again.');
      }
    } on AuthException catch (e) {
      _showMessage(e.message);
    } catch (e) {
      _showMessage('Unexpected error: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _showMessage(String message, {bool isSuccess = false}) {
    showDialog(
      context: context,
      barrierDismissible:
          false, // <-- This prevents dismissing by tapping outside
      builder: (context) {
        return AlertDialog(
          title: Text(isSuccess ? 'Success ✅' : 'Error ❌'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                if (isSuccess) {
                  _emailController.clear();
                  _passwordController.clear();
                  context.go('/home');
                }
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: ListView(
          children: [
            const SizedBox(height: 60),
            const Center(
              child: Text(
                'Vendor Portal',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 30),
            Center(
              child: Column(
                children: const [
                  Icon(
                    Icons.cloud_circle_rounded,
                    size: 80,
                    color: AppColors.primary,
                  ),
                  SizedBox(height: 8),
                  Text('Your Business, Simplified.'),
                ],
              ),
            ),
            const SizedBox(height: 30),
            const Text('Email Address'),
            const SizedBox(height: 8),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                hintText: 'Enter your email address',
                filled: true,
                fillColor: Colors.white,
                errorText: emailErrorText,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Password'),
            const SizedBox(height: 8),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                hintText: 'Enter your password',
                filled: true,
                fillColor: Colors.white,
                errorText: passwordErrorText,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Checkbox(
                  value: rememberMe,
                  onChanged: (value) {
                    setState(() => rememberMe = value ?? false);
                  },
                ),
                const Text("Remember Me"),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ForgotPasswordScreen(),
                      ),
                    );
                  },
                  child: const Text(
                    "Forgot Password?",
                    style: TextStyle(color: AppColors.pink),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: isLoading ? null : _login,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary, // Orchid
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: const TextStyle(fontWeight: FontWeight.bold),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child:
                  isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("Log In Securely"),
            ),
          ],
        ),
      ),
    );
  }
}

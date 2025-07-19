import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'theme/app_theme.dart';
import 'router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://yhlngzruoypycqcmpelh.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InlobG5nenJ1b3lweWNxY21wZWxoIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTI2NTMwMDgsImV4cCI6MjA2ODIyOTAwOH0.fPmphnQITR7Mui9EHowQYA3iwihkDvDwT1O8BGW3ous',
  );

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _showSplash = true;

  @override
  void initState() {
    super.initState();
    _startSplashDelay();
  }

  void _startSplashDelay() async {
    await Future.delayed(const Duration(seconds: 2));
    setState(() {
      _showSplash = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: router, // << IMPORTANT
      debugShowCheckedModeBanner: false,
    );
  }
}

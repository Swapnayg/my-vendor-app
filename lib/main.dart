import 'package:flutter/material.dart';
import 'theme/app_theme.dart'; // ✅ This should point to the app_theme.dart file
import 'screens/splash_screen.dart'; // ✅ Your initial screen
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url:
        'https://yhlngzruoypycqcmpelh.supabase.co', // from Supabase → Settings → API
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InlobG5nenJ1b3lweWNxY21wZWxoIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTI2NTMwMDgsImV4cCI6MjA2ODIyOTAwOH0.fPmphnQITR7Mui9EHowQYA3iwihkDvDwT1O8BGW3ous', // from Supabase → Settings → API
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vendor App',
      debugShowCheckedModeBanner: false,
      theme: appTheme, // ✅ Defined in your app_theme.dart
      home: const SplashScreen(),
    );
  }
}

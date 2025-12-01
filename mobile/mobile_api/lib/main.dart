import 'package:flutter/material.dart';
import 'package:mobile_api/features/auth/login_screen.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Stripe.publishableKey =
      "pk_test_51SYCGcE8BL6ngJFa07aT2e0A7zdHerzicfBM5lCLsoBRZTzeALcXQ0ILnjJQRvOvKvneyxoVBUfY6271OxAPnTv300VFq7DsN6"; // publish key aqui
  await Stripe.instance.applySettings();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const LoginScreen(),
    );
  }
}

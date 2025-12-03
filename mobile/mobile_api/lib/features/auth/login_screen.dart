import 'package:flutter/material.dart';
import 'package:mobile_api/features/auth/auth_service.dart';
import 'package:mobile_api/features/products/home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController(text: 'teste@email.com');
  final _passwordController = TextEditingController(text: '123');
  final _authService = AuthService();
  bool _isLoading = false;

  void _handleLogin() async {
    setState(() => _isLoading = true);
    final success = await _authService.login(
      _emailController.text,
      _passwordController.text,
    );

    setState(() => _isLoading = false);

    // if (success && mounted) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => HomeScreen()),
    );
    // } else if (mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('falha ao realizar login. verifique as credenciais'),
      ),
    );
    // }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login FullStack')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Senha'),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _handleLogin,
                    child: const Text('ENTRAR'),
                  ),
          ],
        ),
      ),
    );
  }
}

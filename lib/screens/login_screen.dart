import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:spaceif/services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _isLoading = false;

  void _showSnackBar(String message, {Color backgroundColor = Colors.green}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _login() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await _authService.login(
        _emailController.text,
        _passwordController.text,
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        final token = responseData['token'];
        _emailController.clear();
        _passwordController.clear();        
        Navigator.pushNamed(context, '/test');
        _showSnackBar('Login bem-sucedido! Token: $token');
      } else {
        // Verificando o erro detalhado
        final errorMessage = responseData['message'] ?? 'Ocorreu um erro inesperado.';
        final detalhes = responseData['detalhes'];
        
        if (detalhes == null) {
          _showSnackBar(errorMessage, backgroundColor: Colors.red);
        } else {
          // Concatenando a mensagem com os detalhes do erro
          String detalhesString = detalhes.entries.map((e) => "${e.key}: ${e.value}").join("\n");
          _showSnackBar("$errorMessage\n$detalhesString", backgroundColor: Colors.red);
        }
      }
    } catch (e) {
      _showSnackBar('Erro de conexão. Por favor, tente novamente.', backgroundColor: Colors.red);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
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
                    onPressed: _login,
                    child: const Text('Entrar'),
                  ),
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/signup');
              },
              child: const Text('Cadastrar-se'),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../services/user_service.dart';
import 'calendar_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _userController = TextEditingController();
  final _passController = TextEditingController();
  bool isRegisterMode = false;
  String? errorMessage;

  final passwordRegex = RegExp(r'^(?=.*[0-9])(?=.*[!@#\$%\^&\*]).{5,}$');

  void _submit() async {
    final user = _userController.text.trim();
    final pass = _passController.text.trim();

    if (user.isEmpty || pass.isEmpty) {
      setState(() => errorMessage = 'Completa todos los campos');
      return;
    }

    if (isRegisterMode && !passwordRegex.hasMatch(pass)) {
      setState(() => errorMessage =
          'La contraseña debe tener al menos 5 caracteres, un número y un símbolo.');
      return;
    }

    bool success;
    if (isRegisterMode) {
      success = await UserService.registerUser(user, pass);
      if (!success) {
        setState(() => errorMessage = 'El usuario ya existe');
        return;
      }
    } else {
      success = await UserService.loginUser(user, pass);
      if (!success) {
        setState(() => errorMessage = 'Usuario o contraseña incorrectos');
        return;
      }
    }

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => CalendarScreen(username: user)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isRegisterMode ? Icons.person_add : Icons.lock_open,
                      size: 80,
                      color: Colors.indigo,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      isRegisterMode ? 'Registro' : 'Inicio de sesión',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _userController,
                      decoration: const InputDecoration(
                        labelText: 'Usuario',
                        prefixIcon: Icon(Icons.person),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 15),
                    TextField(
                      controller: _passController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Contraseña',
                        prefixIcon: Icon(Icons.lock),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 20),
                    if (errorMessage != null)
                      Text(errorMessage!, style: const TextStyle(color: Colors.red)),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(45),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: _submit,
                      child: Text(
                        isRegisterMode ? 'Crear cuenta' : 'Ingresar',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () => setState(() {
                        isRegisterMode = !isRegisterMode;
                        errorMessage = null;
                      }),
                      child: Text(
                        isRegisterMode
                            ? '¿Ya tienes cuenta? Inicia sesión'
                            : '¿No tienes cuenta? Regístrate',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

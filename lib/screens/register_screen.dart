import 'package:flutter/material.dart';
import 'package:rawi_go/screens/login_screen.dart';
import 'package:rawi_go/services/firebase_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _firebaseService = FirebaseService();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showSnackBar("يرجى إدخال البريد الإلكتروني وكلمة المرور");
      return;
    }

    final success = await _firebaseService.register(email, password);
    if (!success) {
      _showSnackBar("فشل في التسجيل. حاول مرة أخرى.");
      return;
    }

    // الانتقال مباشرة إلى صفحة تسجيل الدخول
    _showSnackBar("تم إنشاء الحساب بنجاح.", duration: 3);
    _navigateToLogin();
  }

  void _showSnackBar(String message, {int duration = 2}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: Duration(seconds: duration)),
    );
  }

  void _navigateToLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('إنشاء حساب')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildEmailField(),
            const SizedBox(height: 16.0),
            _buildPasswordField(),
            const SizedBox(height: 24.0),
            _buildRegisterButton(),
            const SizedBox(height: 12.0),
            _buildLoginRow(),
          ],
        ),
      ),
    );
  }

  Widget _buildEmailField() {
    return TextField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      decoration: const InputDecoration(
        labelText: 'البريد الإلكتروني',
        border: OutlineInputBorder(),

        prefixIcon: Icon(Icons.email_rounded, color: Colors.teal),
        // يمكنك تغيير لون الأيقونة هنا إذا أردت
        
      ),
    );
  }

  Widget _buildPasswordField() {
    return TextField(
      controller: _passwordController,
      obscureText: true,
      decoration: const InputDecoration(
        labelText: 'كلمة المرور',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.lock, color: Colors.teal),
      ),
    );
  }

  Widget _buildRegisterButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _register,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
        ),
        child: const Text("تسجيل", style: TextStyle(fontSize: 18,)),
      ),

    );
  }

  Widget _buildLoginRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("لديك حساب بالفعل؟"),
        TextButton(
          onPressed: _navigateToLogin,
          child: const Text("تسجيل الدخول", style: TextStyle(color: Colors.teal,fontSize: 16),),
        ),
      ],
    );
  }
}
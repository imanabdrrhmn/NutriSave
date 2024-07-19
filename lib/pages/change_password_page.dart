import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'confirmation_page.dart';

class ChangePasswordPage extends StatefulWidget {
  @override
  _ChangePasswordPageState createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  String? _errorMessage;

  Future<void> _changePassword() async {
    if (_passwordController.text != _confirmPasswordController.text) {
      setState(() {
        _errorMessage = 'Kata sandi tidak cocok';
      });
      return;
    }

    try {
      User user = _auth.currentUser!;
      await user.updatePassword(_passwordController.text);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => ConfirmationPage()),
      );
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 400),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Buat Ulang Kata Sandi', style: Theme.of(context).textTheme.displayLarge),
                SizedBox(height: 20),
                TextField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: 'Masukkan kata sandi baru',
                  ),
                  obscureText: true,
                ),
                SizedBox(height: 10),
                TextField(
                  controller: _confirmPasswordController,
                  decoration: InputDecoration(
                    labelText: 'Konfirmasi sandi',
                  ),
                  obscureText: true,
                ),
                SizedBox(height: 20),
                _errorMessage != null ? Text(_errorMessage!, style: TextStyle(color: Colors.red)) : Container(),
                ElevatedButton(
                  onPressed: _changePassword,
                  child: Text('Konfirmasi'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(double.infinity, 50), // full width button
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

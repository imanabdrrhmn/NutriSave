import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ResetPasswordPage extends StatefulWidget {
  @override
  _ResetPasswordPageState createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _emailController = TextEditingController();
  String? _message;

  Future<void> _sendResetEmail() async {
    try {
      await _auth.sendPasswordResetEmail(email: _emailController.text);
      setState(() {
        _message = 'Email reset kata sandi telah dikirim. Silakan periksa email Anda.';
      });
    } catch (e) {
      setState(() {
        _message = e.toString();
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
                Text(
                  'Lupa kata sandi ?',
                  style: Theme.of(context).textTheme.displayLarge!.copyWith(
                    color: Colors.black, // Warna teks diubah menjadi hitam
                  ),
                ),
                SizedBox(height: 20),
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Masukkan email akun anda',
                    hintText: 'Masukkan email anda',
                  ),
                ),
                SizedBox(height: 20),
                _message != null ? Text(_message!, style: TextStyle(color: Colors.green)) : Container(),
                ElevatedButton(
                  onPressed: _sendResetEmail,
                  child: Text('Mengatur kata sandi'),
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

import 'package:flutter/material.dart';
import 'login_page.dart';

class ConfirmationPage extends StatelessWidget {
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
                Icon(Icons.check_circle, color: Colors.green, size: 100),
                SizedBox(height: 20),
                Text('Berhasil', style: Theme.of(context).textTheme.displayLarge),
                SizedBox(height: 10),
                Text('Kata sandi Anda telah berhasil diubah', textAlign: TextAlign.center),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => LoginPage()),
                    );
                  },
                  child: Text('Kembali untuk masuk'),
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

import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tentang', style: TextStyle(color: Colors.teal)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.teal),
      ),
      body: ListView(
        children: [
          ListTile(
            title: Text('Kebijakan Privasi'),
          ),
          ListTile(
            title: Text('Nasyratkan Layanan'),
          ),
          ListTile(
            title: Text('Panduan Komunitas'),
          ),
          ListTile(
            title: Text('Kebijakan'),
          ),
        ],
      ),
    );
  }
}

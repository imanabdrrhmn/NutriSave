import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pengaturan', style: TextStyle(color: Colors.teal)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.teal),
      ),
      body: ListView(
        children: [
          ListTile(
            leading: Icon(Icons.notifications),
            title: Text('Notifikasi'),
          ),
          ListTile(
            leading: Icon(Icons.lock),
            title: Text('Bagikan Profil'),
          ),
          ListTile(
            leading: Icon(Icons.save),
            title: Text('Item yang Disimpan'),
          ),
          ListTile(
            leading: Icon(Icons.help),
            title: Text('Pusat Bantuan'),
          ),
          ListTile(
            leading: Icon(Icons.language),
            title: Text('Bahasa'),
          ),
        ],
      ),
    );
  }
}

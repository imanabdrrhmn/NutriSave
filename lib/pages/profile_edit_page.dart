import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ProfileEditPage extends StatefulWidget {
  @override
  _ProfileEditPageState createState() => _ProfileEditPageState();
}

class _ProfileEditPageState extends State<ProfileEditPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  User? _user;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String _profileImage = 'assets/images/profile.png'; // Default image path
  File? _newProfileImageFile;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    _user = _auth.currentUser;
    if (_user != null) {
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(_user!.uid).get();
      setState(() {
        _nameController.text = userDoc['name'];
        _emailController.text = userDoc['email'];
        if (userDoc['profileImage'] != null) {
          _profileImage = userDoc['profileImage'];
        }
      });
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _newProfileImageFile = File(image.path);
      });
    }
  }

  Future<void> _uploadProfileImage(File imageFile) async {
    if (_user != null) {
      try {
        final storageRef = _storage.ref().child('profile_images').child(_user!.uid + '.jpg');
        await storageRef.putFile(imageFile);
        String downloadURL = await storageRef.getDownloadURL();
        setState(() {
          _profileImage = downloadURL;
        });
      } catch (e) {
        print('Error uploading profile image: $e');
      }
    }
  }

  Future<void> _updateProfile() async {
    if (_user != null) {
      if (_newProfileImageFile != null) {
        await _uploadProfileImage(_newProfileImageFile!);
      }

      await _firestore.collection('users').doc(_user!.uid).update({
        'name': _nameController.text,
        'email': _emailController.text,
        'profileImage': _profileImage,
      });

      // Update email in FirebaseAuth
      await _user!.updateEmail(_emailController.text);
      // Update password in FirebaseAuth if not empty
      if (_passwordController.text.isNotEmpty) {
        await _user!.updatePassword(_passwordController.text);
      }
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Profil', style: GoogleFonts.poppins(color: Colors.teal)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.teal),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundImage: _newProfileImageFile != null
                          ? FileImage(_newProfileImageFile!)
                          : _profileImage.startsWith('assets/')
                          ? AssetImage(_profileImage)
                          : NetworkImage(_profileImage) as ImageProvider,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.3),
                          shape: BoxShape.circle,
                        ),
                        padding: EdgeInsets.all(8),
                        child: Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              TextField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Nama lengkap'),
              ),
              SizedBox(height: 10),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'Email'),
              ),
              SizedBox(height: 10),
              TextField(
                controller: _phoneController,
                decoration: InputDecoration(labelText: 'Nomor Handphone'),
              ),
              SizedBox(height: 10),
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(labelText: 'Kata sandi baru'),
                obscureText: true,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _updateProfile,
                child: Text('Memperbarui'),
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 50), // full width button
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

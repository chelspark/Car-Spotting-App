// profile_edit_page.dart
// This screen allows users to update their profile information,
// including their name, bio, and profile picture.
// It uses Firebase Firestore and Firebase Storage to save the data.

import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:car_spotting_app/colours/app_colours.dart';
import 'package:image_picker/image_picker.dart';

// A StatefulWidget that displays the profile editing form.
// Users can update their name, bio, and upload a new profile image.
// On save, data is updated in Firestore and the image is uploaded to Firebase Storage.
class ProfileEditPage extends StatefulWidget {
  const ProfileEditPage({super.key});

  @override
  State<ProfileEditPage> createState() => _ProfileEditPageState();
}

class _ProfileEditPageState extends State<ProfileEditPage> {

  final _nameController = TextEditingController();   // Controller for name input
  final _bioController = TextEditingController();   // Controller for bio input
  String? _profileImage;   // Current profile image URL
  File? _newImageFile;   // New profile image selected by the user
  bool _isLoading = false;   // Loading state for saving indicator

  final userId = FirebaseAuth.instance.currentUser?.uid;   // Current user ID

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

// Loads the current user's profile data from Firestore and populates the form.
  Future<void> _loadProfileData() async {
    // Fetch user profile data from Firestore when the page loads
      final doc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
      final data = doc.data() as Map<String, dynamic>?;
      if (data != null) {
        setState(() {
          _nameController.text = (data['name'] ?? '').toString().isNotEmpty
              ? data['name']
              : 'User';
          _bioController.text = (data['bio'] ?? '').toString().isNotEmpty
              ? data['bio']
              : 'No bio available.';
          _profileImage = (data['profileImage'] ?? '').toString().isNotEmpty
              ? data['profileImage']
              : '';
        });
      }
  }

// Allows the user to select a new profile image using camera or gallery.
  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source, imageQuality: 85);
    if (pickedFile != null) {
      setState(() {
        _newImageFile = File(pickedFile.path);
      });
    }
  }

// Uploads the updated profile image (if any) and form data to Firebase.
  Future<void> _saveProfile() async {
    setState(() {
      _isLoading = true;
    });

    String? imageUrl = _profileImage;
    try {
      if (_newImageFile != null) {
        final ref = FirebaseStorage.instance
            .ref('car/users/profile_images/${FirebaseAuth.instance.currentUser!.uid}');
        
        await ref.putFile(_newImageFile!);
        imageUrl = await ref.getDownloadURL();
      }

      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'name': _nameController.text,
        'bio': _bioController.text,
        'profileImage': imageUrl,
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Post updated successfully!')),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to upload. Try again.')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }

  }
  

  @override
  Widget build(BuildContext content) {
    return Scaffold(
      // AppBar with back button and save action
      appBar: AppBar(
        title: Text(
          'Edit Profile',
          style: Theme.of(content).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 15,
            color: GlobalColours.primaryText,
          ),
        ),
        centerTitle: true,
        backgroundColor: GlobalColours.background,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: GlobalColours.primaryText),
          onPressed: () {
            Navigator.pop(content);
          },
        ),
        actions: [
          TextButton(
            onPressed: _saveProfile,
            child: Text(
              'Save',
              style: Theme.of(content).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: GlobalColours.primaryAction,
              ),
            ),
          ),
        ],
      ),
      // Main content with form and loading indicator
      body: Stack(
        children:  [
          Container(
            width: double.infinity,
            color: GlobalColours.background,
            child: Center(
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.93,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () {
                        showModalBottomSheet(
                          context: context,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(top: Radius.circular(16))
                          ),
                          builder: (_) => SafeArea(
                            child: Wrap(
                              children: [
                                ListTile(
                                  leading: Icon(Icons.photo_camera),
                                  title: Text('Camera'),
                                  onTap: () {
                                    Navigator.pop(context);
                                    _pickImage(ImageSource.camera);
                                  },
                                ),
                                ListTile(
                                  leading: Icon(Icons.photo_library),
                                  title: Text('Gallery'),
                                  onTap: () {
                                    Navigator.pop(context);
                                    _pickImage(ImageSource.gallery);
                                  },
                                ),
                              ],
                            )
                          ),
                        );
                      },
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundImage: _newImageFile != null
                                ? FileImage(_newImageFile!)
                                : (_profileImage != null && _profileImage!.isNotEmpty)
                                    ? NetworkImage(_profileImage!) as ImageProvider
                                    : null,
                            child: (_newImageFile == null && (_profileImage == null || _profileImage!.isEmpty))
                                ? const Icon(Icons.person, size: 50)
                                : null,
                          ),
                          const SizedBox(height: 15),
                          Text(
                            'Edit picture',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.normal,
                              fontSize: 15,
                              color: GlobalColours.primaryAction,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildTextField('Name'),
                    const SizedBox(height: 15),
                    _buildTextField('Bio'),
                  ],
                ),
              ),
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black54,
              child: const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(GlobalColours.primaryAction),
                ),
              ),
            )
        ]
      ),
    );
  }
  
// Builds a text field widget for name or bio input.
// 'label' is either 'Name' or 'Bio'.
  Widget _buildTextField(String label) {
    final controller = label == 'Name' ? _nameController : _bioController;
    final textLabel = label == 'Name' ? 'Name' : 'Bio';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          textLabel,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 15,
            color: GlobalColours.primaryText,
          ),
        ),
        const SizedBox(height: 10),
        TextFormField(
          controller: controller,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.normal,
            fontSize: 13,
            color: GlobalColours.primaryText,
          ),
          maxLength: label == 'Name' ? 30 : 100,
          keyboardType:  TextInputType.text,
          decoration: InputDecoration(
            filled: true,
            fillColor: UploadColours.inputBg,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
          ),
        ),
      ],
    );
  }
}
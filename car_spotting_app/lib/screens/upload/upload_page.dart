// upload_page.dart
// 
// This file defines the `UploadPage` widget in the Car Spotting App.
// It allows users to create a new car spotting post by uploading an image,
// providing car details (make, model, year, location, description), and
// automatically fetching their current location.
// The post data is saved to Firebase Firestore, and the media is uploaded to Firebase Storage.
//
// Features:
// - Image selection (camera or gallery)
// - Location retrieval using Geolocator & Geocoding
// - Form validation
// - Firebase integration for posts
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:car_spotting_app/colours/app_colours.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geocoding/geocoding.dart';

class UploadPage extends StatefulWidget {
  const UploadPage({super.key});

  @override
  State<UploadPage> createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage> {

  final _formKey = GlobalKey<FormState>();   // Key for the form to validate inputs
  final _titleController = TextEditingController();   // Controller for the post title
  final _makeController = TextEditingController();   // Controller for the car make
  final _modelController = TextEditingController();   // Controller for the car model
  final _yearController = TextEditingController();   // Controller for the car year
  final _locationController = TextEditingController();   // Controller for the user's location
  final _descriptionController = TextEditingController();   // Controller for the post description

  File? _mediaFile;
  final ImagePicker _picker = ImagePicker();   // Image picker instance to select images from camera or gallery

  @override
  void initState() {
    super.initState();
    _initUserLocation();
  } 

  // Initializes the user's current location and sets it in the location text field.
  // This is called when the page loads
  Future<void> _initUserLocation() async {
    final location = await _getUserLocation();
    if (!mounted) return;
    if (location != null && mounted) {
      setState(() {
        _locationController.text = location;
      });
    }
  }

  // Picks an image from the specified [source] (camera or gallery) and updates the UI.
  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source, imageQuality: 85);
    if (pickedFile != null) {
      setState(() {
        _mediaFile = File(pickedFile.path);
      });
    }
  }

  // Retrieves the user's current location as a formatted string (City, State, Country).
  // Handles location permissions and errors gracefully.
  // Returns the formatted location string or an error message.
  Future<String?> _getUserLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return 'Location services are disabled.';
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return 'Location permission denied.';
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return 'Location permission permanently denied.';
    }
    try {
      Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
      );

      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude, position.longitude
      );

      if (placemarks.isNotEmpty) {
        final placemark = placemarks.first;
        print('user location: $placemark');
        return '${placemark.locality}, ${placemark.administrativeArea}, ${placemark.country}';
      }
      print('No placemarks found for user location');
      return '';

    } catch (e) {
      print('Error getting location: $e');
      return '';
    }
    
  }

  // Uploads the post data and image to Firebase Storage and Firestore.
  // Validates form fields and ensures an image is selected.
  // Displays success or error feedback to the user.
  Future<void> _uploadPost() async {
    if (!_formKey.currentState!.validate()) return;

    if (_mediaFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please select an image.',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.normal,
              fontSize: 12,
              color: GlobalColours.primaryText,
            ),
          )
        ),
      );
      return;
    }

    try {
      final ref = FirebaseStorage.instance.ref('car/posts/${DateTime.now().microsecondsSinceEpoch}');
      
      await ref.putFile(_mediaFile!);

      final mediaUrl = await ref.getDownloadURL();

      await FirebaseFirestore.instance.collection('posts').add({
        'title': _titleController.text,
        'make': _makeController.text,
        'model': _modelController.text,
        'year': _yearController.text,
        'location': _locationController.text,
        'description': _descriptionController.text,
        'mediaUrl': mediaUrl,
        'timestamp': Timestamp.now(),
        'userId': FirebaseAuth.instance.currentUser?.uid,
      });

      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Post uploaded successfully!')),
      );

      Navigator.pop(context);
      
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to upload. Try again.')),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Upload Car',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: GlobalColours.primaryText,
          ),
        ),
        backgroundColor: GlobalColours.background,
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.pop(context, false),
          icon: Icon(Icons.arrow_back_ios, color: GlobalColours.primaryText),
        ),
        actions: [
          TextButton(
            onPressed: _uploadPost,
            child: Text(
              'Post',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.normal,
                fontSize: 20,
                color: GlobalColours.primaryAction,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Container(
          width: double.infinity,
          color: GlobalColours.background,
          child: Form(
            key: _formKey,
            child: Column(
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
                  child: _mediaFile != null
                      ? Image.file(_mediaFile!, height: 400, width: 400, fit: BoxFit.cover)
                      : Container(
                          height: 200,
                          color: Colors.grey[400],
                          child: const Center(child: Text('Tap to select an image')),
                        ),
                      ),
                const SizedBox(height: 12,),
                Center(
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width * 0.95,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 10),
                        _buildField('Title', _titleController, 'Add a title', 1, 40),
                        _buildField('Car make', _makeController, 'Make', 1, 20),
                        _buildField('Car model', _modelController, 'Model', 1, 20),
                        _buildField('Year', _yearController, 'Year', 1, 4),
                        _buildField('Location', _locationController, 'Location', 1, 70),
                        _buildField('Description', _descriptionController, 'Description', 10, 300),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Builds a reusable form field with a label, controller, and validation.
  // 'title' - The label text for the field.
  // 'controller' - The associated TextEditingController.
  // 'hintText' - Placeholder text.
  // 'maxLines' - Max lines for multi-line fields.
  // 'maxwords' - - Max characters allowed.
  Widget _buildField(String title, TextEditingController controller, String hintText, int maxLines, int maxwords) {
    return Column(
      children: [
        Row(
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.normal,
                fontSize: 15,
                color: GlobalColours.primaryText,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        TextFormField(
          controller: controller,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.normal,
            fontSize: 14,
            color: GlobalColours.primaryText,
          ),
          maxLines: maxLines,
          maxLength: maxwords, // Limit to 20 characters for single line
          keyboardType:  TextInputType.text,
          validator: (value) => value == null || value.isEmpty
              ? 'Required'
              : null,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.normal,
              fontSize: 14,
              color: UploadColours.secondaryText,
            ),
            filled: true,
            fillColor: UploadColours.inputBg,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 12),
          ),
        ),
      ],
    );
  }
}
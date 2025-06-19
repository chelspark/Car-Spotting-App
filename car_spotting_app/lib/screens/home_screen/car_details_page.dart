// CarDetailsPage.dart
// This file defines the CarDetailsPage widget, which displays detailed
// information about a specific car post, including images, details, and the uploader's profile info.
// 
// The page retrieves the post data from a Firestore QueryDocumentSnapshot
// and fetches the user's profile data via Firestore.
// Used in: HomeFeedPage, ProfilePage
import 'package:car_spotting_app/colours/app_colours.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// CarDetailsPage displays details of a specific car post.
// Users can view car information, images, and the profile of the user who uploaded the post.
class CarDetailsPage extends StatelessWidget {
  const CarDetailsPage({super.key, required this.postData});
  final QueryDocumentSnapshot postData;

  // Builds the main UI of the CarDetailsPage.
  // Extracts data from the given Firestore document and renders the page layout.
  @override
  Widget build(BuildContext context) {
    final data = postData.data() as Map<String, dynamic>;
    final mediaUrl = (data['mediaUrl'] ?? '').toString().isNotEmpty  // Use placeholder image if mediaUrl is missing
          ? data['mediaUrl']
          : 'https://via.placeholder.com/150';
    final title = (data['title'] ?? '').toString().isNotEmpty
          ? data['title']
          : 'No title provided';
    final description = (data['description'] ?? '').toString().isNotEmpty
          ? data['description']
          : '';
    final make = (data['make'] ?? '').toString().isNotEmpty
          ? data['make']
          : '';
    final model = (data['model'] ?? '').toString().isNotEmpty
          ? data['model']
          : '';
    final year = (data['year'] ?? '').toString().isNotEmpty
          ? data['year']
          : '';
    final location = (data['location'] ?? '').toString().isNotEmpty
          ? data['location']
          : '';
    final userId = data['userId'] ?? '';

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Car Details',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 15,
            color: GlobalColours.primaryText,
          ),
        ),
        centerTitle: true,
        backgroundColor: GlobalColours.background,
        leading: IconButton(
          onPressed: () => Navigator.pop(context, false),
          icon: Icon(Icons.arrow_back_ios_new, color: GlobalColours.primaryText),
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          width: double.infinity,
          color: GlobalColours.background,
          child: Column(
            children: [
              ClipRRect(   // Car image display
                child: Image.network(
                  mediaUrl,
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.width,
                  fit: BoxFit.cover
                ),
              ),
              Center(
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.95,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 15),
                      // Car title
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: GlobalColours.primaryText,
                        ),
                      ),
                      const SizedBox(height: 10),
                      // Car description
                      Text(
                        description,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.normal,
                          fontSize: 13,
                          color: GlobalColours.primaryText,
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Car details section
                      Text(
                        'Details',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: GlobalColours.primaryText,
                        ),
                      ),
                      const SizedBox(height: 20),
                      _buildDetails('Make', make, context),
                      const SizedBox(height: 20),
                      _buildDetails('Model', model, context),
                      const SizedBox(height: 20),
                      _buildDetails('Year', year, context),
                      const SizedBox(height: 20),
                      _buildDetails('Location', location, context),
                      const SizedBox(height: 20),
                      // Uploader's profile info
                      Text(
                        'Posted by',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: GlobalColours.primaryText,
                        ),
                      ),
                      const SizedBox(height: 20),
                      _posterInfo(userId, context),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper widget to display car details (make, model, year, location) with icons.
  Widget _buildDetails(String label, String value, BuildContext context) {
    IconData iconData;
    if (label == 'Make') {
      iconData = Icons.directions_car;
    }else if (label == 'Model') {
      iconData = Icons.directions_car_filled;
    } else if (label == 'Year') {
      iconData = Icons.calendar_month;
    } else if (label == 'Location') {
      iconData = Icons.location_on;
    } else {
      iconData = Icons.info;
    }

    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: CarDetailsColours.iconBg
          ),
          child: Center(
            child: Icon(iconData, color: GlobalColours.primaryText, size: 20),
          ),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: GlobalColours.primaryText,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              value,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.normal,
                fontSize: 12,
                color: CarDetailsColours.secondaryText,
              ),
            ),
          ],
        ),
      ]
    );
  }

  // Fetches and displays the profile information of the user who uploaded the car post.
  // This includes their profile picture, username, and join date.
  Widget _posterInfo(String userId, BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('users').doc(userId).get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const SizedBox();
        }

        final user = snapshot.data!.data() as Map<String, dynamic>;
        final profileImage = (user['profileImage'] ?? '').toString().isNotEmpty
            ? user['profileImage']
            : '';
        final username = (user['name'] ?? '').toString().isNotEmpty
            ? user['name']
            : 'User';
        final joinedDate = (user['createdAt'] != null || user['createdAt'].isNotEmpty)
              ? DateFormat.y().format(user['createdAt'].toDate())
              : '';
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 50,
              backgroundImage: profileImage.isNotEmpty
                  ? NetworkImage(profileImage)
                  : null,
              child: profileImage.isEmpty ? const Icon(Icons.person, size: 50) : null,
            ),
            const SizedBox(height: 10),
            Text(
              username,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: GlobalColours.primaryText,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              'Joined in $joinedDate',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                color: CarDetailsColours.secondaryText,
              ),
            ),
            TextButton(
              onPressed: () {},
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
              ),
              child: Row(
                children: [
                  Text(
                    'Visit Profile',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: GlobalColours.primaryAction,
                    ),
                  ),
                  Icon(Icons.arrow_forward_ios, color: GlobalColours.primaryAction)
                ],
              )
            ),
          ],
        );
      },
    );
  }
}
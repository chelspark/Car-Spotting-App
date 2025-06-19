// home_feed_page.dart
// Displays the main feed of the Car Spotting App, where users can browse car posts.
// Each post shows the user's profile picture, username, car image, and title.
// Tapping a post navigates to the CarDetailsPage for more information.
// Fetches data from the Firestore `posts` collection, and user profile data from the `users` collection.
import 'package:car_spotting_app/screens/home_screen/car_details_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:car_spotting_app/colours/app_colours.dart';

// The HomeFeedPage displays a scrollable list of car posts.
// It listens to the Firestore `posts` collection and renders each post
// with associated user information. Tapping a post navigates to the CarDetailsPage.
class HomeFeedPage extends StatelessWidget {
  const HomeFeedPage({super.key});

  // Builds the Home Feed UI, including the AppBar and the list of car posts.
  // Uses a StreamBuilder to listen to real-time updates from the Firestore `posts` collection.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Car spotting',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 15,
            color: GlobalColours.primaryText,
          ),
        ),
        centerTitle: true,
        backgroundColor: GlobalColours.background,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('posts')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No posts yet'));
          }

          final posts = snapshot.data!.docs;

          return Container(
            width: double.infinity,
            color: GlobalColours.background,
            child: ListView.builder(
              itemCount: posts.length,
              itemBuilder: (context, index) {
              // Fetch car post data from Firestore snapshot
               final postData = posts[index].data() as Map<String, dynamic>;
               // Use placeholder if no media URL is provided
               final mediaUrl = (postData['mediaUrl'] ?? '').toString().isNotEmpty
                    ? postData['mediaUrl']
                    : 'https://via.placeholder.com/150';
               final title = (postData['title'] ?? '').toString().isNotEmpty
                    ? postData['title']
                    : 'No title provided';
              // Fetch user data for each post using the userId
               final userId = postData['userId'] ?? '';
              
              // Builds each post item in the feed list, fetching associated user data.
               return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance.collection('users').doc(userId).get(),
                builder: (context, userSnapshot) {
                  if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
                    return const SizedBox();
                  }
            
                  final userData = userSnapshot.data!.data() as Map<String, dynamic>;
                  final username = (userData['name'] ?? '').toString().isNotEmpty
                      ? userData['name']
                      : 'User';
                  final profileImage = (userData['profileImage'] ?? '').toString().isNotEmpty
                      ? userData['profileImage']
                      : '';
            
                  return GestureDetector(  // Tapping a post navigates to the CarDetailsPage for more information.
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CarDetailsPage(postData: posts[index]),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const SizedBox(width: 10),
                              CircleAvatar(   // User profile avatar
                                radius: 20,
                                backgroundImage: profileImage.isNotEmpty
                                    ? NetworkImage(profileImage)
                                    : null,
                                child: profileImage.isEmpty ? const Icon(Icons.person): null,
                              ),
                              const SizedBox(width: 10),
                              Text(   // username
                                username,
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: GlobalColours.primaryText,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          // Car image display
                          ClipRRect(
                            child: Image.network(
                              mediaUrl,
                              width: MediaQuery.of(context).size.width,
                              height: MediaQuery.of(context).size.width,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(height: 10),
                          // Car title row
                          Row(
                            children: [
                              const SizedBox(width: 10),
                              Text(
                                title,
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  color: GlobalColours.primaryText,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
               );
              },
            ),
          );
        }
      ),
    );
  }
}
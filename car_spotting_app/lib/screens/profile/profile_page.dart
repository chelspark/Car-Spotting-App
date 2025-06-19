// profile_page.dart
// This screen displays the user's profile information including their name, bio, and profile image.
// Users can view their own posts and navigate to edit their profile or app settings.
// The screen uses Firestore to retrieve user data and their posts in real-time.
import 'package:car_spotting_app/screens/home_screen/car_details_page.dart';
import 'package:car_spotting_app/screens/profile/profile_edit_page.dart';
import 'package:car_spotting_app/screens/profile/settings_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:car_spotting_app/colours/app_colours.dart';
import 'package:intl/intl.dart';

// The main profile page for a user.
// Shows profile details, a list of posts, and allows navigation to edit profile or settings.
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid;   // Current logged-in user's ID

    // Navigates to the Settings page.
    void settingsNavigation() {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const SettingsPage(),
        )
      );
    }

    // Navigates to the Profile Edit page.
    void editProfileNavigation() {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const ProfileEditPage(),
        )
      );
    }

    return Scaffold(
      // App bar with edit and settings icons
      appBar: AppBar(
        backgroundColor: GlobalColours.background,
        actions: [
          IconButton(
            onPressed: () => editProfileNavigation(),
            icon: Icon(Icons.edit_outlined, color: GlobalColours.primaryText,)
          ),
          IconButton(
            onPressed: () => settingsNavigation(),
            icon: const Icon(
              Icons.settings_outlined,
              color: GlobalColours.primaryText,
            )
          ),
        ],
      ),
      // Real-time listener for user profile data.
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('users').doc(userId).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('No profile data found.'));
          }

          final userData = snapshot.data!.data() as Map<String, dynamic>;
          final profileImage = (userData['profileImage'] ?? '').toString().isNotEmpty
              ? userData['profileImage']
              : '';
          final name = (userData['name'] ?? '').toString().isNotEmpty
              ? userData['name']
              : 'User';
          final bio = (userData['bio'] ?? '').toString().isNotEmpty
              ? userData['bio']
              : 'No bio available.';
          final joinedDate = (userData['createdAt'] != null || userData['createdAt'].isNotEmpty)
              ? DateFormat.y().format(userData['createdAt'].toDate())
              : '';

          // Profile section and posts
          return Container(
            width: double.infinity,
            height: MediaQuery.of(context).size.height,
            color: GlobalColours.background,
            child: Center(
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.93,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Profile image, name, bio, and join date
                    CircleAvatar(
                      radius: 50,
                      backgroundImage: profileImage.isNotEmpty
                          ? NetworkImage(profileImage)
                          : null,
                      child: profileImage.isEmpty ? const Icon(Icons.person, size: 50) : null,
                    ),
                    const SizedBox(height: 15),
                    Text(
                      name,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: GlobalColours.primaryText,
                      ),
                    ),
                    const SizedBox(height: 15),
                    Text(
                      bio,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.normal,
                        fontSize: 12,
                        color: UserProfileColours.secondaryText,
                      ),
                    ),
                    const SizedBox(height: 7),
                    Text(
                      'Joined in $joinedDate',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.normal,
                        fontSize: 11,
                        color: UserProfileColours.secondaryText,
                      ),
                    ),
                    const SizedBox(height: 15),
                    // User's posts
                    Text(
                      'Posts',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: GlobalColours.primaryText,
                      ),
                    ),
                    const SizedBox(height: 15),
                    // Posts list
                    PostsGrid(userId: userId)
                  ],
                ),
              ),
            ),
          );     
        },
      ),
    );
  }
}

// A grid widget that displays the user's posts in a 2-column layout.
// Tapping on a post opens the Car Details page.
class PostsGrid extends StatelessWidget {
  const PostsGrid({super.key, required this.userId});
  final String? userId;   // The user's ID to filter posts

  @override
  Widget build(BuildContext context) {
    if (userId == null) {
      return const Center(child: Text('No user ID availabel.'));
    }
    // Listen to real-time posts by the user
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('posts')
          .where('userId', isEqualTo: userId)
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Text(
              'No posts yet',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.normal,
                fontSize: 15,
                color: UserProfileColours.secondaryText,
              ),
            )
          );
        }

        final posts = snapshot.data!.docs;

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 15,
            mainAxisSpacing: 15,
          ),
          itemCount: posts.length,
          itemBuilder: (context, index) {
            final post = posts[index].data() as Map<String, dynamic>;
            final mediaUrl = post['mediaUrl'] ?? '';

            return mediaUrl.isNotEmpty
              // Show the post image, and navigate to Car Details when tapped
              ? GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CarDetailsPage(postData: posts[index]),
                    )
                  );
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    mediaUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.broken_image),
                  ),
                ),
              )
              : const SizedBox();
          },
        );
      },
    );
  }
}
# Mobile Application Development Project for COMP3130

# 🚗 Car Spotter
**Tagline**: _Snap it, Spot it, Share it_

## What is Car Spotter?
**Car Spotter** is a mobile app designed for car enthusiasts to discover, document, and share sightings of unique, rare, or interesting cars they come across in everyday life. The app allows users to take a photo, add relevant car details (make, model, year, etc.), and post it to a location-based feed that others can explore and interact with.

The app builds a community-driven gallery of interesting cars seen on the streets. Users can browse recent sightings near them, like and comment on posts, and build a personal collection of their own car-spotting adventures.

## Target Audience
Car Spotter is tailored for:
- **Car Enthusiasts & Spotters** (e.g., students, hobbyists)
- **Photographers** interested in automotive photography
- **Collectors** searching for rare car sightings

These users value a dedicated space to document car sightings, explore local car culture, and build a visual collection of automotive adventure.

## Main Functionality
**User Authentication**
- Firebase email/password sign-up and login
- Google Sign-In for convenience

**Upload Car Sightings**
- Capture a photo using the camera or select from the gallery
- Add car details (make, model, year, description)
- Auto-tag posts with the user's current location
  
**Explore Feed**
- View a chronological feed of uploaded car sightings
- Tap posts for detailed car information

**Car Details Page**
- Full post view with image, details, and user information

**User Profile**
- Display profile image, bio, and personal car posts in a grid

**Firebase Backend**
- Cloud Firestore: stores user data and posts
- Firebase Storage: stores car images

**Location Integration**
- Uses Geolocator and Geocoding to capture location on uploads

**Basic UI/UX**
- Consistent design with clean navigation and theming

## Design Changes from Deliverable 1
While the core features and flow closely match the initial design proposal, the following changes were made based on implementation feasibility, feedback, and user experience improvments:
- Picture Ratio: Slightly adjusted aspect ratio for better screen fit
- Upload Icon: Slightly different Icon (Flutter default), same position
- Post Button: Moved to AppBar as an action text button for consistency and better UI/UX
- Profile Edit Button: Added an edit icon in the profile page with functional edit flow
- Profile Edit Functionality: Users can update name, bio, and profile picture
- Register Page Fields: Full name input removed for simplicity; users add name in profile ('User' will be given as their default name)
- Comments, Likes, Search, Map: Not implemented in MVP


## Devices Used for Development and Testing
- Android Emulator: Main testing environment (Pixel 6 Emulator)
- MacBook Pro(M3):: Development machine (Visual Studio Code, Android studio for emulator)

## Extra Information

- As additional work beyond the MVP requirements, I implemented a Profile Edit Page.
  - This feature allows users to update their name, bio, and profile picture directly within the app.

## Device Incompatibilities

- The Car Spotter App only works on android.
- Not compatible with iOS or any other device.

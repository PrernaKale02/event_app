# Event App — Flutter + Firebase

A complete event management application built using **Flutter** and **Firebase**. This app allows users to discover events, register for them, manage their profile, and provides admin capabilities for event creation.

## ✨ Features

### 🔍 Event Discovery
- **Search & Filter**: Search events by title or location. Filter events by categories like **Tech, Music, Sports, Art, and General**.
- **Detailed View**: View comprehensive event details including date, time, location, and description.
- **Location Support**: Open event locations directly in Google Maps.

### 👤 User Interaction
- **Authentication**: Secure Login and Signup powered by **Firebase Authentication**.
- **RSVP/Registration**: Simple one-tap registration for events.
- **Bookmarks**: Save interesting events to your personal bookmark list.
- **Social Sharing**: Share event details with friends via other apps.

### ⚙️ Account Management
- **Profile**: View your details, Admin/User role status.
- **My Registrations**: Track all events you have signed up for.
- **Saved Events**: Access your bookmarked events.
- **Customization**: Toggle between **Light and Dark themes**.
- **Edit Profile**: Update your display name.

### 🛡️ Admin Panel
- **Role-based Access**: Admins have exclusive access to manage events.
- **Event Management**: Create new events with titles, descriptions, dates, locations, and categories.
- **Delete Events**: Remove cancelled or old events.

## 🛠️ Tech Stack

- **Frontend**: Flutter (Dart)
- **Backend**: Firebase (Authentication, Cloud Firestore)
- **State Management**: Provider
- **Plugins Details**:
    - `firebase_auth` & `cloud_firestore`: Backend services.
    - `provider`: State management.
    - `shared_preferences`: Local storage for persistence.
    - `url_launcher`: Opening maps.
    - `share_plus`: Content sharing.
    - `intl`: Date formatting.

## 🚀 Getting Started

### Prerequisites
- Flutter SDK installed
- Firebase project setup with `google-services.json` (Android) / `GoogleService-Info.plist` (iOS) configured.

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/PrernaKale02/event_app
   cd event_app
   ```

2. **Install Dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the App**
   ```bash
   flutter run
   ```

## 📸 Screen Overview

| Home Screen | Event Details | Profile |
|:-----------:|:-------------:|:-------:|
| *[Event List with Search & Chips]* | *[Event Info & Register Button]* | *[User Info, Dark Mode, Lists]* |

---

## 👩‍💻 Author

**Prerna Kale**
*   B.Tech Computer Engineering
*   Building AI-driven solutions for real-world problems.

---

## 🏷️ License
This project is for academic and demonstration purposes.

---
*Built with ❤️ using Flutter*

# 🌍 Wander Genie (Travel App)

**Wander Genie** is a modern Flutter application designed to make travel planning, itinerary generation, and expense tracking effortless. It features an **offline-first design** powered by SQLite (`sqflite`), backed by seamless cloud synchronization with **Firebase Authentication** and **Cloud Firestore**.

---

## 📁 Folder Structure & Hierarchy

Below is the project directory structure and a detailed explanation of each module and file:

```text
travel_app/
├── android/                   # Native Android configuration & gradle build files
│   ├── app/
│   │   ├── build.gradle.kts   # Android app-level build configuration
│   │   ├── google-services.json # Firebase Android setup configuration
│   │   └── src/               # Native Android manifest and application files
│   ├── build.gradle.kts       # Top-level Android Gradle build file
│   └── settings.gradle.kts    # Gradle settings configuration
├── ios/                       # Native iOS runner configuration & Xcode workspace
│   └── Runner/                # Swift source files, assets, and Info.plist
├── lib/                       # Main Flutter / Dart codebase
│   ├── main.dart              # Application entry point (Firebase initialization & MaterialApp)
│   ├── app_constants.dart     # Global constants (Theme colors, remote image URLs, assets)
│   ├── firebase_options.dart  # Firebase platform configuration options
│   │
│   ├── database/              # Local Storage Layer
│   │   └── db_helper.dart     # SQLite Database Helper using `sqflite` for offline storage
│   │
│   ├── models/                # Data Models
│   │   ├── user.dart          # User profile model
│   │   ├── trip.dart          # Trip model (destination, dates, budget, sync status)
│   │   ├── itinerary_item.dart# Itinerary activities and scheduling model
│   │   └── expense.dart       # Expense tracking and budgeting model
│   │
│   ├── screens/               # Application Screens / UI Pages
│   │   ├── wander_genie_screen.dart             # Welcome / Onboarding landing screen
│   │   ├── wander_genie_travel_planner_screen.dart # AI-powered travel planner screen
│   │   ├── login_screen.dart                    # User login & authentication screen
│   │   ├── signup_screen.dart                   # User registration screen
│   │   ├── plan_trip_destination_screen.dart    # Destination selection & trip customization
│   │   ├── generating_itinerary_screen.dart     # Generating itinerary screen
│   │   ├── my_trips_screen.dart                 # Overview list of saved & synced trips
│   │   ├── third_screen.dart                    # Trip details & daily schedule view
│   │   ├── expenses_screen.dart                 # Expense tracker & budget breakdown screen
│   │   └── profile_screen.dart                  # User profile management screen
│   │
│   ├── services/              # Services & Business Logic
│   │   ├── firestore_service.dart # Cloud Firestore API for remote CRUD operations
│   │   ├── sync_service.dart      # Offline-first sync engine (SQLite ↔ Firestore)
│   │   └── firestore_test.dart    # Test utility for verifying Firebase connection
│   │
│   └── widgets/               # Reusable UI Components
│       └── app_drawer.dart    # Navigation drawer menu
├── linux/                     # Native Linux build configuration
├── macos/                     # Native macOS build configuration
├── web/                       # Web deployment files
├── windows/                   # Native Windows build configuration
├── pubspec.yaml               # Flutter package dependencies and project configuration
├── analysis_options.yaml      # Dart linting and code style rules
└── README.md                  # Project documentation
```

---

## ✨ Features

- 🗺️ **Smart Trip Planner**: Plan trip destinations, dates, preferences, and budgets.
- 📅 **Interactive Itineraries**: View and manage daily activities for each trip.
- 💰 **Expense Tracking**: Log expenses, categorize spending, and monitor remaining trip budgets.
- 🔄 **Offline-First Storage**: Local database implementation via SQLite (`sqflite`) ensuring the app functions completely offline.
- ☁️ **Cloud Synchronization**: Automatic background synchronization between local SQLite storage and Firebase Cloud Firestore when connected online.
- 🔐 **Authentication**: User account management with Firebase Auth.

---

## 🛠️ Prerequisites

Before running this project, ensure you have the following installed:

- **Flutter SDK**: `^3.12.2` or higher ([Installation Guide](https://docs.flutter.dev/get-started/install))
- **Dart SDK**: Included with Flutter
- **Android Studio** / **VS Code** with Flutter & Dart extensions
- An **Android Emulator**, **iOS Simulator**, or a connected physical device.
- **Java Development Kit (JDK 17+)** for Android builds.

---

## 🚀 How to Run the Project

### 1. Clone the Repository
```bash
git clone https://github.com/your-username/travel_app.git
cd travel_app
```

### 2. Install Dependencies
Get all Flutter packages specified in `pubspec.yaml`:
```bash
flutter pub get
```

### 3. Setup Firebase Configuration (Optional/Recommended)
If you are setting up your own Firebase backend:
1. Add your `google-services.json` inside the `android/app/` directory.
2. (Optional for iOS) Add `GoogleService-Info.plist` inside `ios/Runner/`.
3. Configure `lib/firebase_options.dart` using FlutterFire CLI:
   ```bash
   flutterfire configure
   ```

### 4. Run Static Analysis & Lints (Optional)
Ensure there are no compile-time linting errors:
```bash
flutter analyze
```

### 5. Run the Application
Launch the app on a connected target device or emulator:
```bash
flutter run
```

---

## 📦 Key Dependencies

| Package | Purpose |
| :--- | :--- |
| `sqflite` | Local SQLite database for offline storage |
| `cloud_firestore` | Remote cloud NoSQL database for synchronization |
| `firebase_auth` | User identity and authentication management |
| `firebase_core` | Firebase SDK initialization |
| `google_fonts` | Custom typography (`DM Sans`) |
| `path` | Cross-platform file path manipulation |

---

## 🏗️ Build Commands

- **Android APK**:
  ```bash
  flutter build apk --release
  ```
- **Android App Bundle**:
  ```bash
  flutter build appbundle --release
  ```
- **iOS App**:
  ```bash
  flutter build ios --release
  ```

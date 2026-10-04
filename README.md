<div align="center">

# 🏛️ Prāngan
### *Your Campus, Connected.*

**A Cross-Platform Community Management Platform for Residential Societies & Campus Communities**

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.12%2B-0175C2?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev)
[![Firebase](https://img.shields.io/badge/Firebase-Enabled-FFCA28?style=for-the-badge&logo=firebase&logoColor=black)](https://firebase.google.com)
[![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS%20%7C%20Web-green?style=for-the-badge)](https://flutter.dev/multi-platform)
[![License](https://img.shields.io/badge/License-MIT-purple?style=for-the-badge)](LICENSE)

<br/>

> **Prāngan** (प्रांगण) — Sanskrit for *"courtyard"* — is a real-time, community-first mobile app that digitizes the communication, governance, and social fabric of residential societies and campus communities.

</div>

---

## 📱 App Screenshots

### Welcome · Dashboard · Community Forum

![Welcome, Dashboard and Community Forum screens](assets/images/screens_1.jpg)

### Live Polls · Events · Admin Panel

![Polls, Events and Admin Approval screens](assets/images/screens_2.jpg)

---

## 📑 Table of Contents

- [✨ Overview](#-overview)
- [📸 App Screens & Features](#-app-screens--features)
- [🏗️ Architecture](#️-architecture)
- [🗂️ Project Structure](#️-project-structure)
- [📦 Tech Stack & Dependencies](#-tech-stack--dependencies)
- [🔥 Firebase & Data Modeling](#-firebase--data-modeling)
- [🔐 Authentication & User Roles](#-authentication--user-roles)
- [⚙️ Setup & Installation](#️-setup--installation)
- [🚀 Running the App](#-running-the-app)
- [🏗️ Build & Deployment](#️-build--deployment)
- [🎨 Design System](#-design-system)
- [🤝 Contributing](#-contributing)

---

## ✨ Overview

**Prāngan** is a full-stack Flutter application built for **Kharghar Society** (extensible to any campus/residential community). It replaces fragmented WhatsApp groups, paper notice boards, and manual processes with a structured, role-based digital community platform.

### 🎯 Core Problems It Solves

| Problem | Prāngan's Solution |
|---|---|
| Scattered announcements across WhatsApp groups | Centralized **Notice Board** with real-time sync |
| Manual attendance & event tracking | Digital **Events Calendar** with RSVP |
| No formal grievance system | Community **Discussion Forum** with likes & comments |
| Slow emergency communication | One-tap **SOS Alert Broadcast** to all members |
| No democratic decision-making tool | Live **Community Polls** with animated vote counts |
| Manual admin approval of new residents | Role-based **Admin Approval Workflow** |

---

## 📸 App Screens & Features

### 🔐 Authentication Flow

| Screen | Description |
|---|---|
| **Splash Screen** | Custom branded crest with smooth fade animation. Checks `FirebaseAuth` session state. |
| **Welcome Screen** | App branding with Google Sign-In and Email/Password options. |
| **Sign Up Screen** | New user registration with full form validation. |
| **OTP Verification** | Phone/email verification for extra security. |
| **Join Society Screen** | New users select their campus/society from a searchable list. |
| **Pending Approval Screen** | Real-time waiting screen. Unlocks automatically when admin approves via Firestore stream. |

### 🏠 Core Features (Post Login)

#### 🖥️ Dashboard
- Society name, banner, and quick stats at the top.
- **Emergency Alert Banner** — flashes in high-contrast red when an SOS is active.
- **Quick Action Buttons** — shortcuts to create posts, view events, cast votes.
- Upcoming events strip and live poll previews.

#### 💬 Discussions (Community Forum)
- Residents can post issues, announcements, or photos.
- Full **like** and **comment** system with real-time counts.
- Real-time updates via Firestore `.snapshots()` streams.
- Create posts with optional image attachments via `image_picker`.
- Share posts via native OS share sheet using `share_plus`.

#### 📅 Events
- Society admins create events with title, description, date, and venue.
- Residents can view upcoming and past events.
- Beautiful card-based event listing with `intl`-formatted dates.

#### 🗳️ Live Polls
- Admin creates polls for community decisions (e.g., *"Should we add CCTV?"*).
- Animated vote percentage bars update live as votes come in.
- Each resident can vote once; real-time vote tallying via Firestore.

#### 🚨 Alerts (SOS / Emergency Broadcast)
- **High-priority emergency broadcast** system for security guards & management.
- Instantly visible to all community members on the Dashboard.
- Alert history log with timestamps and severity levels (`info`, `warning`, `sos`).

#### 👤 Admin Panel
- **Resident Approval Workflow:** View all `pending` members; approve or reject with one tap.
- Role-based access control (RBAC): only `admin` role users see the panel.
- Admins can create events, polls, and broadcast emergency alerts.

---

## 🏗️ Architecture

Prāngan follows a clean **MVVM (Model-View-ViewModel)** architecture with Flutter's `Provider` package for reactive state management.

```
┌──────────────────────────────────────────────────────────────┐
│                         UI LAYER                             │
│          lib/screens/  +  lib/widgets/                       │
│   (StatelessWidget / StatefulWidget — Pure UI rendering)     │
└─────────────────────────┬────────────────────────────────────┘
                          │ context.watch<T>() / Consumer<T>
┌─────────────────────────▼────────────────────────────────────┐
│                    VIEWMODEL LAYER                           │
│                    lib/providers/                            │
│   (ChangeNotifier — Business Logic + notifyListeners())      │
│   AuthProvider | SocietyProvider | PostProvider              │
│   EventProvider | PollProvider | AlertProvider               │
└─────────────────────────┬────────────────────────────────────┘
                          │ async calls
┌─────────────────────────▼────────────────────────────────────┐
│                     SERVICE LAYER                            │
│                    lib/services/                             │
│   (Raw Firebase API calls — No UI dependencies)              │
│   AuthService | SocietyService | PostService                 │
│   EventService | PollService | AlertService | StorageService │
└─────────────────────────┬────────────────────────────────────┘
                          │ Firestore SDK / Firebase Auth SDK
┌─────────────────────────▼────────────────────────────────────┐
│                    DATA / MODEL LAYER                        │
│                    lib/models/                               │
│   UserModel | SocietyModel | PostModel                       │
│   EventModel | PollModel | AlertModel                        │
│                  + Firebase Backend                          │
│            Cloud Firestore | Firebase Auth                   │
│         Firebase Storage | Google Sign-In                    │
└──────────────────────────────────────────────────────────────┘
```

### Key Architectural Decisions

- **`MultiProvider` at Root:** All 6 providers are injected at the app root in `main.dart`, making state globally accessible without prop-drilling.
- **Firestore Real-Time Streams:** The app uses `.snapshots()` (Dart `Stream`) for live-updating data (posts, polls, alerts) — not one-time `.get()` calls.
- **Service ↔ Provider Separation:** Services only know about Firebase. Providers only know about Services and UI state. Screens only know about Providers.

---

## 🗂️ Project Structure

```
prangan/
├── lib/
│   ├── main.dart                    # App entry point, MultiProvider setup
│   ├── firebase_options.dart        # Auto-generated Firebase platform config
│   │
│   ├── models/                      # Pure data schemas (Dart classes)
│   │   ├── user_model.dart
│   │   ├── society_model.dart
│   │   ├── post_model.dart
│   │   ├── event_model.dart
│   │   ├── poll_model.dart
│   │   └── alert_model.dart
│   │
│   ├── services/                    # Firebase API abstraction layer
│   │   ├── auth_service.dart
│   │   ├── society_service.dart
│   │   ├── post_service.dart
│   │   ├── event_service.dart
│   │   ├── poll_service.dart
│   │   ├── alert_service.dart
│   │   ├── storage_service.dart
│   │   └── seed_service.dart        # Dev-only data seeding utility
│   │
│   ├── providers/                   # State management (ChangeNotifier)
│   │   ├── auth_provider.dart
│   │   ├── society_provider.dart
│   │   ├── post_provider.dart
│   │   ├── event_provider.dart
│   │   ├── poll_provider.dart
│   │   └── alert_provider.dart
│   │
│   ├── screens/
│   │   ├── splash_screen.dart
│   │   ├── auth/
│   │   │   ├── welcome_screen.dart
│   │   │   ├── signup_screen.dart
│   │   │   └── otp_verification_screen.dart
│   │   ├── society/
│   │   ├── dashboard/
│   │   ├── discussions/
│   │   │   ├── discussion_list_screen.dart
│   │   │   ├── new_post_screen.dart
│   │   │   └── post_detail_screen.dart
│   │   ├── events/
│   │   ├── polls/
│   │   ├── alerts/
│   │   └── admin/
│   │       └── admin_approvals_screen.dart
│   │
│   ├── theme/
│   │   └── app_theme.dart           # Centralized Material 3 theme config
│   ├── widgets/
│   └── utils/
│
├── assets/
│   └── images/                      # App screenshot assets
├── android/
├── ios/
├── web/
├── firestore.rules
├── firebase.json
└── pubspec.yaml
```

---

## 📦 Tech Stack & Dependencies

### Core Framework

| | Technology | Version |
|---|---|---|
| 🐦 | **Flutter SDK** | `^3.x` |
| 🎯 | **Dart SDK** | `^3.12.2` |
| 🎨 | **Material Design** | Material 3 (`useMaterial3: true`) |

### Firebase Backend

| Package | Version | Purpose |
|---|---|---|
| `firebase_core` | `^4.15.0` | Firebase SDK initialization for all platforms |
| `firebase_auth` | `^6.7.0` | User authentication, session persistence, token management |
| `cloud_firestore` | `^6.10.0` | NoSQL real-time database with offline caching |
| `firebase_storage` | `^13.6.0` | Cloud storage for images & media files |
| `google_sign_in` | `^7.2.0` | Native Google OAuth 2.0 sign-in flow |

### State Management & UI

| Package | Version | Purpose |
|---|---|---|
| `provider` | `^6.1.5` | Reactive state management (InheritedWidget wrapper) |
| `google_fonts` | `^8.2.1` | Outfit font family for premium typography |
| `image_picker` | `^1.2.3` | Camera & gallery access for post images |

### Utilities

| Package | Version | Purpose |
|---|---|---|
| `intl` | `^0.20.3` | Date/time formatting (`DateFormat.yMMMd()`) |
| `shared_preferences` | `^2.5.5` | Local key-value storage for offline persistence |
| `share_plus` | `^13.3.0` | Native OS share sheet for notices & posts |
| `cupertino_icons` | `^1.0.8` | iOS-style icon set |

---

## 🔥 Firebase & Data Modeling

### Firestore Collections Schema

```
Firestore (NoSQL)
│
├── users/{uid}
│   ├── uid, name, email, photoUrl?
│   ├── role: "resident" | "admin"
│   ├── status: "pending" | "approved" | "rejected"
│   └── societyId?
│
├── societies/{societyId}
│   ├── name, description, location
│   ├── adminUid, memberCount
│
├── posts/{postId}
│   ├── authorId, authorName, societyId
│   ├── content, imageUrl?
│   ├── likes: List<String>     // UIDs who liked
│   ├── commentCount, createdAt
│
├── events/{eventId}
│   ├── title, description, venue
│   ├── date: Timestamp, societyId
│
├── polls/{pollId}
│   ├── question, options: List<String>
│   ├── votes: Map<uid, optionIndex>
│   └── societyId, createdAt
│
└── alerts/{alertId}
    ├── message, severity: "info"|"warning"|"sos"
    ├── societyId, createdBy, createdAt
```

### Model Serialization Pattern

```dart
// Firestore → Dart Object
factory UserModel.fromFirestore(DocumentSnapshot doc) {
  final data = doc.data() as Map<String, dynamic>;
  return UserModel(
    uid: data['uid'] ?? '',
    name: data['name'] ?? 'Anonymous',
    role: data['role'] ?? 'resident',
    status: data['status'] ?? 'pending',
    photoUrl: data['photoUrl'],   // Nullable
    societyId: data['societyId'], // Nullable
  );
}

// Dart Object → Firestore
Map<String, dynamic> toMap() => {
  'uid': uid, 'name': name,
  'role': role, 'status': status,
  'photoUrl': photoUrl, 'societyId': societyId,
};
```

---

## 🔐 Authentication & User Roles

### Authentication Flow

```
App Launch → SplashScreen → FirebaseAuth.instance.currentUser?
    │
    ├── NULL ──► WelcomeScreen ──► Google/Email Auth
    │                                     │
    │                          Check Firestore /users/{uid}
    │                          ┌──────────┴──────────┐
    │                     New User?              Existing User?
    │                          │                      │
    │              Create doc (pending)        ┌──────┴──────┐
    │              JoinSocietyScreen      approved?       pending?
    │              PendingApproval         │               │
    │              (auto-unlocks)     Dashboard    PendingApproval
    │
    └── EXISTS ──► Check status & route
```

### User Roles

| Role | Status | Access |
|---|---|---|
| `resident` | `pending` | Pending Approval screen only |
| `resident` | `approved` | Dashboard, Discussions, Events, Polls, Alerts |
| `admin` | `approved` | All + Admin Panel, Create Events/Polls/Alerts, Approve Members |

---

## ⚙️ Setup & Installation

### Prerequisites

```
✅ Flutter SDK  >= 3.x       →  https://docs.flutter.dev/get-started/install
✅ Dart SDK     >= 3.12.2    →  bundled with Flutter
✅ Android Studio / VS Code  →  with Flutter & Dart extensions
✅ Java 17                   →  required for Android Gradle 8.x
✅ Firebase Project          →  https://console.firebase.google.com
```

### Step 1 — Clone the Repository

```bash
git clone https://github.com/Sahilp2407/PRANGAN-.git
cd PRANGAN-
```

### Step 2 — Firebase Project Setup

1. Go to [Firebase Console](https://console.firebase.google.com/) and create a project named **Prangan**.
2. Enable these services:
   - **Authentication** → Google Sign-In + Email/Password
   - **Cloud Firestore** → Create database (test mode for dev)
   - **Firebase Storage** → Create default bucket
3. Register your apps (Android package: `com.prangan.app`, iOS bundle: `com.prangan.app`)
4. Download config files:
   - `google-services.json` → `android/app/google-services.json`
   - `GoogleService-Info.plist` → `ios/Runner/GoogleService-Info.plist`

### Step 3 — Add SHA-1 Fingerprint (Android Google Sign-In)

```bash
keytool -list -v \
  -keystore ~/.android/debug.keystore \
  -alias androiddebugkey \
  -storepass android -keypass android
```

Copy the **SHA-1** → Firebase Console → Project Settings → Android App → **Add Fingerprint** → re-download `google-services.json`.

### Step 4 — Install Dependencies

```bash
flutter pub get
```

### Step 5 — iOS only: Install CocoaPods

```bash
cd ios && pod install && cd ..
```

---

## 🚀 Running the App

```bash
flutter devices                        # List connected devices
flutter run                            # Run on default device
flutter run -d "iPhone 15 Pro"         # Run on iOS Simulator
flutter run -d chrome                  # Run on Web
```

---

## 🏗️ Build & Deployment

```bash
# Debug APK
flutter build apk --debug

# Release APK (for distribution)
flutter build apk --release

# App Bundle (Google Play Store)
flutter build appbundle --release

# iOS Release
flutter build ios --release
```

| Feature | Debug Build | Release Build |
|---|---|---|
| **Compilation** | JIT (Just-In-Time) | AOT (Ahead-Of-Time) |
| **Performance** | Slower, debug symbols | Optimized, 60/120 FPS |
| **File Size** | ~40–60 MB | ~15–25 MB |
| **Code Security** | Readable | R8/ProGuard obfuscated |
| **Signing** | `debug.keystore` | Custom `key.jks` required |

### Android Permissions

| Permission | Purpose |
|---|---|
| `INTERNET` | Firebase API & Firestore sync |
| `CAMERA` | Capture photos for posts |
| `READ_EXTERNAL_STORAGE` | Pick images from gallery |

---

## 🎨 Design System

Centralized Material 3 theme in [`lib/theme/app_theme.dart`](lib/theme/app_theme.dart).

### Color Palette

| Token | Hex | Usage |
|---|---|---|
| **Heritage Crimson** | `#86243A` | Primary brand color, AppBar |
| **Primary Dark** | `#5B1625` | Pressed states, dark surfaces |
| **Warm Gold** | `#DAB15C` | Accent, badges, highlights |
| **Neutral Cream** | `#FAF7F2` | Scaffold background |
| **Pure White** | `#FFFFFF` | Card & input surfaces |
| **Emergency Red** | `#D32F2F` | SOS alert banners |

### Typography

- **Font:** [Outfit](https://fonts.google.com/specimen/Outfit) via `google_fonts`
- All `TextTheme` styles globally configured — no ad-hoc inline styles

---

## 🤝 Contributing

1. Fork the repository
2. Create your branch: `git checkout -b feature/your-feature`
3. Commit: `git commit -m "feat: add your feature"`
4. Push: `git push origin feature/your-feature`
5. Open a Pull Request

```bash
flutter analyze   # Check for issues
dart format .     # Auto-format code
flutter test      # Run tests
```

---

## 📝 License

This project is licensed under the **MIT License**. See [LICENSE](LICENSE) for details.

---

<div align="center">

**Built with ❤️ using Flutter & Firebase**

*Prāngan — Bringing Communities Together, One Screen at a Time.*

</div>
